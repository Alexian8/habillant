# Habit Plan — Identité visuelle

> Document `05`. Les valeurs de palette, la typographie et la description
> de l'icône sont **canoniques** dans [`00-fondations.md`](00-fondations.md)
> §2 ; ce document les développe et fixe leurs règles d'usage.

---

## 1. Valeurs de marque

| Valeur | Ce qu'elle signifie | Traduction visuelle |
|---|---|---|
| **Maison** | On parle d'un foyer, pas d'un actif abstrait | Terracotta chaleureux, formes douces, photos réelles |
| **Organisation** | Tout a sa place, tout se retrouve | Trame de plan d'architecte, grilles régulières, cartes |
| **Sécurité** | Les documents d'une vie sont à l'abri | Bleu Ardoise dominant, coffre-fort visuellement « calme » |
| **Simplicité** | Utilisable un dimanche soir, fatigué, sur un chantier | Composants système, hiérarchie évidente, peu d'options par écran |
| **Confiance** | Rien n'est décidé à la place de l'utilisateur | Écrans de validation explicites, états toujours visibles |
| **Maîtrise du budget** | Les chiffres sont exacts et lisibles | Chiffres monospaced, Sauge/Ambre/Brique comme langage budgétaire |

## 2. Logo

### 2.1 Concept

