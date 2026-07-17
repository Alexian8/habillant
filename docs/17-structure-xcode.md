# Habit Plan — Structure du projet Xcode

> Document `17`. Se lit avec [`00-fondations.md`](00-fondations.md)
> (canonique — identité, stack, conventions de données). Décrit le
> prototype SwiftUI présent dans `app/` et son évolution prévue.

---

## 1. Arborescence

```
app/
  project.yml                                  # XcodeGen — cible multiplateforme iOS+macOS
  HabitPlan/
    App/HabitPlanApp.swift                     # @main, injecte AppStore.preview()
    App/RootView.swift                         # TabView iPhone / NavigationSplitView iPad+Mac
    App/AppSection.swift                       # enum de navigation (9 sections)
    DesignSystem/HPColors.swift
    DesignSystem/HPTypography.swift
    DesignSystem/HPComponents.swift
    Features/Dashboard/DashboardView.swift
    Features/Projects/ProjectsListView.swift
    Features/Projects/ProjectDetailView.swift
    Features/Budget/BudgetView.swift
    Features/Quotes/QuotesInvoicesView.swift
    Features/Vault/VaultView.swift
    Features/Rooms/RoomsView.swift
    Features/Contractors/ContractorsView.swift
    Features/Equipment/EquipmentView.swift
    Features/Settings/SettingsView.swift
    Features/Settings/PaywallView.swift
  Packages/HabitPlanKit/
    Package.swift                              # swift-tools-version: 5.10, iOS 17 / macOS 14
    Sources/HabitPlanKit/Models.swift          # tous les types du domaine
    Sources/HabitPlanKit/Money.swift
    Sources/HabitPlanKit/AppStore.swift        # @Observable, store en mémoire
    Sources/HabitPlanKit/SampleData.swift      # jeu « Maison des Lilas »
    Tests/HabitPlanKitTests/HabitPlanKitTests.swift
```

Une **cible multiplateforme unique** `HabitPlan` (iOS 17+ / macOS 14+,
bundle `com.habitplan.app`) plus un **package local** `HabitPlanKit`.

## 2. Rôle de chaque dossier

### `App/`
Le squelette applicatif, volontairement minuscule :
- `HabitPlanApp.swift` — point d'entrée `@main`, crée
  `AppStore.preview()` et l'injecte dans l'environnement.
- `RootView.swift` — la navigation adaptative : `TabView` à 5 onglets en
  taille compacte (iPhone), `NavigationSplitView` avec sidebar (les 9
  sections + sélecteur de logement en en-tête) sur iPad et Mac. macOS n'a
  pas de size class : `#if os(macOS)` force le split view.
- `AppSection.swift` — l'énumération des 9 sections (tableau de bord,
  projets, budget, devis & factures, coffre-fort, pièces & plans,
  artisans, équipements, réglages) avec titre français et SF Symbol.
  C'est la seule source de vérité de la navigation.

### `DesignSystem/`
La traduction en code de la charte de `00-fondations.md` §2 :
- `HPColors.swift` — les 7 jetons (`hpSlate`, `hpTerracotta`, `hpSage`,
  `hpSand`, `hpInk`, `hpAmber`, `hpDanger`) en extension de `Color`, plus
  les teintes sémantiques par statut (`ProjectStatus.tint`,
  `InvoiceStatus.tint`).
- `HPTypography.swift` — `hpLargeTitle`, `hpTitle` (SF Pro Rounded) et
  `hpAmount` (chiffres financiers en `.monospacedDigit()`).
- `HPComponents.swift` — les composants réutilisés partout : `HPCard`,
  `StatTile`, `HPBadge`, `SectionHeader`, `EmptyStateView`,
  `ProgressRing`.

Aucune vue de feature ne définit de couleur ou de police en dur : tout
passe par ce dossier.

### `Features/`
Un sous-dossier **par domaine métier**, chacun autonome (sa propre
`NavigationStack` si besoin) : Dashboard, Projects (liste + détail),
Budget, Quotes (devis & factures), Vault (coffre-fort), Rooms (pièces &
plans), Contractors (artisans), Equipment (équipements), Settings
(réglages + paywall). Cette découpe suit les sections de navigation et
préfigure les modules du produit final — une feature future (OCR,
collaboration, plans) s'ajoutera comme un nouveau dossier sans toucher
aux autres.

