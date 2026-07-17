# Habit Plan — Risques techniques

> Document `15`. Se lit avec [`00-fondations.md`](00-fondations.md)
> (canonique), [`13-mvp.md`](13-mvp.md) et
> [`14-feuille-de-route.md`](14-feuille-de-route.md).
> Probabilité et impact : **F** (faible) · **M** (moyen) · **É** (élevé).
> Revue à chaque fin de trimestre (règle de pilotage, doc 14 §10).

---

## Synthèse

| # | Risque | Prob. | Impact | Version exposée |
|---|---|---|---|---|
| R1 | Précision et variabilité de RoomPlan | É | É | V3 |
| R2 | Complexité de la sync offline-first et conflits | M | É | MVP |
| R3 | Fiabilité de l'OCR sur factures artisanales | É | M | V2 |
| R4 | Coûts de stockage vs prix de l'abonnement | M | M | MVP |
| R5 | Dépendance aux review guidelines App Store | M | É | MVP |
| R6 | RGPD et hébergement UE | F | É | MVP |
| R7 | Performances des gros coffres-forts | M | M | MVP |
| R8 | Montée en charge du backend | F | M | V1+ |
| R9 | Équipe réduite vs surface fonctionnelle | É | É | Toutes |
| R10 | Fidélité multiplateforme SwiftUI | M | M | MVP |

---

## R1 — Précision et variabilité de RoomPlan

- **Description** : la qualité du scan LiDAR varie fortement selon
  l'appareil (Pro vs non-Pro, génération du capteur), la pièce (miroirs,
  baies vitrées, pièces mansardées type combles, mobilier dense) et
  l'éclairage. Des plans faux discréditeraient toute la V3 — et des
  mesures fausses peuvent coûter cher à l'utilisateur (commande de
  matériaux).
- **Probabilité / impact** : É / É.
- **Signaux d'alerte** : écarts > 2-3 % sur la matrice de test du spike ;
  murs non fermés ou dédoublés récurrents ; résultats non reproductibles
  sur la même pièce.
- **Mitigation** : **spike précoce dès la phase 0** (prototype interne,
  matrice appareils × pièces, rapport go/no-go avant tout engagement V3) ;
  **avertissement systématique** « vérifiez les mesures avant commande »
  (garde-fou canonique) ; **correction manuelle** des plans comme
  fonctionnalité de première classe, pas comme rustine ; liste
  d'appareils supportés publiée.

## R2 — Complexité de la sync offline-first et conflits

- **Description** : 27 entités, plusieurs appareils, coupures réseau,
  suppressions croisées : le moteur de sync est l'endroit où l'on perd
  silencieusement des données si l'on improvise. C'est le socle du MVP,
  puis de la collaboration V2 qui multiplie les écrivains.
- **Probabilité / impact** : M / É.
- **Signaux d'alerte** : bugs « la donnée a disparu » en bêta ; divergence
  d'agrégats budgétaires entre appareils ; correctifs de sync au cas par
  cas dans le code métier.
- **Mitigation** : **moteur générique** (aucune logique de sync dans les
  features) **testé par simulation multi-appareils** en CI — scénarios
  rejouables : avion, conflit simultané, suppression croisée ;
  **tombstones** pour toute suppression ; **copies de conflit** pour les
  fichiers ; LWW champ par champ, jamais d'écrasement silencieux ;
  états de sync visibles dans l'UI pour un diagnostic honnête.

## R3 — Fiabilité de l'OCR sur factures artisanales hétérogènes

- **Description** : devis et factures d'artisans sont hétérogènes —
  scans de travers, mentions manuscrites, tableaux atypiques, TVA
  multiples sur un même document. Un OCR trop confiant injecterait des
  montants faux dans le budget.
- **Probabilité / impact** : É / M (impact contenu par la validation).
- **Signaux d'alerte** : taux de champs corrigés par l'utilisateur > 30 %
  sur l'écran de validation ; abandons en cours de validation ; écarts
  HT+TVA≠TTC fréquents dans les extractions.
- **Mitigation** : **validation humaine obligatoire** champ par champ
  avant tout enregistrement (garde-fou canonique — aucune écriture
  automatique) ; l'import du fichier brut fonctionne toujours sans OCR ;
  **amélioration itérative** pilotée par la mesure des corrections ;
  contrôle arithmétique HT+TVA=TTC comme filet.

## R4 — Coûts de stockage vs prix de l'abonnement

- **Description** : à 4,99 €/mois pour 50 Go, quelques comptes remplis de
  vidéos et de scans peuvent rendre l'unité économique négative
  (stockage + trafic sortant + sauvegardes versionnées).
- **Probabilité / impact** : M / M.
- **Signaux d'alerte** : coût de stockage moyen par abonné > 15 % du
  revenu ; croissance du P95 de stockage par compte ; explosion du trafic
  de téléchargement (miniatures manquantes).
- **Mitigation** : **quotas par compte** appliqués côté serveur (1 Go
  gratuit / 50 Go Premium) ; **cycle de vie S3** (classes de stockage
  froides pour les originaux anciens, purge des corbeilles à 30 jours) ;
  miniatures générées côté serveur pour éviter de servir les originaux ;
  **monitoring** du coût par compte dès le MVP avec alertes.

