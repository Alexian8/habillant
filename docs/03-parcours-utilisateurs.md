# Habit Plan — Parcours utilisateurs

> Document `03`. Référence canonique : [`00-fondations.md`](00-fondations.md)
> (statuts §5, offre §6, garde-fous §8). Les noms d'écrans renvoient au
> catalogue de [`04-ecrans.md`](04-ecrans.md). Exemples : jeu de données
> « Maison des Lilas ».

Convention : chaque parcours liste les **étapes**, les **écrans traversés**,
les **frictions évitées** et les **garde-fous** appliqués.

---

## A. Onboarding et création du premier logement

*Persona type : Nadia, sur iPhone, sans capteur LiDAR.*

1. **Accueil** : trois écrans de présentation (carnet du logement, budget
   lisible, coffre-fort) — passables d'un geste, aucune inscription forcée
   pour lire.
2. **Connexion** : « Sign in with Apple » mis en avant (ou e-mail/mot de
   passe). Aucune autre donnée demandée à ce stade.
3. **Création du logement** : nom (« Maison des Lilas »), type, adresse
   (facultative), surface approximative, année de construction.
4. **Étages** : ajout rapide (« Rez-de-chaussée », « Étage », « Combles ») —
   valeurs proposées, réordonnables.
5. **Pièces en mode manuel** : par étage, sélection dans une grille de
   pièces types (cuisine, séjour, chambre…) + surface indicative optionnelle.
   **Aucun scan requis** : le LiDAR est une option (V3), jamais un préalable.
6. **Arrivée sur le Tableau de bord**, pré-rempli d'invites d'action :
   « Ajouter un premier projet », « Scanner un document », « Inviter
   quelqu'un ».

**Écrans** : Bienvenue → Connexion → Nouveau logement → Étages & pièces →
Tableau de bord.
**Frictions évitées** : pas de formulaire long (tout est modifiable plus
tard), pas de demande de notification/photos avant le premier usage réel,
pas de paywall à l'onboarding.
**Garde-fous** : compte utilisable hors ligne dès la création
(offline-first) ; champs facultatifs clairement marqués.

## B. Ajout rapide d'une dépense sur iPhone, depuis le chantier

*Camille, dans la cuisine en travaux, réseau faible.*