Un **toit de maison dont le pan droit se prolonge en coche (✓)**, posé sur
une **trame discrète de plan d'architecte**. Lecture double et immédiate :
la maison (le sujet) et la validation (la promesse — c'est fait, c'est
rangé, c'est maîtrisé). La trame de plan rappelle le « du plan à la
facture » du slogan.

### 2.2 Construction

- Grille de construction carrée **24×24 unités**.
- **Pan gauche du toit** : segment ascendant de (3, 15) au faîte (12, 6),
  épaisseur de trait 2,5 unités, extrémités arrondies.
- **Pan droit / coche** : du faîte (12, 6), segment descendant jusqu'à
  (15, 12) — point bas de la coche — puis segment **remontant** jusqu'à
  (21, 8) : le pan droit devient la branche longue du ✓. Même épaisseur,
  jonctions arrondies.
- Le trait est **continu** : un seul chemin du pied gauche du toit à la
  pointe de la coche — symbole d'un suivi sans rupture.
- **Trame de fond** (versions couleur uniquement) : quadrillage fin type
  papier millimétré, pas de 3 unités, opacité ≤ 8 %, jamais sous le trait
  principal à plus de 8 % — la trame se devine, ne se lit pas.
- Angles directeurs : pans à 45°, branche de coche à ~30° — silhouette
  stable, ni raide ni penchée.

### 2.3 Variantes

| Variante | Usage | Spécification |
|---|---|---|
| Couleur sur clair | Site, documents | Trait Bleu Ardoise `#2C4A63`, trame Encre 8 %, fond Sable `#F4F1EC` ou blanc |
| Couleur sur sombre | Mode sombre, vidéos | Trait Sable `#F4F1EC`, trame Sable 8 %, fond Encre `#1C2733` |
| **Monochrome** | Tampon, filigrane, gravure, impression 1 couleur | Trait seul, une couleur, **sans trame** ; jamais en dessous de 16 px de haut |
| Logotype | En-têtes, marketing | Symbole + « Habit Plan » en SF Pro Semibold, espacé du symbole d'une hauteur de trait |

### 2.4 Zone de protection et interdits

- **Zone de protection** : marge minimale égale à la **hauteur du pan
  gauche** (soit ~1/2 de la hauteur du symbole) sur les quatre côtés ;
  rien n'y entre, ni texte ni bord d'écran.
- Interdits : ne pas incliner, ne pas séparer la coche du toit, ne pas
  changer les couleurs hors palette, ne pas ajouter d'ombre portée, ne pas
  poser la version couleur sur photo chargée (utiliser la monochrome).

### 2.5 Icône d'application (canonique)

- Fond : **dégradé vertical Bleu Ardoise `#2C4A63` → Encre `#1C2733`**
  (clair en haut, sombre en bas).
- Trame de plan d'architecte en Sable à très faible opacité (≤ 8 %).
- Symbole toit-coche en **trait Sable `#F4F1EC`**, centré optiquement
  (légèrement au-dessus du centre géométrique), occupant ~60 % de la
  largeur.
- Déclinaisons iOS/macOS générées depuis le même master ; pas de texte
  dans l'icône ; la version « monochrome/teintée » du système reprend le
  trait seul.

## 3. Palette (canonique — §2 des fondations)

| Jeton | Nom | Hex | Usage général |
|---|---|---|---|
| `hpSlate` | Bleu Ardoise | `#2C4A63` | Couleur principale : navigation, titres, éléments structurants |
| `hpTerracotta` | Terracotta | `#E07A5F` | Accent : boutons d'action, éléments « maison », sélection |
| `hpSage` | Vert Sauge | `#81B29A` | Positif : validation, budget sain, statuts accomplis |
| `hpSand` | Sable | `#F4F1EC` | Fonds clairs, cartes, surfaces de repos |
| `hpInk` | Encre | `#1C2733` | Texte principal, fonds du mode sombre |
| `hpAmber` | Ambre | `#E9C46A` | Avertissement : échéance proche, confiance OCR faible, quota |
| `hpDanger` | Brique | `#D64545` | Alerte : dépassement, retard, erreur, litige |

### 3.1 Règles d'usage

- **Proportions indicatives** : Sable/Encre (fonds) ~60 %, Bleu Ardoise
  ~25 %, Terracotta ~10 %, couleurs sémantiques (Sauge/Ambre/Brique) ~5 %.
- Sauge, Ambre et Brique sont **réservées à la sémantique d'état** — jamais
  décoratives. La couleur n'est jamais le seul porteur d'information :
  toujours doublée d'un libellé ou d'un symbole (accessibilité).
- Terracotta = action et chaleur ; un seul bouton Terracotta majeur par
  écran.
- Contrastes : texte Encre sur Sable et texte Sable sur Ardoise/Encre
  respectent WCAG AA ; l'Ambre n'est jamais utilisée pour du texte fin sur
  fond clair (fond de badge avec texte Encre à la place).

### 3.2 Exemples d'application par écran

| Écran | Application de la palette |
|---|---|
| Tableau de bord | Fond Sable ; cartes blanches ; titres Ardoise (SF Pro Rounded) ; jauge budget Sauge → Ambre → Brique selon consommation ; bouton « + » Terracotta |
| Fiche projet | Badge de statut coloré (voir §5.2) ; barre de progression Sauge ; dépassement budgétaire chiffré en Brique |
| Comparaison de devis | Colonnes neutres ; écarts favorables surlignés Sauge, défavorables Brique ; devis accepté couronné d'un badge Sauge |
| Factures | Échéance lointaine neutre, proche Ambre, dépassée Brique ; « Payée » en Sauge |
| Coffre-fort | Ambiance la plus calme : Ardoise et Sable seulement, aucune couleur vive hors alerte réelle |
| Validation OCR | Champs sûrs neutres ; champs à faible confiance en Ambre ; jamais de pré-validation verte |
| Paywall | Fond Ardoise → Encre (comme l'icône), texte Sable, bouton d'abonnement Terracotta, garantie « lecture à vie » en Sauge |

## 4. Typographie

- **SF Pro** (police système) partout — natif, lisible, Dynamic Type.
- **Chiffres financiers** : `.monospacedDigit()` obligatoire pour tout
  montant, quota ou compteur (alignement des colonnes, pas de « saut » au
  rafraîchissement).
- **Titres de tableau de bord** : SF Pro **Rounded** (`.rounded`) — la
  rondeur porte la chaleur « maison » sans police exotique.
- Hiérarchie : styles système (`largeTitle` → `caption`) sans tailles
  arbitraires ; graisse Semibold pour les titres, Regular pour le corps.
- Aucune police tierce : cohérence, poids de l'app, localisation.

## 5. Principes d'interface communs iPhone / iPad / Mac

### 5.1 Cartes
L'unité de contenu est la **carte** : coins arrondis continus, fond blanc
sur Sable (clair) ou gris Encre relevé (sombre), une information dominante
par carte, action principale au plus près du contenu.

### 5.2 Badges de statut colorés par état
Un langage unique dans toute l'app — pastille + libellé, couleur par
famille d'état :

| Famille d'état | Exemples (statuts canoniques) | Couleur |
|---|---|---|
| Neutre / amont | `Idée`, `À étudier`, `À chiffrer`, `Reçu`, `En attente` | Ardoise (teinte légère) |
| Actif | `Devis demandés`, `Planifié`, `En cours` | Terracotta |
| Positif | `Devis accepté`, `Terminé`, `Accepté`, `Payée` | Sauge |
| Vigilance | `En pause`, `Expiré`, `À payer` (échéance proche), `Partiellement payée` | Ambre |
| Alerte | `Litige`, `Contestée`, `En retard`, dépassement | Brique |
| Arrêt | `Annulé`, `Refusé` | Gris neutre |

### 5.3 Densité adaptée par plateforme
- **iPhone** : une colonne, gros touchables, saisie une main, feuilles
  modales.
- **iPad** : deux volets (`NavigationSplitView`), comparaisons côte à
  côte, Apple Pencil pour annoter plans et devis.
- **Mac** : densité maximale — tableaux triables, édition en ligne,
  raccourcis clavier, fenêtres multiples, glisser-déposer.
- Même hiérarchie et mêmes couleurs partout : on change de densité, jamais
  de langage.

### 5.4 Mode sombre
- Fonds Encre `#1C2733`, cartes en gris bleuté relevé, texte Sable.
- Les couleurs sémantiques conservent leur teinte (variantes ajustées pour
  le contraste) — un badge Sauge reste Sauge.
- Le coffre-fort et les écrans financiers sont irréprochables en sombre :
  ce sont les écrans du soir.

### 5.5 États toujours visibles
Synchronisation (5 états canoniques), mode hors ligne, fichier en attente :
indiqués discrètement mais en permanence — la confiance naît de la
transparence, jamais d'un sablier muet.

## 6. Slogans

**Slogan principal (canonique) : « Gérez votre maison, du plan à la
facture. »** — il coiffe toutes les communications.

Propositions complémentaires (déclinaisons par contexte) :

1. « La mémoire de votre maison. »
2. « Chaque document à sa place, chaque euro à sa ligne. »
3. « Vos travaux, enfin au clair. »
4. « Le carnet numérique de votre logement. »
5. « De l'idée au devis, du devis à la facture. »
6. « Votre maison mérite un dossier bien tenu. »
7. « Tout votre chantier dans la poche. » *(communication iPhone)*
8. « Comparez, décidez, gardez la preuve. » *(fonction devis)*
9. « Aujourd'hui les travaux, demain la revente. » *(dossier du logement)*
10. « Rien ne se perd, tout se retrouve. » *(coffre-fort)*

## 7. Ton de voix

**Rassurant, concret, jamais culpabilisant.**

- **Rassurant** : on nomme ce qui se passe et ce qui va se passer.
  « Votre facture est enregistrée et disponible hors ligne. » Jamais
  d'alarmisme : une échéance dépassée est un fait à traiter, pas une faute.
- **Concret** : des mots de maison, pas de jargon logiciel ni de droit.
  « Devis accepté », « reste à payer », « à vérifier » — pas
  d'« artefacts », de « workflow » ni d'« items ».
- **Jamais culpabilisant** : pas de « Vous avez oublié… », pas de compteurs
  honteux, pas de relance passive-agressive. Un report d'entretien se
  formule : « Reporté au 12 mars — nous vous le rappellerons. »
- **Honnête sur les limites** : l'app *signale* et *compare*, elle ne
  garantit rien qu'elle ne peut tenir ; les mesures de scan sont « à
  vérifier avant commande », une estimation est « indicative » (garde-fous
  canoniques §8).
- **Sobre dans l'enthousiasme** : un chantier terminé mérite un
  « Beau travail. Projet terminé et archivé. » — pas de confettis à chaque
  tap.

Ce ton s'applique partout : interface, notifications, e-mails, App Store,
messages d'erreur. En cas de doute, relire la phrase à voix haute comme si
on la disait à Bernard (persona 3) : si elle inquiète, infantilise ou
embrouille, la réécrire.
