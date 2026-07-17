import SwiftUI
import HabitPlanKit

// Locale de formatage du prototype, cohérente avec `Money.formatted`.
private let frenchLocale = Locale(identifier: "fr_FR")

/// « 12,5 m² » : une décimale seulement si la surface n'est pas entière.
private func areaText(_ area: Double) -> String {
    let isWhole = area.truncatingRemainder(dividingBy: 1) == 0
    let number = area.formatted(
        .number.precision(.fractionLength(isWhole ? 0 : 1)).locale(frenchLocale)
    )
    return "\(number) m²"
}

/// Pièces du logement groupées par niveau (ordre de saisie : RDC, Étage,
/// Combles…), avec surfaces et nombre de projets touchant chaque pièce.
struct RoomsView: View {
    @Environment(AppStore.self) private var store

    /// Niveau du logement et ses pièces, dans l'ordre rencontré.
    private struct Floor {
        let name: String
        let rooms: [Room]

        var totalArea: Double {
            rooms.compactMap(\.areaM2).reduce(0, +)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                plansSection
                if floors.isEmpty {
                    Section {
                        EmptyStateView(
                            title: "Aucune pièce",
                            message: "Les pièces du logement apparaîtront ici, niveau par niveau.",
                            systemImage: "square.split.bottomrightquarter.fill"
                        )
                    }
                } else {
                    ForEach(floors, id: \.name) { floor in
                        floorSection(floor)
                    }
                    totalsSection
                }
            }
            .hpRoomsListStyle()
            .navigationTitle("Pièces & plans")
        }
    }

    // MARK: - Sections

    private var plansSection: some View {
        Section("Plans") {
            EmptyStateView(
                title: "Scan LiDAR et plans 2D/3D",
                message: "Prévu en V3. Sur les appareils sans LiDAR : création manuelle et import de plans.",
                systemImage: "square.split.bottomrightquarter.fill"
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func floorSection(_ floor: Floor) -> some View {
        Section {
            ForEach(floor.rooms) { room in
                RoomRow(room: room,
                        projectCount: projectCount(for: room),
                        areaLabel: room.areaM2.map(areaText))
            }
        } header: {
            Text(floor.name)
        } footer: {
            if floor.totalArea > 0 {
                Text("Surface du niveau : \(areaText(floor.totalArea))")
            }
        }
    }

    private var totalsSection: some View {
        Section {
        } footer: {
            if let property = store.selectedProperty {
                Text("Surface saisie : \(areaText(enteredArea)) · Surface du logement : \(areaText(property.surfaceM2))")
            } else {
                Text("Surface saisie : \(areaText(enteredArea))")
            }
        }
    }

    // MARK: - Données dérivées

    /// Niveaux dans l'ordre où ils apparaissent dans les pièces du logement.
    private var floors: [Floor] {
        guard let propertyID = store.selectedPropertyID else { return [] }
        var order: [String] = []
        var grouped: [String: [Room]] = [:]
        for room in store.rooms(in: propertyID) {
            if grouped[room.floorName] == nil {
                order.append(room.floorName)
            }
            grouped[room.floorName, default: []].append(room)
        }
        return order.map { Floor(name: $0, rooms: grouped[$0] ?? []) }
    }

    /// Somme des surfaces renseignées, tous niveaux confondus.
    private var enteredArea: Double {
        floors.reduce(0) { $0 + $1.totalArea }
    }

    /// Nombre de projets dont le périmètre inclut la pièce.
    private func projectCount(for room: Room) -> Int {
        store.projects(in: room.propertyID)
            .filter { $0.roomIDs.contains(room.id) }
            .count
    }
}

// MARK: - Ligne de pièce

private struct RoomRow: View {
    let room: Room
    let projectCount: Int
    let areaLabel: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: room.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.hpSlate)
                .frame(width: 36, height: 36)
                .background(Color.hpSand, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(room.name)
                    .font(.subheadline.weight(.medium))
                if let areaLabel {
                    Text(areaLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            if projectCount > 0 {
                HPBadge(
                    text: projectCount == 1 ? "1 projet" : "\(projectCount) projets",
                    tint: .hpTerracotta
                )
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Style de liste

private extension View {
    // `.insetGrouped` n'existe pas sur macOS.
    @ViewBuilder
    func hpRoomsListStyle() -> some View {
        #if os(iOS)
        listStyle(.insetGrouped)
        #else
        listStyle(.inset)
        #endif
    }
}

#Preview {
    RoomsView()
        .environment(AppStore.preview())
}
