import SwiftUI

// Typographie : SF Pro système, titres en Rounded, chiffres financiers
// en chasse fixe — docs/00-fondations.md §2.
extension Font {
    static var hpLargeTitle: Font {
        .system(.largeTitle, design: .rounded).bold()
    }

    static var hpTitle: Font {
        .system(.title2, design: .rounded).bold()
    }

    static var hpAmount: Font {
        .title3.weight(.semibold).monospacedDigit()
    }
}

#Preview("Typographie") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Tableau de bord").font(.hpLargeTitle)
        Text("Rénovation de la cuisine").font(.hpTitle)
        Text("18 500 €").font(.hpAmount)
    }
    .padding()
}
