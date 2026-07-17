import Foundation

/// Montant monétaire en centimes entiers, associé à un code devise ISO 4217.
/// Convention du projet : tous les calculs se font en centimes (`Int`),
/// jamais en virgule flottante.
public struct Money: Hashable, Codable, Sendable, Comparable {
    /// Montant en centimes (ex. 18 500 € → 1 850 000).
    public var cents: Int
    /// Code devise ISO 4217 (`"EUR"` par défaut).
    public var currencyCode: String

    public init(cents: Int, currencyCode: String = "EUR") {
        self.cents = cents
        self.currencyCode = currencyCode
    }

    /// Construit un montant à partir d'une valeur en euros (arrondie au centime).
    public static func euros(_ euros: Double) -> Money {
        Money(cents: Int((euros * 100).rounded()))
    }

    /// Montant nul en euros.
    public static let zero = Money(cents: 0)

    /// Chaîne monétaire au format français : sans décimales si le montant est
    /// rond (ex. « 18 500 € »), sinon deux décimales (ex. « 951,50 € »).
    public var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.currencyCode = currencyCode
        let isRound = cents % 100 == 0
        formatter.minimumFractionDigits = isRound ? 0 : 2
        formatter.maximumFractionDigits = isRound ? 0 : 2
        let value = Double(cents) / 100.0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) \(currencyCode)"
    }

    public static func + (l: Money, r: Money) -> Money {
        Money(cents: l.cents + r.cents, currencyCode: l.currencyCode)
    }

    public static func - (l: Money, r: Money) -> Money {
        Money(cents: l.cents - r.cents, currencyCode: l.currencyCode)
    }

    public static func < (l: Money, r: Money) -> Bool {
        l.cents < r.cents
    }
}
