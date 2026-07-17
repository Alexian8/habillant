# Habit Plan — Fondations du produit (document canonique)

> Ce document est la **référence unique** du projet. Toute décision de nommage,
> d'architecture ou de périmètre prise ici prévaut sur les autres documents.
> Les documents `01` à `17` détaillent chaque sujet ; en cas de divergence,
> corriger le document détaillé, pas celui-ci.

---

## 1. Identité

| Élément | Valeur |
|---|---|
| Nom marketing | **Habit Plan** |
| Nom technique | **HabitPlan** |
| Slogan principal | « Gérez votre maison, du plan à la facture. » |
| Bundle ID | `com.habitplan.app` |
| Plateformes | iOS 17+, iPadOS 17+, macOS 14+ (Sonoma) |
| Langue de lancement | Français (structure prête pour la localisation) |
| Distribution | App Store public — gratuit + abonnement Premium (StoreKit 2) |

## 2. Palette et typographie (canonique)

| Jeton | Nom | Hex | Usage |
|---|---|---|---|
| `hpSlate` | Bleu Ardoise | `#2C4A63` | Couleur principale — confiance, structure |
| `hpTerracotta` | Terracotta | `#E07A5F` | Accent — maison, chaleur, actions |
| `hpSage` | Vert Sauge | `#81B29A` | Validation, budget sain, succès |
| `hpSand` | Sable | `#F4F1EC` | Fonds clairs, cartes |
| `hpInk` | Encre | `#1C2733` | Texte principal, fonds sombres |
| `hpAmber` | Ambre | `#E9C46A` | Avertissements, échéances proches |
| `hpDanger` | Brique | `#D64545` | Dépassements, retards, erreurs |

Typographie : **SF Pro** (système) partout, chiffres financiers en
`.monospacedDigit()`. Titres de tableau de bord en SF Pro Rounded (`.rounded`).

Icône d'application : un toit de maison dont le pan droit se prolonge en
**coche** (✓), posé sur une trame discrète de plan d'architecte, fond dégradé
Bleu Ardoise → Encre, trait Sable.

## 3. Stack technique (canonique)

### Client Apple
- **SwiftUI** exclusivement, Swift 5.10, macro `@Observable`.
- Navigation : `TabView` sur iPhone, `NavigationSplitView` sur iPad et Mac.
- Graphiques : **Swift Charts**. Scan : **RoomPlan / ARKit / RealityKit** (V3).
  OCR embarqué : **Vision / VisionKit**. Abonnements : **StoreKit 2**.
- Persistance locale cible : **SQLite via GRDB** (le prototype utilise un
  store en mémoire).
