import SwiftUI
import HabitPlanKit

/// Liste des projets du logement sélectionné, filtrable par état
/// (segments Actifs / Tous / Terminés) et par recherche sur le titre.
struct ProjectsListView: View {
    @Environment(AppStore.self) private var store
    @State private var filter: ProjectFilter = .active
    @State private var searchText = ""
    @State private var isShowingComingSoon = false

    var body: some View {
        Group {
            if store.selectedPropertyID != nil {
                projectList
            } else {
                EmptyStateView(
                    title: "Aucun logement",
                    message: "Sélectionnez un logement pour consulter ses projets de travaux.",
                    systemImage: "house"
                )
            }
        }
        .navigationTitle("Projets")
        .navigationDestination(for: UUID.self) { ProjectDetailView(projectID: $0) }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // Le prototype ne crée pas de projet : bouton grisé + alerte.
                Button {
                    isShowingComingSoon = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Nouveau projet")
            }
        }
        .alert("Bientôt disponible", isPresented: $isShowingComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("La création de projet arrivera dans une prochaine version.")
        }
    }

    private var projectList: some View {
        List {
            Section {
                Picker("Filtre", selection: $filter) {
                    ForEach(ProjectFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            Section {
                if filteredProjects.isEmpty {
                    Text(emptyMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredProjects) { project in
                        NavigationLink(value: project.id) {
                            ProjectRow(project: project, spent: store.spent(on: project.id))
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Rechercher un projet")
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
    }

    private var filteredProjects: [Project] {
        guard let propertyID = store.selectedPropertyID else { return [] }
        var result = store.projects(in: propertyID)
        switch filter {
        case .active:
            result = result.filter { $0.status.isActive }
        case .all:
            break
        case .done:
            result = result.filter { $0.status == .done }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    private var emptyMessage: String {
        guard searchText.isEmpty else {
            return "Aucun projet ne correspond à « \(searchText) »."
        }
        switch filter {
        case .active: return "Aucun projet actif pour ce logement."
        case .all: return "Aucun projet pour ce logement."
        case .done: return "Aucun projet terminé pour ce logement."
        }
    }
}

// MARK: - Filtre

private enum ProjectFilter: String, CaseIterable, Identifiable {
    case active, all, done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: return "Actifs"
        case .all: return "Tous"
        case .done: return "Terminés"
        }
    }
}

// MARK: - Ligne de projet

private struct ProjectRow: View {
    let project: Project
    let spent: Money

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(project.title)
                    .font(.headline)
                HPBadge(text: project.status.displayName, tint: project.status.tint)
                Text("\(project.budgetPlanned.formatted) prévus · \(spent.formatted) dépensés")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            ProgressRing(progress: project.progress, tint: project.status.tint, lineWidth: 4)
                .frame(width: 34, height: 34)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ProjectsListView()
    }
    .environment(AppStore.preview())
}
