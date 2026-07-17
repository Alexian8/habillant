# Habit Plan — Présentation du concept

> Document `01`. Se lit avec [`00-fondations.md`](00-fondations.md), qui reste
> la référence canonique (identité, palette, stack, modèle de données, offre).

**Habit Plan** — « Gérez votre maison, du plan à la facture. »

---

## 1. Le problème

Posséder un logement, c'est gérer sans le savoir une petite entreprise :
des dizaines de milliers d'euros de travaux, des dizaines d'interlocuteurs,
des centaines de documents. Or presque personne n'est outillé pour cela.

### 1.1 Des documents éparpillés

- La facture du chauffagiste est dans une boîte mail, le devis du plombier
  dans une autre, la notice de la chaudière dans un carton à la cave.
- Le diagnostic de performance énergétique, l'attestation d'assurance
  décennale de l'artisan, le permis de construire : chacun dort dans un
  dossier différent — quand il n'est pas perdu.
- Au moment de faire jouer une garantie, de déclarer un sinistre ou de
  vendre le bien, il faut reconstituer l'historique à la main, souvent
  plusieurs années après les faits.

### 1.2 Un budget travaux opaque

- Les dépenses s'accumulent au fil des tickets et des virements, sans vue
  consolidée : personne ne sait dire combien la rénovation de la cuisine a
  **réellement** coûté, ni où en est le budget global.
- Les devis se comparent mal : montants HT/TTC mélangés, taux de TVA
  différents (20 %, 10 %, 5,5 %), postes découpés différemment d'un artisan
  à l'autre.
- Les acomptes versés, les soldes restants et les factures en retard ne
  sont suivis nulle part — jusqu'à la mauvaise surprise.

### 1.3 Un suivi de chantier informel

- L'avancement se suit par SMS, appels et photos noyées dans la pellicule
  du téléphone.
- Aucune trace datée de l'état « avant / pendant / après », pourtant
  précieuse en cas de litige ou de malfaçon.
- Les décisions (« devis accepté », « on décale la pose ») ne sont écrites
  nulle part ; l'entretien futur (chaudière, VMC, toiture) repose sur la
  mémoire.

Les outils existants ne répondent qu'à un fragment du problème : le tableur
suit des montants mais pas des documents ; l'app de scan range des PDF mais
n'a aucune notion de budget ; les logiciels professionnels du bâtiment sont
pensés pour l'artisan, pas pour le propriétaire.

## 2. La proposition de valeur

Habit Plan est le **carnet numérique permanent de la maison** : une seule
application, sur iPhone, iPad et Mac, qui relie entre eux les projets, les
dépenses, les devis, les factures, les documents, les photos, les plans,
les artisans et les équipements d'un logement.

Trois promesses :

1. **Tout est au même endroit.** Chaque document, chaque euro, chaque photo
   est rattaché au bon logement, au bon projet, à la bonne pièce — et
   retrouvable en quelques secondes, même hors ligne (architecture
   offline-first, cf. `00-fondations.md` §3).
2. **Le budget devient lisible.** Montants normalisés (HT / TVA / TTC,
   centimes exacts), comparaison de devis côte à côte, suivi des paiements
   et alertes de dépassement.
3. **La mémoire du logement est garantie.** Historique daté et exportable :
   même après expiration de l'abonnement, **lecture et export restent
   garantis à vie** (cf. `00-fondations.md` §6).

## 3. Les 10 domaines couverts

| # | Domaine | Ce que fait Habit Plan |
|---|---|---|
| 1 | **Travaux et rénovations** | Projets avec cycle de vie complet (12 statuts, de `Idée` à `Terminé`, litige et annulation compris), tâches, jalons, avancement. |
| 2 | **Dépenses et budgets** | Budget par projet et par logement, dépenses catégorisées (matériaux, main-d'œuvre, frais annexes…), paiements et acomptes, graphiques Swift Charts. |
| 3 | **Devis et factures** | Réception, statuts dédiés (devis : reçu → accepté/refusé/expiré ; factures : à payer → payée / en retard / contestée), comparaison multi-devis, échéances. |
| 4 | **Documents administratifs** | Coffre-fort structuré : actes, diagnostics, permis, assurances, attestations — avec liens vers projets, pièces et équipements (`DocumentLink`). |
| 5 | **Photos de chantier** | Prises de vue datées et géolocalisées par pièce et par projet, séries avant / pendant / après, annotation. |
| 6 | **Plans 2D/3D** | Plans par étage, saisie manuelle des pièces dès le MVP ; scan **RoomPlan/LiDAR** produisant un plan 2D coté en V3, avec correction des dimensions. |
| 7 | **Artisans** | Annuaire personnel : coordonnées, spécialités, documents (assurance, SIRET), historique des devis, factures et projets par artisan. |
| 8 | **Garanties** | Suivi des garanties légales et commerciales (biennale, décennale, fabricant), échéances et justificatifs rattachés. |
| 9 | **Équipements** | Inventaire par pièce (chaudière, VMC, électroménager…) : marque, modèle, numéro de série, notice, date d'installation. |
| 10 | **Entretien futur** | Tâches d'entretien récurrentes (révision chaudière, ramonage, gouttières) avec rappels et historique des interventions. |

Ces domaines s'appuient sur le modèle de 27 entités défini en
`00-fondations.md` §5 — ils ne sont pas dix modules juxtaposés, mais dix
facettes d'un même graphe de données : une facture *connaît* son devis, son
projet, son artisan et son équipement.

## 4. Positionnement

**Le carnet numérique permanent de la maison.**

- **Assez simple pour un particulier** : ajouter une dépense prend dix
  secondes, scanner une facture en prend trente, et l'app reste utile même
  si l'on ne s'en sert que quelques fois par mois.
- **Assez complet pour une rénovation totale** : multi-projets, multi-
  artisans, dizaines de devis, centaines de documents, invités avec rôles,
  budget consolidé au centime.
- **Pensé pour durer** : un logement se garde des décennies ; Habit Plan
  est conçu comme un actif qui prend de la valeur avec le temps — jusqu'au
  « dossier numérique du logement » remis à l'acheteur lors d'une vente.
- **Digne de confiance** : hébergement en Union européenne, documents
  jamais exposés par URL publique permanente, données extraites par OCR
  toujours validées par l'utilisateur (garde-fous canoniques,
  `00-fondations.md` §8).

