import SwiftUI
import HabitPlanKit

@main
struct HabitPlanApp: App {
    // Le prototype travaille sur le jeu d'exemple « Maison des Lilas ».
    @State private var store = AppStore.preview()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
