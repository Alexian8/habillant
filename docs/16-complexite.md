# Habit Plan — Complexité par fonction

> Document `16`. Se lit avec [`00-fondations.md`](00-fondations.md)
> (canonique), [`13-mvp.md`](13-mvp.md) (périmètre) et
> [`15-risques-techniques.md`](15-risques-techniques.md) (risques).
>
> Échelle : **S** (quelques jours) · **M** (1-2 semaines) · **L**
> (3-6 semaines) · **XL** (> 6 semaines ou plusieurs itérations).
> Risque : F / M / É, renvoie aux fiches R1-R10 du doc 15.

---

## 1. Tableau exhaustif

| Fonction | Client | Serveur | Risque | Version | Notes / dépendances |
|---|---|---|---|---|---|
| Comptes (Sign in with Apple, e-mail, appareils) | M | L | M (R5, R6) | MVP | Argon2id, JWT + refresh rotatif, révocation ; suppression de compte avec purge 30 j. |
| Logements / étages | S | S | F | MVP | CRUD simple ; axe de classement de tout le reste. |
| Pièces (saisie manuelle) | S | S | F | MVP | Icône SF Symbol, surface optionnelle ; détachement à la suppression. |
| Projets (12 statuts, priorité, avancement) | M | S | F | MVP | Machine à états simple ; liaisons pièces ; couplage devis accepté → statut. |
| Tâches de projet | S | S | F | MVP | Titre, échéance, fait/à faire ; pas de sous-tâches au MVP. |
| Budget (global + par projet) | M | S | M (R2) | MVP | Agrégats dérivés localement ; exactitude au centime, cohérence inter-appareils via sync. |
| Dépenses (HT/TVA/TTC, catégories) | M | S | F | MVP | Centimes entiers, `vatRateBps` ; contrôle HT+TVA=TTC à la saisie. |
| Devis (import PDF/photo + manuel, statuts) | M | M | M (R5) | MVP | Fichier stocké au coffre ; dépend de fichiers/presigned ; statuts canoniques. |
| Comparaison de devis (intelligente) | L | M | É (R3) | V2 | Dépend de l'OCR de postes ; alignement de lignes hétérogènes ; jamais de recommandation. |
| Factures (statuts, échéances, paiements partiels) | M | M | F | MVP | Lien devis → facture ; calcul de solde ; badge retard. |
| Coffre-fort (catégories, étiquettes, favoris, corbeille) | L | M | M (R7) | MVP | Pagination, miniatures, `DocumentLink` ; corbeille 30 j ; documents sensibles hors aperçus système. |
| OCR + écran de validation | L | L | É (R3) | V2 | Vision côté client, file Redis côté serveur ; validation humaine obligatoire champ par champ. |
| Recherche (métadonnées MVP, plein texte V2) | M | M | M (R7) | MVP / V2 | FTS5 local + index serveur ; le plein texte dans le contenu dépend de l'OCR. |
| Synchronisation offline-first | XL | XL | É (R2) | MVP | Moteur générique, journal, LWW champ par champ, tombstones, copies de conflit ; simulation multi-appareils en CI. |
| Fichiers / URL présignées | M | L | M (R4, R6) | MVP | Upload différé, presign 15 min, quotas, cycle de vie S3, miniatures. |
| Photos de chantier (avant/pendant/après) | M | S | F | V2 | `WorkStage` ; s'appuie sur le pipeline fichiers existant. |
| Plans manuels (croquis simples) | L | S | M | V3 | Précède l'édition de plans ; canevas 2D, cotes saisies. |
| Scan LiDAR (RoomPlan) | XL | M | É (R1) | V3 | Spike dès la phase 0 ; avertissement mesures ; matrice d'appareils supportés. |
| Édition de plans (2D cotés, 3D, étages, surfaces) | XL | M | É (R1) | V3 | Correction manuelle de première classe ; annotations spatiales ; exports USDZ + rapport de mesures. |
| Artisans (annuaire, SIRET, assurance, notes) | M | S | F | MVP | CRUD + rattachements ; alerte assurance décennale expirée en V2. |
| Équipements (inventaire) | M | S | F | V2 | Rattachés pièce/logement ; prototype UI déjà esquissé. |
| Garanties | S | S | F | V2 | Échéances ; alimente rappels ; `expiringWarranties(within:)`. |
| Entretien (tâches récurrentes) | M | M | F | V2 | Récurrence par mois ; génération des prochaines occurrences côté serveur. |
| Rappels / notifications (locales MVP, APNs V2) | M | L | M (R5) | MVP / V2 | MVP : notifications locales (échéances J-7/J-1) ; V2 : moteur serveur + APNs + `NotificationItem`. |
| Collaboration / rôles (5 rôles, invitations) | L | XL | É (R2) | V2 | Droits fins (rôle `professional` restreint) ; multiplie les écrivains de sync ; audit requis. |
| Abonnements / paywall (StoreKit 2, limites) | L | L | É (R5) | MVP | Vérification des transactions côté serveur ; limites appliquées des deux côtés ; lecture/export à vie après expiration. |
| Publicité (gratuit, discrète) | M | S | M (R5, R6) | MVP | Écrans exclus testés par UI ; régie filtrée RGPD ; jamais pendant une action critique. |
| Exports (PDF projet, CSV, ZIP coffre) | M | M | F | MVP | Génération asynchrone côté serveur pour le ZIP ; fidélité aux totaux. |
| IA résumés (opt-in) | M | L | M (R6) | V2 | Consentement explicite ; résume/compare/signale, ne choisit jamais ; pipeline en file Redis. |
| Tableau de bord | M | S | F | MVP | Agrégats du store local (budget, retards, devis en attente) ; Swift Charts. |
| Journal d'audit (`ActivityLog`) | S | M | F | MVP (socle) / V2 (UI) | Écriture dès le MVP (traçabilité) ; exposition UI utile surtout avec la collaboration. |

