# Habit Plan — 12. Modèle économique

> Document détaillé du volet « Modèle économique » de `00-fondations.md`
> §6, dont les chiffres sont **canoniques**. En cas de divergence,
> `00-fondations.md` prévaut.

---

## 1. Offres et prix (canoniques)

| Offre | Prix | Contenu clé |
|---|---|---|
| **Gratuit** | 0 € | 1 logement, 3 projets actifs, 1 Go, 3 scans LiDAR/mois, pub discrète |
| **Premium mensuel** | 4,99 €/mois | Tout illimité\*, 50 Go, sans pub |
| **Premium annuel** | 39,99 €/an | Idem + 2 mois offerts |
| **Famille** | 59,99 €/an | Partage familial Apple (jusqu'à 6 personnes) |

- **Essai gratuit de 14 jours** sur toutes les formules Premium, sans
  engagement, annulable à tout moment via l'App Store.
- \*Scans LiDAR : usage raisonnable — **50/mois** (canonique).
- Après expiration de l'abonnement : **lecture et export garantis à vie**
  (voir §7).

## 2. Limites Gratuit vs Premium (détail)

| Capacité | Gratuit | Premium / Famille |
|---|---|---|
| Logements | 1 | Illimités |
| Projets **actifs** | 3 (les projets `done`/`cancelled` ne comptent pas) | Illimités |
| Stockage | 1 Go (compteur visible, `10-stockage.md` §2.5) | 50 Go |
| Scans LiDAR (RoomPlan) | 3/mois | 50/mois (usage raisonnable) |
| OCR | Embarqué (Vision, sur l'appareil) | Embarqué + OCR serveur amélioré (sur consentement, `11-securite-rgpd.md` §7.3) |
| Comparaison IA de devis | — | Incluse (résume, compare, signale — ne choisit jamais, canonique §8) |
| Exports | Export complet ZIP **toujours gratuit** (droit, pas une option) | Idem + exports PDF de synthèse enrichis (dossier projet, rapport budget) |
| Collaboration | Propriétaire + 1 invité en lecture seule | Tous les rôles (`editor`, `contributor`, `viewer`, `professional`), membres illimités |
| Historique | Versions et journal d'activité sur 30 jours | Historique complet illimité |
| Recherche intelligente | Recherche simple (titres, catégories) | Recherche plein texte dans les documents (contenu OCR), filtres avancés |
| Support | Base de connaissances | Support prioritaire par e-mail |
| Publicité | Discrète et native (§3) | Aucune |

Règle transverse : une limite atteinte **plafonne la création**, jamais
l'accès. Les données existantes restent lisibles, modifiables et
exportables (voir §4).

## 3. Principes publicitaires (offre Gratuit)

- **Discrète et native** : encarts intégrés au flux (une carte sobre dans
  une liste), jamais d'interstitiel plein écran, jamais de vidéo
  auto-jouée, jamais de bandeau permanent.
- **Jamais de publicité** — liste canonique de `00-fondations.md` §6 :
  dans le **coffre-fort**, sur une **facture**, pendant un **scan**, sur un
  **écran financier**, pendant une **action critique** (paiement, suppression,
  export, partage).
- Pas de tracking cross-app sans consentement ATT ; aucune donnée du
  contenu utilisateur transmise à la régie (`11-securite-rgpd.md` §8).
- La publicité disparaît **immédiatement** à l'activation de l'essai ou de
  l'abonnement, et pendant toute sa durée.

## 4. Stratégie de conversion

### 4.1 Paywall contextuel, jamais punitif

- Le paywall apparaît **au moment où la limite est atteinte**, dans son
  contexte : à la création du 4ᵉ projet actif, du 4ᵉ scan du mois, du
  2ᵉ logement, au dépassement du 1 Go — avec le bénéfice concret mis en
  avant (« Passez Premium pour suivre tous vos chantiers »).
- **Jamais bloquant sur les données existantes** : atteindre une limite
  n'empêche ni de consulter, ni de modifier, ni d'exporter ce qui existe.
  On ne prend jamais les données de l'utilisateur en otage.
- Alternatives toujours proposées : archiver un projet terminé, libérer de
  l'espace — le paywall informe, il ne piège pas.
- Fréquence plafonnée : pas de rappel insistant, pas d'écran de vente au
  lancement de l'app.

### 4.2 Mécanique d'abonnement (StoreKit 2)

- **Achats intégrés uniquement**, gérés via **StoreKit 2** : produits
  auto-renouvelables, essai 14 j comme offre d'introduction, gestion et
  annulation via l'App Store.
- **Restauration d'achats** : bouton « Restaurer mes achats » toujours
  accessible (exigence App Store) ; vérification du statut via l'API
  StoreKit 2 à chaque lancement.
- **Synchronisation de l'abonnement entre appareils par le compte** :
  le statut vérifié est enregistré côté serveur (entité `Subscription`,
  notifications serveur App Store) et propagé par la sync — l'iPad et le
  Mac reflètent l'achat fait sur l'iPhone dès la prochaine sync, y compris
  quand les appareils n'utilisent pas le même identifiant Apple de
  téléchargement (cas du compte Habit Plan partagé).
- **Famille** : formule compatible partage familial Apple ; chaque membre
  du foyer bénéficie de Premium avec son propre compte Habit Plan.
- Périodes de grâce et incidents de facturation : statut « en attente de
  paiement » avec accès Premium maintenu pendant la période de grâce
  App Store, puis retour Gratuit sans perte de données.

## 5. Projections indicatives

> Chiffres **indicatifs** de cadrage, pas des engagements ; à recaler sur
> les données réelles après lancement.

- **Hypothèse de conversion** : 3 à 5 % des utilisateurs actifs mensuels
  vers Premium (fourchette habituelle des apps utilitaires freemium ;
  la valeur perçue — coffre-fort + suivi de chantier — vise le haut de la
  fourchette chez les utilisateurs en travaux).
- **ARPU abonnés** : mix estimé 60 % annuel / 30 % mensuel / 10 % Famille
  → ≈ 45 € bruts/abonné/an, soit ≈ 31 € nets après commission App Store
  (15 % via le programme petites entreprises, sinon 30 % la première année).
- **Saisonnalité travaux** : pics d'acquisition et de conversion au
  **printemps/été** (mars–juillet : devis, chantiers, emménagements) ;
  creux relatif en hiver, hors rebond de janvier (résolutions, projets de
  l'année). Les campagnes et les mises en avant de l'essai 14 j suivent
  cette saisonnalité.
- Leviers suivis : activation (1ᵉʳ projet + 1ᵉʳ document), déclencheurs de
  paywall les plus convertisseurs, rétention à 12 mois des abonnés annuels.

## 6. Conformité App Store

- **Achats intégrés uniquement** pour tout contenu numérique ; **aucun
  contournement** : pas de lien de paiement externe, pas de vente de
  l'abonnement hors App Store pour l'app (règles 3.1.x).
- **Mentions claires** avant l'achat : prix, durée, renouvellement
  automatique, conditions de l'essai (date de fin, facturation à échéance),
  liens CGU et politique de confidentialité sur l'écran d'achat.
- Suppression de compte self-service dans l'app, fiche « Confidentialité de
  l'app » (privacy labels) exacte et tenue à jour, formulaire ATT
  conforme (`11-securite-rgpd.md` §8).

## 7. Engagement de réversibilité

> Reprise de la garantie canonique (`00-fondations.md` §6 et
> `10-stockage.md` §6) : après expiration de l'abonnement, **la lecture et
> l'export complets restent gratuits à vie**. L'export ZIP structuré
> (JSON + PDF lisibles) est disponible en un geste, sans contact avec le
> support, quel que soit le statut d'abonnement. La confiance est le
> produit : personne ne paie sous la menace de perdre ses factures.

Concrètement, en repassant Gratuit : les logements, projets et documents
au-delà des limites restent consultables et exportables ; seule la
**création** au-delà des plafonds est suspendue (§2).

## 8. Pistes futures — explicitement hors périmètre

Non incluses au MVP ni planifiées dans une version datée ; documentées
pour cadrer les discussions :

- **Connexion bancaire en lecture seule** : opt-in strict, lecture seule,
  jamais au MVP (garde-fou canonique §8) — rapprochement automatique
  paiements/factures. N'entrera qu'avec un prestataire agréé DSP2 et une
  analyse d'impact préalable.
- **Place de marché d'artisans** : mise en relation éventuelle avec des
  artisans, **avec prudence** — l'app pourrait présenter des artisans
  pertinents, mais **ne choisit jamais un artisan à la place de
  l'utilisateur** (garde-fou canonique §8) : pas de classement opaque,
  pas d'attribution automatique, transparence totale sur toute mise en
  avant rémunérée si ce chantier s'ouvrait un jour.

Toute évolution de ces pistes devra d'abord être arbitrée dans
`00-fondations.md`.

---

*Voir aussi : `10-stockage.md` (quotas, export, garantie de récupération)
et `11-securite-rgpd.md` (publicité, consentements, ATT).*
