import Foundation

/// Jeu de données d'exemple « Maison des Lilas » (docs/00-fondations.md §7).
/// Toutes les dates sont relatives à `Date.now` afin que le prototype reste
/// crédible quelle que soit la date d'exécution.
public enum SampleData {

    /// Peuple le store avec le jeu complet. Ne sélectionne pas de logement ;
    /// c'est `AppStore.preview()` qui s'en charge.
    public static func populate(_ store: AppStore) {
        // MARK: Logement

        let property = Property(
            name: "Maison des Lilas",
            type: "Maison",
            address: "12 rue des Lilas, 93100",
            city: "Montreuil",
            surfaceM2: 110,
            constructionYear: 1930
        )
        let pid = property.id

        // MARK: Pièces (3 niveaux, 8 pièces)

        let salon = Room(propertyID: pid, floorName: "Rez-de-chaussée",
                         name: "Salon", icon: "sofa.fill", areaM2: 28)
        let cuisine = Room(propertyID: pid, floorName: "Rez-de-chaussée",
                           name: "Cuisine", icon: "refrigerator.fill", areaM2: 12.5)
        let entree = Room(propertyID: pid, floorName: "Rez-de-chaussée",
                          name: "Entrée", icon: "door.french.open", areaM2: 6)
        let wc = Room(propertyID: pid, floorName: "Rez-de-chaussée",
                      name: "WC", icon: "toilet.fill", areaM2: 1.5)
        let chambre1 = Room(propertyID: pid, floorName: "Étage",
                            name: "Chambre principale", icon: "bed.double.fill", areaM2: 14)
        let chambre2 = Room(propertyID: pid, floorName: "Étage",
                            name: "Chambre d'enfant", icon: "bed.double", areaM2: 11)
        let salleDeBain = Room(propertyID: pid, floorName: "Étage",
                               name: "Salle de bain", icon: "shower.fill", areaM2: 6.5)
        let combles = Room(propertyID: pid, floorName: "Combles",
                           name: "Combles", icon: "archivebox.fill", areaM2: 30)

        // MARK: Artisans

        let martin = Contractor(
            companyName: "Martin Électricité", trade: "Électricité générale",
            city: "Montreuil", phone: "01 48 57 21 34",
            email: "contact@martin-electricite.fr", siret: "812 345 678 00021",
            insuranceValidUntil: days(210), rating: 5,
            notes: "Très réactif, chantier propre. Recommandé par les voisins."
        )
        let costa = Contractor(
            companyName: "Plomberie Costa", trade: "Plomberie / chauffage",
            city: "Vincennes", phone: "01 43 74 56 78",
            email: "contact@plomberie-costa.fr", siret: "789 456 123 00013",
            insuranceValidUntil: days(95), rating: 4,
            notes: "Devis détaillés. Demander l'attestation décennale à jour."
        )
        let dubois = Contractor(
            companyName: "Menuiserie Dubois", trade: "Menuiserie / agencement",
            city: "Fontenay-sous-Bois", phone: "01 48 76 12 90",
            email: "atelier@menuiserie-dubois.fr", siret: "352 987 654 00034",
            insuranceValidUntil: days(320), rating: 4,
            notes: "Fabrication sur mesure, délais d'environ six semaines."
        )
        let isoPlus = Contractor(
            companyName: "ISO+ Combles", trade: "Isolation thermique",
            city: "Rosny-sous-Bois", phone: "01 45 28 33 07",
            email: "devis@isoplus-combles.fr", siret: "901 234 567 00018",
            insuranceValidUntil: days(45), rating: 3,
            notes: "Certifié RGE — éligible aux aides. Relancer pour le devis."
        )

        // MARK: Projets

        let cuisineProject = Project(
            propertyID: pid,
            title: "Rénovation de la cuisine",
            details: "Dépose complète, reprise de l'électricité et de la plomberie, "
                + "nouveau mobilier sur mesure et carrelage au sol.",
            status: .inProgress,
            priority: .high,
            budgetPlanned: Money(cents: 1_850_000),
            startDate: days(-45),
            endDatePlanned: days(40),
            progress: 0.45,
            roomIDs: [cuisine.id]
        )
        let sdbProject = Project(
            propertyID: pid,
            title: "Salle de bain de l'étage",
            details: "Remplacement de la baignoire par une douche à l'italienne, "
                + "meuble vasque sur mesure, reprise de la faïence.",
            status: .quotesReceived,
            priority: .normal,
            budgetPlanned: Money(cents: 1_200_000),
            endDatePlanned: days(120),
            roomIDs: [salleDeBain.id]
        )
        let isolationProject = Project(
            propertyID: pid,
            title: "Isolation des combles",
            details: "Isolation en laine de bois soufflée, objectif de gain "
                + "énergétique avant l'hiver. Aides MaPrimeRénov' à étudier.",
            status: .toPrice,
            priority: .normal,
            budgetPlanned: Money(cents: 800_000),
            roomIDs: [combles.id]
        )
        let fenetresProject = Project(
            propertyID: pid,
            title: "Remplacement des fenêtres",
            details: "Passage en double vitrage sur la façade sud, "
                + "menuiseries bois pour rester dans le style 1930.",
            status: .idea,
            priority: .low,
            budgetPlanned: Money(cents: 950_000),
            roomIDs: [salon.id, chambre1.id, chambre2.id]
        )

        // MARK: Tâches

        let sampleTasks: [ProjectTask] = [
            ProjectTask(projectID: cuisineProject.id, title: "Déposer l'ancienne cuisine",
                        dueDate: days(-40), isDone: true),
            ProjectTask(projectID: cuisineProject.id, title: "Passer les gaines électriques",
                        dueDate: days(-30), isDone: true),
            ProjectTask(projectID: cuisineProject.id, title: "Poser le nouveau tableau électrique",
                        dueDate: days(-21), isDone: true),
            ProjectTask(projectID: cuisineProject.id, title: "Reprendre la plomberie de l'évier",
                        dueDate: days(-10), isDone: true),
            ProjectTask(projectID: cuisineProject.id, title: "Poser le carrelage du sol",
                        dueDate: days(7)),
            ProjectTask(projectID: cuisineProject.id, title: "Installer les meubles bas",
                        dueDate: days(14)),
            ProjectTask(projectID: cuisineProject.id, title: "Poser le plan de travail",
                        dueDate: days(21)),
            ProjectTask(projectID: sdbProject.id, title: "Comparer les deux devis reçus",
                        dueDate: days(5)),
            ProjectTask(projectID: sdbProject.id, title: "Vérifier l'assurance décennale de Plomberie Costa",
                        dueDate: days(10)),
            ProjectTask(projectID: isolationProject.id, title: "Relancer ISO+ Combles pour le devis",
                        dueDate: days(12)),
            ProjectTask(projectID: fenetresProject.id, title: "Mesurer les fenêtres de la façade sud"),
        ]

        // MARK: Dépenses (TVA rénovation 10 % ou 5,5 % — HT + TVA = TTC exact)

        let a1 = amounts(ht: 420_000, bps: 1000)   // 4 200,00 + 420,00 = 4 620,00
        let a2 = amounts(ht: 86_500, bps: 1000)    //   865,00 +  86,50 =   951,50
        let a3 = amounts(ht: 96_000, bps: 1000)    //   960,00 +  96,00 = 1 056,00
        let a4 = amounts(ht: 118_400, bps: 1000)   // 1 184,00 + 118,40 = 1 302,40
        let a5 = amounts(ht: 64_900, bps: 1000)    //   649,00 +  64,90 =   713,90
        let a6 = amounts(ht: 72_000, bps: 1000)    //   720,00 +  72,00 =   792,00
        let a7 = amounts(ht: 28_600, bps: 1000)    //   286,00 +  28,60 =   314,60
        let a8 = amounts(ht: 9_000, bps: 1000)     //    90,00 +   9,00 =    99,00
        let a9 = amounts(ht: 12_000, bps: 550)     //   120,00 +   6,60 =   126,60
        let a10 = amounts(ht: 18_000, bps: 550)    //   180,00 +   9,90 =   189,90
        let a11 = amounts(ht: 42_000, bps: 1000)   //   420,00 +  42,00 =   462,00
        let a12 = amounts(ht: 39_900, bps: 1000)   //   399,00 +  39,90 =   438,90

        let sampleExpenses: [Expense] = [
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    contractorID: dubois.id, label: "Acompte meubles de cuisine sur mesure",
                    category: .materials, amountHT: a1.ht, amountVAT: a1.vat,
                    amountTTC: a1.ttc, vatRateBps: 1000, date: days(-40),
                    paymentMethod: "Virement"),
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    contractorID: martin.id, label: "Tableau électrique et disjoncteurs",
                    category: .materials, amountHT: a2.ht, amountVAT: a2.vat,
                    amountTTC: a2.ttc, vatRateBps: 1000, date: days(-32)),
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    contractorID: martin.id, label: "Main-d'œuvre électricité (2 jours)",
                    category: .labor, amountHT: a3.ht, amountVAT: a3.vat,
                    amountTTC: a3.ttc, vatRateBps: 1000, date: days(-30),
                    paymentMethod: "Virement"),
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    label: "Carrelage grès cérame 60 × 60",
                    category: .materials, amountHT: a4.ht, amountVAT: a4.vat,
                    amountTTC: a4.ttc, vatRateBps: 1000, date: days(-18)),
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    label: "Évier et robinetterie",
                    category: .materials, amountHT: a5.ht, amountVAT: a5.vat,
                    amountTTC: a5.ttc, vatRateBps: 1000, date: days(-15)),
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    contractorID: costa.id, label: "Main-d'œuvre plomberie",
                    category: .labor, amountHT: a6.ht, amountVAT: a6.vat,
                    amountTTC: a6.ttc, vatRateBps: 1000, date: days(-12),
                    paymentMethod: "Virement"),
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    label: "Peinture et enduits",
                    category: .materials, amountHT: a7.ht, amountVAT: a7.vat,
                    amountTTC: a7.ttc, vatRateBps: 1000, date: days(-8)),
            Expense(propertyID: pid, projectID: cuisineProject.id,
                    label: "Location d'une ponceuse (week-end)",
                    category: .fees, amountHT: a8.ht, amountVAT: a8.vat,
                    amountTTC: a8.ttc, vatRateBps: 1000, date: days(-9)),
            Expense(propertyID: pid, projectID: isolationProject.id, roomID: combles.id,
                    label: "Échantillons d'isolant laine de bois",
                    category: .materials, amountHT: a9.ht, amountVAT: a9.vat,
                    amountTTC: a9.ttc, vatRateBps: 550, date: days(-5)),
            Expense(propertyID: pid, projectID: isolationProject.id, roomID: combles.id,
                    label: "Diagnostic humidité des combles",
                    category: .fees, amountHT: a10.ht, amountVAT: a10.vat,
                    amountTTC: a10.ttc, vatRateBps: 550, date: days(-20),
                    paymentMethod: "Virement"),
            Expense(propertyID: pid, projectID: cuisineProject.id,
                    label: "Assurance chantier cuisine",
                    category: .insurance, amountHT: a11.ht, amountVAT: a11.vat,
                    amountTTC: a11.ttc, vatRateBps: 1000, date: days(-35),
                    paymentMethod: "Prélèvement"),
            Expense(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                    label: "Hotte aspirante",
                    category: .equipment, amountHT: a12.ht, amountVAT: a12.vat,
                    amountTTC: a12.ttc, vatRateBps: 1000, date: days(-6)),
        ]

        // MARK: Devis

        let q1 = amounts(ht: 880_000, bps: 1000)   // Douche à l'italienne — Costa
        let q2 = amounts(ht: 240_000, bps: 1000)   // Meuble vasque — Dubois
        let q3 = amounts(ht: 690_000, bps: 550)    // Isolation soufflée — ISO+
        let q4 = amounts(ht: 320_000, bps: 1000)   // Électricité cuisine — Martin

        let sampleQuotes: [Quote] = [
            Quote(propertyID: pid, projectID: sdbProject.id, contractorID: costa.id,
                  reference: "DEV-2026-041", issuedAt: days(-12), validUntil: days(18),
                  amountHT: q1.ht, amountVAT: q1.vat, amountTTC: q1.ttc,
                  status: .received,
                  paymentTerms: "Acompte 30 % à la commande, solde à réception"),
            Quote(propertyID: pid, projectID: sdbProject.id, contractorID: dubois.id,
                  reference: "MD-26-117", issuedAt: days(-9), validUntil: days(21),
                  amountHT: q2.ht, amountVAT: q2.vat, amountTTC: q2.ttc,
                  status: .received,
                  paymentTerms: "50 % à la commande, 50 % à la pose"),
            Quote(propertyID: pid, projectID: isolationProject.id, contractorID: isoPlus.id,
                  reference: "ISO-8842", issuedAt: days(-2), validUntil: days(28),
                  amountHT: q3.ht, amountVAT: q3.vat, amountTTC: q3.ttc,
                  status: .pending,
                  paymentTerms: "En attente du chiffrage définitif"),
            Quote(propertyID: pid, projectID: cuisineProject.id, contractorID: martin.id,
                  reference: "ME-2026-063", issuedAt: days(-50), validUntil: days(-20),
                  amountHT: q4.ht, amountVAT: q4.vat, amountTTC: q4.ttc,
                  status: .accepted,
                  paymentTerms: "Acompte 40 %, solde en fin de chantier"),
        ]

        // MARK: Factures

        let f1 = amounts(ht: 160_000, bps: 1000)   // Acompte électricité — payée
        let f2 = amounts(ht: 72_000, bps: 1000)    // Plomberie — en retard
        let f3 = amounts(ht: 420_000, bps: 1000)   // Acompte menuiserie — payée
        let f4 = amounts(ht: 96_000, bps: 1000)    // Solde électricité — partielle

        let sampleInvoices: [Invoice] = [
            Invoice(propertyID: pid, projectID: cuisineProject.id, contractorID: martin.id,
                    reference: "FA-2026-118", issuedAt: days(-38), dueDate: days(-24),
                    amountHT: f1.ht, amountVAT: f1.vat, amountTTC: f1.ttc,
                    status: .paid),
            Invoice(propertyID: pid, projectID: cuisineProject.id, contractorID: costa.id,
                    reference: "F-2418", issuedAt: days(-20), dueDate: days(-5),
                    amountHT: f2.ht, amountVAT: f2.vat, amountTTC: f2.ttc,
                    status: .overdue),
            Invoice(propertyID: pid, projectID: cuisineProject.id, contractorID: dubois.id,
                    reference: "MD-F-2026-052", issuedAt: days(-40), dueDate: days(-26),
                    amountHT: f3.ht, amountVAT: f3.vat, amountTTC: f3.ttc,
                    status: .paid),
            Invoice(propertyID: pid, projectID: cuisineProject.id, contractorID: martin.id,
                    reference: "FA-2026-131", issuedAt: days(-6), dueDate: days(24),
                    amountHT: f4.ht, amountVAT: f4.vat, amountTTC: f4.ttc,
                    status: .partiallyPaid),
        ]

        // MARK: Documents du coffre-fort

        let sampleDocuments: [VaultDocument] = [
            VaultDocument(propertyID: pid, name: "Facture Martin Électricité — acompte",
                          kind: .invoice, fileSizeBytes: 412_000, addedAt: days(-38),
                          tags: ["cuisine", "électricité"]),
            VaultDocument(propertyID: pid, name: "Devis Plomberie Costa — salle de bain",
                          kind: .quote, fileSizeBytes: 287_000, addedAt: days(-12),
                          tags: ["salle de bain"], syncState: .syncing),
            VaultDocument(propertyID: pid, name: "Contrat Menuiserie Dubois",
                          kind: .contract, fileSizeBytes: 1_240_000, addedAt: days(-42),
                          isSensitive: true, tags: ["cuisine", "contrat"]),
            VaultDocument(propertyID: pid, name: "Attestation décennale Plomberie Costa",
                          kind: .insurance, fileSizeBytes: 156_000, addedAt: days(-11),
                          isFavorite: true, tags: ["assurance"]),
            VaultDocument(propertyID: pid, name: "Diagnostic amiante avant travaux",
                          kind: .diagnostic, fileSizeBytes: 3_480_000, addedAt: days(-60),
                          isSensitive: true, tags: ["diagnostic", "obligatoire"]),
            VaultDocument(propertyID: pid, name: "Plan du rez-de-chaussée — projet cuisine",
                          kind: .plan, fileSizeBytes: 2_150_000, addedAt: days(-45),
                          isFavorite: true, tags: ["cuisine", "plan"]),
            VaultDocument(propertyID: pid, name: "Notice chaudière Frisquet",
                          kind: .manual, fileSizeBytes: 5_620_000, addedAt: days(-400),
                          tags: ["chauffage"], syncState: .offlineAvailable),
            VaultDocument(propertyID: pid, name: "Garantie hotte Bosch",
                          kind: .warranty, fileSizeBytes: 98_000, addedAt: days(-6),
                          tags: ["cuisine", "garantie"], syncState: .pendingUpload),
            VaultDocument(propertyID: pid, name: "Offre de prêt travaux",
                          kind: .loan, fileSizeBytes: 864_000, addedAt: days(-70),
                          isSensitive: true, tags: ["financement"]),
            VaultDocument(propertyID: pid, name: "Dossier MaPrimeRénov' — combles",
                          kind: .grant, fileSizeBytes: 1_930_000, addedAt: days(-10),
                          tags: ["combles", "aides"], syncState: .error),
        ]

        // MARK: Équipements

        let chaudiere = Equipment(
            propertyID: pid, roomID: cuisine.id, name: "Chaudière gaz à condensation",
            category: "Chauffage", brand: "Frisquet", model: "Hydromotrix Condensation 25 kW",
            serialNumber: "FR-25-88412", purchaseDate: days(-1100),
            price: Money(cents: 385_000)
        )
        let vmc = Equipment(
            propertyID: pid, roomID: combles.id, name: "VMC double flux",
            category: "Ventilation", brand: "Atlantic", model: "Duocosy HR",
            serialNumber: "AT-77-20931", purchaseDate: days(-730),
            price: Money(cents: 189_000)
        )
        let adoucisseur = Equipment(
            propertyID: pid, name: "Adoucisseur d'eau",
            category: "Traitement de l'eau", brand: "Culligan", model: "Medallist S",
            serialNumber: "CU-19-55207", purchaseDate: days(-1500),
            price: Money(cents: 145_000)
        )
        let hotte = Equipment(
            propertyID: pid, roomID: cuisine.id, name: "Hotte aspirante",
            category: "Électroménager", brand: "Bosch", model: "DWB97JQ50",
            serialNumber: "BO-24-77120", purchaseDate: days(-6),
            price: Money(cents: 43_890)
        )
        let ballon = Equipment(
            propertyID: pid, roomID: combles.id, name: "Ballon thermodynamique",
            category: "Eau chaude", brand: "Thermor", model: "Aéromax 5 — 200 L",
            serialNumber: "TH-23-90714", purchaseDate: days(-500),
            price: Money(cents: 259_000)
        )

        // MARK: Garanties (1 expirant sous 60 jours)

        let sampleWarranties: [Warranty] = [
            Warranty(equipmentID: chaudiere.id, label: "Garantie constructeur chaudière",
                     providerName: "Frisquet", startDate: days(-1100), endDate: days(45)),
            Warranty(equipmentID: hotte.id, label: "Garantie hotte (2 ans)",
                     providerName: "Bosch", startDate: days(-6), endDate: days(724)),
            Warranty(equipmentID: vmc.id, label: "Extension de garantie VMC",
                     providerName: "Atlantic", startDate: days(-365), endDate: days(400)),
        ]

        // MARK: Entretiens

        let sampleMaintenance: [MaintenanceTask] = [
            MaintenanceTask(propertyID: pid, equipmentID: chaudiere.id,
                            label: "Entretien annuel de la chaudière",
                            frequencyMonths: 12, nextDueDate: days(21)),
            MaintenanceTask(propertyID: pid,
                            label: "Ramonage du conduit de cheminée",
                            frequencyMonths: 12, nextDueDate: days(35)),
            MaintenanceTask(propertyID: pid, equipmentID: vmc.id,
                            label: "Nettoyage des filtres de la VMC",
                            frequencyMonths: 6, nextDueDate: days(10)),
            MaintenanceTask(propertyID: pid, equipmentID: adoucisseur.id,
                            label: "Recharge en sel de l'adoucisseur",
                            frequencyMonths: 2, nextDueDate: days(5)),
        ]

        // MARK: Photos

        let samplePhotos: [PhotoItem] = [
            PhotoItem(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                      caption: "Cuisine d'origine avant dépose", takenAt: days(-45),
                      stage: .before, systemImagePlaceholder: "refrigerator.fill"),
            PhotoItem(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                      caption: "Saignées et gaines électriques", takenAt: days(-30),
                      stage: .during, systemImagePlaceholder: "bolt.fill"),
            PhotoItem(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                      caption: "Nouveau tableau électrique posé", takenAt: days(-21),
                      stage: .during, systemImagePlaceholder: "powerplug.fill"),
            PhotoItem(propertyID: pid, projectID: cuisineProject.id, roomID: cuisine.id,
                      caption: "Pose du carrelage en cours", takenAt: days(-3),
                      stage: .during, systemImagePlaceholder: "square.grid.3x3.fill"),
            PhotoItem(propertyID: pid, projectID: sdbProject.id, roomID: salleDeBain.id,
                      caption: "Salle de bain actuelle", takenAt: days(-12),
                      stage: .before, systemImagePlaceholder: "shower.fill"),
            PhotoItem(propertyID: pid, projectID: isolationProject.id, roomID: combles.id,
                      caption: "Combles avant isolation", takenAt: days(-20),
                      stage: .before, systemImagePlaceholder: "house.fill"),
        ]

        // MARK: Affectation au store

        store.properties = [property]
        store.rooms = [salon, cuisine, entree, wc, chambre1, chambre2, salleDeBain, combles]
        store.contractors = [martin, costa, dubois, isoPlus]
        store.projects = [cuisineProject, sdbProject, isolationProject, fenetresProject]
        store.tasks = sampleTasks
        store.expenses = sampleExpenses
        store.quotes = sampleQuotes
        store.invoices = sampleInvoices
        store.documents = sampleDocuments
        store.equipments = [chaudiere, vmc, adoucisseur, hotte, ballon]
        store.warranties = sampleWarranties
        store.maintenanceTasks = sampleMaintenance
        store.photos = samplePhotos
    }

    // MARK: - Aides privées

    /// Date décalée de `value` jours par rapport à maintenant.
    private static func days(_ value: Int) -> Date {
        Calendar.current.date(byAdding: DateComponents(day: value), to: .now) ?? .now
    }

    /// Triplet HT / TVA / TTC exact : la TVA est arrondie au centime puis
    /// le TTC est calculé comme HT + TVA, jamais l'inverse.
    private static func amounts(ht: Int, bps: Int) -> (ht: Money, vat: Money, ttc: Money) {
        let vatCents = Int((Double(ht) * Double(bps) / 10_000).rounded())
        return (Money(cents: ht), Money(cents: vatCents), Money(cents: ht + vatCents))
    }
}