1. Onglet **Budget** → bouton **+** (ou action rapide depuis l'icône de
   l'app) : « Nouvelle dépense ».
2. Saisie minimale : montant TTC (pavé numérique, chiffres
   `.monospacedDigit()`), libellé, catégorie proposée (`Matériaux`),
   projet pré-sélectionné (« Rénovation de la cuisine », dernier utilisé).
3. Option : photo du ticket en un geste (rattachée à la dépense, OCR
   différé).
4. **Enregistrer** — moins de 10 secondes au total. La dépense apparaît
   immédiatement, badge « en attente de synchronisation » si hors ligne.

**Écrans** : Tableau de bord ou Budget → Nouvelle dépense (feuille modale).
**Frictions évitées** : aucun champ obligatoire au-delà du montant et du
libellé ; HT/TVA calculables plus tard ; pas d'échec si hors réseau.
**Garde-fous** : montants stockés en centimes (`Int`) ; la dépense est
modifiable et supprimable (corbeille) sans écrasement silencieux.

## C. Numérisation d'une facture papier → OCR → validation → coffre-fort

*Nadia numérise la facture papier de Plomberie Costa.*

1. **Coffre-fort** (ou Factures) → **Scanner** : cadrage automatique
   VisionKit, multi-pages, recadrage.
2. Traitement **OCR (Vision)** local : détection du type (« facture »), de
   l'émetteur (« Plomberie Costa »), des montants HT/TVA/TTC, de la date,
   de l'échéance.
3. **Écran de validation des champs détectés** — étape *obligatoire* :
   chaque champ est présenté avec sa valeur détectée, surligné dans
   l'aperçu du document ; l'utilisateur **valide toujours**, corrige ou
   efface champ par champ. Indice de confiance faible = champ signalé en
   Ambre, jamais pré-validé.
4. Rattachements proposés (jamais imposés) : artisan existant, projet
   (« Salle de bain de l'étage »), facture liée au devis accepté.
5. **Classement au coffre-fort** : catégorie « Factures », logement
   courant ; la facture créée passe au statut `À payer` avec son échéance,
   qui alimente rappels et tableau de bord.

**Écrans** : Coffre-fort → Caméra de scan → Validation OCR → Fiche facture.
**Frictions évitées** : aucune ressaisie complète (l'OCR pré-remplit),
mais aucune confiance aveugle ; classement en un écran.
**Garde-fous canoniques** : « toute donnée extraite par OCR/IA est soumise
à validation utilisateur » (§8) ; document stocké chiffré, jamais servi par
URL publique permanente ; corbeille 30 jours en cas de suppression.

## D. Demande, réception et comparaison de devis sur iPad, acceptation

*Camille & Hugo, projet « Salle de bain de l'étage » (12 000 € budgétés).*

1. Projet en statut `À chiffrer` → action **« Demander des devis »** :
   sélection d'artisans de l'annuaire (Plomberie Costa, Martin Électricité),
   note de consultation commune ; le projet passe à `Devis demandés`.
2. **Réception** : chaque devis (PDF reçu par mail, AirDrop ou scan) est
   importé, passé par l'écran de validation OCR (parcours C), créé au
   statut `Reçu`. Le projet passe à `Devis reçus`.
3. **Comparaison côte à côte** (écran signature iPad) : deux ou trois devis
   en colonnes, postes alignés quand ils se correspondent, écarts de prix
   surlignés (Sauge = moins cher, Brique = plus cher), totaux HT/TVA/TTC
   normalisés, TVA 10 % vérifiée. Annotations à l'Apple Pencil sur les PDF.
4. L'app **résume, compare, signale** (poste manquant chez l'un, taux de
   TVA différent, délai de validité) — elle **ne recommande jamais** un
   artisan.
5. **Acceptation** : « Marquer comme accepté » sur le devis retenu →
   confirmation explicite ; le devis passe à `Accepté`, les autres peuvent
   être passés à `Refusé` (avec courtoisie : modèle de message de refus).
   Le projet passe à `Devis accepté` et le montant s'inscrit au budget
   engagé.

**Écrans** : Fiche projet → Demande de devis → Liste des devis →
Comparaison de devis → Fiche devis → Confirmation.
**Frictions évitées** : plus de jonglage entre PDF aux formats
hétérogènes ; les statuts avancent d'eux-mêmes avec les actions.
**Garde-fous** : jamais de choix automatique ni de « meilleur devis »
décrété (§8) ; l'acceptation reste un geste explicite de l'utilisateur ;
aucune notification envoyée à l'artisan sans confirmation.

## E. Scan LiDAR d'une pièce → plan 2D coté → correction des dimensions (V3)

*Hugo scanne la future salle de bain avec un iPhone Pro.*

1. **Scan & Plans** → « Scanner une pièce » : vérification de la
   compatibilité LiDAR (sinon, proposition du mode manuel — jamais
   d'impasse), rappel du quota (3 scans/mois en Gratuit).
2. **Capture RoomPlan** : guidage temps réel (balayer les murs, ouvertures
   détectées), possibilité de reprendre une zone.
3. **Génération du plan 2D coté** : murs, portes, fenêtres, surface
   calculée ; rattachement à la pièce et à l'étage.
4. **Correction des dimensions** : chaque cote est éditable au clavier ;
   les murs se réajustent ; l'original du scan est conservé (la correction
   ne détruit rien).
5. Enregistrement dans `RoomScan`/`FloorPlan` ; le plan devient annotable
   (Apple Pencil sur iPad) et exportable en PDF.

**Écrans** : Scan & Plans → Pré-scan → Capture AR → Aperçu du plan →
Édition des cotes → Plan enregistré.
**Frictions évitées** : pas d'échec silencieux (reprise de capture
possible) ; le mode manuel reste accessible à tout moment.
**Garde-fou canonique** : avertissement **systématique** — « Vérifiez les
mesures avant toute commande de matériaux » (§8).

## F. Invitation d'un conjoint, puis d'un professionnel à rôle restreint

1. **Membres du logement** → « Inviter » : Hugo invite Camille avec le rôle
   `Co-gestionnaire` (`editor`). Envoi par lien/e-mail ; Camille accepte via
   Sign in with Apple et voit tout le logement.
2. Plus tard, invitation de Claire (architecte) : choix du rôle
   **`Professionnel`**, sélection du **périmètre** — uniquement le projet
   « Rénovation de la cuisine ».
3. **Écran récapitulatif de l'invitation** : liste explicite de ce que
   Claire verra (tâches, photos, documents du projet, commentaires) et de
   ce qu'elle **ne verra pas** (budget global, autres projets, coffre-fort,
   documents sensibles).
