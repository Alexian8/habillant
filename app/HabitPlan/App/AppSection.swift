import Foundation

/// Sections de navigation de l'application (sidebar iPad/Mac, onglets iPhone).
enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard, projects, budget, quotes, vault, rooms, contractors, equipment, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:   return "Tableau de bord"
        case .projects:    return "Projets"
        case .budget:      return "Budget"
        case .quotes:      return "Devis & factures"
        case .vault:       return "Coffre-fort"
        case .rooms:       return "Pièces & plans"
        case .contractors: return "Artisans"
        case .equipment:   return "Équipements"
        case .settings:    return "Réglages"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:   return "gauge.with.needle"
        case .projects:    return "hammer.fill"
        case .budget:      return "eurosign.circle.fill"
        case .quotes:      return "doc.plaintext.fill"
        case .vault:       return "lock.doc.fill"
        case .rooms:       return "square.split.bottomrightquarter.fill"
        case .contractors: return "person.2.fill"
        case .equipment:   return "wrench.and.screwdriver.fill"
        case .settings:    return "gearshape.fill"
        }
    }
}
