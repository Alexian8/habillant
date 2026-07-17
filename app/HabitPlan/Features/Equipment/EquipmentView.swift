import SwiftUI
import HabitPlanKit

/// Inventaire du logement : équipements, garanties et entretiens récurrents.
struct EquipmentView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                inventorySection(
                    "Équipements", systemImage: "wrench.and.screwdriver.fill",
                    items: equipments,
                    emptyText: "Aucun équipement enregistré."
                ) { EquipmentRow(equipment: $0) }

                inventorySection(
                    "Garanties", systemImage: "checkmark.shield.fill",
                    items: warranties,
                    emptyText: "Aucune garantie enregistrée."
                ) { WarrantyRow(warranty: $0) }

                inventorySection(
                    "Entretien", systemImage: "calendar.badge.clock",
                    items: maintenance,
                    emptyText: "Aucun entretien planifié."
                ) { MaintenanceRow(task: $0) }
            }
            .padding()
        }
        .navigationTitle("Équipements")
    }

    // MARK: Listes dérivées (logement sélectionné)

    private var equipments: [Equipment] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.equipments
            .filter { $0.propertyID == id }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Garanties rattachées au logement via leur équipement ; une garantie
    /// sans équipement est considérée comme globale au logement.
    private var warranties: [Warranty] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.warranties
            .filter { warranty in
                guard let equipmentID = warranty.equipmentID else { return true }
                return store.equipments.contains { $0.id == equipmentID && $0.propertyID == id }
            }
            .sorted { $0.endDate < $1.endDate }
    }

    private var maintenance: [MaintenanceTask] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.maintenanceTasks
            .filter { $0.propertyID == id }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }

    // MARK: Gabarit de section

    private func inventorySection<Item: Identifiable, RowContent: View>(
        _ title: String, systemImage: String,
        items: [Item], emptyText: String,
        @ViewBuilder row: @escaping (Item) -> RowContent
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title, systemImage: systemImage)
            HPCard {
                if items.isEmpty {
                    Text(emptyText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(items) { item in
                            row(item)
                            if item.id != items.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Équipement

private struct EquipmentRow: View {
    @Environment(AppStore.self) private var store
    let equipment: Equipment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(equipment.name)
                    .font(.headline)
                if let brandModel {
                    Text(brandModel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let room = store.room(equipment.roomID) {
                    Label(room.name, systemImage: room.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !equipment.serialNumber.isEmpty {
                    Text("N° de série \(equipment.serialNumber)")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 8)
            if let price = equipment.price {
                Text(price.formatted)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }
        }
    }

    private var brandModel: String? {
        let parts = [equipment.brand, equipment.model].filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}

// MARK: - Garantie

private struct WarrantyRow: View {
    let warranty: Warranty

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(warranty.label)
                    .font(.headline)
                Text(warranty.providerName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Du \(warranty.startDate.frenchShort) au \(warranty.endDate.frenchShort)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            HPBadge(text: status.text, tint: status.tint)
        }
    }

    /// Expirée, expirant sous 60 jours, ou active.
    private var status: (text: String, tint: Color) {
        if warranty.endDate < .now {
            return ("Expirée", .hpDanger)
        }
        let limit = Calendar.current.date(byAdding: .day, value: 60, to: .now) ?? .now
        if warranty.endDate < limit {
            return ("Expire bientôt", .hpAmber)
        }
        return ("Active", .hpSage)
    }
}

// MARK: - Entretien

private struct MaintenanceRow: View {
    let task: MaintenanceTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(dueTint)
                .frame(width: 32, height: 32)
                .background(dueTint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(task.label)
                    .font(.headline)
                Text(frequencyText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Text(task.nextDueDate.frenchShort)
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(dueTint)
        }
    }

    private var frequencyText: String {
        switch task.frequencyMonths {
        case 1: return "Tous les mois"
        case 12: return "Chaque année"
        default: return "Tous les \(task.frequencyMonths) mois"
        }
    }

    /// Échéance dépassée en rouge, sous 30 jours en ambre, sinon neutre.
    private var dueTint: Color {
        if task.nextDueDate < .now {
            return .hpDanger
        }
        let limit = Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
        if task.nextDueDate < limit {
            return .hpAmber
        }
        return .secondary
    }
}

// MARK: - Formatage

private extension Date {
    /// Date courte au format français (ex. « 12 sept. 2026 »).
    var frenchShort: String {
        formatted(
            .dateTime.day().month(.abbreviated).year()
                .locale(Locale(identifier: "fr_FR"))
        )
    }
}

#Preview {
    NavigationStack {
        EquipmentView()
    }
    .environment(AppStore.preview())
}
