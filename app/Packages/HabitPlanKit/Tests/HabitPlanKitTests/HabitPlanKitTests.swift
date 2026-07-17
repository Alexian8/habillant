import XCTest
import HabitPlanKit

final class HabitPlanKitTests: XCTestCase {

    // MARK: - Money

    func testMoneyArithmetic() {
        let a = Money(cents: 1_000)
        let b = Money(cents: 250)
        XCTAssertEqual((a + b).cents, 1_250)
        XCTAssertEqual((a - b).cents, 750)
        XCTAssertTrue(b < a)
        XCTAssertFalse(a < b)
        XCTAssertEqual(Money.zero.cents, 0)
        XCTAssertEqual(Money.zero.currencyCode, "EUR")
        XCTAssertEqual(Money.euros(12.34).cents, 1_234)
        XCTAssertEqual(Money.euros(185).cents, 18_500)
    }

    /// Le format français utilise des espaces insécables (U+00A0 / U+202F)
    /// comme séparateurs de milliers : on normalise avant de comparer.
    private func normalized(_ s: String) -> String {
        s.replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: "\u{202F}", with: "")
            .replacingOccurrences(of: " ", with: "")
    }

    func testMoneyFormattedRoundAmountHasNoDecimals() {
        let formatted = normalized(Money(cents: 1_850_000).formatted)
        XCTAssertTrue(formatted.contains("€"), "Devise absente : \(formatted)")
        XCTAssertTrue(formatted.contains("18500"), "Montant inattendu : \(formatted)")
        XCTAssertFalse(formatted.contains(","), "Un montant rond ne doit pas avoir de décimales : \(formatted)")
    }

    func testMoneyFormattedNonRoundAmountHasTwoDecimals() {
        let formatted = normalized(Money(cents: 95_150).formatted)
        XCTAssertTrue(formatted.contains("€"), "Devise absente : \(formatted)")
        XCTAssertTrue(formatted.contains("951,50"), "Décimales attendues : \(formatted)")
    }

    // MARK: - Agrégats budget sur un store construit à la main

    func testBudgetAggregates() {
        let store = AppStore()
        let property = Property(name: "Test", type: "Maison", address: "1 rue A",
                                city: "Paris", surfaceM2: 100, constructionYear: 2000)
        let other = Property(name: "Autre", type: "Appartement", address: "2 rue B",
                             city: "Lyon", surfaceM2: 60, constructionYear: 1990)
        store.properties = [property, other]
        store.selectedPropertyID = property.id

        let project = Project(propertyID: property.id, title: "Projet actif",
                              status: .inProgress, budgetPlanned: Money(cents: 100_000))
        let cancelled = Project(propertyID: property.id, title: "Projet annulé",
                                status: .cancelled, budgetPlanned: Money(cents: 50_000))
        store.projects = [project, cancelled]

        store.expenses = [
            Expense(propertyID: property.id, projectID: project.id, label: "Dépense 1",
                    category: .materials, amountHT: Money(cents: 10_000),
                    amountVAT: Money(cents: 1_000), amountTTC: Money(cents: 11_000),
                    vatRateBps: 1000, date: .now),
            Expense(propertyID: property.id, label: "Dépense 2",
                    category: .other, amountHT: Money(cents: 2_000),
                    amountVAT: Money(cents: 200), amountTTC: Money(cents: 2_200),
                    vatRateBps: 1000, date: .now),
            // Autre logement : doit être exclue des agrégats.
            Expense(propertyID: other.id, label: "Hors périmètre",
                    category: .other, amountHT: Money(cents: 99_000),
                    amountVAT: Money(cents: 9_900), amountTTC: Money(cents: 108_900),
                    vatRateBps: 1000, date: .now),
        ]

        XCTAssertEqual(store.totalBudgetPlanned.cents, 100_000,
                       "Le projet annulé ne compte pas dans le budget prévu")
        XCTAssertEqual(store.totalSpent.cents, 13_200)
        XCTAssertEqual(store.remainingBudget.cents, 86_800)
        XCTAssertEqual(store.spent(on: project.id).cents, 11_000)

        let byCategory = store.spentByCategory()
        XCTAssertEqual(byCategory.count, 2)
        XCTAssertEqual(byCategory.first?.category, .materials)
        XCTAssertEqual(byCategory.first?.total.cents, 11_000)

        // Sans logement sélectionné, tout retombe à zéro.
        store.selectedPropertyID = nil
        XCTAssertEqual(store.totalSpent, Money.zero)
        XCTAssertEqual(store.remainingBudget, Money.zero)
    }

    // MARK: - toggleTask

    func testToggleTask() {
        let store = AppStore()
        let task = ProjectTask(projectID: UUID(), title: "Tâche test")
        store.tasks = [task]

        XCTAssertFalse(store.tasks[0].isDone)
        store.toggleTask(task.id)
        XCTAssertTrue(store.tasks[0].isDone)
        store.toggleTask(task.id)
        XCTAssertFalse(store.tasks[0].isDone)

        // Identifiant inconnu : aucun effet, pas de plantage.
        store.toggleTask(UUID())
        XCTAssertFalse(store.tasks[0].isDone)
    }

    // MARK: - expiringWarranties(within:)

    func testExpiringWarranties() {
        let store = AppStore()
        let property = Property(name: "Test", type: "Maison", address: "1 rue A",
                                city: "Paris", surfaceM2: 100, constructionYear: 2000)
        let other = Property(name: "Autre", type: "Appartement", address: "2 rue B",
                             city: "Lyon", surfaceM2: 60, constructionYear: 1990)
        store.properties = [property, other]
        store.selectedPropertyID = property.id

        let equipment = Equipment(propertyID: property.id, name: "Chaudière",
                                  category: "Chauffage")
        let foreignEquipment = Equipment(propertyID: other.id, name: "Climatisation",
                                         category: "Climatisation")
        store.equipments = [equipment, foreignEquipment]

        func date(_ days: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
        }

        let soon = Warranty(equipmentID: equipment.id, label: "Expire bientôt",
                            providerName: "A", startDate: date(-300), endDate: date(30))
        let far = Warranty(equipmentID: equipment.id, label: "Expire dans longtemps",
                           providerName: "B", startDate: date(-300), endDate: date(400))
        let expired = Warranty(equipmentID: equipment.id, label: "Déjà expirée",
                               providerName: "C", startDate: date(-300), endDate: date(-10))
        let foreign = Warranty(equipmentID: foreignEquipment.id, label: "Autre logement",
                               providerName: "D", startDate: date(-300), endDate: date(30))
        let unattached = Warranty(label: "Sans équipement",
                                  providerName: "E", startDate: date(-300), endDate: date(20))
        store.warranties = [soon, far, expired, foreign, unattached]

        let expiring = store.expiringWarranties(within: 60)
        XCTAssertEqual(expiring.map(\.id), [unattached.id, soon.id],
                       "Attendu : les deux garanties < 60 j, triées par échéance")
        XCTAssertTrue(store.expiringWarranties(within: 5).isEmpty)
    }

    // MARK: - Cohérence du jeu d'exemple

    func testSampleDataAmountsAreConsistent() {
        let store = AppStore.preview()

        for expense in store.expenses {
            XCTAssertEqual(expense.amountHT.cents + expense.amountVAT.cents,
                           expense.amountTTC.cents,
                           "HT + TVA ≠ TTC pour la dépense « \(expense.label) »")
            XCTAssertTrue([550, 1000].contains(expense.vatRateBps),
                          "Taux de TVA inattendu pour « \(expense.label) »")
        }
        for quote in store.quotes {
            XCTAssertEqual(quote.amountHT.cents + quote.amountVAT.cents,
                           quote.amountTTC.cents,
                           "HT + TVA ≠ TTC pour le devis \(quote.reference)")
        }
        for invoice in store.invoices {
            XCTAssertEqual(invoice.amountHT.cents + invoice.amountVAT.cents,
                           invoice.amountTTC.cents,
                           "HT + TVA ≠ TTC pour la facture \(invoice.reference)")
        }
    }

    func testSampleDataShape() {
        let store = AppStore.preview()

        XCTAssertEqual(store.properties.count, 1)
        XCTAssertNotNil(store.selectedPropertyID)
        XCTAssertEqual(store.selectedProperty?.name, "Maison des Lilas")
        XCTAssertFalse(store.isPremium)

        XCTAssertEqual(store.rooms.count, 8)
        XCTAssertEqual(Set(store.rooms.map(\.floorName)).count, 3)
        XCTAssertEqual(store.projects.count, 4)
        XCTAssertEqual(store.contractors.count, 4)
        XCTAssertEqual(store.quotes.count, 4)
        XCTAssertEqual(store.invoices.count, 4)
        XCTAssertEqual(store.documents.count, 10)
        XCTAssertEqual(store.equipments.count, 5)
        XCTAssertEqual(store.warranties.count, 3)
        XCTAssertEqual(store.maintenanceTasks.count, 4)
        XCTAssertEqual(store.photos.count, 6)
        XCTAssertGreaterThanOrEqual(store.tasks.count, 10)
        XCTAssertGreaterThanOrEqual(store.expenses.count, 12)

        XCTAssertFalse(store.activeProjects.isEmpty)
        XCTAssertGreaterThanOrEqual(store.overdueInvoices.count, 1)
        XCTAssertGreaterThanOrEqual(store.pendingQuotes.count, 1)
        XCTAssertGreaterThanOrEqual(store.expiringWarranties(within: 60).count, 1)
        XCTAssertGreaterThanOrEqual(store.upcomingMaintenance(within: 60).count, 1)
        XCTAssertTrue(store.documents.contains { $0.isSensitive })
    }

    // MARK: - Libellés des énumérations

    func testAllEnumDisplayNamesAreNonEmpty() {
        for status in ProjectStatus.allCases {
            XCTAssertFalse(status.displayName.isEmpty, "ProjectStatus.\(status.rawValue)")
            XCTAssertFalse(status.systemImage.isEmpty, "ProjectStatus.\(status.rawValue)")
        }
        for priority in ProjectPriority.allCases {
            XCTAssertFalse(priority.displayName.isEmpty, "ProjectPriority.\(priority.rawValue)")
        }
        for category in ExpenseCategory.allCases {
            XCTAssertFalse(category.displayName.isEmpty, "ExpenseCategory.\(category.rawValue)")
            XCTAssertFalse(category.systemImage.isEmpty, "ExpenseCategory.\(category.rawValue)")
        }
        for status in QuoteStatus.allCases {
            XCTAssertFalse(status.displayName.isEmpty, "QuoteStatus.\(status.rawValue)")
        }
        for status in InvoiceStatus.allCases {
            XCTAssertFalse(status.displayName.isEmpty, "InvoiceStatus.\(status.rawValue)")
        }
        for kind in DocumentKind.allCases {
            XCTAssertFalse(kind.displayName.isEmpty, "DocumentKind.\(kind.rawValue)")
            XCTAssertFalse(kind.systemImage.isEmpty, "DocumentKind.\(kind.rawValue)")
        }
        for stage in WorkStage.allCases {
            XCTAssertFalse(stage.displayName.isEmpty, "WorkStage.\(stage.rawValue)")
        }
        for state in SyncState.allCases {
            XCTAssertFalse(state.displayName.isEmpty, "SyncState.\(state.rawValue)")
            XCTAssertFalse(state.systemImage.isEmpty, "SyncState.\(state.rawValue)")
        }
    }
}
