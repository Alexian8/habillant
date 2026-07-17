import SwiftUI
import HabitPlanKit

/// Racine de navigation : onglets sur iPhone (largeur compacte),
/// NavigationSplitView sur iPad et Mac.
struct RootView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        #if os(macOS)
        SplitRootView()
        #else
        if horizontalSizeClass == .compact {
            CompactRootView()
        } else {
            SplitRootView()
        }
        #endif
    }
}

#if os(iOS)
/// iPhone : cinq onglets principaux, chacun dans sa propre pile de navigation.
private struct CompactRootView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label(AppSection.dashboard.title, systemImage: AppSection.dashboard.systemImage) }
            NavigationStack { ProjectsListView() }
                .tabItem { Label(AppSection.projects.title, systemImage: AppSection.projects.systemImage) }
            NavigationStack { BudgetView() }
                .tabItem { Label(AppSection.budget.title, systemImage: AppSection.budget.systemImage) }
            NavigationStack { VaultView() }
                .tabItem { Label(AppSection.vault.title, systemImage: AppSection.vault.systemImage) }
            NavigationStack { SettingsView() }
                .tabItem { Label(AppSection.settings.title, systemImage: AppSection.settings.systemImage) }
        }
        .tint(.hpTerracotta)
    }
}
#endif

/// iPad et Mac : barre latérale avec sélecteur de logement + détail par section.
private struct SplitRootView: View {
    @Environment(AppStore.self) private var store
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    PropertySidebarHeader()
                }
                Section {
                    ForEach(AppSection.allCases) { section in
                        Label(section.title, systemImage: section.systemImage)
                            .tag(section)
                    }
                }
            }
            .navigationTitle("Habit Plan")
            .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        } detail: {
            NavigationStack {
                detailView(for: selection ?? .dashboard)
            }
        }
        .tint(.hpTerracotta)
    }

    @ViewBuilder
    private func detailView(for section: AppSection) -> some View {
        switch section {
        case .dashboard:   DashboardView()
        case .projects:    ProjectsListView()
        case .budget:      BudgetView()
        case .quotes:      QuotesInvoicesView()
        case .vault:       VaultView()
        case .rooms:       RoomsView()
        case .contractors: ContractorsView()
        case .equipment:   EquipmentView()
        case .settings:    SettingsView()
        }
    }
}

/// En-tête de la barre latérale : logement sélectionné, avec menu de
/// changement lorsque le compte gère plusieurs logements.
private struct PropertySidebarHeader: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        if store.properties.count > 1 {
            Menu {
                ForEach(store.properties) { property in
                    Button {
                        store.selectedPropertyID = property.id
                    } label: {
                        if property.id == store.selectedPropertyID {
                            Label("\(property.name) — \(property.city)", systemImage: "checkmark")
                        } else {
                            Text("\(property.name) — \(property.city)")
                        }
                    }
                }
            } label: {
                headerLabel(showsChevron: true)
            }
            .buttonStyle(.plain)
        } else {
            headerLabel(showsChevron: false)
        }
    }

    private func headerLabel(showsChevron: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "house.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.hpTerracotta)
                .frame(width: 32, height: 32)
                .background(Color.hpTerracotta.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(store.selectedProperty?.name ?? "Aucun logement")
                    .font(.headline)
                    .lineLimit(1)
                Text(store.selectedProperty?.city ?? "Ajoutez un logement")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            if showsChevron {
                Spacer(minLength: 4)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}

#Preview {
    RootView()
        .environment(AppStore.preview())
}