- Un projet Xcode généré par **XcodeGen** (`app/project.yml`), une cible
  multiplateforme unique (iOS + macOS) + package local **HabitPlanKit**
  (modèle de domaine, données d'exemple, logique métier testable).

### Serveur
- API REST **`/v1`** en **Swift Vapor** (cohérence de langage avec le client ;
  alternative documentée : NestJS/TypeScript).
- **PostgreSQL 16** (données), **Redis** (files de travail OCR/IA/miniatures),
  stockage objet **compatible S3 en Union européenne** (Scaleway Object
  Storage, Paris), **APNs** (push), WebSocket de notification de sync.
- Hébergement **UE uniquement** : Scaleway (Paris) ou OVHcloud (Gravelines).
- Sauvegardes chiffrées (pgBackRest + versioning S3), journal d'audit,
  console d'administration interne, quotas de stockage par compte.

### Authentification
- **Sign in with Apple** + e-mail/mot de passe (hachage **Argon2id**).
- Jetons **JWT** courts (15 min) + refresh token **rotatif** ; registre
  d'appareils avec révocation ; limitation des tentatives ; **passkeys**
  (WebAuthn) prévues en V2+.

### Synchronisation (résumé — détail dans `09-synchronisation.md`)
- **Offline-first** : la base SQLite locale est la source de vérité de l'UI.
- Journal local des changements (`pending_changes`) ; push par lots ;
  pull incrémental par curseur (`updated_since`).
- Fusion **LWW champ par champ** + copies de conflit pour les fichiers ;
  suppressions par **tombstones** ; jamais d'écrasement silencieux.
- Fichiers envoyés en différé via **URL présignées** (15 min).
- États affichés : synchronisé · synchronisation en cours · disponible hors
  ligne · erreur · fichier en attente.

## 4. Conventions de données (canoniques)

- **Identifiants** : UUID **v7**, générés côté client.
- **Montants** : centimes entiers (`Int`) + code devise ISO 4217 (`"EUR"`).
  Toujours trois champs : `amountHT`, `amountVAT`, `amountTTC`.
- **Taux de TVA** : en points de base (`vatRateBps` — 2000 = 20,00 % ;
  taux français courants : 2000, 1000, 550).
- **Dates** : ISO 8601 UTC côté serveur ; `Date` côté Swift.
- **Suppression** : soft delete généralisé (`deletedAt`) ; corbeille 30 jours
  pour les documents ; purge différée 30 jours après suppression d'un
  logement ou d'un compte.

## 5. Modèle de données — 27 entités (canonique)

User, Device, Subscription, Property, PropertyMember, Floor, Room, RoomScan,
FloorPlan, Project, ProjectTask, Expense, Payment, Quote, Invoice, Document,
DocumentLink, Contractor, Contact, Photo, Equipment, Warranty,
MaintenanceTask, Reminder, Comment, ActivityLog, NotificationItem.

> Nommage Swift : `Task` → **`ProjectTask`** (conflit avec la concurrence
> Swift), `Plan` → **`FloorPlan`**, `Document` → **`VaultDocument`** côté
> client (conflit avec `DocumentGroup`), `Notification` → **`NotificationItem`**.

### Statuts de projet (12, ordre canonique)
`idea` Idée · `toStudy` À étudier · `toPrice` À chiffrer · `quotesRequested`
Devis demandés · `quotesReceived` Devis reçus · `quoteAccepted` Devis accepté ·
`planned` Planifié · `inProgress` En cours · `paused` En pause · `done`
Terminé · `dispute` Litige · `cancelled` Annulé.

### Rôles membres (5)
`owner` Propriétaire · `editor` Co-gestionnaire · `contributor` Contributeur ·
`viewer` Lecture seule · `professional` Professionnel (accès restreint au
projet concerné, jamais aux données financières globales ni aux documents
sensibles).

### Statuts de devis
`received` Reçu · `pending` En attente · `accepted` Accepté · `declined`
Refusé · `expired` Expiré.

### Statuts de facture
`toPay` À payer · `partiallyPaid` Partiellement payée · `paid` Payée ·
`overdue` En retard · `disputed` Contestée.

### Catégories de dépense (canoniques)
`materials` Matériaux · `labor` Main-d'œuvre · `fees` Frais annexes ·
`equipment` Équipement · `permits` Autorisations · `insurance` Assurance ·
`other` Autre.

## 6. Modèle économique (chiffres canoniques, indicatifs)

| Offre | Prix | Contenu clé |
|---|---|---|
| **Gratuit** | 0 € | 1 logement, 3 projets actifs, 1 Go, 3 scans LiDAR/mois, pub discrète |
| **Premium mensuel** | 4,99 €/mois | Tout illimité*, 50 Go, sans pub |
| **Premium annuel** | 39,99 €/an | Idem + 2 mois offerts |
| **Famille** | 59,99 €/an | Partage familial Apple (6 personnes) |

Essai gratuit 14 jours. \*Scans LiDAR : usage raisonnable (50/mois).
La publicité n'apparaît **jamais** : dans le coffre-fort, sur une facture,
pendant un scan, sur un écran financier, pendant une action critique.
Après expiration de l'abonnement : **lecture et export garantis à vie**.

## 7. Jeu de données d'exemple (canonique — utilisé par le prototype et les docs)

« **Maison des Lilas** », maison 1930 de 110 m² à Montreuil (93100),
2 étages + combles. Projets : *Rénovation de la cuisine* (en cours,
18 500 € budget), *Salle de bain de l'étage* (devis reçus, 12 000 €),
*Isolation des combles* (à chiffrer, 8 000 €), *Remplacement des fenêtres*
(idée). Artisans : **Martin Électricité** (Montreuil), **Plomberie Costa**
(Vincennes), **Menuiserie Dubois** (Fontenay-sous-Bois), **ISO+ Combles**
(Rosny). TVA rénovation 10 % ou 5,5 % (énergie), neuf 20 %.

## 8. Garde-fous produit (canoniques)

- L'IA **résume, compare, signale** — elle ne **choisit jamais** un artisan
  et ne présente jamais une estimation comme une certitude ni comme un avis
  juridique, technique ou financier.
- Toute donnée extraite par OCR/IA est **soumise à validation utilisateur**.
- Les documents privés ne sont jamais servis par une URL publique permanente.
- Aucun document privé n'entraîne de modèle sans consentement explicite.
- Les mesures issues d'un scan doivent être **vérifiées avant commande de
  matériaux** — avertissement affiché systématiquement.
- Connexion bancaire éventuelle : **lecture seule**, opt-in, jamais au MVP.
