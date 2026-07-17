import Foundation

// MARK: - Énumérations de domaine

/// Statut d'un projet de travaux (ordre canonique du cycle de vie).
public enum ProjectStatus: String, CaseIterable, Codable, Sendable {
    case idea, toStudy, toPrice, quotesRequested, quotesReceived,
         quoteAccepted, planned, inProgress, paused, done, dispute, cancelled

    /// Libellé français canonique.
    public var displayName: String {
        switch self {
        case .idea: return "Idée"
        case .toStudy: return "À étudier"
        case .toPrice: return "À chiffrer"
        case .quotesRequested: return "Devis demandés"
        case .quotesReceived: return "Devis reçus"
        case .quoteAccepted: return "Devis accepté"
        case .planned: return "Planifié"
        case .inProgress: return "En cours"
        case .paused: return "En pause"
        case .done: return "Terminé"
        case .dispute: return "Litige"
        case .cancelled: return "Annulé"
        }
    }

    public var systemImage: String {
        switch self {
        case .idea: return "lightbulb"
        case .toStudy: return "magnifyingglass"
        case .toPrice: return "eurosign.circle"
        case .quotesRequested: return "envelope"
        case .quotesReceived: return "tray.full"
        case .quoteAccepted: return "checkmark.circle"
        case .planned: return "calendar"
        case .inProgress: return "hammer.fill"
        case .paused: return "pause.circle"
        case .done: return "checkmark.seal.fill"
        case .dispute: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle"
        }
    }

    /// Vrai pour un projet engagé : planifié, en cours, en pause,
    /// ou en phase de devis.
    public var isActive: Bool {
        switch self {
        case .quotesRequested, .quotesReceived, .quoteAccepted,
             .planned, .inProgress, .paused:
            return true
        case .idea, .toStudy, .toPrice, .done, .dispute, .cancelled:
            return false
        }
    }
}

/// Priorité d'un projet.
public enum ProjectPriority: String, CaseIterable, Codable, Sendable {
    case low, normal, high, urgent

    public var displayName: String {
        switch self {
        case .low: return "Basse"
        case .normal: return "Normale"
        case .high: return "Haute"
        case .urgent: return "Urgente"
        }
    }
}

/// Catégorie d'une dépense.
public enum ExpenseCategory: String, CaseIterable, Codable, Sendable {
    case materials, labor, fees, equipment, permits, insurance, other

    public var displayName: String {
        switch self {
        case .materials: return "Matériaux"
        case .labor: return "Main-d'œuvre"
        case .fees: return "Frais annexes"
        case .equipment: return "Équipement"
        case .permits: return "Autorisations"
        case .insurance: return "Assurance"
        case .other: return "Autre"
        }
    }

    public var systemImage: String {
        switch self {
        case .materials: return "shippingbox.fill"
        case .labor: return "hammer.fill"
        case .fees: return "doc.plaintext.fill"
        case .equipment: return "wrench.and.screwdriver.fill"
        case .permits: return "checkmark.seal.fill"
        case .insurance: return "shield.fill"
        case .other: return "ellipsis.circle"
        }
    }
}

/// Statut d'un devis.
public enum QuoteStatus: String, CaseIterable, Codable, Sendable {
    case received, pending, accepted, declined, expired

    public var displayName: String {
        switch self {
        case .received: return "Reçu"
        case .pending: return "En attente"
        case .accepted: return "Accepté"
        case .declined: return "Refusé"
        case .expired: return "Expiré"
        }
    }
}

/// Statut d'une facture.
public enum InvoiceStatus: String, CaseIterable, Codable, Sendable {
    case toPay, partiallyPaid, paid, overdue, disputed

    public var displayName: String {
        switch self {
        case .toPay: return "À payer"
        case .partiallyPaid: return "Partiellement payée"
        case .paid: return "Payée"
        case .overdue: return "En retard"
        case .disputed: return "Contestée"
        }
    }
}

/// Nature d'un document du coffre-fort.
public enum DocumentKind: String, CaseIterable, Codable, Sendable {
    case invoice, quote, contract, insurance, diagnostic, plan, manual,
         warranty, permit, loan, grant, photo, video, other

