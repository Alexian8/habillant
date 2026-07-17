# Habit Plan — 08 · API `/v1` — Endpoints

> Contrat de l'API REST servie par Vapor (`06-architecture-technique.md`).
> Les ressources et rôles renvoient à `07-modele-de-donnees.md` ; le
> protocole de sync est détaillé dans `09-synchronisation.md`.

---

## 1. Conventions

- **Format** : JSON UTF-8, clés **camelCase**, dates ISO 8601 UTC,
  identifiants **UUID v7 générés côté client** (le serveur les accepte à la
  création), montants en **centimes** (`amountHT`/`amountVAT`/`amountTTC`),
  TVA en `vatRateBps`.
- **Versionnage** : préfixe d'URL `/v1`. Changements rétrocompatibles
  (champs ajoutés) sans nouvelle version ; rupture → `/v2` avec période de
  recouvrement. Le client envoie `User-Agent: HabitPlan/{version}`.
- **Auth** : `Authorization: Bearer <JWT>` (15 min) sauf routes `/v1/auth/*`.
- **Pagination par curseur** : `?limit=50&cursor=<opaque>` ; réponse
  `{"items":[...],"nextCursor":"..."|null}`. Jamais de pagination par offset.
- **Erreurs — RFC 7807** (`application/problem+json`) :

```json
{
  "type": "https://api.habitplan.app/problems/quota-exceeded",
  "title": "Quota de stockage dépassé",
  "status": 402,
  "detail": "1,0 Go utilisé sur 1,0 Go. Passez à Premium ou libérez de l'espace.",
  "requestId": "018f7a10-2c3d-7e4f-a1b2-c3d4e5f60789"
}
```

- **Idempotence** : tout `POST` de création accepte `Idempotency-Key: <uuid>`
  (posée automatiquement par le client). Rejeu sous 24 h → même réponse,
  aucune duplication. Les `PUT`/`PATCH`/`DELETE` sont naturellement
  idempotents.
- **Écritures concurrentes** : les `PATCH` portent `If-Match: <syncVersion>` ;
  décalage → `409` avec l'état serveur (même sémantique que le push de sync).
- **Suppression** : `DELETE` = soft delete (`deletedAt`), cf. `07` §5.
- **Limites** : rate limiting par utilisateur et par IP (strict sur
  `/v1/auth/*`) ; réponses `429` avec `Retry-After`.

## 2. Authentification et appareils

| Méthode | Chemin | Description |
|---|---|---|
| POST | `/v1/auth/apple` | Sign in with Apple : vérifie l'identityToken, crée le compte au premier passage → paire JWT + refresh token |
| POST | `/v1/auth/register` | Création par e-mail/mot de passe (Argon2id) ; envoie l'e-mail de vérification |
| POST | `/v1/auth/login` | Connexion e-mail/mot de passe (limitation de tentatives) |
| POST | `/v1/auth/refresh` | Échange le refresh token **rotatif** ; réutilisation détectée → révocation de la famille |
| POST | `/v1/auth/logout` | Révoque le refresh token courant (et le `Device` si fourni) |
| GET | `/v1/devices` | Liste des appareils du compte |
| POST | `/v1/devices` | Enregistre/actualise l'appareil courant (`apnsToken`, modèle, OS) |
| DELETE | `/v1/devices/{id}` | Révoque un appareil (déconnexion à distance) |
| GET | `/v1/me` | Profil courant, consentements, usage stockage |
| PATCH | `/v1/me` | Mise à jour du profil (`displayName`, `locale`, `analysisConsentAt`) |

## 3. Ressources — CRUD

Schéma général : collections **imbriquées sous le logement** pour le listage
et la création, ressources **plates** pour l'accès individuel :
`GET/POST /v1/properties/{propertyId}/expenses` puis
`GET/PATCH/DELETE /v1/expenses/{id}`. « Rôle minimal » = rôle requis sur le
logement (matrice complète : `07-modele-de-donnees.md` §4 ; `professional`
limité à son `scopeProjectId`).

