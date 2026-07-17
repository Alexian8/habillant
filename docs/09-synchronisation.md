# Habit Plan — 09. Stratégie de synchronisation (offline-first)

> Document détaillé du volet « Synchronisation » résumé dans
> `00-fondations.md` §3. En cas de divergence, `00-fondations.md` prévaut.

---

## 1. Principes

1. **La base SQLite locale (GRDB) est la source de vérité de l'UI.**
   Chaque écran lit et écrit exclusivement dans la base locale. Le réseau
   est un mécanisme de convergence en arrière-plan, jamais un prérequis.
2. **Aucune opération utilisateur n'est bloquée par le réseau.** Créer un
   projet, saisir une dépense, joindre une facture, annoter un plan :
   tout fonctionne en avion, en cave, sur un chantier sans couverture.
3. **Toute écriture locale est journalisée** avant d'être poussée. Rien ne
   part au serveur sans trace locale ; rien n'est perdu si l'app est tuée.
4. **Jamais d'écrasement silencieux.** Un conflit produit soit une fusion
   déterministe, soit une copie de conflit visible — jamais une perte.
5. **La sync est observable.** L'utilisateur voit toujours l'état de ses
   données (voir §6) et la file d'attente des fichiers en cours d'envoi.

## 2. Schéma local

### 2.1 Tables miroirs

Chaque entité du modèle (les 27 entités de `00-fondations.md` §5) possède
une table SQLite miroir de la table PostgreSQL serveur, avec les colonnes
de sync communes :

| Colonne | Type | Rôle |
|---|---|---|
| `id` | TEXT (UUID v7) | Identifiant généré côté client |
| `syncVersion` | INTEGER | Version serveur connue (0 = jamais poussé) |
| `updatedAt` | TEXT (ISO 8601 UTC) | Dernière modification, source de LWW |
| `deletedAt` | TEXT nullable | Soft delete (tombstone local) |
| `isDirty` | INTEGER (bool) | Modifié localement, en attente de push |

Les UUID v7 générés côté client garantissent qu'une entité créée hors
ligne a déjà son identifiant définitif : aucune étape de « réconciliation
d'ID » n'est nécessaire après le push.

### 2.2 Table `pending_changes` (journal des changements)

```sql
CREATE TABLE pending_changes (
  id           TEXT PRIMARY KEY,          -- UUID v7 du changement
  operation    TEXT NOT NULL,             -- 'create' | 'update' | 'delete'
  entityType   TEXT NOT NULL,             -- ex. 'Project', 'Invoice'
  entityId     TEXT NOT NULL,             -- UUID de l'entité concernée
  payload      TEXT NOT NULL,             -- JSON : champs modifiés uniquement
  attemptCount INTEGER NOT NULL DEFAULT 0,-- tentatives d'envoi
  createdAt    TEXT NOT NULL,             -- horodatage ISO 8601 UTC
  lastError    TEXT                       -- dernier message d'erreur, si échec
);
```

Règles du journal :

- Une écriture locale = une transaction SQLite qui modifie la table miroir
  **et** insère la ligne `pending_changes` (atomicité garantie).
- Les `update` successifs d'une même entité sont **coalescés** : les
  payloads sont fusionnés champ par champ, l'horodatage du plus récent
  est conservé. Un `create` suivi d'un `delete` hors ligne s'annule.
- Le `payload` ne contient que les **champs réellement modifiés** — c'est
  la granularité qui permet la fusion champ par champ côté serveur.
- Après acquittement serveur, la ligne est supprimée et `isDirty` retombe
  à faux ; `syncVersion` est mis à jour avec la valeur renvoyée.

## 3. Cycle de synchronisation

### 3.1 Déclencheurs

| Déclencheur | Détail |
|---|---|
| App active | Au passage au premier plan (`scenePhase == .active`) |
| WebSocket | Notification de sync poussée par le serveur (« un autre appareil a écrit ») |
| Push silencieux | APNs `content-available` quand le WebSocket est fermé (app en arrière-plan) |
| Timer | Filet de sécurité périodique (toutes les 15 min app ouverte) |
| Écriture locale | Débouncé quelques secondes après une modification, si réseau disponible |
| Retour du réseau | Reprise immédiate quand la connectivité revient |

### 3.2 Push — par lots ordonnés

