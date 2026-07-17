# Habit Plan — 10. Stratégie de stockage

> Document détaillé du volet « Stockage » résumé dans `00-fondations.md`
> §3 et §6. En cas de divergence, `00-fondations.md` prévaut.

---

## 1. Vue d'ensemble

Trois lieux de vie pour une donnée :

1. **PostgreSQL 16** (serveur, UE) — toutes les métadonnées et entités
   structurées : la vérité durable du compte.
2. **Stockage objet compatible S3 en UE** (Scaleway Object Storage, Paris)
   — les binaires : documents, photos, scans, plans, miniatures.
3. **Cache local chiffré** (appareil) — copie de travail pour l'usage
   hors ligne, jamais la seule copie une fois la sync effectuée.

## 2. Côté serveur

### 2.1 PostgreSQL — métadonnées

- Les 27 entités du modèle (`00-fondations.md` §5) vivent dans PostgreSQL ;
  un fichier binaire n'est **jamais** stocké en base, seulement sa fiche
  (`Document`) : nom, type MIME, taille, hash SHA-256, clé S3, versions.
- Colonnes de sync (`syncVersion`, `updatedAt`, `deletedAt`) sur chaque
  table, index sur `(propertyId, updatedAt)` pour le pull incrémental.
- Soft delete généralisé, corbeille 30 jours pour les documents, purge
  différée 30 jours (logement, compte) — conforme §4 des fondations.

### 2.2 S3 — arborescence de clés (canonique)

```
account/{userId}/property/{propertyId}/documents/{documentId}/v{n}
account/{userId}/property/{propertyId}/photos/{photoId}/v{n}
account/{userId}/property/{propertyId}/scans/{roomScanId}/v{n}
account/{userId}/property/{propertyId}/plans/{floorPlanId}/v{n}
account/{userId}/property/{propertyId}/thumbnails/{entityId}/{size}
```

- Préfixe par compte puis par logement : l'isolation des accès, les quotas
  et la purge d'un logement ou d'un compte se font par préfixe.
