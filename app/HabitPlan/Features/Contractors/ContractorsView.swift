import SwiftUI
import HabitPlanKit

/// Annuaire des artisans : coordonnées, note personnelle, état de
/// l'assurance et documents liés (devis, factures).
struct ContractorsView: View {
    @Environment(AppStore.self) private var store
    @State private var searchText = ""

    private var filteredContractors: [Contractor] {
        let sorted = store.contractors.sorted {
            $0.companyName.localizedCaseInsensitiveCompare($1.companyName) == .orderedAscending
        }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter {
            $0.companyName.localizedCaseInsensitiveContains(searchText)
                || $0.trade.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        contractorList
            .navigationTitle("Artisans")
            .searchable(text: $searchText, prompt: "Nom ou métier")
            .overlay {
                if filteredContractors.isEmpty {
                    if searchText.isEmpty {
                        EmptyStateView(
                            title: "Aucun artisan",
                            message: "Ajoutez vos artisans pour garder leurs coordonnées, devis et factures au même endroit.",
                            systemImage: "person.2.fill"
                        )
                    } else {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
    }

    private var contractorList: some View {
        let list = List(filteredContractors) { contractor in
            ContractorRow(contractor: contractor)
        }
        #if os(iOS)
        return list.listStyle(.insetGrouped)
        #else
        return list.listStyle(.inset)
        #endif
    }
}

// MARK: - Ligne artisan

private struct ContractorRow: View {
    @Environment(AppStore.self) private var store
    let contractor: Contractor
    @State private var isExpanded = false
    @State private var showsContactAlert = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            details
        } label: {
            summary
        }
        .alert("Disponible sur appareil", isPresented: $showsContactAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Les appels et e-mails ne sont pas simulés dans le prototype.")
        }
    }

    // MARK: Résumé

    private var summary: some View {
        HStack(spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 3) {
                Text(contractor.companyName)
                    .font(.headline)
                Text("\(contractor.trade) — \(contractor.city)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ratingStars
                    if let badge = insuranceBadge {
                        HPBadge(text: badge.text, tint: badge.tint)
                    }
                }
            }
            Spacer(minLength: 8)
            HStack(spacing: 2) {
                contactButton(systemImage: "phone")
                contactButton(systemImage: "envelope")
            }
        }
        .padding(.vertical, 2)
    }

    private var avatar: some View {
        Text(initials)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(Color.hpSlate, in: Circle())
    }

    /// Initiales des deux premiers mots du nom de l'entreprise.
    private var initials: String {
        contractor.companyName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }

    private var ratingStars: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= contractor.rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(index <= contractor.rating ? Color.hpAmber : Color.gray.opacity(0.45))
            }
        }
        .accessibilityLabel("Note : \(contractor.rating) sur 5")
    }

    /// Assurance expirée, ou à renouveler dans les 60 prochains jours.
    private var insuranceBadge: (text: String, tint: Color)? {
        guard let validUntil = contractor.insuranceValidUntil else { return nil }
        if validUntil < .now {
            return ("Assurance expirée", .hpDanger)
        }
        let limit = Calendar.current.date(byAdding: .day, value: 60, to: .now) ?? .now
        if validUntil < limit {
            return ("Assurance à renouveler", .hpAmber)
        }
        return nil
    }

    // Le prototype n'ouvre ni tel: ni mailto: — simple alerte.
    private func contactButton(systemImage: String) -> some View {
        Button {
            showsContactAlert = true
        } label: {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }

    // MARK: Détail déplié

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent("SIRET", value: contractor.siret)
            LabeledContent("E-mail", value: contractor.email)
            LabeledContent("Téléphone", value: contractor.phone)
            if !contractor.notes.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notes")
                    Text(contractor.notes)
                        .foregroundStyle(.secondary)
                }
            }
            LabeledContent("Documents liés", value: linkedDocumentsText)
        }
        .font(.subheadline)
        .padding(.vertical, 4)
    }

    private var linkedDocumentsText: String {
        let quoteCount = store.quotes.filter { $0.contractorID == contractor.id }.count
        let invoiceCount = store.invoices.filter { $0.contractorID == contractor.id }.count
        let invoiceWord = invoiceCount > 1 ? "factures" : "facture"
        return "\(quoteCount) devis · \(invoiceCount) \(invoiceWord)"
    }
}

#Preview {
    NavigationStack {
        ContractorsView()
    }
    .environment(AppStore.preview())
}