4. Claire accepte ; côté client, son interface est réduite au projet.
   Toute contribution (document déposé, commentaire) est tracée dans le
   journal d'activité.
5. Révocation possible à tout moment, en un geste, avec effet immédiat.

**Écrans** : Réglages du logement → Membres → Nouvelle invitation → Choix
du rôle → Récapitulatif des accès → Liste des membres.
**Frictions évitées** : l'invité n'a pas besoin d'abonnement ; parcours
d'acceptation en deux minutes.
**Garde-fous canoniques** : le rôle `professional` n'accède **jamais** aux
données financières globales ni aux documents sensibles (§5) ; le
récapitulatif des accès est montré *avant* l'envoi.

## G. Suivi photo avant / pendant / après

1. Depuis la fiche pièce ou la fiche projet : **« Ajouter des photos »**,
   avec étiquette de phase : `Avant` / `Pendant` / `Après`.
2. Chaque photo est datée, rattachée à la pièce et au projet, légendable.
3. **Vue chronologique** par pièce : frise temporelle des photos, filtre
   par phase.
4. **Vue comparaison** : deux photos côte à côte (avant/après) avec curseur
   de balayage — partageable en image, exportable dans le dossier du
   logement.
5. Sur Mac : import massif par glisser-déposer, classement assisté par
   date et par pièce (proposition à valider, jamais automatique).

**Écrans** : Fiche pièce/projet → Capture ou import → Galerie du projet →
Comparaison avant/après.
**Frictions évitées** : les photos ne se perdent plus dans la pellicule ;
la comparaison ne demande aucun montage manuel.
**Garde-fous** : métadonnées de date préservées (valeur de preuve) ;
suppression = corbeille 30 jours ; photos jamais publiques.

## H. Passage au Premium — paywall contextuel non agressif

1. **Déclencheur contextuel** : Camille crée un **4ᵉ projet actif** (limite
   Gratuit : 3). Écran Premium présenté **à ce moment-là**, jamais à froid.
2. Le paywall rappelle ce que l'utilisateur essaie de faire (« Pour suivre
   un 4ᵉ projet… »), présente les 3 offres canoniques (4,99 €/mois,
   39,99 €/an « 2 mois offerts », Famille 59,99 €/an), l'essai de 14 jours,
   et — en clair — la règle : **« Si vous arrêtez, vous gardez la lecture
   et l'export de toutes vos données, à vie. »**
3. Alternatives toujours visibles : « Plus tard » (retour sans pénalité) et
   « Archiver un projet terminé » (rester en Gratuit).
4. Achat via StoreKit 2, confirmation, retour direct à l'action initiale :
   le 4ᵉ projet se crée.

