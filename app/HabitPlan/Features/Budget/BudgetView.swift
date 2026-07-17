import SwiftUI
import Charts
import HabitPlanKit

/// Écran Budget : synthèse chiffrée, répartition par catégorie,
/// suivi par projet et dernières dépenses du logement sélectionné.
struct BudgetView: View {
    @Environment(AppStore.self) private var store
    @State private var isShowingExpenseForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if store.selectedProperty == nil {
                    EmptyStateView(
                        title: "Aucun logement",
                        message: "Sélectionnez un logement pour suivre son budget travaux.",
                        systemImage: "house"
                    )
                } else {
                    statRow
                    categorySection
                    projectsSection
                    latestExpensesSection
                }
            }
            .padding()
        }
        .navigationTitle("Budget")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingExpenseForm = true
                } label: {
                    Label("Ajouter une dépense", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingExpenseForm) {
            ExpenseFormView()
        }
    }

    // MARK: - Données dérivées

    private var categoryTotals: [(category: ExpenseCategory, total: Money)] {
        store.spentByCategory()
    }

    private var propertyProjects: [Project] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.projects(in: id)
    }

    private var latestExpenses: [Expense] {
        guard let id = store.selectedPropertyID else { return [] }
        return Array(
            store.expenses
                .filter { $0.propertyID == id }
                .sorted { $0.date > $1.date }
                .prefix(10)
        )
    }

    // MARK: - Synthèse

    private var statRow: some View {
        HStack(spacing: 12) {
            StatTile(
                title: "Budget prévu",
                value: store.totalBudgetPlanned.formatted,
                systemImage: "banknote.fill",
                tint: .hpSlate
            )
            StatTile(
                title: "Dépensé",
                value: store.totalSpent.formatted,
                systemImage: "eurosign.circle.fill",
                tint: .hpTerracotta
            )
            StatTile(
                title: "Restant",
                value: store.remainingBudget.formatted,
                systemImage: "chart.pie.fill",
                tint: store.remainingBudget.cents < 0 ? .hpDanger : .hpSage
            )
        }
    }

    // MARK: - Répartition par catégorie

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("Répartition par catégorie", systemImage: "chart.bar.xaxis")
            HPCard {
                if categoryTotals.isEmpty {
                    Text("Aucune dépense enregistrée pour le moment.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Chart(categoryTotals, id: \.category) { item in
                        BarMark(
                            x: .value("Montant", Double(item.total.cents) / 100),
                            y: .value("Catégorie", item.category.displayName)
                        )
                        .foregroundStyle(Color.hpSlate)
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let euros = value.as(Double.self) {
                                    Text("\(Int(euros)) €")
                                }
                            }
                        }
                    }
                    .frame(height: CGFloat(categoryTotals.count) * 30 + 24)
                }
            }
        }
    }

    // MARK: - Dépenses par projet

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("Dépenses par projet", systemImage: "hammer.fill")
            HPCard {
                if propertyProjects.isEmpty {
                    Text("Aucun projet pour ce logement.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(propertyProjects) { project in
                            ProjectBudgetRow(
                                project: project,
                                spent: store.spent(on: project.id)
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Dernières dépenses

    private var latestExpensesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("Dernières dépenses", systemImage: "clock.arrow.circlepath")
            HPCard {
                if latestExpenses.isEmpty {
                    Text("Les dépenses ajoutées apparaîtront ici.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(latestExpenses) { expense in
                            ExpenseRow(expense: expense)
                        }
                        Text("Montants TTC — le détail HT et TVA est conservé pour chaque dépense.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}

// MARK: - Ligne de budget projet

/// Titre du projet, dépensé / budget, et barre de progression fine
/// (brique en cas de dépassement).
private struct ProjectBudgetRow: View {
    let project: Project
    let spent: Money

    private var ratio: Double {
        guard project.budgetPlanned.cents > 0 else {
            return spent.cents > 0 ? 1 : 0
        }
        return Double(spent.cents) / Double(project.budgetPlanned.cents)
    }

    private var tint: Color {
        spent.cents > project.budgetPlanned.cents ? .hpDanger : .hpTerracotta
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(project.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text("\(spent.formatted) / \(project.budgetPlanned.formatted)")
                    .font(.hpAmount)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(tint.opacity(0.15))
                    Capsule()
                        .fill(tint)
                        .frame(width: geometry.size.width * min(max(ratio, 0), 1))
                }
            }
            .frame(height: 5)
        }
    }
}

// MARK: - Ligne de dépense

private struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: expense.category.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.hpSlate)
                .frame(width: 24, height: 24)
                .background(Color.hpSlate.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(expense.label)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(expense.date, format: .dateTime.day().month())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Text(expense.amountTTC.formatted)
                .font(.hpAmount)
                .lineLimit(1)
        }
    }
}

// MARK: - Formulaire de dépense

/// Saisie d'une dépense : le montant est saisi TTC, le HT et la TVA
/// sont recalculés en centimes à partir du taux choisi.
struct ExpenseFormView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var label = ""
    @State private var category: ExpenseCategory = .materials
    @State private var amountText = ""
    @State private var vatRateBps = 1000
    @State private var projectID: UUID?
    @State private var date = Date.now

    private static let vatRates: [(bps: Int, label: String)] = [
        (1000, "10 %"), (550, "5,5 %"), (2000, "20 %")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Dépense") {
                    TextField("Libellé", text: $label)
                    Picker("Catégorie", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                }
                Section("Montant") {
                    TextField("Montant TTC (€)", text: $amountText)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    Picker("Taux de TVA", selection: $vatRateBps) {
                        ForEach(Self.vatRates, id: \.bps) { rate in
                            Text(rate.label).tag(rate.bps)
                        }
                    }
                }
                Section("Rattachement") {
                    Picker("Projet", selection: $projectID) {
                        Text("Aucun").tag(UUID?.none)
                        ForEach(availableProjects) { project in
                            Text(project.title).tag(Optional(project.id))
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Nouvelle dépense")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { addExpense() }
                        .disabled(!canSubmit)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 460)
        #endif
    }

    // MARK: - Validation

    private var availableProjects: [Project] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.projects(in: id)
    }

    private var trimmedLabel: String {
        label.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Montant TTC saisi, en euros ; tolère la virgule et les espaces.
    private var amountTTC: Double? {
        let normalized = amountText
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: " ", with: "")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
    }

    private var canSubmit: Bool {
        !trimmedLabel.isEmpty && amountTTC != nil && store.selectedPropertyID != nil
    }

    private func addExpense() {
        guard let euros = amountTTC, let propertyID = store.selectedPropertyID else { return }
        let ttcCents = Int((euros * 100).rounded())
        let htCents = Int((Double(ttcCents) / (1 + Double(vatRateBps) / 10_000)).rounded())
        let expense = Expense(
            propertyID: propertyID,
            projectID: projectID,
            label: trimmedLabel,
            category: category,
            amountHT: Money(cents: htCents),
            amountVAT: Money(cents: ttcCents - htCents),
            amountTTC: Money(cents: ttcCents),
            vatRateBps: vatRateBps,
            date: date,
            paymentMethod: "Carte bancaire"
        )
        store.addExpense(expense)
        dismiss()
    }
}

// MARK: - Previews

#Preview("Budget") {
    NavigationStack {
        BudgetView()
    }
    .environment(AppStore.preview())
}

#Preview("Nouvelle dépense") {
    ExpenseFormView()
        .environment(AppStore.preview())
}
