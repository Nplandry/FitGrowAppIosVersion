import SwiftUI
import Firebase

@main
struct firstProyectinXcodeApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