    public var displayName: String {
        switch self {
        case .invoice: return "Facture"
        case .quote: return "Devis"
        case .contract: return "Contrat"
        case .insurance: return "Assurance"
        case .diagnostic: return "Diagnostic"
        case .plan: return "Plan"
        case .manual: return "Notice"
        case .warranty: return "Garantie"
        case .permit: return "Autorisation"
        case .loan: return "Prêt"
        case .grant: return "Aide"
        case .photo: return "Photo"
        case .video: return "Vidéo"
        case .other: return "Autre"
        }
    }

    public var systemImage: String {
        switch self {
        case .invoice: return "doc.text.fill"
        case .quote: return "doc.plaintext"
        case .contract: return "signature"
        case .insurance: return "shield.fill"
        case .diagnostic: return "stethoscope"
        case .plan: return "map.fill"
        case .manual: return "book.fill"
        case .warranty: return "checkmark.shield.fill"
        case .permit: return "building.columns.fill"
        case .loan: return "banknote.fill"
        case .grant: return "gift.fill"
        case .photo: return "photo.fill"
        case .video: return "video.fill"
        case .other: return "doc.fill"
        }
    }
}

/// Étape des travaux à laquelle une photo a été prise.
public enum WorkStage: String, CaseIterable, Codable, Sendable {
    case before, during, after

    public var displayName: String {
        switch self {
        case .before: return "Avant"
        case .during: return "Pendant"
        case .after: return "Après"
        }
    }
}

/// État de synchronisation d'un fichier (voir docs/00-fondations.md §3).
public enum SyncState: String, CaseIterable, Codable, Sendable {
    case synced, syncing, offlineAvailable, error, pendingUpload

    public var displayName: String {
        switch self {
        case .synced: return "Synchronisé"
        case .syncing: return "Synchronisation en cours"
        case .offlineAvailable: return "Disponible hors ligne"
        case .error: return "Erreur de synchronisation"
        case .pendingUpload: return "Fichier en attente"
        }
    }

    public var systemImage: String {
        switch self {
        case .synced: return "checkmark.icloud.fill"
        case .syncing: return "arrow.triangle.2.circlepath.icloud"
        case .offlineAvailable: return "arrow.down.circle.fill"
        case .error: return "exclamationmark.icloud.fill"
        case .pendingUpload: return "icloud.and.arrow.up"
        }
    }
}

// MARK: - Entités de domaine

/// Logement géré par l'utilisateur.
public struct Property: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var name: String
    public var type: String
    public var address: String
    public var city: String
    public var surfaceM2: Double
    public var constructionYear: Int

    public init(id: UUID = UUID(), name: String, type: String,
                address: String, city: String,
                surfaceM2: Double, constructionYear: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.address = address
        self.city = city
        self.surfaceM2 = surfaceM2
        self.constructionYear = constructionYear
    }
}

/// Pièce d'un logement, rattachée à un niveau (`floorName`).
public struct Room: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var floorName: String
    public var name: String
    /// Nom de symbole SF représentant la pièce.
    public var icon: String
    public var areaM2: Double?

    public init(id: UUID = UUID(), propertyID: UUID, floorName: String,
                name: String, icon: String, areaM2: Double? = nil) {
        self.id = id
        self.propertyID = propertyID
        self.floorName = floorName
        self.name = name
        self.icon = icon
        self.areaM2 = areaM2
    }
}

/// Projet de travaux (rénovation, isolation, etc.).
public struct Project: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var title: String
    public var details: String
    public var status: ProjectStatus
    public var priority: ProjectPriority
    public var budgetPlanned: Money
    public var startDate: Date?
    public var endDatePlanned: Date?
    /// Avancement de 0 à 1.
    public var progress: Double
    public var roomIDs: [UUID]

    public init(id: UUID = UUID(), propertyID: UUID, title: String,
                details: String = "", status: ProjectStatus,
                priority: ProjectPriority = .normal, budgetPlanned: Money,
                startDate: Date? = nil, endDatePlanned: Date? = nil,
                progress: Double = 0, roomIDs: [UUID] = []) {
        self.id = id
        self.propertyID = propertyID
        self.title = title
        self.details = details
        self.status = status
        self.priority = priority
        self.budgetPlanned = budgetPlanned
        self.startDate = startDate
        self.endDatePlanned = endDatePlanned
        self.progress = progress
        self.roomIDs = roomIDs
    }
}