Lecture : la colonne « Version » suit strictement le périmètre du doc 13 ;
toute divergence est une erreur à corriger ici.

### Comment lire et maintenir ce tableau

- La complexité **client** couvre UI, logique locale et tests ; la
  complexité **serveur** couvre API, base, files de travail et
  infrastructure. Une fonction « S / S » peut rester coûteuse par ses
  liaisons (ex. : pièces → détachement des dépenses à la suppression).
- Les estimations supposent le socle de phase 0 en place (auth, sync,
  fichiers, CI) : une fonction M au-dessus d'un socle absent devient L.
- Toute nouvelle fonction entre d'abord ici (ligne + version cible) avant
  d'entrer dans la feuille de route ; le tableau est revu à chaque revue
  trimestrielle (doc 14 §11).

### Répartition de l'effort par version

| Version | Fonctions | Dominantes |
|---|---|---|
| MVP | 17 lignes (dont sync XL/XL) | Sync, coffre-fort, StoreKit — ~60 % de l'effort MVP sur 3 chantiers |
| V2 | 9 lignes | Collaboration (serveur XL) et OCR+validation (L/L) concentrent l'essentiel |
| V3 | 3 lignes | Presque tout côté client (scan XL, édition XL) — serveur marginal |

Le déséquilibre est voulu : le MVP porte les fondations transverses
(sync, fichiers, paiement), la V2 les fonctions à plusieurs écrivains et
à extraction de données, la V3 un bloc quasi autonome côté client.

## 2. Les 5 chantiers les plus lourds

### 2.1 Synchronisation offline-first (XL / XL — MVP)

