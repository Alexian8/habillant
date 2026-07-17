# Habit Plan — 11. Sécurité et conformité RGPD

> Document détaillé des volets « Authentification », « Sauvegardes/audit »
> et garde-fous de `00-fondations.md` §3 et §8. En cas de divergence,
> `00-fondations.md` prévaut. Habit Plan héberge des données sensibles
> (factures, budgets, documents de propriété) : la sécurité est un
> prérequis produit, pas une option.

---

## 1. Transport

- **TLS 1.3** exigé sur toutes les connexions (API `/v1`, WebSocket,
  S3 présigné) ; TLS < 1.2 refusé, suites de chiffrement modernes
  uniquement, HSTS activé côté serveur.
- **Certificate pinning côté app** : épinglage des clés publiques (SPKI)
  de l'API avec clé de secours pré-provisionnée pour permettre la rotation
  sans mise à jour de l'app. Échec d'épinglage = connexion refusée, jamais
  de repli silencieux en clair ou non épinglé.
- ATS (App Transport Security) sans exception dans l'app.

## 2. Authentification

- **Sign in with Apple** (méthode mise en avant) et **e-mail + mot de
  passe** haché **Argon2id** (paramètres mémoire/itérations revus
  annuellement ; jamais de mot de passe en clair, ni en logs).
- **JWT d'accès de 15 minutes** + **refresh token rotatif** : chaque
  rafraîchissement invalide le précédent et en émet un nouveau. La
  **réutilisation d'un refresh token déjà consommé** est détectée comme un
  vol présumé → révocation immédiate de toute la famille de tokens et
  notification à l'utilisateur.
- **Passkeys (WebAuthn)** prévues en **V2+** (canonique §3) — l'API
  d'authentification est conçue pour les accueillir sans refonte.