/// Tâche d'un projet (nommée ainsi pour éviter le conflit avec `Swift.Task`).
public struct ProjectTask: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var projectID: UUID
    public var title: String
    public var dueDate: Date?
    public var isDone: Bool

    public init(id: UUID = UUID(), projectID: UUID, title: String,
                dueDate: Date? = nil, isDone: Bool = false) {
        self.id = id
        self.projectID = projectID
        self.title = title
        self.dueDate = dueDate
        self.isDone = isDone
    }
}

/// Dépense réelle, toujours exprimée en trois montants HT / TVA / TTC.
public struct Expense: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var projectID: UUID?
    public var roomID: UUID?
    public var contractorID: UUID?
    public var label: String
    public var category: ExpenseCategory
    public var amountHT: Money
    public var amountVAT: Money
    public var amountTTC: Money
    /// Taux de TVA en points de base (1000 = 10,00 %).
    public var vatRateBps: Int
    public var date: Date
    public var paymentMethod: String

    public init(id: UUID = UUID(), propertyID: UUID, projectID: UUID? = nil,
                roomID: UUID? = nil, contractorID: UUID? = nil,
                label: String, category: ExpenseCategory,
                amountHT: Money, amountVAT: Money, amountTTC: Money,
                vatRateBps: Int, date: Date,
                paymentMethod: String = "Carte bancaire") {
        self.id = id
        self.propertyID = propertyID
        self.projectID = projectID
        self.roomID = roomID
        self.contractorID = contractorID
        self.label = label
        self.category = category
        self.amountHT = amountHT
        self.amountVAT = amountVAT
        self.amountTTC = amountTTC
        self.vatRateBps = vatRateBps
        self.date = date
        self.paymentMethod = paymentMethod
    }
}

/// Devis reçu d'un artisan.
public struct Quote: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var projectID: UUID?
    public var contractorID: UUID
    public var reference: String
    public var issuedAt: Date
    public var validUntil: Date?
    public var amountHT: Money
    public var amountVAT: Money
    public var amountTTC: Money
    public var status: QuoteStatus
    public var paymentTerms: String

    public init(id: UUID = UUID(), propertyID: UUID, projectID: UUID? = nil,
                contractorID: UUID, reference: String, issuedAt: Date,
                validUntil: Date? = nil, amountHT: Money, amountVAT: Money,
                amountTTC: Money, status: QuoteStatus,
                paymentTerms: String = "") {
        self.id = id
        self.propertyID = propertyID
        self.projectID = projectID
        self.contractorID = contractorID
        self.reference = reference
        self.issuedAt = issuedAt
        self.validUntil = validUntil
        self.amountHT = amountHT
        self.amountVAT = amountVAT
        self.amountTTC = amountTTC
        self.status = status
        self.paymentTerms = paymentTerms
    }
}

/// Facture émise par un artisan ou un fournisseur.
public struct Invoice: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var projectID: UUID?
    public var contractorID: UUID?
    public var reference: String
    public var issuedAt: Date
    public var dueDate: Date?
    public var amountHT: Money
    public var amountVAT: Money
    public var amountTTC: Money
    public var status: InvoiceStatus

    public init(id: UUID = UUID(), propertyID: UUID, projectID: UUID? = nil,
                contractorID: UUID? = nil, reference: String, issuedAt: Date,
                dueDate: Date? = nil, amountHT: Money, amountVAT: Money,
                amountTTC: Money, status: InvoiceStatus) {
        self.id = id
        self.propertyID = propertyID
        self.projectID = projectID
        self.contractorID = contractorID
        self.reference = reference
        self.issuedAt = issuedAt
        self.dueDate = dueDate
        self.amountHT = amountHT
        self.amountVAT = amountVAT
        self.amountTTC = amountTTC
        self.status = status
    }
}

