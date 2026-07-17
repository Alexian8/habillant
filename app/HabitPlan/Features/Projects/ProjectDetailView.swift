import SwiftUI
import HabitPlanKit

/// Fiche détaillée d'un projet : budget, avancement, tâches, pièces,
/// dépenses et devis rattachés.
struct ProjectDetailView: View {
    let projectID: UUID

    @Environment(AppStore.self) private var store

    var body: some View {
        if let project = store.project(projectID) {
            content(for: project)
        } else {
            EmptyStateView(
                title: "Projet introuvable",
                message: "Ce projet n'existe plus ou a été supprimé.",
                systemImage: "hammer"
            )
            .navigationTitle("Projet")
        }
    }

    private func content(for project: Project) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header(for: project)
                budgetTiles(for: project)
                progressCard(for: project)
                tasksCard
                roomsCard(for: project)
                expensesCard
                quotesCard
            }
            .padding()
        }
        .navigationTitle(project.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - En-tête

    private func header(for project: Project) -> some View {
        HPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(project.title)
                    .font(.hpTitle)
                HStack(spacing: 12) {
                    HPBadge(text: project.status.displayName, tint: project.status.tint)
                    Label("Priorité \(project.priority.displayName.lowercased())", systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if project.startDate != nil || project.endDatePlanned != nil {
                    HStack(spacing: 16) {
                        if let start = project.startDate {
                            Label {
                                Text("Début ") + Text(start, format: .dateTime.day().month().year())
                            } icon: {
                                Image(systemName: "calendar")
                            }
                        }
                        if let end = project.endDatePlanned {
                            Label {
                                Text("Fin prévue ") + Text(end, format: .dateTime.day().month().year())
                            } icon: {
                                Image(systemName: "calendar.badge.checkmark")
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                if !project.details.isEmpty {
                    Text(project.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Budget

    private func budgetTiles(for project: Project) -> some View {
        let spent = store.spent(on: project.id)
        let gap = project.budgetPlanned - spent
        let isOverBudget = project.budgetPlanned < spent
        return HStack(spacing: 12) {
            StatTile(
                title: "Budget prévu",
                value: project.budgetPlanned.formatted,
                systemImage: "eurosign.circle.fill",
                tint: .hpSlate
            )
            StatTile(
                title: "Dépensé",
                value: spent.formatted,
                systemImage: "creditcard.fill",
                tint: .hpTerracotta
            )
            StatTile(
                title: "Écart",
                value: gap.formatted,
                systemImage: "plusminus.circle.fill",
                tint: isOverBudget ? .hpDanger : .hpSage
            )
        }
    }

    // MARK: - Avancement

    private func progressCard(for project: Project) -> some View {
        HPCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("Avancement", systemImage: "chart.pie.fill")
                HStack {
                    Spacer()
                    ZStack {
                        ProgressRing(progress: project.progress, tint: project.status.tint, lineWidth: 10)
                            .frame(width: 110, height: 110)
                        Text(project.progress, format: .percent.precision(.fractionLength(0)))
                            .font(.hpAmount)
                    }
                    Spacer()
                }
            }
        }
    }

    // MARK: - Tâches

    private var tasksCard: some View {
        // Tâches à faire d'abord, l'ordre par échéance du store est conservé.
        let tasks = store.tasks(for: projectID)
        let ordered = tasks.filter { !$0.isDone } + tasks.filter(\.isDone)
        return HPCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("Tâches", systemImage: "checklist")
                if ordered.isEmpty {
                    Text("Aucune tâche pour ce projet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(ordered) { task in
                        TaskRow(task: task) {
                            store.toggleTask(task.id)
                        }
                        if task.id != ordered.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pièces

    private func roomsCard(for project: Project) -> some View {
        let roomNames = project.roomIDs.compactMap { store.room($0)?.name }
        return HPCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("Pièces concernées", systemImage: "square.split.bottomrightquarter.fill")
                if roomNames.isEmpty {
                    Text("Aucune pièce associée.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 8) {
                        ForEach(roomNames, id: \.self) { name in
                            HPBadge(text: name, tint: .gray)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Dépenses

    private var expensesCard: some View {
        let projectExpenses = store.expenses
            .filter { $0.projectID == projectID }
            .sorted { $0.date > $1.date }
        return HPCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("Dépenses du projet", systemImage: "eurosign.circle.fill")
                if projectExpenses.isEmpty {
                    Text("Aucune dépense enregistrée.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(projectExpenses) { expense in
                        HStack(spacing: 10) {
                            Image(systemName: expense.category.systemImage)
                                .foregroundStyle(Color.hpSlate)
                                .frame(width: 26)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(expense.label)
                                Text(expense.category.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            Text(expense.amountTTC.formatted)
                                .font(.hpAmount)
                        }
                    }
                    Divider()
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(store.spent(on: projectID).formatted)
                            .font(.hpAmount)
                    }
                }
            }
        }
    }

    // MARK: - Devis

    private var quotesCard: some View {
        let projectQuotes = store.quotes.filter { $0.projectID == projectID }
        return HPCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("Devis liés", systemImage: "doc.plaintext.fill")
                if projectQuotes.isEmpty {
                    Text("Aucun devis rattaché.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(projectQuotes) { quote in
                        QuoteRow(
                            quote: quote,
                            contractorName: store.contractor(quote.contractorID)?.companyName,
                            onAccept: { store.setQuoteStatus(quote.id, status: .accepted) },
                            onDecline: { store.setQuoteStatus(quote.id, status: .declined) }
                        )
                        if quote.id != projectQuotes.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Ligne de tâche

private struct TaskRow: View {
    let task: ProjectTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? Color.hpSage : Color.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .strikethrough(task.isDone)
                        .foregroundStyle(task.isDone ? .secondary : .primary)
                    if let due = task.dueDate {
                        (Text("Échéance ") + Text(due, format: .dateTime.day().month().year()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ligne de devis

private struct QuoteRow: View {
    let quote: Quote
    let contractorName: String?
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(quote.reference)
                        .font(.headline)
                    Text(contractorName ?? "Artisan inconnu")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(quote.amountTTC.formatted)
                        .font(.hpAmount)
                    HPBadge(text: quote.status.displayName, tint: quote.status.tint)
                }
            }
            if quote.status == .received || quote.status == .pending {
                HStack(spacing: 8) {
                    Button("Accepter", action: onAccept)
                        .buttonStyle(.bordered)
                        .tint(.hpSage)
                    Button("Refuser", action: onDecline)
                        .buttonStyle(.bordered)
                        .tint(.hpDanger)
                }
                .controlSize(.small)
            }
        }
    }
}

// Teinte locale des statuts de devis (portée limitée à ce fichier).
private extension QuoteStatus {
    var tint: Color {
        switch self {
        case .accepted: return .hpSage
        case .declined: return .hpDanger
        case .expired: return .gray
        case .received, .pending: return .hpSlate
        }
    }
}

#Preview {
    struct PreviewHost: View {
        @Environment(AppStore.self) private var store

        var body: some View {
            NavigationStack {
                if let project = store.projects.first {
                    ProjectDetailView(projectID: project.id)
                } else {
                    Text("Store de preview vide")
                }
            }
        }
    }
    return PreviewHost()
        .environment(AppStore.preview())
}
