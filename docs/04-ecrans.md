# Habit Plan — Catalogue des écrans

> Document `04`. Référence canonique : [`00-fondations.md`](00-fondations.md).
> Navigation : `TabView` sur iPhone (onglets : Accueil · Projets · Budget ·
> Coffre-fort · Plus), `NavigationSplitView` sur iPad et Mac (barre latérale
> par module). Les parcours d'usage sont détaillés dans
> [`03-parcours-utilisateurs.md`](03-parcours-utilisateurs.md).

Conventions des tableaux : **But & contenu** = objectif et éléments
principaux ; **Actions** = actions majeures ; **iPhone / iPad / Mac** =
différences notables (sinon « identique »). La priorité (MVP/V2/V3) figure
dans la table récapitulative finale.

---

## 1. Onboarding & Compte

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Bienvenue | Présenter la promesse en 3 panneaux (carnet, budget, coffre-fort) | Continuer, Passer | iPad/Mac : panneaux côte à côte |
| Connexion / Inscription | Sign in with Apple en premier ; e-mail + mot de passe en second | Se connecter, Créer un compte, Mot de passe oublié | Mac : fenêtre centrée |
| Autorisations contextuelles | Demander notifications/photos **au moment du besoin**, avec justification | Autoriser, Plus tard | identique |

## 2. Logements

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Sélecteur de logements | Lister les logements, bascule rapide (1 seul en Gratuit) | Ouvrir, Ajouter (paywall si limite) | iPad/Mac : en tête de barre latérale |
| Nouveau logement (assistant) | Créer : nom, type, adresse, surface, année | Enregistrer étape par étape | iPad/Mac : formulaire une page |
| Fiche logement | Synthèse : photo, caractéristiques, étages, membres, chiffres clés | Modifier, Exporter le dossier, Gérer les membres | Mac : panneaux juxtaposés |
| Étages & pièces | Structurer le logement, mode manuel sans LiDAR | Ajouter/réordonner étages et pièces | iPad : édition sur plan ; iPhone : listes |
| Fiche pièce | Tout ce qui touche la pièce : photos, équipements, plans, projets liés | Ajouter photo/équipement, Ouvrir le plan | iPad/Mac : galerie + plan côte à côte |
| Membres & invitations | Liste des membres et rôles (5 rôles canoniques) | Inviter, Changer rôle, Révoquer | identique |
| Récapitulatif d'invitation | Montrer **avant envoi** ce que l'invité verra / ne verra pas (rôle `professional` restreint) | Confirmer, Modifier le périmètre | identique |
| Export du dossier du logement | Composer l'archive de vente/transmission par sections | Sélectionner, Relire, Générer, Partager | Mac privilégié (génération lourde) |

## 3. Tableau de bord

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Tableau de bord | Vue d'ensemble : budget global, projets en cours, échéances (Ambre/Brique), entretiens à venir, dernières photos ; titres SF Pro Rounded | Accès rapides « + dépense », « scanner », « + projet » | iPhone : cartes empilées ; iPad : grille ; Mac : tableau de bord dense multi-colonnes |
| Fil d'activité | Journal chronologique du logement (ActivityLog) : qui a fait quoi | Filtrer par membre/module | Mac : filtre + recherche avancée |

## 4. Projets

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Liste des projets | Projets groupés par statut (12 statuts canoniques), badge coloré, budget/consommé | Créer, Filtrer, Archiver | iPad/Mac : colonnes type kanban par statut |
| Fiche projet | Cœur du suivi : statut, budget vs dépensé, tâches, devis, factures, photos, documents, membres invités | Changer de statut, Demander des devis, Ajouter tâche/dépense | iPad/Mac : onglets latéraux ; iPhone : sections empilées |
| Création / édition de projet | Nom, pièce(s), budget prévu, dates cibles, description | Enregistrer | identique |

## 5. Tâches

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Tâches du projet | Liste ordonnable des `ProjectTask` : état, assigné, échéance | Cocher, Réordonner, Assigner | Mac : édition en ligne au clavier |
| Toutes les tâches | Vue transverse « à faire » tous projets confondus | Filtrer par projet/échéance | iPad/Mac : regroupement par colonne |
| Fiche tâche | Détail : description, checklist, photos, commentaires | Terminer, Commenter, Joindre | identique |

## 6. Budget & Dépenses

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Budget du logement | Consolidation tous projets : engagé, payé, reste ; graphiques Swift Charts par catégorie | Changer de période, Ouvrir un projet | Mac : rapports détaillés attenants |
| Budget du projet | Prévu vs engagé vs payé, répartition par catégorie de dépense (7 canoniques) | Ajuster le budget, Ajouter dépense | identique |
| Liste des dépenses | Dépenses filtrables (projet, catégorie, période), montants `.monospacedDigit()` | Rechercher, Trier, Exporter | Mac : tableau dense multi-colonnes |
| Nouvelle dépense (feuille rapide) | Saisie en ~10 s : montant TTC, libellé, catégorie, projet, photo de ticket | Enregistrer, Ajouter photo | iPhone optimisé une main ; Mac : raccourci clavier |
| Fiche dépense | Détail HT/TVA/TTC, paiements liés, justificatifs | Modifier, Lier facture, Supprimer (corbeille) | identique |
| Rapports & exports | Synthèses par période/bien, export CSV/PDF (usage bailleur, fiscal) | Générer, Imprimer, Partager | Mac principalement ; iPad lecture |