/// Document du coffre-fort (nommé ainsi pour éviter le conflit
/// avec `DocumentGroup`).
public struct VaultDocument: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var name: String
    public var kind: DocumentKind
    public var fileSizeBytes: Int
    public var addedAt: Date
    public var isFavorite: Bool
    public var isSensitive: Bool
    public var tags: [String]
    public var syncState: SyncState

    public init(id: UUID = UUID(), propertyID: UUID, name: String,
                kind: DocumentKind, fileSizeBytes: Int, addedAt: Date,
                isFavorite: Bool = false, isSensitive: Bool = false,
                tags: [String] = [], syncState: SyncState = .synced) {
        self.id = id
        self.propertyID = propertyID
        self.name = name
        self.kind = kind
        self.fileSizeBytes = fileSizeBytes
        self.addedAt = addedAt
        self.isFavorite = isFavorite
        self.isSensitive = isSensitive
        self.tags = tags
        self.syncState = syncState
    }
}

/// Artisan ou entreprise du bâtiment.
public struct Contractor: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var companyName: String
    public var trade: String
    public var city: String
    public var phone: String
    public var email: String
    public var siret: String
    public var insuranceValidUntil: Date?
    /// Note de 0 à 5.
    public var rating: Int
    public var notes: String

    public init(id: UUID = UUID(), companyName: String, trade: String,
                city: String, phone: String, email: String, siret: String,
                insuranceValidUntil: Date? = nil, rating: Int = 0,
                notes: String = "") {
        self.id = id
        self.companyName = companyName
        self.trade = trade
        self.city = city
        self.phone = phone
        self.email = email
        self.siret = siret
        self.insuranceValidUntil = insuranceValidUntil
        self.rating = rating
        self.notes = notes
    }
}

/// Équipement du logement (chaudière, VMC, électroménager…).
public struct Equipment: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var roomID: UUID?
    public var name: String
    public var category: String
    public var brand: String
    public var model: String
    public var serialNumber: String
    public var purchaseDate: Date?
    public var price: Money?

    public init(id: UUID = UUID(), propertyID: UUID, roomID: UUID? = nil,
                name: String, category: String, brand: String = "",
                model: String = "", serialNumber: String = "",
                purchaseDate: Date? = nil, price: Money? = nil) {
        self.id = id
        self.propertyID = propertyID
        self.roomID = roomID
        self.name = name
        self.category = category
        self.brand = brand
        self.model = model
        self.serialNumber = serialNumber
        self.purchaseDate = purchaseDate
        self.price = price
    }
}

/// Garantie couvrant un équipement.
public struct Warranty: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var equipmentID: UUID?
    public var label: String
    public var providerName: String
    public var startDate: Date
    public var endDate: Date

    public init(id: UUID = UUID(), equipmentID: UUID? = nil, label: String,
                providerName: String, startDate: Date, endDate: Date) {
        self.id = id
        self.equipmentID = equipmentID
        self.label = label
        self.providerName = providerName
        self.startDate = startDate
        self.endDate = endDate
    }
}

/// Entretien récurrent (ramonage, entretien chaudière…).
public struct MaintenanceTask: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var equipmentID: UUID?
    public var label: String
    public var frequencyMonths: Int
    public var nextDueDate: Date

    public init(id: UUID = UUID(), propertyID: UUID, equipmentID: UUID? = nil,
                label: String, frequencyMonths: Int, nextDueDate: Date) {
        self.id = id
        self.propertyID = propertyID
        self.equipmentID = equipmentID
        self.label = label
        self.frequencyMonths = frequencyMonths
        self.nextDueDate = nextDueDate
    }
}

/// Photo de chantier ; le prototype affiche un symbole SF en guise d'image.
public struct PhotoItem: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var propertyID: UUID
    public var projectID: UUID?
    public var roomID: UUID?
    public var caption: String
    public var takenAt: Date
    public var stage: WorkStage
    public var systemImagePlaceholder: String

    public init(id: UUID = UUID(), propertyID: UUID, projectID: UUID? = nil,
                roomID: UUID? = nil, caption: String, takenAt: Date,
                stage: WorkStage, systemImagePlaceholder: String = "photo.fill") {
        self.id = id
        self.propertyID = propertyID
        self.projectID = projectID
        self.roomID = roomID
        self.caption = caption
        self.takenAt = takenAt
        self.stage = stage
        self.systemImagePlaceholder = systemImagePlaceholder
    }
}
