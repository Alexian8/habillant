import SwiftUI

// MARK: - HPCard

/// Carte de base : fond adaptatif clair/sombre, coins arrondis 16, ombre discrète.
struct HPCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.background.secondary)
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
            )
    }
}

// MARK: - StatTile

/// Tuile compacte de statistique : icône teintée, valeur, libellé secondaire.
struct StatTile: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    init(title: String, value: String, systemImage: String, tint: Color) {
        self.title = title
        self.value = value
        self.systemImage = systemImage
        self.tint = tint
    }

    var body: some View {
        HPCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(value)
                    .font(.hpAmount)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - HPBadge

/// Pastille de statut : capsule teintée, texte de la même teinte.
struct HPBadge: View {
    let text: String
    let tint: Color

    init(text: String, tint: Color) {
        self.text = text
        self.tint = tint
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.15), in: Capsule())
            .foregroundStyle(tint)
    }
}

// MARK: - SectionHeader

/// Titre de section d'écran, avec icône optionnelle.
struct SectionHeader: View {
    let title: String
    let systemImage: String?

    init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.hpTerracotta)
            }
            Text(title)
                .font(.hpTitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - EmptyStateView

/// État vide standard d'une liste ou d'un écran.
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    init(title: String, message: String, systemImage: String) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        }
    }
}

// MARK: - ProgressRing

/// Anneau de progression animé (0...1).
struct ProgressRing: View {
    let progress: Double
    let tint: Color
    let lineWidth: CGFloat

    init(progress: Double, tint: Color = .hpTerracotta, lineWidth: CGFloat = 6) {
        self.progress = progress
        self.tint = tint
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)
        }
        .padding(lineWidth / 2)
    }
}

// MARK: - Previews

#Preview("HPCard") {
    HPCard {
        VStack(alignment: .leading, spacing: 6) {
            Text("Rénovation de la cuisine").font(.hpTitle)
            Text("Budget prévu : 18 500 €")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    .padding()
}

#Preview("StatTile") {
    HStack(spacing: 12) {
        StatTile(title: "Dépensé", value: "9 240 €", systemImage: "eurosign.circle.fill", tint: .hpTerracotta)
        StatTile(title: "Budget restant", value: "9 260 €", systemImage: "chart.pie.fill", tint: .hpSage)
    }
    .padding()
}

#Preview("HPBadge") {
    HStack(spacing: 8) {
        HPBadge(text: "En cours", tint: .hpTerracotta)
        HPBadge(text: "Payée", tint: .hpSage)
        HPBadge(text: "En retard", tint: .hpDanger)
    }
    .padding()
}

#Preview("SectionHeader") {
    VStack(spacing: 16) {
        SectionHeader("Projets actifs", systemImage: "hammer.fill")
        SectionHeader("Échéances")
    }
    .padding()
}

#Preview("EmptyStateView") {
    EmptyStateView(
        title: "Aucun document",
        message: "Ajoutez vos devis, factures et diagnostics pour les retrouver ici.",
        systemImage: "lock.doc.fill"
    )
}

#Preview("ProgressRing") {
    HStack(spacing: 24) {
        ProgressRing(progress: 0.35)
            .frame(width: 48, height: 48)
        ProgressRing(progress: 0.8, tint: .hpSage, lineWidth: 8)
            .frame(width: 64, height: 64)
    }
    .padding()
}
