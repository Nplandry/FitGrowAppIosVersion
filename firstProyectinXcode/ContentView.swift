import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isRegistering = false

    var body: some View {
        NavigationView {
            VStack {
                if isAuthenticated {
                    // Asegúrate de pasar el @Binding isAuthenticated al componente HomePage
                    HomePage(isAuthenticated: $isAuthenticated)
                } else {
                    // Si no está autenticado, muestra LoginPage
                    LoginPage(isAuthenticated: $isAuthenticated, isRegistering: $isRegistering)
                        .navigationBarHidden(true) // Oculta la barra de navegación en LoginPage
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