- **Limitation des tentatives + verrouillage progressif** : délais
  croissants après échecs (1 s, 5 s, 30 s, 5 min…), verrouillage temporaire
  au-delà, déblocage par e-mail. Compteurs par compte **et** par IP ;
  réponses identiques que le compte existe ou non (pas d'énumération).
- Réinitialisation de mot de passe par lien à usage unique, courte durée ;
  toute modification d'identifiants notifie tous les appareils du compte.

## 3. Appareils

- **Registre d'appareils** (entité `Device`) : chaque installation est
  enregistrée (modèle, nom, plateforme, dernière activité) et liée à sa
  famille de refresh tokens.
- **Révocation à distance** : depuis Réglages → Appareils, l'utilisateur
  déconnecte n'importe quel appareil ; ses tokens sont invalidés à la
  prochaine requête et son cache local est purgé au prochain lancement.
- **Journal des connexions consultable** : connexions, rafraîchissements
  suspects, révocations — avec date, appareil et localisation approximative
  (pays/ville, jamais stockée en précision GPS).

## 4. Autorisation

- Contrôle **par logement ET par rôle à chaque requête** : toute route
  vérifie que l'utilisateur est membre (`PropertyMember`) du logement
  concerné **et** que son rôle (§5 des fondations : `owner`, `editor`,
  `contributor`, `viewer`, `professional`) autorise l'opération. Le rôle
  `professional` n'accède qu'au projet auquel il est rattaché — jamais aux
  données financières globales ni aux documents sensibles (canonique).
- **Protection IDOR systématique** : aucune ressource n'est servie sur la
  seule foi de son UUID ; chaque requête refait la jointure
  ressource → logement → membre. Les UUID v7 ne sont pas des secrets.
- **Tests d'isolation entre comptes** dans la CI : suite de tests
  automatisés qui tente d'accéder aux données d'un compte B avec les
  jetons d'un compte A sur chaque famille de routes ; toute régression
  bloque le déploiement.
- Réponse `404` (et non `403`) pour une ressource d'autrui : ne pas révéler
  l'existence d'une donnée.

## 5. Fichiers

- **Aucune URL publique permanente** vers un document privé (garde-fou
  canonique §8). Buckets S3 privés, aucun objet en accès anonyme.
- Accès par **liens présignés de 15 minutes**, générés à la demande après
  contrôle d'autorisation (§4), **à usage unique de préférence** (jeton
  applicatif consommé au premier téléchargement ; à défaut, portée
  restreinte à l'objet exact + durée courte). Jamais de lien présigné
  en clair dans les logs.
- **Scan antivirus à l'upload** : chaque binaire transite par une file
  d'analyse (worker dédié) avant d'être marqué disponible ; fichier
  détecté = quarantaine, jamais distribué aux autres appareils, propriétaire
  averti. Types MIME et tailles validés côté serveur.

## 6. Chiffrement au repos et secrets

- **Disques serveurs chiffrés** (base PostgreSQL, Redis, volumes).
- **SSE sur S3** pour tous les objets, sauvegardes comprises
  (`10-stockage.md` §2.4 et §4).
- **Clés gérées par KMS** (service de gestion de clés du fournisseur UE) :
  rotation planifiée, séparation des clés production/sauvegardes.
- **Secrets en coffre** (Vault ou équivalent) : identifiants base de
  données, clés S3, clés APNs, secrets JWT — jamais dans le dépôt, jamais
  en variable d'environnement en clair dans les images, accès journalisé.
- Sur l'appareil : protection de fichiers système pour la base SQLite et
  le cache (`10-stockage.md` §3.1) ; jetons dans le **trousseau** (Keychain),
  jamais dans `UserDefaults`.

## 7. RGPD

### 7.1 Socle

- **Hébergement UE uniquement** (canonique §3) : Scaleway Paris ou OVHcloud
  Gravelines ; aucun transfert hors UE de données personnelles.
- **DPA signé avec chaque sous-traitant** (hébergeur, stockage objet,
  e-mailing transactionnel, régie publicitaire) ; liste des sous-traitants
  publiée et tenue à jour.
- **Registre des traitements** tenu (art. 30) : finalité, base légale,
  catégories de données, durées, destinataires, mesures de sécurité.

### 7.2 Bases légales par traitement (extrait du registre)

| Traitement | Base légale |
|---|---|
| Compte, sync, stockage des documents | Exécution du contrat |
| Registre d'appareils, journal de connexions, anti-abus | Intérêt légitime (sécurité) |
| **OCR côté serveur** | **Consentement explicite** |
| **Fonctions d'analyse (résumé, comparaison de devis)** | **Consentement explicite** |
| Notifications d'échéances | Exécution du contrat (désactivables) |
| Publicité (offre Gratuit) | Consentement (ATT) / intérêt légitime pour la pub non ciblée |
| Facturation, obligations comptables | Obligation légale |

### 7.3 Consentements OCR et IA — règles canoniques

- Consentement **EXPLICITE, séparé et granulaire** : un interrupteur pour
  l'OCR serveur, un autre pour les fonctions d'analyse — jamais de case
  pré-cochée, jamais de consentement groupé dans les CGU.
- L'application reste **pleinement utilisable sans** ces consentements :
  l'OCR embarqué (Vision, sur l'appareil) fonctionne toujours ; seuls les
  traitements côté serveur sont conditionnés.
- **Aucun document privé ne sert à entraîner un modèle** (garde-fou
  canonique §8) : les documents envoyés pour analyse sont traités pour la
  seule restitution à l'utilisateur, puis les copies de travail sont
  supprimées. Toute donnée extraite reste soumise à validation utilisateur.
- Retrait du consentement aussi simple que son octroi, effet immédiat.

### 7.4 Minimisation et durées

- On ne collecte que le nécessaire : pas de position GPS stockée, pas de
  carnet d'adresses importé sans action explicite, analytics agrégées et
  sans identifiant publicitaire par défaut.
