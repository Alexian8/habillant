# Habit Plan — Périmètre du MVP

> Document `13`. Se lit avec [`00-fondations.md`](00-fondations.md), qui reste
> la référence canonique. La feuille de route associée est dans
> [`14-feuille-de-route.md`](14-feuille-de-route.md).

Le MVP répond à une seule question : *« un propriétaire peut-il gérer un
chantier réel de bout en bout — du premier devis à la dernière facture —
sans quitter l'application ? »* Tout ce qui ne sert pas cette réponse est
reporté, explicitement, avec sa justification.

---

## 1. Inclus dans le MVP

### 1.1 Comptes et authentification
- **Sign in with Apple** et création de compte **e-mail / mot de passe**
  (hachage Argon2id côté serveur).
- Jetons JWT courts (15 min) + refresh token rotatif ; registre d'appareils
  avec révocation depuis les réglages.
- Suppression de compte conforme App Store (purge différée 30 jours).

### 1.2 Logements, étages, pièces
- Saisie **manuelle** : logement (nom, type, adresse, surface, année),
  étages nommés, pièces avec icône et surface optionnelle.
- Multi-logements (limité à 1 en offre gratuite).
- Aucun scan, aucun plan dessiné : la structure sert d'axe de classement
  pour projets, dépenses et documents.

### 1.3 Projets et tâches
- Projets avec les **12 statuts canoniques** (`idea` → `cancelled`,
  ordre de `00-fondations.md` §5), priorité, budget prévu, dates,
  avancement, pièces liées.
- Tâches simples par projet : titre, échéance, fait / à faire.

### 1.4 Budget et dépenses
- Budget **global du logement** (somme des budgets projets non annulés)
  et **budget par projet**, avec reste et dépassement signalé.
- Dépenses avec **HT / TVA / TTC** systématiques (centimes entiers,
  `vatRateBps` : 2000, 1000, 550), catégorie canonique, rattachement
  facultatif à un projet, une pièce, un artisan.
- Graphiques Swift Charts : répartition par catégorie, courbe cumulée.

### 1.5 Devis
- Import **PDF ou photo** (le fichier est stocké tel quel dans le
  coffre-fort) + **saisie manuelle** des montants et métadonnées.
- Statuts canoniques : `received`, `pending`, `accepted`, `declined`,
  `expired` ; l'acceptation propose de basculer le projet en
  `quoteAccepted`.