**Écrans** : action bloquée → Paywall → feuille d'achat App Store →
confirmation → reprise de l'action.
**Frictions évitées** : jamais de compte à rebours, de dark pattern ni de
paywall plein écran au lancement ; le refus n'est jamais re-sollicité dans
la même session.
**Garde-fous canoniques** : plafonds et prix de `00-fondations.md` §6 ; la
publicité du niveau Gratuit n'apparaît jamais dans le coffre-fort, sur une
facture, pendant un scan, sur un écran financier ni pendant une action
critique.

## I. Export du « dossier numérique du logement » à la vente

*Sofiane vend un appartement ; Bernard prépare une transmission.*

1. **Fiche logement** (ou Réglages) → **« Exporter le dossier du
   logement »**, de préférence sur Mac.
2. **Choix du contenu** par sections cochables : documents administratifs,
   diagnostics, historique des travaux (projets + dépenses), factures et
   garanties, plans, photos avant/après, équipements et carnet d'entretien.
3. **Contrôle de confidentialité** : les éléments marqués sensibles ou
   personnels sont **exclus par défaut** ; écran de relecture avant
   génération.
4. Génération : archive structurée (PDF de synthèse + dossiers de pièces
   jointes), avec sommaire daté. Partage par fichier — **jamais** par lien
   public permanent.
5. L'export est journalisé (journal d'activité) ; le logement d'origine
   reste intact.

**Écrans** : Fiche logement → Export du dossier → Sélection du contenu →
Relecture → Progression → Partage.
**Frictions évitées** : plus de week-ends à reconstituer un classeur pour
le notaire ou l'acheteur.
**Garde-fous** : export disponible **même après expiration de
l'abonnement** (lecture et export garantis à vie, §6) ; documents privés
jamais exposés par URL publique (§8).

## J. Rappel d'entretien chaudière → tâche accomplie

1. À la création de l'équipement « Chaudière » (parcours équipements),
   Habit Plan a proposé une tâche d'entretien récurrente : « Révision
   annuelle » (obligation d'entretien), échéance chaque automne.
2. **J-30** : notification discrète + badge Ambre sur le tableau de bord
   (« Entretien à prévoir »).
3. Nadia ouvre la tâche : fiche équipement accessible (modèle, notice),
   dernier intervenant (Plomberie Costa) proposé en un tap pour reprise de
   contact.
4. Après l'intervention : **« Marquer comme fait »**, avec ajout facultatif
   de l'attestation d'entretien (scan → validation OCR → coffre-fort) et de
   la dépense associée.
5. La tâche passe en Sauge (fait), s'archive dans l'**historique
   d'entretien** de l'équipement, et la prochaine occurrence se programme
   automatiquement (modifiable).

**Écrans** : Notification → Fiche tâche d'entretien → Fiche équipement →
(Scan/Validation) → Confirmation → Historique d'entretien.
**Frictions évitées** : plus d'oubli d'entretien obligatoire ; la preuve
d'entretien (utile pour assurance et garantie) est rangée d'office.
**Garde-fous** : rappels réglables ou désactivables par tâche ; le report
d'une échéance n'est jamais culpabilisé (ton : rassurant, jamais
moralisateur — cf. [`05-identite-visuelle.md`](05-identite-visuelle.md)).

---

## Règles transverses aux parcours

- **Validation humaine partout** : OCR, classements proposés, cotes de
  scan — l'app propose, l'utilisateur dispose (§8).
- **Offline-first** : tous les parcours de saisie (A, B, G, J) fonctionnent
  sans réseau ; l'état de synchronisation est toujours visible.
- **Statuts moteurs** : les parcours font avancer les statuts canoniques
  (projets, devis, factures) sans jamais les forcer à l'insu de
  l'utilisateur.
- **Réversibilité** : soft delete généralisé, corbeille 30 jours pour les
  documents, aucune action destructrice sans confirmation.
- **Monétisation au bon moment** : le Premium ne s'interpose que lorsqu'une
  limite réelle est atteinte (H), jamais au milieu d'un scan, d'un paiement
  ou d'une urgence.