- `v{n}` : numéro de version applicatif, incrémenté à chaque remplacement
  du binaire (nouvelle version d'un devis, facture rescannée…).
- Les clés ne contiennent **aucune donnée personnelle** (pas de nom de
  fichier) : uniquement des UUID.

### 2.3 Miniatures et dérivés

- Générées de façon asynchrone par des workers consommant une **file
  Redis** (même infrastructure de files que l'OCR — `00-fondations.md` §3).
- Tailles produites : vignette de liste (256 px), aperçu (1024 px),
  première page rendue pour les PDF.
- Une miniature est un dérivé jetable : jamais versionnée, régénérable,
  exclue des quotas et des sauvegardes.

### 2.4 Versioning, chiffrement, cycle de vie

- **Versioning S3 activé** sur les buckets de documents : protège contre
  l'écrasement accidentel et alimente les copies de conflit
  (`09-synchronisation.md` §4.3) et l'historique des versions.
- **Chiffrement au repos SSE** systématique côté bucket, clés gérées par
  KMS (détail dans `11-securite-rgpd.md` §7).
- **Classes de stockage et cycle de vie** :

| Objet | 0–90 j | Après 90 j |
|---|---|---|
| Originaux (documents, photos, scans) | Classe standard (« chaud ») | Transition **standard-IA** (accès peu fréquent) |
| Versions non courantes | Standard-IA immédiat | Conservées tant que le document existe |
| Miniatures / dérivés | Standard | Jamais archivées (régénérables), purgées si orphelines |

  La transition est transparente pour l'utilisateur : mêmes URL présignées,
  latence de premier accès légèrement supérieure, coût de stockage réduit.

### 2.5 Quotas par offre

| Offre | Quota | Détail |
|---|---|---|
| Gratuit | **1 Go** | Somme des originaux (versions courantes) du compte |
| Premium / Famille | **50 Go** | Idem |

- **Compteur visible** dans Réglages → Stockage : jauge globale, répartition
  par logement et par type (documents, photos, scans), plus gros fichiers.
- Ne comptent pas dans le quota : miniatures, versions archivées par
  l'historique, métadonnées.
- Dépassement : les uploads de binaires sont refusés avec un message
  explicite (jamais de suppression automatique) ; la sync des métadonnées
  continue (`09-synchronisation.md` §7.4). Alertes à 80 % et 95 %.
- Rétrogradation Premium → Gratuit avec plus de 1 Go utilisé : tout reste
  **lisible et exportable** (garantie §6) ; seuls les nouveaux uploads
  sont bloqués jusqu'à passage sous le quota.

## 3. Côté client

### 3.1 Cache local chiffré

- Les binaires téléchargés vivent dans un cache dédié du conteneur de
  l'app, protégé par la **protection de fichiers** du système
  (Data Protection, classe « complète sauf premier déverrouillage » pour
  permettre les envois en tâche de fond) ; la base SQLite bénéficie de la
  même protection.
- Rien n'est stocké hors du sandbox ; l'exclusion de la sauvegarde iCloud
  est positionnée sur le cache (régénérable), pas sur la base locale.

### 3.2 Politique de rétention configurable

- Réglage **« Garder hors ligne »** à trois niveaux, par logement :
  *Favoris uniquement* (défaut), *Documents récents (90 j)*, *Tout*.
- Un plafond de cache est configurable (500 Mo / 2 Go / 5 Go / illimité) ;
  l'espace utilisé est affiché avec un bouton « Libérer de l'espace ».

### 3.3 Éviction LRU

- Les **aperçus et miniatures** sont évincés en LRU (les moins récemment
  consultés d'abord) quand le plafond de cache est atteint.
- Un original n'est évincé que s'il est **synchronisé au serveur** ; un
  fichier encore en file d'upload n'est jamais évincé.
- Les documents marqués **favoris** (ou couverts par la politique « garder
  hors ligne ») sont **exclus de l'éviction** : toujours disponibles hors
  ligne, badge `arrow.down.circle.fill` (cf. états UI de
  `09-synchronisation.md` §6).

## 4. Sauvegardes (serveur)

| Élément | Valeur |
|---|---|
| Outil | **pgBackRest** |
| Sauvegarde complète | Quotidienne |
| Journal | **WAL archivé en continu** (point-in-time recovery) |
| **RPO** | 15 minutes maximum |
| **RTO** | 4 heures maximum |
| Chiffrement | Sauvegardes chiffrées (clé distincte de la production, en coffre) |
| Rétention | 30 jours |
| Destination | Bucket S3 UE distinct, autre zone que la base primaire |
| Tests de restauration | **Trimestriels**, restauration complète sur environnement isolé, résultat consigné |

Les binaires S3 sont protégés par le versioning + la réplication du
fournisseur ; la corbeille applicative de 30 jours couvre les suppressions
utilisateur. Un test de restauration qui échoue est traité comme un
incident de priorité maximale.

## 5. Détection de doublons

- À l'import, le client calcule le **SHA-256** du fichier ; le hash est
  envoyé avec les métadonnées et indexé côté serveur.
- Hash identique déjà présent dans le même logement → l'app **propose** la
  fusion : « Ce document existe déjà (Facture Plomberie Costa, 12/03).
  Conserver les deux ou fusionner ? »
- La fusion n'est **jamais automatique** : deux imports identiques peuvent
  être légitimes (exemplaire signé vs non signé, pièces de deux dossiers).
  Sans réponse de l'utilisateur, les deux fichiers sont conservés.
- Le hash sert aussi de contrôle d'intégrité après upload et download.

## 6. Export complet et garantie de récupération

### 6.1 Export ZIP structuré

Depuis Réglages → « Exporter mes données », génération asynchrone d'une
archive ZIP par logement (ou compte entier) :

```
HabitPlan-Export-MaisonDesLilas-2026-07-17.zip
├── index.json                  # inventaire complet, machine-lisible
├── projets/
│   ├── renovation-cuisine/
│   │   ├── projet.json         # entité + tâches + dépenses + paiements
│   │   ├── projet.pdf          # synthèse lisible (budget, statut, journal)
│   │   └── documents/          # devis, factures — fichiers originaux
│   └── …
├── documents/                  # coffre-fort hors projet
├── artisans/                   # contacts + coordonnées (JSON + PDF)
├── equipements/                # équipements, garanties, entretiens
├── plans/                      # plans et scans exportés
└── photos/
```

- **Dossiers par module**, `index.json` racine (versions, hashes, liens
  entre entités), et **PDF lisibles** pour les données structurées : un
  notaire ou un artisan peut lire l'export sans l'application.
- L'export est aussi le support du droit à la portabilité
  (`11-securite-rgpd.md` §8).

### 6.2 Garantie canonique

> **L'utilisateur récupère TOUJOURS ses données.** Après expiration de
> l'abonnement, la **lecture et l'export complets restent gratuits à
> vie** (`00-fondations.md` §6). Aucun quota, aucune limite d'offre,
> aucun incident de paiement ne peut retirer l'accès en lecture ni le
> droit d'exporter. Les données ne sont supprimées que sur demande
> explicite (purge différée de 30 jours) ou suppression du compte.

---

*Voir aussi : `09-synchronisation.md` (upload différé, file d'attente) et
`11-securite-rgpd.md` (chiffrement, URL présignées, droits RGPD).*