- Comparaison **manuelle** uniquement : liste triable des devis d'un
  projet (montants côte à côte, pas d'analyse de postes).

### 1.6 Factures et échéances
- Factures avec statuts canoniques (`toPay` → `disputed`), date
  d'échéance, paiements partiels, lien devis → facture.
- Rappels locaux d'échéance (notification à J-7 et J-1) ; le moteur de
  rappels serveur complet arrive en V2.

### 1.7 Coffre-fort documentaire
- Import depuis Fichiers, l'appareil photo ou le partage système.
- **Catégories** (les `DocumentKind` canoniques), **étiquettes libres**,
  **favoris**, marquage « sensible », **recherche sur métadonnées**
  (nom, catégorie, étiquettes, artisan, projet) — la recherche plein
  texte dans le contenu arrive avec l'OCR en V2.
- Corbeille 30 jours, aperçu PDF/image natif, liaison document ↔ projet /
  dépense / devis / facture (`DocumentLink`).

### 1.8 Synchronisation offline-first (complète dès le MVP)
- SQLite/GRDB local source de vérité, journal `pending_changes`, push par
  lots, pull incrémental par curseur, LWW champ par champ, tombstones,
  copies de conflit pour les fichiers, URL présignées pour les binaires.
- États affichés partout : synchronisé · en cours · hors ligne · erreur ·
  fichier en attente.
- C'est le chantier le plus lourd du MVP ; il n'est **pas** simplifiable
  après coup, donc il entre entier (voir `16-complexite.md`).

### 1.9 Plateformes
- **iPhone, iPad, Mac** dès la V1 : cible SwiftUI multiplateforme unique,
  `TabView` en compact, `NavigationSplitView` sur iPad et Mac.

### 1.10 Monétisation
- **StoreKit 2** : Premium mensuel 4,99 €, annuel 39,99 €, Famille
  59,99 €/an, essai 14 jours (chiffres canoniques, indicatifs).
- Offre **gratuite avec limites** : 1 logement, 3 projets actifs, 1 Go.
- **Publicité discrète** en gratuit, avec les exclusions canoniques
  (jamais dans le coffre-fort, sur une facture, sur un écran financier,
  pendant une action critique).
- Après expiration : lecture et export garantis à vie.

### 1.11 Exports
- **PDF** : synthèse d'un projet (budget, dépenses, documents liés).
- **CSV** : dépenses et factures (compatible tableur).
- **ZIP** : archive complète du coffre-fort d'un logement.

## 2. Exclus du MVP (avec justification)

| Fonction | Cible | Justification |
|---|---|---|
| **OCR automatique** des devis/factures | V2 | La valeur exige un écran de **validation humaine** soigné (garde-fou canonique) ; le lancer sans lui produirait des données fausses. L'import du fichier brut, lui, est dans le MVP. |
| **Comparaison intelligente de devis** | V2 | Dépend de l'extraction de postes par OCR ; la comparaison manuelle côte à côte du MVP couvre le besoin immédiat. |
| **Collaboration multi-utilisateurs** (rôles, invitations) | V2 | Multiplie la complexité de sync et de droits ; le MVP valide d'abord l'usage mono-utilisateur multi-appareils. |
| **Scan LiDAR / plans générés** | V3 | Risque technique majeur (précision RoomPlan). **Un prototype RoomPlan interne est lancé dès le MVP** — en spike parallèle, hors livrable — pour dérisquer la V3 (voir `15-risques-techniques.md`). |
| **Équipements, garanties, entretien** | V2 | Utile mais indépendant du parcours « chantier » ; aucun couplage bloquant. Le prototype UI en donne déjà un aperçu. |
| **IA (résumés, alertes intelligentes)** | V2 (limitée) | Exige consentement explicite et garde-fous (`00-fondations.md` §8) ; aucune fonction MVP n'en dépend. |
| **Connexion bancaire** | Au-delà de V3 | Canoniquement « jamais au MVP » ; lecture seule et opt-in le jour venu. |

## 3. Critères d'acceptation mesurables par module

| Module | Critères d'acceptation |
|---|---|
| Comptes | Création e-mail < 60 s ; Sign in with Apple en ≤ 2 écrans ; révocation d'appareil effective < 1 min ; 5 échecs → verrouillage temporaire. |
| Logements/pièces | Créer 1 logement + 3 étages + 8 pièces en < 3 min ; suppression d'une pièce ne supprime jamais les dépenses liées (détachement). |
| Projets | Les 12 statuts sont atteignables ; changement de statut visible sur un 2ᵉ appareil < 30 s en ligne ; 100 projets listés sans saccade (60 fps). |
| Budget/dépenses | HT + TVA = TTC vérifié à la saisie (blocage si incohérent) ; totaux du tableau de bord exacts au centime sur le jeu « Maison des Lilas » ; saisie d'une dépense en < 30 s. |
| Devis | Import d'un PDF de 10 Mo < 15 s en Wi-Fi ; devis accepté → proposition de mise à jour du statut projet ; devis expiré signalé le jour J. |
| Factures | Facture en retard badgée le lendemain de l'échéance ; paiement partiel recalcule le solde ; notification locale reçue à J-7 et J-1. |
| Coffre-fort | Recherche sur métadonnées < 500 ms pour 1 000 documents ; corbeille restaure à l'identique (étiquettes comprises) ; document sensible jamais dans les aperçus système. |
| Sync | Scénario avion : 20 modifications hors ligne réappliquées sans perte au retour du réseau ; conflit simultané sur 2 appareils → aucun écrasement silencieux ; suppression propagée par tombstone. |
| Abonnement | Achat, restauration et remboursement testés en sandbox ; limites gratuites appliquées côté serveur **et** client ; expiration → lecture/export toujours possibles. |
| Publicité | Aucune pub sur les écrans exclus (vérifié par test UI) ; latence d'affichage sans impact sur le scroll. |
| Exports | PDF projet fidèle aux totaux ; CSV réimportable dans Numbers/Excel sans perte ; ZIP contenant 100 % des fichiers non supprimés du coffre. |

## 4. Definition of done (s'applique à chaque module)

Un module n'est « terminé » que si, en une seule fois :

1. **Tests** — logique métier couverte par des tests XCTest dans
   `HabitPlanKit` (agrégats, statuts, arithmétique `Money`) ; scénarios de
   sync rejoués par simulation multi-appareils ; au moins un test UI du
   parcours nominal par plateforme.
2. **Accessibilité** — **Dynamic Type** jusqu'à la taille XXL sans
   troncature bloquante ; **VoiceOver** : chaque élément interactif a un
   libellé et les montants sont lus en toutes lettres ; cibles tactiles
   ≥ 44 pt.
3. **Mode sombre** — chaque écran validé en clair et en sombre avec la
   palette canonique (`hpSand`/`hpInk` adaptatifs), contrastes AA.
4. **Localisation** — tous les textes UI en **français**, centralisés
   (aucune chaîne en dur dans les vues), formats monétaires et de dates
   via les formatters localisés : la structure est prête pour l'i18n
   sans refactoring.
5. **Revue** — code relu, `#if os(...)` justifiés, aucun UIKit/AppKit
   direct, captures iPhone/iPad/Mac jointes à la PR.

## 5. Ce que le MVP doit prouver

- Un utilisateur gère un chantier réel (devis → travaux → factures →
  archivage) sans tableur ni boîte mail à côté.
- La sync offline-first tient sur 2+ appareils sans perte de données.
- La conversion gratuit → Premium est mesurable (objectif indicatif :
  ≥ 4 % à 90 jours) avant d'investir dans la V2.
