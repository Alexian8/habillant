import SwiftUI
import HabitPlanKit

// Locale de formatage du prototype, cohérente avec `Money.formatted`.
private let frenchLocale = Locale(identifier: "fr_FR")

/// Coffre-fort numérique du logement : documents filtrables par nature,
/// recherche sur le nom et les tags, état de synchronisation par fichier.
/// Espace volontairement sans aucune promotion.
struct VaultView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedKind: DocumentKind?
    @State private var searchText = ""
    @State private var showingImportAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if propertyDocuments.isEmpty {
                    emptyVault
                } else {
                    content
                }
            }
            .navigationTitle("Coffre-fort")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingImportAlert = true
                    } label: {
                        Label("Importer un document", systemImage: "plus")
                    }
                }
            }
            .alert("Bientôt disponible", isPresented: $showingImportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("L'import de documents arrive dans la prochaine itération du prototype.")
            }
        }
    }

    // MARK: - Contenu

    private var content: some View {
        VStack(spacing: 0) {
            kindFilterBar
            documentList
        }
        .searchable(text: $searchText, prompt: "Nom ou tag")
    }

    private var documentList: some View {
        List {
            Section {
                summaryHeader
            }
            Section {
                if filteredDocuments.isEmpty {
                    EmptyStateView(
                        title: "Aucun résultat",
                        message: "Modifiez la recherche ou le filtre par type.",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    ForEach(filteredDocuments) { document in
                        VaultDocumentRow(document: document)
                    }
                }
            }
        }
        .hpVaultListStyle()
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(countText)
                .font(.subheadline.weight(.semibold))
            Label("Chiffré de bout en transit · hébergé en Union européenne",
                  systemImage: "lock.shield")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var kindFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "Toutes",
                           systemImage: "square.grid.2x2",
                           isSelected: selectedKind == nil) {
                    selectedKind = nil
                }
                ForEach(availableKinds, id: \.self) { kind in
                    filterChip(title: kind.displayName,
                               systemImage: kind.systemImage,
                               isSelected: selectedKind == kind) {
                        selectedKind = kind
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private func filterChip(title: String, systemImage: String,
                            isSelected: Bool,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(isSelected ? Color.hpSlate : Color.gray.opacity(0.15),
                            in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var emptyVault: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                title: "Coffre-fort vide",
                message: "Importez vos devis, factures, diagnostics et notices pour les retrouver ici, où que vous soyez.",
                systemImage: "lock.doc.fill"
            )
            .fixedSize(horizontal: false, vertical: true)
            Button("Importer un document") {
                showingImportAlert = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.hpTerracotta)
        }
    }

    // MARK: - Données dérivées

    /// Documents du logement sélectionné, plus récents d'abord.
    private var propertyDocuments: [VaultDocument] {
        guard let propertyID = store.selectedPropertyID else { return [] }
        return store.documents
            .filter { $0.propertyID == propertyID }
            .sorted { $0.addedAt > $1.addedAt }
    }

    /// Types réellement présents, dans l'ordre canonique de `DocumentKind`.
    private var availableKinds: [DocumentKind] {
        let present = Set(propertyDocuments.map(\.kind))
        return DocumentKind.allCases.filter { present.contains($0) }
    }

    private var filteredDocuments: [VaultDocument] {
        propertyDocuments.filter { document in
            if let kind = selectedKind, document.kind != kind { return false }
            guard !searchText.isEmpty else { return true }
            return document.name.localizedCaseInsensitiveContains(searchText)
                || document.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var countText: String {
        let count = propertyDocuments.count
        let totalBytes = propertyDocuments.reduce(Int64(0)) { $0 + Int64($1.fileSizeBytes) }
        let size = totalBytes.formatted(.byteCount(style: .file).locale(frenchLocale))
        return count == 1
            ? "1 document · \(size) au total"
            : "\(count) documents · \(size) au total"
    }
}

// MARK: - Ligne de document

private struct VaultDocumentRow: View {
    let document: VaultDocument

    private var syncTint: Color {
        switch document.syncState {
        case .synced: return .hpSage
        case .error: return .hpDanger
        case .pendingUpload, .syncing: return .hpAmber
        case .offlineAvailable: return .hpSlate
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: document.kind.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.hpSlate)
                .frame(width: 38, height: 38)
                .background(Color.hpSlate.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(document.name)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    if document.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.hpAmber)
                            .accessibilityLabel("Favori")
                    }
                    if document.isSensitive {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Document sensible")
                    }
                }
                Text("\(sizeText) · ajouté le \(dateText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !document.tags.isEmpty {
                    tagRow
                }
            }

            Spacer(minLength: 8)

            Image(systemName: document.syncState.systemImage)
                .font(.subheadline)
                .foregroundStyle(syncTint)
                .accessibilityLabel(document.syncState.displayName)
        }
        .padding(.vertical, 2)
    }

    private var tagRow: some View {
        HStack(spacing: 4) {
            ForEach(document.tags.prefix(2), id: \.self) { tag in
                HPBadge(text: tag, tint: .gray)
            }
            if document.tags.count > 2 {
                HPBadge(text: "+\(document.tags.count - 2)", tint: .gray)
            }
        }
    }

    private var sizeText: String {
        Int64(document.fileSizeBytes)
            .formatted(.byteCount(style: .file).locale(frenchLocale))
    }

    private var dateText: String {
        document.addedAt
            .formatted(.dateTime.day().month(.abbreviated).year().locale(frenchLocale))
    }
}

// MARK: - Style de liste

private extension View {
    // `.insetGrouped` n'existe pas sur macOS.
    @ViewBuilder
    func hpVaultListStyle() -> some View {
        #if os(iOS)
        listStyle(.insetGrouped)
        #else
        listStyle(.inset)
        #endif
    }
}

#Preview {
    VaultView()
        .environment(AppStore.preview())
}