Le plus gros chantier du projet, et le seul qui soit à la fois invisible
et vital. Il traverse les 27 entités, impose son schéma local (journal
`pending_changes`, versions par champ, tombstones) et son protocole
(push par lots, pull par curseur, presign différé pour les fichiers).
Son coût réel n'est pas l'écriture du chemin nominal mais celle des cas
dégradés : conflit simultané, suppression croisée, reprise après une
longue coupure, migration de schéma. D'où la stratégie : un moteur
**générique**, développé en phase 0 avant toute UI, validé par une
**simulation multi-appareils** rejouable en CI. Chaque semaine gagnée en
le bâclant se paierait dix fois en bêta sous forme de données perdues.

### 2.2 LiDAR et plans (XL client — V3)

Scan RoomPlan, plans 2D cotés, 3D, édition, étages multiples, annotations
spatiales, surfaces, exports USDZ : c'est presque une application dans
l'application, avec un risque matériel (R1) que le logiciel ne peut pas
entièrement compenser. Le pari est séquencé : **spike dès la phase 0**
pour mesurer la réalité du terrain, décision go/no-go documentée, puis en
V3 un pipeline où la **correction manuelle** est une fonctionnalité de
première classe et où l'avertissement sur les mesures est systématique.
L'édition de plans est le sous-chantier le plus coûteux : un éditeur
géométrique correct (contraintes, cotes, annulation) demande plusieurs
itérations avec le designer.

### 2.3 OCR + écran de validation (L / L — V2)

La difficulté n'est pas d'appeler Vision, mais de construire la boucle
complète : extraction, score de confiance par champ, **écran de
validation** où l'utilisateur confirme ou corrige chaque valeur, contrôle
arithmétique HT+TVA=TTC, et mesure des corrections pour améliorer
l'extraction itérativement (R3). L'écran de validation est un vrai
travail de design : il doit rendre la vérification plus rapide que la
saisie manuelle, sinon la fonction sera perçue comme une corvée. Le
garde-fou canonique est absolu : aucune donnée extraite n'est écrite sans
validation humaine.

### 2.4 Collaboration et rôles (L / XL — V2)

Cinq rôles dont un rôle `professional` aux droits volontairement
restreints (jamais les finances globales ni les documents sensibles) :
la matrice de permissions doit être appliquée **côté serveur** sur chaque
route et chaque objet, pas seulement masquée côté client. Surtout, la
collaboration multiplie les écrivains simultanés et transforme des
conflits de sync théoriques en cas quotidiens — c'est pourquoi elle
n'arrive qu'en V2, sur un moteur de sync éprouvé en production par le
MVP. S'y ajoutent invitations, départs, transferts de propriété et
journal d'audit exposé, indispensables dès que plusieurs personnes
touchent aux mêmes données.

### 2.5 StoreKit 2 et limites d'offre (L / L — MVP)

L'achat lui-même est bien outillé par StoreKit 2 ; la charge vient de
tout ce qui l'entoure : vérification des transactions côté serveur,
gestion des états (essai 14 jours, grâce, remboursement, partage
familial), et surtout l'application **cohérente des limites gratuites**
(1 logement, 3 projets actifs, 1 Go) des deux côtés — y compris hors
ligne, où le client doit trancher sans le serveur. La promesse canonique
« lecture et export garantis à vie après expiration » impose de
distinguer partout écriture (bloquable) et lecture/export (jamais
bloqués). C'est aussi la zone la plus scrutée par la review App Store
(R5) : elle mérite ses propres tests de bout en bout en sandbox.

---

## 3. Conséquences pour le plan

Trois enseignements guident la feuille de route (doc 14) :

1. Les deux XL du MVP (sync, et son pendant serveur) se traitent en
   **phase 0**, avant toute feature — ils conditionnent tout le reste.
2. Les XL de V2 et V3 (collaboration serveur, scan et édition de plans)
   se **dérisquent en avance** : moteur de sync éprouvé en production
   pour l'un, spike RoomPlan dès la phase 0 pour l'autre.
3. Aucune fonction É (risque élevé) ne se livre sans son garde-fou
   canonique : validation humaine pour l'OCR, avertissement mesures pour
   le scan, droits vérifiés côté serveur pour la collaboration.
