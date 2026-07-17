# Habit Plan — Feuille de route

> Document `14`. Se lit avec [`00-fondations.md`](00-fondations.md)
> (canonique) et [`13-mvp.md`](13-mvp.md) (périmètre détaillé du MVP).
> Les durées sont des estimations pour l'équipe décrite en §8.

---

## 1. Vue d'ensemble

```
Phase 0          MVP              Bêta         V1        V2            V3
fondations       (12-16 sem.      TestFlight   App       collaboration LiDAR
(6-8 sem.)       cumulées)        (4 sem.)     Store     OCR, devis…   plans
────────────────────────────────────────────────────────────────────────────▶
  └─ spike RoomPlan en parallèle (dérisquage V3, hors livrable)
```

## 2. Phase 0 — Fondations (semaines 1 à 6-8)

Objectif : tout ce qui est coûteux à refaire est posé en premier.

- **Socle serveur** : Vapor `/v1`, PostgreSQL 16, Redis, stockage S3 UE
  (Scaleway Paris), environnements dev/staging/prod, sauvegardes chiffrées.
- **Auth** : Sign in with Apple + e-mail/Argon2id, JWT + refresh rotatif,
  registre d'appareils.
- **Sync** : moteur générique offline-first (journal `pending_changes`,
  push/pull, LWW champ par champ, tombstones) testé par **simulation
  multi-appareils** avant toute UI.
- **CI/CD** : builds signés iOS/macOS, tests XCTest à chaque PR, lint,
  déploiement serveur automatisé.
- **Design system** : `HPColors`, `HPTypography`, `HPComponents`
  (contrat du prototype), bibliothèque de composants validée en clair,
  sombre et Dynamic Type.
- **Spike RoomPlan** (en parallèle, 1 dev en temps partagé) : prototype
  interne de scan, matrice appareils × types de pièces, mesure des écarts.
  Livrable : un rapport go/no-go pour la V3, pas une fonctionnalité.

Sortie de phase : un appareil crée un compte, écrit une entité, la
retrouve sur un second appareil ; pipeline CI vert.

## 3. MVP (semaines 7 à 12-16 cumulées)

Jalons intermédiaires **testables** (chacun démontrable sur appareil) :

| Jalon | Contenu | Semaine cumulée |
|---|---|---|
| M1 | Logements, étages, pièces ; navigation iPhone/iPad/Mac | 8 |
| M2 | Projets (12 statuts) + tâches, synchronisés | 10 |
| M3 | Dépenses HT/TVA/TTC, budgets, tableau de bord, graphiques | 12 |
| M4 | Devis (import PDF/photo + manuel) et factures + échéances | 13 |
| M5 | Coffre-fort complet (catégories, étiquettes, recherche, favoris, corbeille) | 14 |
| M6 | StoreKit 2, limites gratuites, pub discrète, exports PDF/CSV/ZIP | 15-16 |

Chaque jalon inclut sa definition of done (`13-mvp.md` §4) — pas de
« finition en fin de course ».

## 4. Bêta TestFlight (4 semaines)

- **200 à 500 testeurs** recrutés parmi des propriétaires en travaux
  (forums rénovation, groupes locaux), vagues de 50.
- **Boucle de retours** : formulaire intégré + TestFlight feedback, tri
  hebdomadaire, correctifs livrés chaque semaine.
- Critères de sortie : crash-free ≥ 99,5 % ; zéro perte de données de
  sync signalée ; parcours d'achat sandbox validé ; top 10 des irritants
  traités ou explicitement reportés.

## 5. Lancement V1 — App Store

- Fiche App Store en français, captures iPhone/iPad/Mac, préparation de
  la review (compte de démo, notes pour l'équipe de review sur la pub et
  l'abonnement).
- Lancement progressif (déploiement par paliers), monitoring serveur et
  quotas de stockage actifs, page de statut.
- Audit RGPD externe **avant** l'ouverture publique (voir
  `15-risques-techniques.md`).

## 6. V2 — Le foyer et l'intelligence assistée

- **Collaboration familiale** : invitations, rôles canoniques (`owner`,
  `editor`, `contributor`, `viewer`, `professional`), sync multi-comptes.
- **OCR + écran de validation** : extraction Vision des montants, dates,
  TVA, SIRET ; chaque champ extrait est **validé par l'utilisateur**
  avant enregistrement (garde-fou canonique).
- **Comparaison de devis** : alignement des postes, écarts signalés,
  jamais de recommandation d'artisan.
- **Équipements, garanties, entretien** : inventaire, échéances de
  garantie, tâches récurrentes, rappels serveur.