### `Packages/HabitPlanKit`
Tout ce qui n'est **pas** de l'interface : le modèle de domaine
(`Models.swift` — enums de statuts canoniques et structs des entités),
l'arithmétique monétaire (`Money.swift` — centimes entiers, formatage
`fr_FR`), le store observable (`AppStore.swift` — `@Observable`, données
en mémoire, agrégats budgétaires et listes dérivées) et le jeu d'exemple
(`SampleData.swift` — « Maison des Lilas », doc 00 §7). Le package se
compile et se teste **sans l'app** : `swift test` suffit. Les tests
XCTest couvrent l'arithmétique et le formatage de `Money`, les agrégats,
`toggleTask`, `expiringWarranties(within:)`, la cohérence HT+TVA=TTC du
jeu d'exemple et les libellés français de tous les enums.

## 3. Pourquoi XcodeGen

Le fichier `.xcodeproj` n'est **pas versionné** : il est généré depuis
`app/project.yml`.

- **Pas de conflits git** sur `project.pbxproj`, fichier binaire-en-texte
  notoirement inmergeable dès que deux personnes ajoutent des fichiers.
- **Onboarding reproductible** en trois commandes :

  ```bash
  brew install xcodegen
  cd app && xcodegen generate
  open HabitPlan.xcodeproj
  ```

- **Configuration lisible et relue** : cibles, destinations
  (`supportedDestinations: [iOS, macOS]`), deployment targets (iOS 17.0 /
  macOS 14.0), dépendance au package local `Packages/HabitPlanKit` et
  `GENERATE_INFOPLIST_FILE: YES` tiennent dans un YAML court, diffable
  en revue de code.

## 4. Conventions de code

- **Swift 5.10**, SwiftUI pur, macro `@Observable` (`import Observation`).
- **Aucun UIKit/AppKit direct** : pas de `UIColor`/`NSColor` (couleurs
  via `Color(red:green:blue:)` dans le design system), pas de wrappers
  `UIViewRepresentable` dans le prototype.
- **`#if os(iOS)` pour les API non portables**, et seulement pour elles :
  `.navigationBarTitleDisplayMode`, `.listStyle(.insetGrouped)` (sinon
  `.inset`), `EditButton`. Préférer les placements portables
  (`.primaryAction` plutôt que `.navigationBarTrailing`). Tout code doit
  compiler pour iOS 17 **et** macOS 14.
- **Textes UI en français**, identifiants de code en anglais. Les
  libellés vivent dans des propriétés dédiées (`displayName`, `title`) —
  centralisables, donc prêts pour la localisation sans refactoring.
- **Un fichier par vue majeure**, nommé comme sa vue
  (`ProjectDetailView.swift`), avec un `#Preview` alimenté par
  `AppStore.preview()`.
- Formatage monétaire uniquement via `Money.formatted` ; commentaires
  sobres, réservés aux contraintes non évidentes.

## 5. Évolution prévue

- **Packages futurs** : `HabitPlanSync` (moteur offline-first : journal,
  push/pull, tombstones — testable par simulation sans UI),
  `HabitPlanScan` (RoomPlan/ARKit, isolé car iOS-seulement et lourd),
  `HabitPlanDesign` (le design system extrait pour être partagé avec de
  futures cibles). `HabitPlanKit` restera le socle du domaine, avec GRDB
  en remplacement du store en mémoire.
- **Nouvelles cibles** : widgets (budget, échéances) et **App Intents**
  (raccourcis « ajouter une dépense », Spotlight), ajoutées dans
  `project.yml`.
- **Tests UI XCUITest par plateforme** : parcours nominaux iPhone, iPad
  et Mac en CI, conformément à la definition of done
  ([`13-mvp.md`](13-mvp.md) §4).
- **Xcode Cloud** pour les builds signés, les tests sur les trois
  plateformes et la distribution TestFlight.

## 6. Lancer le prototype

```bash
brew install xcodegen
cd app
xcodegen generate
open HabitPlan.xcodeproj
```

Choisir la destination (simulateur iPhone, iPad ou « My Mac ») et lancer.
Les tests du domaine s'exécutent aussi seuls :

```bash
cd app/Packages/HabitPlanKit && swift test
```

### Limites actuelles du prototype

- **Données en mémoire** uniquement : le jeu « Maison des Lilas » est
  reconstruit à chaque lancement, rien n'est persisté (GRDB viendra avec
  le MVP).
- **Pas de réseau** : ni compte, ni synchronisation, ni fichiers — les
  états de sync affichés (`SyncState`) sont illustratifs.
- Pas d'import de documents réels, pas de StoreKit actif (le paywall est
  une maquette), pas de notifications.

Le prototype sert à valider la navigation, le design system et le modèle
de domaine — pas à héberger des données réelles.