## 7. Devis

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Liste des devis | Par projet ou global ; statuts canoniques (Reçu, En attente, Accepté, Refusé, Expiré) ; validité restante | Importer, Filtrer | identique |
| Import de devis | PDF/scan → OCR → **écran de validation** (parcours C) | Valider champ par champ, Rattacher projet/artisan | iPad/Mac : aperçu + champs côte à côte |
| Fiche devis | Postes, montants HT/TVA/TTC, artisan, validité, document source | Accepter, Refuser, Comparer | identique |
| Comparaison de devis | 2-3 devis en colonnes, postes alignés, écarts surlignés (Sauge/Brique) ; l'app signale, ne choisit jamais | Accepter l'un, Annoter (Pencil), Exporter | **Écran signature iPad** ; iPhone : bascule par onglets ; Mac : colonnes larges |
| Demande de devis | Sélection d'artisans, note de consultation ; passe le projet à `Devis demandés` | Envoyer, Suivre les relances | identique |

## 8. Factures

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Liste des factures | Statuts canoniques (À payer, Partiellement payée, Payée, En retard, Contestée), échéances triées | Filtrer, Marquer payée | Mac : tableau + totaux de pied |
| Fiche facture | Montants, échéance, paiements (acomptes), devis lié, document source | Enregistrer un paiement, Contester, Rappel | identique |
| Enregistrement de paiement | Feuille : montant, date, moyen ; calcule le reste dû | Enregistrer | identique |