## 5. Différenciation

| Face à… | Leur limite | La réponse Habit Plan |
|---|---|---|
| **Tableurs** (Numbers, Excel, Sheets) | Chiffres sans documents ni photos ; formules fragiles ; aucune notion de statut, de rappel ou de partage par rôle. | Modèle structuré (HT/TVA/TTC, statuts, échéances), documents et photos rattachés aux montants, rappels natifs, saisie mobile en quelques gestes. |
| **Apps de scan / GED grand public** (scan vers PDF, coffres-forts génériques) | Des fichiers rangés, mais muets : aucun lien avec un budget, un projet, un artisan, une garantie. | L'OCR alimente des données exploitables (montant, TVA, date, émetteur) — validées par l'utilisateur — qui nourrissent le budget et les échéanciers. |
| **Logiciels pro du bâtiment** (devis-facturation artisan, gestion de chantier) | Conçus pour celui qui *vend* les travaux : jargon, prix pro, aucune vision patrimoniale du logement. | Conçu pour celui qui *possède* le logement ; le professionnel peut être **invité** sur un projet avec un rôle restreint, sans accès aux finances globales. |
| **Apps de suivi immobilier / patrimoine** | Vision financière macro, pas d'outillage terrain (chantier, photos, plans, entretien). | Le terrain d'abord : saisie sur chantier, plans par pièce, photos datées — la vision patrimoniale en découle. |

## 6. Une expérience par appareil

Une seule application multiplateforme (SwiftUI, cible unique iOS + macOS),
mais trois usages assumés :

### iPhone — l'outil de terrain
- **Saisie rapide** : ajouter une dépense ou une note en quelques secondes,
  y compris sans réseau (offline-first).
- **Scan** : numérisation de factures et documents à la volée (VisionKit),
  photos de chantier datées et rattachées à la pièce.
- **Rappels et alertes** : échéances de factures, fins de garantie,
  entretiens à venir, notifications de chantier.
- Navigation par `TabView`, gestes rapides, widgets et actions depuis
  l'écran verrouillé à terme.

### iPad — la table à dessin
- **Plans** : consultation et édition des plans d'étage, annotations à
  l'**Apple Pencil**, scan RoomPlan (V3) sur les modèles LiDAR.
- **Comparaison de devis côte à côte** : deux ou trois devis affichés en
  parallèle, poste par poste, écarts mis en évidence.
- Lecture confortable des documents du coffre-fort, revue photo grand
  format. Navigation par `NavigationSplitView`.

### Mac — le bureau de gestion
- **Gestion détaillée** : tableaux denses, tri, filtres, édition au clavier,
  fenêtres multiples.
- **Imports massifs** : glisser-déposer de dossiers entiers de PDF et de
  photos, classement assisté.
- **Rapports et tableaux de bord** : synthèses budgétaires, exports (dont
  le dossier numérique du logement), impression.

Le même compte, les mêmes données, synchronisées entre les trois (sync
offline-first, `00-fondations.md` §3) : on commence sur le chantier avec
l'iPhone, on arbitre les devis sur l'iPad le soir, on fait les comptes sur
le Mac le week-end.

## 7. Modèle économique (rappel)

Gratuit généreux (1 logement, 3 projets actifs, 1 Go, 3 scans LiDAR/mois)
pour installer l'usage ; **Premium** à 4,99 €/mois ou 39,99 €/an (offre
Famille 59,99 €/an) pour tout débloquer. Chiffres et règles publicitaires
canoniques : `00-fondations.md` §6. Principe clé : le gratuit n'est jamais
un piège — après expiration, lecture et export garantis à vie.

## 8. Illustration : la Maison des Lilas

Le jeu d'exemple canonique (`00-fondations.md` §7) incarne le concept :
une maison de 1930 de 110 m² à Montreuil, quatre projets à des stades
différents — cuisine en cours (18 500 €), salle de bain à l'étape devis
(12 000 €), combles à chiffrer (8 000 €), fenêtres à l'état d'idée — et
quatre artisans suivis. C'est exactement la situation qu'Habit Plan rend
enfin lisible : plusieurs chantiers, plusieurs temporalités, un seul carnet.
