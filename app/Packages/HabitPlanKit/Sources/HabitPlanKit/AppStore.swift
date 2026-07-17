import Foundation
import Observation

/// Store en mémoire du prototype. Source de vérité unique de l'interface ;
/// la persistance SQLite (GRDB) remplacera ces tableaux dans la version cible.
/// Tous les agrégats et listes dérivées portent sur le logement sélectionné.
@Observable
public final class AppStore {
    public var properties: [Property] = []
    public var selectedPropertyID: UUID?
    public var rooms: [Room] = []
    public var projects: [Project] = []
    public var tasks: [ProjectTask] = []
    public var expenses: [Expense] = []
    public var quotes: [Quote] = []
    public var invoices: [Invoice] = []
    public var documents: [VaultDocument] = []
    public var contractors: [Contractor] = []
    public var equipments: [Equipment] = []
    public var warranties: [Warranty] = []
    public var maintenanceTasks: [MaintenanceTask] = []
    public var photos: [PhotoItem] = []
    public var isPremium: Bool = false

    /// Store vide ; utiliser `preview()` pour un store peuplé.
    public init() {}

    /// Store peuplé avec le jeu d'exemple « Maison des Lilas »,
    /// logement sélectionné.
    public static func preview() -> AppStore {
        let store = AppStore()
        SampleData.populate(store)
        store.selectedPropertyID = store.properties.first?.id
        return store
    }

    // MARK: - Sélection

    public var selectedProperty: Property? {
        guard let id = selectedPropertyID else { return nil }
        return properties.first { $0.id == id }
    }

    public func rooms(in propertyID: UUID) -> [Room] {
        rooms.filter { $0.propertyID == propertyID }
    }

    public func projects(in propertyID: UUID) -> [Project] {
        projects.filter { $0.propertyID == propertyID }
    }

    // MARK: - Agrégats budget (logement sélectionné)

    /// Somme des budgets prévus des projets non annulés.
    public var totalBudgetPlanned: Money {
        guard let id = selectedPropertyID else { return .zero }
        let cents = projects
            .filter { $0.propertyID == id && $0.status != .cancelled }
            .reduce(0) { $0 + $1.budgetPlanned.cents }
        return Money(cents: cents)
    }

    /// Somme TTC de toutes les dépenses du logement sélectionné.
    public var totalSpent: Money {
        guard let id = selectedPropertyID else { return .zero }
        let cents = expenses
            .filter { $0.propertyID == id }
            .reduce(0) { $0 + $1.amountTTC.cents }
        return Money(cents: cents)
    }

    /// Budget prévu moins dépensé (peut être négatif en cas de dépassement).
    public var remainingBudget: Money {
        totalBudgetPlanned - totalSpent
    }

    /// Somme TTC des dépenses rattachées à un projet.
    public func spent(on projectID: UUID) -> Money {
        let cents = expenses
            .filter { $0.projectID == projectID }
            .reduce(0) { $0 + $1.amountTTC.cents }
        return Money(cents: cents)
    }

    /// Totaux TTC par catégorie de dépense, triés par montant décroissant.
    /// Seules les catégories effectivement utilisées sont retournées.
    public func spentByCategory() -> [(category: ExpenseCategory, total: Money)] {
        guard let id = selectedPropertyID else { return [] }
        var totals: [ExpenseCategory: Int] = [:]
        for expense in expenses where expense.propertyID == id {
            totals[expense.category, default: 0] += expense.amountTTC.cents
        }
        return totals
            .map { (category: $0.key, total: Money(cents: $0.value)) }
            .sorted { $0.total.cents > $1.total.cents }
    }

    // MARK: - Listes dérivées (logement sélectionné)

    public var activeProjects: [Project] {
        guard let id = selectedPropertyID else { return [] }
        return projects.filter { $0.propertyID == id && $0.status.isActive }
    }

    public var overdueInvoices: [Invoice] {
        guard let id = selectedPropertyID else { return [] }
        return invoices.filter { $0.propertyID == id && $0.status == .overdue }
    }

    /// Devis encore ouverts : reçus ou en attente.
    public var pendingQuotes: [Quote] {
        guard let id = selectedPropertyID else { return [] }
        return quotes.filter {
            $0.propertyID == id && ($0.status == .received || $0.status == .pending)
        }
    }

    /// Entretiens dont l'échéance tombe dans les `days` prochains jours,
    /// triés par échéance croissante.
    public func upcomingMaintenance(within days: Int) -> [MaintenanceTask] {
        guard let id = selectedPropertyID else { return [] }
        let now = Date.now
        guard let limit = Calendar.current.date(byAdding: .day, value: days, to: now) else {
            return []
        }
        return maintenanceTasks
            .filter { $0.propertyID == id && $0.nextDueDate >= now && $0.nextDueDate <= limit }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }

    /// Garanties expirant dans les `days` prochains jours (les garanties déjà
    /// expirées sont exclues), triées par date de fin croissante. Une garantie
    /// est rattachée au logement via son équipement ; sans équipement, elle
    /// est considérée comme rattachée au logement sélectionné.
    public func expiringWarranties(within days: Int) -> [Warranty] {
        guard let id = selectedPropertyID else { return [] }
        let now = Date.now
        guard let limit = Calendar.current.date(byAdding: .day, value: days, to: now) else {
            return []
        }
        return warranties
            .filter { warranty in
                guard warranty.endDate >= now, warranty.endDate <= limit else { return false }
                guard let equipmentID = warranty.equipmentID else { return true }
                return equipments.contains { $0.id == equipmentID && $0.propertyID == id }
            }
            .sorted { $0.endDate < $1.endDate }
    }

    /// Tâches d'un projet, échéances les plus proches d'abord
    /// (les tâches sans échéance en dernier).
    public func tasks(for projectID: UUID) -> [ProjectTask] {
        tasks
            .filter { $0.projectID == projectID }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    public func contractor(_ id: UUID?) -> Contractor? {
        guard let id else { return nil }
        return contractors.first { $0.id == id }
    }

    public func project(_ id: UUID?) -> Project? {
        guard let id else { return nil }
        return projects.first { $0.id == id }
    }

    public func room(_ id: UUID?) -> Room? {
        guard let id else { return nil }
        return rooms.first { $0.id == id }
    }

    // MARK: - Mutations

    /// Inverse l'état fait / à faire d'une tâche.
    public func toggleTask(_ taskID: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].isDone.toggle()
    }

    public func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }

    public func setQuoteStatus(_ quoteID: UUID, status: QuoteStatus) {
        guard let index = quotes.firstIndex(where: { $0.id == quoteID }) else { return }
        quotes[index].status = status
    }
}
