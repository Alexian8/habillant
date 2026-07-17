import SwiftUI
import HabitPlanKit

// Palette canonique — docs/00-fondations.md §2.
extension Color {
    /// Bleu Ardoise #2C4A63 — couleur principale.
    static let hpSlate = Color(red: 44 / 255, green: 74 / 255, blue: 99 / 255)
    /// Terracotta #E07A5F — accent, actions.
    static let hpTerracotta = Color(red: 224 / 255, green: 122 / 255, blue: 95 / 255)
    /// Vert Sauge #81B29A — validation, budget sain.
    static let hpSage = Color(red: 129 / 255, green: 178 / 255, blue: 154 / 255)
    /// Sable #F4F1EC — fonds clairs, cartes.
    static let hpSand = Color(red: 244 / 255, green: 241 / 255, blue: 236 / 255)
    /// Encre #1C2733 — texte principal, fonds sombres.
    static let hpInk = Color(red: 28 / 255, green: 39 / 255, blue: 51 / 255)
    /// Ambre #E9C46A — avertissements, échéances proches.
    static let hpAmber = Color(red: 233 / 255, green: 196 / 255, blue: 106 / 255)
    /// Brique #D64545 — dépassements, retards, erreurs.
    static let hpDanger = Color(red: 214 / 255, green: 69 / 255, blue: 69 / 255)
}

extension ProjectStatus {
    var tint: Color {
        switch self {
        case .idea, .toStudy, .toPrice:
            return .hpAmber
        case .quotesRequested, .quotesReceived, .quoteAccepted:
            return .hpSlate
        case .planned, .inProgress:
            return .hpTerracotta
        case .done:
            return .hpSage
        case .paused:
            return .gray
        case .dispute, .cancelled:
            return .hpDanger
        }
    }
}

extension InvoiceStatus {
    var tint: Color {
        switch self {
        case .paid:
            return .hpSage
        case .overdue, .disputed:
            return .hpDanger
        case .toPay, .partiallyPaid:
            return .hpSlate
        }
    }
}

#Preview("Palette") {
    let colors: [(String, Color)] = [
        ("hpSlate", .hpSlate), ("hpTerracotta", .hpTerracotta), ("hpSage", .hpSage),
        ("hpSand", .hpSand), ("hpInk", .hpInk), ("hpAmber", .hpAmber), ("hpDanger", .hpDanger)
    ]
    return VStack(spacing: 8) {
        ForEach(colors, id: \.0) { name, color in
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 44, height: 28)
                Text(name).font(.callout.monospaced())
                Spacer()
            }
        }
    }
    .padding()
}
