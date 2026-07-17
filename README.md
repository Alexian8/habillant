# Habit Plan

> **« Gérez votre maison, du plan à la facture. »**

**Habit Plan** est une application Apple multiplateforme (iPhone, iPad, Mac)
destinée aux particuliers propriétaires : elle centralise travaux et
rénovations, budgets et dépenses, devis et factures, documents administratifs,
photos de chantier, plans 2D/3D, artisans, équipements, garanties et entretien
du logement — avec synchronisation temps réel entre appareils et un
fonctionnement **offline-first**.

Nom technique du projet : `HabitPlan`.

## Contenu du dépôt

```
docs/          Conception complète du produit (français)
app/           Prototype SwiftUI navigable (iOS 17+ / iPadOS 17+ / macOS 14+)
```

### Documentation de conception

| # | Document | Sujet |
|---|---|---|
| 00 | [Fondations](docs/00-fondations.md) | **Document canonique** : décisions, conventions, palette, entités |
| 01 | [Concept](docs/01-concept.md) | Présentation du concept et expérience par appareil |
| 02 | [Utilisateurs cibles](docs/02-utilisateurs-cibles.md) | Personas et non-cibles |
| 03 | [Parcours utilisateurs](docs/03-parcours-utilisateurs.md) | Parcours détaillés de bout en bout |
| 04 | [Écrans](docs/04-ecrans.md) | Liste des écrans par module et par plateforme |
| 05 | [Identité visuelle](docs/05-identite-visuelle.md) | Logo, icône, palette, typographie, slogans |
| 06 | [Architecture technique](docs/06-architecture-technique.md) | Client, serveur, infrastructure, CI/CD |
| 07 | [Modèle de données](docs/07-modele-de-donnees.md) | 27 entités, relations, autorisations, suppressions |
| 08 | [Endpoints API](docs/08-api-endpoints.md) | API REST `/v1`, exemples de requêtes |
| 09 | [Synchronisation](docs/09-synchronisation.md) | Stratégie offline-first et résolution de conflits |
| 10 | [Stockage](docs/10-stockage.md) | Fichiers, quotas, sauvegardes, exports |
| 11 | [Sécurité & RGPD](docs/11-securite-rgpd.md) | Règles de sécurité et conformité |
| 12 | [Modèle économique](docs/12-modele-economique.md) | Gratuit, Premium, Famille, publicité |
| 13 | [MVP](docs/13-mvp.md) | Périmètre de la première version |
| 14 | [Feuille de route](docs/14-feuille-de-route.md) | Phases MVP → V2 → V3 |
| 15 | [Risques techniques](docs/15-risques-techniques.md) | Risques et mitigations |
| 16 | [Complexité](docs/16-complexite.md) | Complexité estimée de chaque fonction |
| 17 | [Structure Xcode](docs/17-structure-xcode.md) | Organisation du projet et conventions |

### Prototype SwiftUI

Le prototype (`app/`) est **navigable** sur les trois plateformes avec un jeu
de données d'exemple (« Maison des Lilas ») : tableau de bord, projets et
tâches, budget et dépenses, devis et factures, coffre-fort, pièces, artisans,
équipements/garanties/entretien, réglages et paywall. Les données sont en
mémoire — pas encore de persistance ni de réseau.

```bash
brew install xcodegen
cd app
xcodegen generate
open HabitPlan.xcodeproj
```

Prérequis : Xcode 15.4+, iOS 17 / macOS 14. Le domaine métier vit dans le
package local `app/Packages/HabitPlanKit` (testé via XCTest, sans dépendance
UI) ; l'interface dans `app/HabitPlan/`.

## Principes non négociables

- **Offline-first** : tout est consultable et modifiable hors ligne ; jamais
  d'écrasement silencieux à la synchronisation.
- **Les données appartiennent à l'utilisateur** : export complet gratuit,
  y compris après expiration de l'abonnement.
- **L'IA assiste, ne décide pas** : jamais de choix d'artisan automatique,
  toute extraction OCR est validée par l'utilisateur.
- **Vie privée** : hébergement UE, RGPD, aucune URL publique permanente vers
  un document privé, consentement explicite pour l'OCR serveur et l'IA.
- **Publicité encadrée** (version gratuite) : jamais dans le coffre-fort, sur
  une facture, pendant un scan ou sur un écran financier.