1. Lecture de `pending_changes` **dans l'ordre de création** (les UUID v7
   sont triables chronologiquement), regroupée en lots (max. 100 changements
   ou 1 Mo de payload).
2. L'ordre respecte les **dépendances d'entités** : un `Project` est poussé
   avant ses `ProjectTask`, une `Invoice` avant ses `Payment`, un
   `Document` (métadonnées) avant son fichier binaire.
3. Chaque lot est envoyé sur `POST /v1/sync/push`. La requête est
   **idempotente** : l'identifiant du changement sert de clé
   d'idempotence, un lot rejoué après timeout n'est jamais appliqué deux fois.
4. Réponse serveur, par changement : `applied` (avec nouveau `syncVersion`),
   `merged` (fusion effectuée, état résultant renvoyé) ou `conflict`
   (traité selon §4).

### 3.3 Pull — incrémental par curseur

1. Le client conserve un curseur `updated_since` **par logement** (horodatage
   serveur du dernier pull réussi, jamais l'horloge du client).
2. `GET /v1/sync/pull?updated_since=…` renvoie les entités modifiées,
   les tombstones, et un nouveau curseur ; la réponse est paginée.
3. Les entités reçues sont appliquées en transaction dans les tables
   miroirs ; si une entité reçue est aussi `isDirty` localement, la
   résolution de conflit du §4 s'applique **avant** écriture.
4. Le pull suit toujours le push dans un même cycle : on pousse d'abord
   ses changements, puis on récupère l'état du monde.

## 4. Résolution de conflits

### 4.1 Détection

Un conflit existe quand un changement poussé référence un `syncVersion`
inférieur à la version serveur courante : quelqu'un d'autre (ou un autre
appareil) a écrit entre-temps. La comparaison des `updatedAt` sert ensuite
d'arbitre pour la fusion.

### 4.2 Entités structurées — fusion LWW champ par champ

- La fusion se fait **champ par champ**, pas entité par entité : si
  l'appareil A modifie le budget d'un projet et l'appareil B son statut,
  les deux changements sont conservés.
- Pour un même champ modifié des deux côtés : **Last-Writer-Wins** sur
  `updatedAt` du champ (horodatage du changement, en UTC). L'écriture la
  plus récente gagne, la valeur perdante est archivée dans l'historique
  des versions de l'entité — elle reste récupérable.
- Les champs financiers (`amountHT`, `amountVAT`, `amountTTC`) sont fusionnés
  comme un **groupe atomique** : on ne mélange jamais le HT d'une écriture
  avec le TTC d'une autre.

### 4.3 Fichiers binaires — copie de conflit

Un fichier binaire (PDF, photo, scan) ne se fusionne pas. Si deux versions
divergentes du même document existent, le serveur conserve les deux :

- la version la plus récente devient la version courante ;
- l'autre est enregistrée comme document frère nommé
  **« Facture (copie de conflit du 12/03) »** — libellé localisé, date du
  jour du conflit — placée au même endroit, signalée à l'utilisateur ;
- l'utilisateur compare puis supprime, conserve ou fusionne manuellement.

### 4.4 Suppressions — tombstones

- Toute suppression est un **soft delete** (`deletedAt`) propagé comme
  tombstone ; les tombstones sont conservés côté serveur au moins 90 jours
  pour que les appareils longtemps hors ligne convergent correctement.
- Conflit suppression/modification : la **modification gagne** — une entité
  modifiée après sa suppression par un autre appareil est restaurée, et
  l'utilisateur qui avait supprimé en est informé. On ne perd jamais une
  saisie au profit d'une corbeille.

### 4.5 Règle absolue

**Jamais d'écrasement silencieux.** Toute valeur écartée par une fusion est
consignée dans l'historique des versions de l'entité (visible dans la fiche,
« Historique ») et peut être restaurée. Un conflit de fichier produit
toujours une copie visible, jamais un remplacement muet.

## 5. Fichiers (upload différé)

1. À l'ajout d'un document, les **métadonnées** partent dans
   `pending_changes` ; le binaire est copié dans le cache local chiffré
   (voir `10-stockage.md`) et inscrit dans une **file d'upload** dédiée.
2. L'envoi passe par **URL présignées** (validité 15 min) obtenues auprès de
   l'API — l'app ne détient aucun identifiant S3.
3. Au-delà de 8 Mo, l'envoi est **multipart** : chaque partie acquittée est
   définitivement acquise, une coupure réseau ne fait reprendre que les
   parties manquantes (reprise après coupure, y compris après relance de
   l'app).
4. La **file d'attente est visible** : écran « Envois en cours » listant
   chaque fichier, sa progression, son état, avec pause/reprise/annulation.
   Les envois utilisent `URLSession` en tâche de fond pour continuer app
   fermée.
5. Un document dont le binaire n'est pas encore envoyé est pleinement
   utilisable localement ; les autres appareils voient ses métadonnées avec
   l'état « fichier en attente ».

## 6. États UI (canoniques)

| État | Icône (SF Symbols) | Signification | Comportement |
|---|---|---|---|
| Synchronisé | `checkmark.icloud` (Vert Sauge) | Local = serveur | Aucun ; état par défaut, discret |
| Synchronisation en cours | `arrow.triangle.2.circlepath.icloud` (animée, Bleu Ardoise) | Push ou pull actif | Indicateur non bloquant dans la barre |
| Disponible hors ligne | `arrow.down.circle.fill` (Bleu Ardoise) | Binaire présent dans le cache local | Ouvrable sans réseau, badgé sur la vignette |
| Erreur | `exclamationmark.icloud` (Brique `hpDanger`) | Échec après épuisement des retries | Bandeau explicite + action « Réessayer » |
| Fichier en attente | `clock.arrow.circlepath` (Ambre `hpAmber`) | Binaire en file d'upload | Progression visible, pause/reprise |

Retry : **backoff exponentiel avec jitter** — 2 s, 4 s, 8 s… plafonné à
15 min, `attemptCount` incrémenté à chaque tentative. Les erreurs réseau
(timeout, 5xx) sont retentées indéfiniment ; les erreurs métier (4xx :
validation, quota, autorisation) arrêtent le retry et affichent l'état
**Erreur** avec un message actionnable. Aucun retry en arrière-plan sur
réseau cellulaire pour les gros fichiers si l'option « Wi-Fi uniquement »
est activée.

## 7. Cas limites

### 7.1 Changement d'appareil

Nouvel appareil = **bootstrap** : pull complet des métadonnées du compte
(curseur à zéro), puis téléchargement des binaires à la demande et des
favoris marqués « garder hors ligne ». Aucune donnée ne dépend de
l'ancien appareil — tout état durable vit au serveur une fois synchronisé.
L'ancien appareil peut être révoqué depuis le registre d'appareils.

### 7.2 Restauration de sauvegarde (iCloud/iTunes)

Une restauration peut ramener une base locale **ancienne** avec des
`pending_changes` déjà appliqués. Protections :

- l'idempotence du push (clé = id du changement) rend leur rejeu inoffensif ;
- au premier lancement post-restauration (identifiant d'installation
  différent), l'app force un pull complet avant tout push, et tout
  changement local plus ancien que la version serveur passe par la
  résolution de conflit normale — jamais d'écrasement d'un état plus récent.

### 7.3 Deux appareils hors ligne longtemps sur le même compte

Chacun accumule son journal local. À la reconnexion, le premier pousse
normalement ; le second déclenche la mécanique complète du §4 : fusion
champ par champ pour les entités, copies de conflit pour les binaires,
tombstones arbitrés. Si l'absence dépasse la rétention des tombstones
(90 j), le client effectue un pull complet de réconciliation au lieu du
pull incrémental. Résultat garanti : convergence des deux appareils sans
perte, avec au pire des copies de conflit à trier.

### 7.4 Quota de stockage dépassé

Le push des **métadonnées n'est jamais bloqué** par le quota — seuls les
binaires le sont. Un upload refusé pour quota (voir `10-stockage.md` §2.5)
place le fichier en état **Erreur** avec message explicite : « Espace
insuffisant — libérez de l'espace ou passez Premium ». Le fichier reste
intact dans le cache local, la file est mise en pause pour les binaires,
et reprend automatiquement dès que de l'espace se libère ou que l'offre
change. Aucune donnée locale n'est supprimée d'office.

---

*Voir aussi : `10-stockage.md` (cache local, quotas, versioning S3) et
`11-securite-rgpd.md` (URL présignées, chiffrement).*