## 9. Coffre-fort

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Accueil du coffre-fort | Catégories (actes, diagnostics, assurances, factures, notices…), état de sync ; **jamais de publicité ici** | Scanner, Importer, Rechercher | Mac : navigation par colonnes |
| Scanner un document | Caméra VisionKit : cadrage auto, multi-pages | Capturer, Recadrer, Ajouter page | iPhone/iPad seulement ; Mac : import fichier |
| Validation OCR | **Étape obligatoire** : champs détectés à confirmer un à un, confiance faible en Ambre | Valider, Corriger, Effacer champ | iPad/Mac : document + champs côte à côte |
| Fiche document (visionneuse) | Aperçu PDF/image, métadonnées, liens (`DocumentLink`) vers projet/pièce/équipement | Partager (jamais d'URL publique), Lier, Déplacer | iPad : annotation Pencil |
| Corbeille | Documents supprimés, conservés 30 jours | Restaurer, Supprimer définitivement | identique |

## 10. Scan & Plans

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Plans du logement | Plans par étage (`FloorPlan`), miniatures | Ouvrir, Créer (manuel ou scan) | iPad/Mac : grand aperçu |
| Éditeur de plan manuel | Tracé simple de pièces sans LiDAR (formes, cotes saisies) | Dessiner, Coter, Enregistrer | iPad + Pencil privilégiés ; iPhone : consultation |
| Pré-scan LiDAR | Vérif. compatibilité, quota (3/mois Gratuit), conseils de capture | Commencer, Basculer en manuel | iPhone/iPad Pro uniquement |
| Capture RoomPlan | Guidage AR temps réel, reprise de zone | Terminer, Reprendre | iPhone/iPad LiDAR uniquement |
| Aperçu & édition des cotes | Plan 2D coté généré ; chaque cote éditable ; original conservé ; **avertissement mesures systématique** | Corriger cotes, Enregistrer | iPad confort maximal |
| Visionneuse de plan | Consultation, annotation, export PDF | Annoter (Pencil), Exporter, Imprimer | Mac : impression/export soignés |

## 11. Photos

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Galerie (projet / pièce) | Photos datées, filtres par phase Avant/Pendant/Après | Ajouter, Filtrer, Sélectionner | Mac : import massif par glisser-déposer |
| Capture avec phase | Prise de vue avec étiquette de phase et rattachement pièce/projet | Capturer, Légender | iPhone principalement |
| Comparaison avant/après | Deux photos côte à côte, curseur de balayage | Choisir les photos, Partager l'image | iPad/Mac : plein écran large |
| Visionneuse photo | Zoom, légende, métadonnées de date (valeur de preuve) | Légender, Déplacer, Supprimer (corbeille) | identique |

## 12. Artisans

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Annuaire des artisans | Fiches (ex. Martin Électricité, Plomberie Costa…), spécialités, localisation | Ajouter, Rechercher | Mac : tableau triable |
| Fiche artisan | Coordonnées, SIRET, assurance décennale (document lié), historique devis/factures/projets | Appeler, Écrire, Demander un devis | iPad/Mac : historique côte à côte |
| Nouvel artisan / édition | Saisie ou création automatique depuis un devis importé (à valider) | Enregistrer | identique |

## 13. Équipements, Garanties & Entretien

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Inventaire des équipements | Par pièce : marque, modèle, n° de série, date d'installation | Ajouter, Filtrer par pièce | Mac : tableau dense |
| Fiche équipement | Détail + notice (coffre-fort), garanties, historique d'entretien | Ajouter garantie, Planifier entretien | identique |
| Nouvel équipement | Saisie assistée (photo de plaque signalétique → OCR à valider) | Enregistrer | identique |
| Garanties & échéances | Toutes les garanties triées par fin (Ambre à l'approche) | Ouvrir justificatif, Prolonger | identique |
| Calendrier d'entretien | Tâches récurrentes (`MaintenanceTask`) : chaudière, ramonage… | Marquer fait, Reporter, Régler la récurrence | iPad/Mac : vue calendrier ; iPhone : liste |
| Fiche tâche d'entretien | Détail, équipement lié, dernier intervenant, attestation | Marquer fait, Joindre attestation, Contacter l'artisan | identique |

## 14. Recherche

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Recherche globale | Une seule barre : documents, dépenses, devis, factures, artisans, équipements, photos ; résultats groupés par type | Filtrer par type/logement/période | Mac : ⌘F global, résultats en tableau |

## 15. Notifications

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Centre de notifications | `NotificationItem` : échéances, rappels, activité des membres, sync | Marquer lu, Ouvrir l'objet, Régler | identique |

## 16. Réglages

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Réglages généraux | Apparence (mode sombre), notifications, devise, langue | Modifier | Mac : fenêtre Réglages native |
| Compte & sécurité | Profil, e-mail, mot de passe, **appareils connectés** (révocation) | Révoquer un appareil, Supprimer le compte (purge 30 j) | identique |
| Abonnement | État de l'offre, quotas (stockage, scans), gestion StoreKit 2 | Changer d'offre, Restaurer les achats | identique |
| Stockage & synchronisation | Quota utilisé, états de sync (5 états canoniques), fichiers en attente | Forcer la sync, Libérer de l'espace | identique |
| Aide & à propos | Guides, contact, mentions légales, version | Contacter le support | identique |

## 17. Paywall

| Écran | But & contenu | Actions | iPhone / iPad / Mac |
|---|---|---|---|
| Écran Premium contextuel | Déclenché par une limite réelle ; rappelle l'action en cours, 3 offres canoniques + essai 14 j + garantie « lecture/export à vie » ; alternative gratuite toujours proposée | S'abonner, Plus tard, Alternative (ex. archiver un projet) | identique ; jamais plein écran au lancement |

---

## Table récapitulative — priorités

Légende : **MVP** = lancement · **V2** = confort et profondeur · **V3** =
scan LiDAR et au-delà (RoomPlan est canoniquement V3).

| Module | Écran | Priorité |
|---|---|---|
| Onboarding | Bienvenue · Connexion/Inscription · Autorisations contextuelles | MVP |
| Logements | Sélecteur · Nouveau logement · Fiche logement · Étages & pièces · Fiche pièce | MVP |
| Logements | Membres & invitations · Récapitulatif d'invitation | MVP |
| Logements | Export du dossier du logement | V2 |
| Tableau de bord | Tableau de bord | MVP |
| Tableau de bord | Fil d'activité | V2 |
| Projets | Liste · Fiche projet · Création/édition | MVP |
| Tâches | Tâches du projet · Fiche tâche | MVP |
| Tâches | Toutes les tâches (vue transverse) | V2 |
| Budget | Budget logement · Budget projet · Liste dépenses · Nouvelle dépense · Fiche dépense | MVP |
| Budget | Rapports & exports | V2 |
| Devis | Liste · Import + validation OCR · Fiche devis · Comparaison · Demande de devis | MVP |
| Factures | Liste · Fiche facture · Enregistrement de paiement | MVP |
| Coffre-fort | Accueil · Scanner · Validation OCR · Fiche document · Corbeille | MVP |
| Scan & Plans | Plans du logement · Visionneuse de plan | MVP |
| Scan & Plans | Éditeur de plan manuel | V2 |
| Scan & Plans | Pré-scan LiDAR · Capture RoomPlan · Édition des cotes | V3 |
| Photos | Galerie · Capture avec phase · Visionneuse | MVP |
| Photos | Comparaison avant/après | V2 |
| Artisans | Annuaire · Fiche artisan · Nouvel artisan | MVP |
| Équipements | Inventaire · Fiche équipement · Nouvel équipement · Garanties & échéances | MVP |
| Équipements | Calendrier d'entretien · Fiche tâche d'entretien | MVP |
| Recherche | Recherche globale | V2 |
| Notifications | Centre de notifications | MVP |
| Réglages | Généraux · Compte & sécurité · Abonnement · Stockage & sync · Aide | MVP |
| Paywall | Écran Premium contextuel | MVP |

Notes de périmètre : les passkeys (WebAuthn) arrivent en V2+ (§3 des
fondations) ; toute connexion bancaire éventuelle est hors MVP, opt-in et
en lecture seule (§8) ; la publicité du niveau Gratuit est exclue des
écrans coffre-fort, factures, scan, financiers et des actions critiques (§6).
