import SwiftUI
import HabitPlanKit

/// Réglages : compte, abonnement, logements, données et confidentialité.
struct SettingsView: View {
    @Environment(AppStore.self) private var store

    @State private var showsPaywall = false
    @State private var showsRestoreAlert = false
    @State private var showsPremiumRequiredAlert = false
    @State private var showsComingSoonAlert = false

    // Préférences locales du prototype, volontairement non persistées.
    @State private var serverOCRConsent = false
    @State private var smartAnalysisEnabled = false

    var body: some View {
        Form {
            accountSection
            subscriptionSection
            propertiesSection
            dataSection
            privacySection
            aboutSection
        }
        .formStyle(.grouped)
        .navigationTitle("Réglages")
        .sheet(isPresented: $showsPaywall) {
            PaywallView()
        }
        .alert("Restaurer mes achats", isPresented: $showsRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Aucun achat à restaurer dans le prototype.")
        }
        .alert("Premium requis", isPresented: $showsPremiumRequiredAlert) {
            Button("Découvrir Premium") { showsPaywall = true }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("L'offre gratuite est limitée à un logement. Passez à Premium pour en gérer plusieurs.")
        }
        .alert("Bientôt disponible", isPresented: $showsComingSoonAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("L'ajout d'un logement n'est pas encore simulé dans le prototype.")
        }
    }

    // MARK: Compte

    private var accountSection: some View {
        Section("Compte") {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.hpSlate)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Alexian J.")
                        .font(.headline)
                    Text("a•••@gmail.com")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 2)
            Label("Appareils connectés (3)", systemImage: "laptopcomputer.and.iphone")
        }
    }

    // MARK: Abonnement

    private var subscriptionSection: some View {
        Section("Abonnement") {
            if store.isPremium {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.hpSage)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Habit Plan Premium")
                            .font(.headline)
                        Text("Tout illimité · 50 Go · sans publicité")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Habit Plan Gratuit")
                        .font(.headline)
                    Text("1 logement · 3 projets actifs · 1 Go")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Button {
                    showsPaywall = true
                } label: {
                    Label("Découvrir Premium", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.hpTerracotta, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            Button("Restaurer mes achats") {
                showsRestoreAlert = true
            }
        }
    }

    // MARK: Logements

    private var propertiesSection: some View {
        Section("Logements") {
            ForEach(store.properties) { property in
                VStack(alignment: .leading, spacing: 2) {
                    Text(property.name)
                    Text(property.city)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                if store.isPremium {
                    showsComingSoonAlert = true
                } else {
                    showsPremiumRequiredAlert = true
                }
            } label: {
                Label("Ajouter un logement", systemImage: "plus")
            }
        }
    }

    // MARK: Données

    private var dataSection: some View {
        Section("Données") {
            VStack(alignment: .leading, spacing: 2) {
                Label("Exporter mes données", systemImage: "square.and.arrow.up")
                Text("Toujours disponible, même sans abonnement")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            LabeledContent {
                Text("\(offlineDocumentCount)")
                    .foregroundStyle(.secondary)
            } label: {
                Label("Documents hors ligne", systemImage: "arrow.down.circle.fill")
            }
            LabeledContent {
                Text("Synchronisé")
                    .foregroundStyle(Color.hpSage)
            } label: {
                Label("Synchronisation", systemImage: "checkmark.icloud")
            }
        }
    }

    private var offlineDocumentCount: Int {
        store.documents
            .filter { $0.propertyID == store.selectedPropertyID && $0.syncState == .offlineAvailable }
            .count
    }

    // MARK: Confidentialité

    private var privacySection: some View {
        Section {
            Toggle("Consentement OCR serveur", isOn: $serverOCRConsent)
                .toggleStyle(.switch)
            Toggle("Fonctions d'analyse intelligente", isOn: $smartAnalysisEnabled)
                .toggleStyle(.switch)
            Label("Journal d'activité", systemImage: "list.bullet.rectangle")
        } header: {
            Text("Confidentialité")
        } footer: {
            Text("Désactivé par défaut. L'application fonctionne sans.")
        }
    }

    // MARK: À propos

    private var aboutSection: some View {
        Section("À propos") {
            LabeledContent("Version", value: "0.1.0 (prototype)")
            fakeLink("Politique de confidentialité")
            fakeLink("Conditions d'utilisation")
        }
    }

    // Lien factice du prototype : la destination n'existe pas encore.
    private func fakeLink(_ title: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppStore.preview())
}