## R5 — Dépendance aux review guidelines App Store

- **Description** : l'application cumule des sujets sensibles en review :
  achat intégré (limites gratuit/Premium), publicité, compte + suppression
  de compte, documents personnels. Un rejet peut coûter des semaines.
- **Probabilité / impact** : M / É (bloque le lancement).
- **Signaux d'alerte** : rejets en TestFlight externe ; évolution des
  guidelines sur la pub ou les abonnements ; demandes de justification
  répétées.
- **Mitigation** : conformité par conception — StoreKit 2 natif, aucune
  incitation à payer hors App Store, suppression de compte dans l'app,
  fiche de confidentialité exacte ; pub absente des écrans sensibles
  (règle canonique, testée par tests UI) ; notes de review préparées
  (compte de démonstration) ; marge de 1-2 semaines dans la timeline
  (doc 14 §9) ; lecture/export garantis après expiration — argument
  produit et argument de review.

## R6 — RGPD et hébergement UE

- **Description** : documents personnels sensibles (factures, assurances,
  diagnostics) : toute non-conformité (base légale, droit à l'effacement,
  sous-traitants hors UE) est un risque légal et de réputation.
- **Probabilité / impact** : F (architecture UE choisie) / É.
- **Signaux d'alerte** : un sous-traitant (analytics, pub, push tiers)
  transférant hors UE ; demandes d'effacement non purgées à 30 jours ;
  registre de traitements obsolète.
- **Mitigation** : hébergement **UE uniquement** (Scaleway Paris /
  OVHcloud, décision canonique) ; purge différée 30 jours implémentée et
  testée ; URL présignées courtes, jamais d'URL publique permanente ;
  registre des traitements tenu dès la phase 0 ; **audit externe avant le
  lancement** (jalon T3, doc 14 §5) ; choix de la régie publicitaire
  filtré par la conformité RGPD.

## R7 — Performances des gros coffres-forts

- **Description** : un carnet de maison vit des années : 5 000+ documents,
  photos lourdes. Listes qui rament, recherche lente et mémoire saturée
  détruisent la confiance dans le « coffre-fort ».
- **Probabilité / impact** : M / M.
- **Signaux d'alerte** : ouverture du coffre > 1 s en bêta ; recherche
  > 500 ms (critère doc 13 §3) ; consommation mémoire croissante au
  scroll ; pull de sync initial de plusieurs minutes.
- **Mitigation** : **pagination** systématique (listes et API) ;
  **miniatures** servies avant les originaux, téléchargés à la demande ;
  **indexation** SQLite (FTS5 sur les métadonnées) et index PostgreSQL ;
  jeu de test « 10 000 documents » en CI de performance.

## R8 — Montée en charge du backend

- **Description** : un pic (presse, mise en avant App Store) peut saturer
  l'API, et surtout le pipeline de fichiers et de miniatures.
- **Probabilité / impact** : F / M (l'offline-first amortit : l'app reste
  utilisable, la sync rattrape).
- **Signaux d'alerte** : latence P95 `/v1` > 500 ms ; files Redis qui
  s'allongent ; erreurs 5xx sur les URL présignées.
- **Mitigation** : **architecture stateless** (état en PostgreSQL/Redis,
  API scalable horizontalement) ; travail lourd (miniatures, exports,
  OCR) en files Redis découplées ; **tests de charge** avant V1 et avant
  chaque lancement marketing ; autoscaling et page de statut.

## R9 — Équipe réduite vs surface fonctionnelle

- **Description** : 27 entités, 3 plateformes, un serveur, la sync, les
  abonnements — pour 2 dev Apple, 1 dev back, 1 designer, PM partiel.
  Le risque n° 1 est de tout commencer et de ne rien finir.
- **Probabilité / impact** : É / É.
- **Signaux d'alerte** : jalons M1-M6 glissant deux fois de suite ;
  travaux V2/V3 entamés avant la sortie V1 (hors spike RoomPlan) ;
  definition of done rognée « temporairement ».
- **Mitigation** : **discipline de périmètre MVP** — les exclusions du
  doc 13 §2 sont fermes ; tout glissement se paie en périmètre, jamais en
  qualité (doc 14 §9) ; le spike RoomPlan est borné (1 dev en temps
  partagé, livrable = rapport) ; revue trimestrielle périmètre/risques.

## R10 — Fidélité multiplateforme SwiftUI

- **Description** : une cible unique iOS/iPadOS/macOS expose aux API non
  portables et aux régressions silencieuses : un écran parfait sur iPhone
  peut être cassé sur Mac (toolbars, listes, raccourcis, fenêtrage).
- **Probabilité / impact** : M / M.
- **Signaux d'alerte** : accumulation de `#if os(...)` dans les vues
  métier ; bugs « Mac seulement » découverts en bêta ; écarts visuels
  entre plateformes sur le design system.
- **Mitigation** : **tests UI par plateforme** en CI (parcours nominaux
  iPhone, iPad, Mac) ; **garde `#if os(...)`** : autorisé et justifié,
  concentré dans le design system et les adaptateurs, pas dispersé dans
  les features ; interdiction d'UIKit/AppKit direct (convention doc 17) ;
  captures des trois plateformes exigées à chaque PR (definition of done).