- Durées : corbeille documents 30 j ; purge 30 j après suppression de
  logement ou de compte ; journaux techniques 12 mois max ; sauvegardes
  30 j (les données purgées disparaissent des sauvegardes à l'expiration
  de cette rétention).

### 7.5 Droits des personnes

- **Accès / rectification** : directement dans l'app (toutes les données
  sont éditables ou consultables).
- **Portabilité** : export complet **self-service** — l'archive ZIP
  structurée de `10-stockage.md` §6 (JSON machine-lisible + PDF), gratuite,
  sans passer par le support, abonnement actif ou non.
- **Effacement** : suppression de compte self-service dans l'app (exigence
  App Store), avec **purge définitive sous 30 jours** de la base, des
  objets S3 (toutes versions) et, à l'expiration de leur rétention, des
  sauvegardes. Confirmation envoyée à l'issue de la purge.
- Délai de réponse aux demandes non self-service : 30 jours max.

### 7.6 Violation de données

- **Notification à la CNIL sous 72 h** en cas de violation présentant un
  risque ; information des utilisateurs concernés sans retard injustifié
  si le risque est élevé. Procédure écrite, responsable identifié,
  chronologie consignée (voir §10).

## 8. Publicité (offre Gratuit)

- **SDK respectueux** : régie choisie pour sa conformité RGPD/ATT, formats
  natifs et discrets, pas de vidéo auto-jouée, pas de plein écran
  interstitiel surprise.
- **Jamais de publicité** sur les écrans listés en `00-fondations.md` §6 :
  coffre-fort, facture, scan en cours, écrans financiers, actions
  critiques. Application stricte, testée en UI tests.
- **Pas de tracking cross-app sans ATT** : sans consentement App Tracking
  Transparency, publicité contextuelle uniquement, aucun identifiant
  publicitaire transmis. Le refus d'ATT ne dégrade aucune fonctionnalité.
- Aucune donnée du contenu utilisateur (documents, montants, artisans)
  n'est transmise à la régie — le ciblage contextuel se limite à la
  catégorie d'écran non sensible.

## 9. Journal d'audit

- Entité `ActivityLog` (canonique §5) : **qui / quoi / quand, par
  logement** — création, modification, suppression, partage, export,
  changement de rôle, connexion d'un nouveau membre.
- **Visible par le propriétaire** (`owner`) du logement dans l'app :
  chronologie filtrable par membre, module et période. Les rôles non
  propriétaires voient leurs propres actions.
- Append-only côté serveur (aucune modification a posteriori), conservé
  pendant la vie du logement, inclus dans l'export.
- Journal d'administration distinct pour les actions internes (support,
  restauration), lui-même audité.

## 10. Plan de réponse à incident

1. **Détection** : alerte automatisée (supervision, taux d'erreurs,
   volumes d'accès anormaux, échec des contrôles d'isolation) ou
   signalement (utilisateur, chercheur — adresse `security@habitplan.app`
   publiée, avec politique de divulgation responsable).
2. **Qualification** (≤ 4 h) : gravité, périmètre, données concernées ;
   désignation d'un responsable d'incident unique.
3. **Confinement** : révocation des jetons et clés compromis, isolation
   des systèmes touchés, blocage des accès suspects ; la coupure d'un
   service prime sur sa disponibilité en cas de fuite active.
4. **Éradication et récupération** : correctif, restauration éventuelle
   (RPO 15 min / RTO 4 h, `10-stockage.md` §4), rotation des secrets.
5. **Notification** : CNIL sous 72 h si requis (§7.6), utilisateurs
   concernés, transparence sur la nature des données touchées.
6. **Post-mortem** sous 7 jours : chronologie, causes racines, actions
   correctives datées et suivies ; exercice de simulation annuel.

---

*Voir aussi : `09-synchronisation.md` (états d'erreur, appareils),
`10-stockage.md` (chiffrement des sauvegardes, export) et
`12-modele-economique.md` (principes publicitaires).*
