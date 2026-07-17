import SwiftUI
import HabitPlanKit

/// Écran d'accueil : synthèse du logement sélectionné — budget, avancement
/// des travaux, échéances à traiter, dépenses et dernières photos.
struct DashboardView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                budgetGrid
                progressCard
                todoCard
                categoriesCard
                photosCard
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("Tableau de bord")
    }

    // MARK: - En-tête

    @ViewBuilder
    private var header: some View {
        if let property = store.selectedProperty {
            VStack(alignment: .leading, spacing: 4) {
                Text(property.name)
                    .font(.hpLargeTitle)
                Text("\(property.address), \(property.city)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Label("\(Int(property.surfaceM2.rounded())) m²", systemImage: "ruler")
                    Label(String(property.constructionYear), systemImage: "calendar")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        } else {
            EmptyStateView(
                title: "Aucun logement",
                message: "Sélectionnez ou ajoutez un logement pour voir son tableau de bord.",
                systemImage: "house.fill"
            )
        }
    }

    // MARK: - Budget

    private var budgetGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            StatTile(
                title: "Budget prévu",
                value: store.totalBudgetPlanned.formatted,
                systemImage: "eurosign.circle.fill",
                tint: .hpSlate
            )
            StatTile(
                title: "Déjà dépensé",
                value: store.totalSpent.formatted,
                systemImage: "creditcard.fill",
                tint: .hpTerracotta
            )
            StatTile(
                title: "Restant",
                value: store.remainingBudget.formatted,
                systemImage: "chart.pie.fill",
                tint: store.remainingBudget < .zero ? .hpDanger : .hpSage
            )
        }
    }

    // MARK: - Progression des travaux

    private var averageProgress: Double {
        let projects = store.activeProjects
        guard !projects.isEmpty else { return 0 }
        return projects.reduce(0) { $0 + $1.progress } / Double(projects.count)
    }

    private var progressCard: some View {
        HPCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Progression des travaux", systemImage: "hammer.fill")
                if store.activeProjects.isEmpty {
                    Text("Aucun projet actif pour le moment.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.activeProjects) { project in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.title)
                                    .font(.subheadline.weight(.medium))
                                    .lineLimit(1)
                                HPBadge(text: project.status.displayName, tint: project.status.tint)
                            }
                            Spacer(minLength: 8)
                            ProgressRing(progress: project.progress, tint: project.status.tint)
                                .frame(width: 40, height: 40)
                        }
                        Divider()
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Avancement global")
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text(averageProgress.formatted(.percent.precision(.fractionLength(0))))
                                .font(.subheadline.weight(.semibold).monospacedDigit())
                                .foregroundStyle(Color.hpTerracotta)
                        }
                        ProportionalBar(fraction: averageProgress, tint: .hpTerracotta)
                    }
                }
            }
        }
    }

    // MARK: - À traiter

    private var todoCard: some View {
        let invoices = store.overdueInvoices
        let quotes = store.pendingQuotes
        let warranties = store.expiringWarranties(within: 60)
        let maintenance = store.upcomingMaintenance(within: 30)
        let isEmpty = invoices.isEmpty && quotes.isEmpty && warranties.isEmpty && maintenance.isEmpty

        return HPCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("À traiter", systemImage: "tray.full.fill")
                if isEmpty {
                    EmptyStateView(
                        title: "Rien à traiter",
                        message: "Aucune échéance ni relance en attente. Tout est à jour.",
                        systemImage: "checkmark.circle.fill"
                    )
                } else {
                    ForEach(invoices) { invoice in
                        ActionRow(
                            systemImage: "exclamationmark.circle.fill",
                            tint: .hpDanger,
                            title: "Facture \(invoice.reference) en retard",
                            subtitle: store.contractor(invoice.contractorID)?.companyName,
                            value: Text(invoice.amountTTC.formatted)
                                .font(.hpAmount)
                                .foregroundStyle(Color.hpDanger)
                        )
                    }
                    ForEach(quotes) { quote in
                        ActionRow(
                            systemImage: "doc.plaintext.fill",
                            tint: .hpSlate,
                            title: "Devis \(quote.reference) en attente",
                            subtitle: store.contractor(quote.contractorID)?.companyName,
                            value: Text(quote.amountTTC.formatted)
                                .font(.hpAmount)
                        )
                    }
                    ForEach(warranties) { warranty in
                        ActionRow(
                            systemImage: "checkmark.shield.fill",
                            tint: .hpAmber,
                            title: "Garantie « \(warranty.label) » expire bientôt",
                            subtitle: warranty.providerName,
                            value: Text(warranty.endDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        )
                    }
                    ForEach(maintenance) { task in
                        ActionRow(
                            systemImage: "wrench.and.screwdriver.fill",
                            tint: .hpTerracotta,
                            title: task.label,
                            subtitle: "Entretien à prévoir",
                            value: Text(task.nextDueDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Dépenses par catégorie

    private var categoriesCard: some View {
        let totals = store.spentByCategory()
        let maxCents = totals.first?.total.cents ?? 0

        return HPCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Dépenses par catégorie", systemImage: "chart.bar.fill")
                if totals.isEmpty {
                    Text("Aucune dépense enregistrée.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(totals, id: \.category) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label(entry.category.displayName, systemImage: entry.category.systemImage)
                                    .font(.subheadline.weight(.medium))
                                    .lineLimit(1)
                                Spacer(minLength: 8)
                                Text(entry.total.formatted)
                                    .font(.hpAmount)
                            }
                            ProportionalBar(
                                fraction: maxCents > 0 ? Double(entry.total.cents) / Double(maxCents) : 0,
                                tint: .hpSlate
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Dernières photos

    private var latestPhotos: [PhotoItem] {
        guard let id = store.selectedPropertyID else { return [] }
        return store.photos
            .filter { $0.propertyID == id }
            .sorted { $0.takenAt > $1.takenAt }
    }

    private var photosCard: some View {
        HPCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Dernières photos", systemImage: "photo.on.rectangle.angled")
                if latestPhotos.isEmpty {
                    Text("Aucune photo de chantier.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(latestPhotos) { photo in
                                VStack(alignment: .leading, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.hpSand)
                                        .frame(width: 120, height: 90)
                                        .overlay {
                                            Image(systemName: photo.systemImagePlaceholder)
                                                .font(.system(size: 28))
                                                .foregroundStyle(Color.hpSlate.opacity(0.6))
                                        }
                                    Text(photo.caption)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                        .frame(width: 120, alignment: .leading)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Sous-vues

/// Ligne d'échéance : icône teintée, libellé, valeur alignée à droite.
private struct ActionRow: View {
    let systemImage: String
    let tint: Color
    let title: String
    let subtitle: String?
    let value: Text

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            value
                .lineLimit(1)
        }
    }
}

/// Barre horizontale proportionnelle (0...1), sans dépendance à Swift Charts.
private struct ProportionalBar: View {
    let fraction: Double
    let tint: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(tint.opacity(0.15))
                Rectangle()
                    .fill(tint)
                    .frame(width: geometry.size.width * min(max(fraction, 0), 1))
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack { DashboardView() }.environment(AppStore.preview())
}
