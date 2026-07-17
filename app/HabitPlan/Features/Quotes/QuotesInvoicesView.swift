import SwiftUI
import HabitPlanKit

/// Écran Devis & factures : deux onglets segmentés sur le logement sélectionné.
struct QuotesInvoicesView: View {
    private enum Tab: String, CaseIterable, Identifiable {
        case quotes = "Devis"
        case invoices = "Factures"
        var id: String { rawValue }
    }

    @Environment(AppStore.self) private var store
    @State private var tab: Tab = .quotes

    var body: some View {
        VStack(spacing: 0) {
            Picker("Type de document", selection: $tab) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal)
            .padding(.vertical, 8)

            switch tab {
            case .quotes:
                quotesTab
            case .invoices:
                invoicesTab
            }
        }
        .navigationTitle("Devis & factures")
    }

    // MARK: - Données dérivées

    private var propertyQuotes: [Quote] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.quotes
            .filter { $0.propertyID == id }
            .sorted { $0.issuedAt > $1.issuedAt }
    }

    private var propertyInvoices: [Invoice] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.invoices
            .filter { $0.propertyID == id }
            .sorted { $0.issuedAt > $1.issuedAt }
    }

    /// Somme TTC des factures restant à régler (à payer, partielles, en retard).
    private var totalOutstanding: Money {
        let unpaid: Set<InvoiceStatus> = [.toPay, .partiallyPaid, .overdue]
        let cents = propertyInvoices
            .filter { unpaid.contains($0.status) }
            .reduce(0) { $0 + $1.amountTTC.cents }
        return Money(cents: cents)
    }

    // MARK: - Onglet Devis

    @ViewBuilder
    private var quotesTab: some View {
        if propertyQuotes.isEmpty {
            EmptyStateView(
                title: "Aucun devis",
                message: "Les devis reçus de vos artisans apparaîtront ici.",
                systemImage: "doc.plaintext"
            )
            Spacer(minLength: 0)
        } else {
            List {
                Section {
                    ForEach(propertyQuotes) { quote in
                        QuoteRow(quote: quote)
                    }
                } footer: {
                    comparisonFootnote
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.inset)
            #endif
        }
    }

    // MARK: - Onglet Factures

    @ViewBuilder
    private var invoicesTab: some View {
        if propertyInvoices.isEmpty {
            EmptyStateView(
                title: "Aucune facture",
                message: "Les factures de vos travaux apparaîtront ici.",
                systemImage: "doc.text"
            )
            Spacer(minLength: 0)
        } else {
            VStack(spacing: 0) {
                HPCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total à régler")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(totalOutstanding.formatted)
                                .font(.hpAmount)
                        }
                        Spacer()
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.hpTerracotta)
                            .frame(width: 32, height: 32)
                            .background(Color.hpTerracotta.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                List {
                    Section {
                        ForEach(propertyInvoices) { invoice in
                            InvoiceRow(invoice: invoice)
                        }
                    } footer: {
                        comparisonFootnote
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #else
                .listStyle(.inset)
                #endif
            }
        }
    }

    private var comparisonFootnote: some View {
        Text("Comparaison intelligente des devis : à venir (V2)")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Ligne de devis

private struct QuoteRow: View {
    @Environment(AppStore.self) private var store
    let quote: Quote

    /// Un devis reste actionnable tant qu'il n'a pas été tranché.
    private var isActionable: Bool {
        quote.status == .received || quote.status == .pending
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(quote.reference)
                        .font(.headline)
                    Text(store.contractor(quote.contractorID)?.companyName ?? "Artisan inconnu")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(quote.amountTTC.formatted)
                        .font(.hpAmount)
                    HPBadge(text: quote.status.displayName, tint: quote.status.tint)
                }
                if isActionable {
                    Menu {
                        Button {
                            store.setQuoteStatus(quote.id, status: .accepted)
                        } label: {
                            Label("Accepter", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive) {
                            store.setQuoteStatus(quote.id, status: .declined)
                        } label: {
                            Label("Refuser", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.secondary)
                    }
                    .fixedSize()
                }
            }
            HStack(spacing: 12) {
                Text("Émis le \(quote.issuedAt, format: .dateTime.day().month().year())")
                if let validUntil = quote.validUntil {
                    Text("Valide jusqu'au \(validUntil, format: .dateTime.day().month().year())")
                        .foregroundStyle(validityColor(for: validUntil))
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        #if os(iOS)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if isActionable {
                Button {
                    store.setQuoteStatus(quote.id, status: .accepted)
                } label: {
                    Label("Accepter", systemImage: "checkmark.circle")
                }
                .tint(.hpSage)
                Button {
                    store.setQuoteStatus(quote.id, status: .declined)
                } label: {
                    Label("Refuser", systemImage: "xmark.circle")
                }
                .tint(.hpDanger)
            }
        }
        #endif
    }

    /// Brique si la validité est dépassée, ambre si elle expire sous 15 jours.
    private func validityColor(for date: Date) -> Color {
        if date < .now { return .hpDanger }
        if let limit = Calendar.current.date(byAdding: .day, value: 15, to: .now),
           date <= limit {
            return .hpAmber
        }
        return .secondary
    }
}

// MARK: - Ligne de facture

private struct InvoiceRow: View {
    @Environment(AppStore.self) private var store
    let invoice: Invoice

    private var isOverdue: Bool {
        guard let dueDate = invoice.dueDate else { return false }
        return dueDate < .now && invoice.status != .paid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(invoice.reference)
                        .font(.headline)
                    if let name = store.contractor(invoice.contractorID)?.companyName {
                        Text(name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(invoice.amountTTC.formatted)
                        .font(.hpAmount)
                    HPBadge(text: invoice.status.displayName, tint: invoice.status.tint)
                }
            }
            HStack(spacing: 12) {
                Text("Émise le \(invoice.issuedAt, format: .dateTime.day().month().year())")
                if let dueDate = invoice.dueDate {
                    Text("Échéance le \(dueDate, format: .dateTime.day().month().year())")
                        .foregroundStyle(isOverdue ? Color.hpDanger : Color.secondary)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Teinte des statuts de devis

private extension QuoteStatus {
    var tint: Color {
        switch self {
        case .accepted:
            return .hpSage
        case .declined, .expired:
            return .hpDanger
        case .received, .pending:
            return .hpSlate
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        QuotesInvoicesView()
    }
    .environment(AppStore.preview())
}