- **Photos avant/pendant/après** rattachées aux projets et aux pièces.
- **IA limitée avec consentement explicite** : résumés de projet et de
  documents — l'IA résume, compare, signale ; elle ne choisit jamais.

## 7. V3 — Les plans

- **Scan LiDAR complet** via RoomPlan (nourri par le spike de phase 0) :
  avertissement systématique « vérifier les mesures avant commande ».
- **Plans 2D cotés** générés + vue **3D** ; **édition de plans**
  (correction manuelle des murs et ouvertures) ; **étages multiples**
  assemblés.
- **Annotations spatiales** (attacher une note, une photo, un équipement
  à un point du plan) ; **calculs de surfaces** au sol et murales.
- **Exports** : USDZ et rapport de mesures PDF.

## 8. Au-delà de V3

- **Passkeys** (WebAuthn) en complément des méthodes existantes.
- **Web et Android** en s'appuyant sur la même API `/v1` (le serveur est
  agnostique du client depuis la phase 0).
- **Connexion bancaire lecture seule**, opt-in, pour le rapprochement des
  dépenses.
- **Dossier de vente enrichi** : export notarial complet du carnet
  (documents, historique des travaux, plans, équipements).

## 9. Timeline trimestrielle

Effectif suggéré : **2 dev Apple, 1 dev back, 1 designer, PM à temps
partiel**. T1 démarre au lancement du projet.

| Trimestre | Livrables principaux | Équipe concentrée sur |
|---|---|---|
| **T1** | Phase 0 complète (serveur, auth, sync, CI/CD, design system) ; spike RoomPlan lancé ; jalons M1-M2 | Back : socle + sync · Apple : design system, navigation, spike · Designer : système + parcours cœur |
| **T2** | Jalons M3-M6 ; MVP fonctionnel complet ; début de bêta TestFlight | Apple : modules MVP · Back : quotas, exports, monitoring · PM : recrutement testeurs |
| **T3** | Bêta (4 sem.), correctifs, audit RGPD, **lancement V1 App Store** ; démarrage V2 (collaboration, OCR) | Tous : qualité puis lancement · Back : rôles/invitations · Designer : écran de validation OCR |
| **T4** | V2 livrée par lots : collaboration, OCR + validation, équipements/garanties/entretien, photos de chantier | Apple : OCR client + inventaire · Back : moteur de rappels, partage |
| **T5** | Fin V2 (comparaison de devis, IA limitée opt-in) ; démarrage V3 sur les conclusions du spike | Apple : 1 dev dédié RoomPlan/plans · Back : pipeline IA + consentements |
| **T6** | V3 : scan LiDAR, plans 2D/3D, édition, annotations, surfaces, exports USDZ | Apple : plans · Designer : édition de plans · Back : stockage scans |

Hypothèses : pas de vacance de poste ; la review App Store peut coûter
1 à 2 semaines (marge incluse en T3) ; tout glissement se traite par
**réduction de périmètre**, jamais par report de la qualité (definition
of done non négociable).

## 10. Critères d'entrée et de sortie des versions

| Version | Entrée (on ne démarre que si…) | Sortie (on ne livre que si…) |
|---|---|---|
| MVP | Phase 0 validée : sync démontrée sur 2 appareils, CI verte | Les 6 jalons M1-M6 passent leurs critères d'acceptation (`13-mvp.md` §3) |
| V1 | Bêta : crash-free ≥ 99,5 %, zéro perte de sync, audit RGPD réalisé | Review App Store passée, monitoring et quotas actifs |
| V2 | V1 stable 4 semaines en production ; métriques de conversion lues | Collaboration éprouvée par bêta dédiée ; OCR mesuré (< 30 % de champs corrigés) |
| V3 | Rapport go/no-go du spike RoomPlan favorable, mis à jour sur appareils récents | Correction manuelle des plans complète ; avertissement mesures systématique |

## 11. Règles de pilotage

- Un jalon non démontrable sur appareil n'est pas un jalon.
- Le spike RoomPlan ne bloque jamais le MVP : il informe la V3 ; s'il
  conclut défavorablement, la V3 se replie sur les plans manuels et
  l'édition, sans scan.
- Tout glissement se traite par réduction de périmètre (jamais de la
  qualité) ; les exclusions du doc 13 §2 ne se rouvrent qu'en revue de
  trimestre.
- Chaque trimestre se termine par une revue périmètre/risques alignée sur
  `15-risques-techniques.md`, avec mise à jour de ce document.
