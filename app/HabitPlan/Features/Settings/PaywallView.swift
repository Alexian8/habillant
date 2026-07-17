import SwiftUI
import HabitPlanKit

/// Offres d'abonnement présentées sur le paywall
/// (chiffres canoniques — docs/00-fondations.md §6).
private enum PaywallPlan: String, CaseIterable, Identifiable {
    case monthly, annual, family

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly: return "Mensuel"
        case .annual: return "Annuel"
        case .family: return "Famille"
        }
    }

    var price: String {
        switch self {
        case .monthly: return "4,99 €"
        case .annual: return "39,99 €"
        case .family: return "59,99 €"
        }
    }

    var period: String {
        switch self {
        case .monthly: return "par mois"
        case .annual, .family: return "par an"
        }
    }

    var note: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "2 mois offerts"
        case .family: return "Jusqu'à 6 personnes"
        }
    }

    var noteTint: Color {
        self == .annual ? .hpTerracotta : .hpSlate
    }
}

/// Écran d'abonnement Premium, présenté en sheet depuis les réglages.
/// L'achat est simulé : aucun passage par StoreKit dans le prototype.
struct PaywallView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PaywallPlan = .annual

    private struct Benefit: Identifiable {
        let icon: String
        let title: String
        let detail: String
        var id: String { title }
    }

    private static let benefits: [Benefit] = [
        Benefit(icon: "building.2.fill", title: "Plusieurs logements",
                detail: "Principal, secondaire, locatif : tout au même endroit."),
        Benefit(icon: "hammer.fill", title: "Projets illimités",
                detail: "Suivez autant de chantiers que nécessaire."),
        Benefit(icon: "icloud.fill", title: "50 Go de stockage",
                detail: "Documents, plans et photos en haute qualité."),
        Benefit(icon: "doc.viewfinder.fill", title: "OCR avancé",
                detail: "Montants et échéances extraits automatiquement."),
        Benefit(icon: "chart.bar.doc.horizontal.fill", title: "Comparaison de devis",
                detail: "Les offres de vos artisans, côte à côte."),
        Benefit(icon: "hand.raised.fill", title: "Sans publicité",
                detail: "Aucune distraction, nulle part.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    benefitList
                    planPicker
                    subscribeArea
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 680)
        #endif
    }

    // MARK: En-tête

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: "house.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(
                    LinearGradient(
                        colors: [.hpSlate, .hpInk],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            Text("Passez à Habit Plan Premium")
                .font(.hpTitle)
                .multilineTextAlignment(.center)
            Text("Gérez votre maison, du plan à la facture — sans limites.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: Avantages

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Self.benefits) { benefit in
                HStack(spacing: 12) {
                    Image(systemName: benefit.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.hpTerracotta)
                        .frame(width: 32, height: 32)
                        .background(Color.hpTerracotta.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(benefit.title)
                            .font(.subheadline.weight(.semibold))
                        Text(benefit.detail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: Offres

    private var planPicker: some View {
        VStack(spacing: 10) {
            ForEach(PaywallPlan.allCases) { plan in
                PlanCard(plan: plan, isSelected: plan == selectedPlan) {
                    selectedPlan = plan
                }
            }
        }
    }

    // MARK: Souscription

    private var subscribeArea: some View {
        VStack(spacing: 14) {
            Button {
                // Simulation d'achat : bascule simplement le compte en Premium.
                store.isPremium = true
                dismiss()
            } label: {
                Text("Commencer — 14 jours d'essai gratuit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.hpTerracotta, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Text("Sans engagement. Vos données restent exportables gratuitement, abonnement ou non.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Plus tard") { dismiss() }
                .buttonStyle(.plain)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Carte d'offre

private struct PlanCard: View {
    let plan: PaywallPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.hpTerracotta : Color.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.headline)
                    if let note = plan.note {
                        HPBadge(text: note, tint: plan.noteTint)
                    }
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 1) {
                    Text(plan.price)
                        .font(.hpAmount)
                    Text(plan.period)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.background.secondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.hpTerracotta : Color.secondary.opacity(0.25),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
        .environment(AppStore.preview())
}
