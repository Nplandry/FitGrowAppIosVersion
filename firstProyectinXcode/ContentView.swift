import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isRegistering = false

    var body: some View {
        NavigationView {
            VStack {
                if isAuthenticated {
                    // Muestra MainTabView cuando el usuario está autenticado
                    MainTabView(isAuthenticated: $isAuthenticated)
                } else {
                    // Muestra LoginPage cuando el usuario no está autenticado
                    LoginPage(isAuthenticated: $isAuthenticated, isRegistering: $isRegistering)
                        .navigationBarHidden(true)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