### 3.1 Logements et membres

| Méthode | Chemin | Description | Rôle minimal |
|---|---|---|---|
| GET | `/v1/properties` | Logements accessibles à l'utilisateur | — (authentifié) |
| POST | `/v1/properties` | Crée un logement (l'appelant devient `owner`) | — |
| GET / PATCH | `/v1/properties/{id}` | Détail / mise à jour | viewer / editor |
| DELETE | `/v1/properties/{id}` | Suppression confirmée → purge différée 30 j | owner |
| POST | `/v1/properties/{id}/restore` | Restauration avant purge | owner |
| GET | `/v1/properties/{id}/members` | Membres et invitations | viewer |
| POST | `/v1/properties/{id}/members` | Invitation par e-mail (`role`, `scopeProjectId` si `professional`) | editor |
| PATCH | `/v1/members/{id}` | Changement de rôle / périmètre | editor (owner pour toucher un owner) |
| DELETE | `/v1/members/{id}` | Révocation (`status=revoked`) | editor |
| POST | `/v1/invitations/{token}/accept` | Acceptation d'une invitation | — (authentifié) |

### 3.2 Structure, travaux, finances, annuaire, équipements

| Méthode | Chemin | Description | Rôle minimal |
|---|---|---|---|
| GET / POST | `/v1/properties/{id}/floors` · `/rooms` | Étages, pièces (liste plate `?floorId=` en option) | viewer / editor |
| GET / PATCH / DELETE | `/v1/floors/{id}` · `/v1/rooms/{id}` | Détail, édition, suppression | viewer / editor |
| GET / POST | `/v1/rooms/{id}/scans` | Scans LiDAR (quota 3/mois en gratuit) | viewer / editor |
| GET / POST | `/v1/floors/{id}/plans` | Plans d'étage (`FloorPlan`) | viewer / editor |
| GET / POST | `/v1/properties/{id}/projects` | Projets (filtre `?status=`) | viewer / editor |
| GET / PATCH / DELETE | `/v1/projects/{id}` | Détail, statut (12 canoniques), suppression (dépenses/factures détachées, cf. `07` §5) | viewer / editor |
| GET / POST | `/v1/projects/{id}/tasks` | Tâches du projet | viewer / contributor |
| GET / PATCH / DELETE | `/v1/tasks/{id}` | Détail, statut, assignation | viewer / contributor |
| GET / POST | `/v1/properties/{id}/expenses` | Dépenses (filtres `?projectId=&category=&from=&to=`) | viewer / contributor |
| GET / PATCH / DELETE | `/v1/expenses/{id}` | Détail, édition | viewer / contributor (les siennes) |
| GET / POST | `/v1/properties/{id}/payments` | Paiements (`expenseId` ou `invoiceId`) | viewer / contributor |
| GET / PATCH / DELETE | `/v1/payments/{id}` | Détail, édition | viewer / contributor |
| GET / POST | `/v1/projects/{id}/quotes` | Devis du projet | viewer / editor (`professional` : dépôt et lecture des siens) |
| GET / PATCH / DELETE | `/v1/quotes/{id}` | Détail, statut (`accepted`…) | viewer / editor |
| GET / POST | `/v1/properties/{id}/invoices` | Factures (filtres `?status=&projectId=`) | viewer / contributor |
| GET / PATCH / DELETE | `/v1/invoices/{id}` | Détail, statut, échéance | viewer / contributor |
| GET / POST | `/v1/properties/{id}/contractors` | Annuaire artisans | viewer / contributor |
| GET / PATCH / DELETE | `/v1/contractors/{id}` | Détail, notes privées, note 1–5 | viewer / contributor |
| GET / POST | `/v1/properties/{id}/contacts` | Contacts (`?contractorId=`) | viewer / contributor |
| GET / PATCH / DELETE | `/v1/contacts/{id}` | Détail | viewer / contributor |
| GET / POST | `/v1/properties/{id}/equipments` | Équipements (`?roomId=`) | viewer / contributor |
| GET / PATCH / DELETE | `/v1/equipments/{id}` | Détail | viewer / contributor |
| GET / POST | `/v1/equipments/{id}/warranties` | Garanties | viewer / contributor |
| GET / PATCH / DELETE | `/v1/warranties/{id}` | Détail | viewer / contributor |
| GET / POST | `/v1/properties/{id}/maintenance-tasks` | Entretien récurrent | viewer / contributor |
| GET / PATCH / DELETE | `/v1/maintenance-tasks/{id}` | Détail, `lastDoneAt` | viewer / contributor |
| GET / POST | `/v1/properties/{id}/reminders` | Rappels | viewer / contributor |
| GET / PATCH / DELETE | `/v1/reminders/{id}` | Détail, report (`snoozedUntil`) | viewer / contributor |
| GET / POST | `/v1/{targetType}/{id}/comments` | Commentaires d'une cible (projet, tâche, devis…) | viewer / contributor |
| PATCH / DELETE | `/v1/comments/{id}` | Édition / suppression (auteur, ou editor) | auteur |
| GET | `/v1/properties/{id}/activity` | Journal d'activité (pull seul, curseur) | viewer |
| GET | `/v1/notifications` | Notifications de l'utilisateur (`?unread=true`) | — |
| PATCH | `/v1/notifications/{id}` | Marquer lu (`readAt`) | — |
| POST | `/v1/notifications/read-all` | Tout marquer lu | — |

## 4. Documents et fichiers

Création **en deux temps** — l'API ne reçoit jamais les octets du fichier :

1. `POST /v1/documents` : métadonnées (`id` UUID v7 client, `propertyId`,
   `title`, `kind`, `sensitive`, `mimeType`, `fileSizeBytes`,
   `checksumSHA256`). Vérification du **quota** → `402` sinon. Réponse :
   document en `uploadStatus=pending` + **URL présignée S3 de PUT (15 min)**.
2. Le client téléverse directement sur S3 (tâche de fond, reprise possible).
3. `POST /v1/documents/{id}/complete` : le serveur vérifie taille et
   checksum, passe `uploadStatus=uploaded`, décompte le quota, met en file
   la miniature.

| Méthode | Chemin | Description | Rôle minimal |
|---|---|---|---|
| GET | `/v1/properties/{id}/documents` | Coffre-fort (filtres `?kind=&linkedTo=`) ; `sensitive` exclus pour `professional` | viewer |
| POST | `/v1/documents` | Étape 1 ci-dessus | contributor |
| POST | `/v1/documents/{id}/complete` | Étape 3 ci-dessus | contributor |
| GET | `/v1/documents/{id}` | Métadonnées + liens | viewer |
| GET | `/v1/documents/{id}/download` | **Lien présigné GET 15 min** (jamais d'URL publique permanente) | viewer |
| PATCH | `/v1/documents/{id}` | Titre, `kind`, `sensitive` | contributor |
| POST | `/v1/documents/{id}/versions` | Nouvelle version (mêmes 2 temps ; incrémente `currentVersion`) | contributor |
| GET | `/v1/documents/{id}/versions` | Historique ; `?version=` sur `/download` | viewer |
| DELETE | `/v1/documents/{id}` | Mise en **corbeille** (`trashedAt`) | contributor (auteur) / editor |
| GET | `/v1/properties/{id}/trash` | Corbeille 30 j | editor |
| POST | `/v1/documents/{id}/restore` | Restauration depuis la corbeille | editor |
| DELETE | `/v1/documents/{id}/purge` | Purge immédiate et définitive | editor |
| POST / DELETE | `/v1/documents/{id}/links` | Lier / délier (`targetType`, `targetId`) | contributor |
| GET / POST | `/v1/{ownerType}/{id}/photos` | Photos d'une cible (même flux en 2 temps) | viewer / contributor |
| DELETE | `/v1/photos/{id}` | Suppression | contributor (auteur) |

## 5. Synchronisation

| Méthode | Chemin | Description |
|---|---|---|
| POST | `/v1/sync/push` | Lot de changements locaux (max 200) ; réponse par changement : `applied` ou `conflict` |
| GET | `/v1/sync/pull?propertyId=&cursor=&limit=` | Delta incrémental (créations, modifications, **tombstones**) trié par `updatedAt` ; `cursor` opaque |
| GET | `/v1/sync/socket` | WebSocket : signal « logement modifié », sans donnée métier |

Conflit = `baseSyncVersion` du client ≠ `syncVersion` serveur → fusion
**LWW champ par champ**, jamais d'écrasement silencieux ; le client reçoit
l'état fusionné et le journalise (détail : `09-synchronisation.md`).

## 6. OCR / analyse (opt-in)

Préconditions : `analysisConsentAt` non nul sur le compte (consentement
explicite, `00-fondations.md` §8) et `uploadStatus=uploaded`.

| Méthode | Chemin | Description | Rôle minimal |
|---|---|---|---|
| POST | `/v1/documents/{id}/analyze` | Met en file l'analyse (OCR + extraction structurée). Réponse `202` + `jobId` | contributor |
| GET | `/v1/analysis/{jobId}` | État et résultat. Le résultat est **toujours une proposition à valider** — jamais appliqué automatiquement | contributor |
| POST | `/v1/analysis/{jobId}/apply` | Applique **les champs explicitement validés par l'utilisateur** (corps = sous-ensemble des propositions) | contributor |

## 7. Abonnements

| Méthode | Chemin | Description |
|---|---|---|
| POST | `/v1/subscriptions/app-store-notifications` | Webhook **App Store Server Notifications V2** (JWS vérifié) — source de vérité de l'entité `Subscription` |
| GET | `/v1/subscriptions/me` | Droits courants : offre, `expiresAt`, quotas (stockage, projets actifs, scans/mois) |
| POST | `/v1/subscriptions/refresh` | Re-vérification à la demande (après achat StoreKit 2 côté client) |

## 8. Exports et RGPD

| Méthode | Chemin | Description | Rôle minimal |
|---|---|---|---|
| POST | `/v1/exports` | Export asynchrone d'un logement (`propertyId`, `format`: `zip` documents + JSON, ou `pdf` synthèse) → `202` + id | editor |
| GET | `/v1/exports/{id}` | État ; une fois `done`, lien présigné 15 min | editor |
| POST | `/v1/account/export` | **Portabilité RGPD** : archive complète du compte (asynchrone, notifiée) | — |
| DELETE | `/v1/account` | **Effacement RGPD** : confirmation par mot de passe ou Apple ; purge différée 30 j (`07` §5) | — |

L'export reste disponible même après expiration de l'abonnement (lecture et
export garantis à vie).

---

## 9. Exemples

### 9.1 Création de dépense

`POST /v1/properties/018f7a10-.../expenses` · `Idempotency-Key: 018f7a11-9c2e-7b3a-8d4f-1a2b3c4d5e6f`

```json
{
  "id": "018f7a11-8b1d-7c2e-9f30-4a5b6c7d8e9f",
  "projectId": "018f7a0e-1111-7aaa-bbbb-cccccccccccc",
  "contractorId": "018f7a0e-2222-7aaa-bbbb-dddddddddddd",
  "label": "Carrelage sol cuisine — fourniture",
  "category": "materials",
  "amountHT": 128500,
  "amountVAT": 12850,
  "amountTTC": 141350,
  "vatRateBps": 1000,
  "currencyCode": "EUR",
  "expenseDate": "2026-07-02",
  "notes": "Livraison prévue semaine 29"
}
```

Réponse `201` : l'objet complet, enrichi des champs serveur
`"createdAt"`, `"updatedAt"`, `"syncVersion": 1`, `"deletedAt": null`.

### 9.2 Push de sync avec conflit

`POST /v1/sync/push`

```json
{
  "deviceId": "018f7a09-aaaa-7bbb-cccc-dddddddddddd",
  "changes": [
    {
      "entity": "expense",
      "op": "update",
      "id": "018f7a11-8b1d-7c2e-9f30-4a5b6c7d8e9f",
      "baseSyncVersion": 3,
      "fields": { "amountTTC": 152000, "amountHT": 138182, "amountVAT": 13818 },
      "clientUpdatedAt": "2026-07-16T18:42:10Z"
    },
    {
      "entity": "projectTask",
      "op": "update",
      "id": "018f7a12-3333-7aaa-bbbb-eeeeeeeeeeee",
      "baseSyncVersion": 7,
      "fields": { "status": "done", "completedAt": "2026-07-16T18:40:00Z" },
      "clientUpdatedAt": "2026-07-16T18:40:02Z"
    }
  ]
}
```

Réponse `200` — la première écriture était en retard d'une version (un autre
membre a modifié `notes` entre-temps) ; fusion LWW champ par champ, aucun
champ perdu :

```json
{
  "results": [
    {
      "id": "018f7a11-8b1d-7c2e-9f30-4a5b6c7d8e9f",
      "status": "conflict",
      "resolution": "mergedFieldByField",
      "server": {
        "syncVersion": 5,
        "updatedAt": "2026-07-16T18:42:11Z",
        "fields": {
          "amountTTC": 152000, "amountHT": 138182, "amountVAT": 13818,
          "notes": "Devis révisé reçu le 16/07"
        }
      }
    },
    { "id": "018f7a12-3333-7aaa-bbbb-eeeeeeeeeeee", "status": "applied", "syncVersion": 8 }
  ]
}
```

### 9.3 Résultat d'analyse OCR

`GET /v1/analysis/018f7a14-5555-7aaa-bbbb-ffffffffffff` → `200`

```json
{
  "jobId": "018f7a14-5555-7aaa-bbbb-ffffffffffff",
  "documentId": "018f7a13-4444-7aaa-bbbb-aaaaaaaaaaaa",
  "status": "done",
  "requiresValidation": true,
  "proposal": {
    "detectedKind": "invoice",
    "fields": {
      "contractorName": { "value": "Plomberie Costa", "confidence": 0.94, "matchedContractorId": "018f7a0e-2222-7aaa-bbbb-dddddddddddd" },
      "reference": { "value": "FAC-2026-0341", "confidence": 0.97 },
      "amountHT": { "value": 218182, "confidence": 0.91 },
      "amountVAT": { "value": 21818, "confidence": 0.90 },
      "amountTTC": { "value": 240000, "confidence": 0.95 },
      "vatRateBps": { "value": 1000, "confidence": 0.88 },
      "issuedDate": { "value": "2026-07-10", "confidence": 0.93 },
      "dueDate": { "value": "2026-08-09", "confidence": 0.85 }
    },
    "suggestedLinks": [
      { "targetType": "project", "targetId": "018f7a0e-1111-7aaa-bbbb-cccccccccccc", "reason": "contractorRecentQuotes" }
    ]
  }
}
```

Aucun de ces champs n'est écrit en base tant que l'utilisateur n'a pas
validé via `POST /v1/analysis/{jobId}/apply` — l'analyse **propose**,
l'utilisateur **décide** (`00-fondations.md` §8).

### 9.4 Erreur type (rôle insuffisant)

`GET /v1/properties/{id}/expenses` par un membre `professional` → `403`

```json
{
  "type": "https://api.habitplan.app/problems/role-forbidden",
  "title": "Accès refusé pour ce rôle",
  "status": 403,
  "detail": "Le rôle professional n'accède jamais aux données financières globales du logement.",
  "requestId": "018f7a15-6666-7aaa-bbbb-abcdefabcdef"
}
```
