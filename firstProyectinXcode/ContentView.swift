import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isRegistering = false

    var body: some View {
        NavigationView {
            VStack {
                if isAuthenticated {
                    Text("Bienvenido al sistema!")
                        .font(.title)
                        .padding()
                    
                    // Aquí puedes agregar más vistas para la aplicación cuando el usuario esté autenticado
                } else {
                    LoginPage(isAuthenticated: $isAuthenticated, isRegistering: $isRegistering)
                        .navigationBarHidden(true) // Si no quieres que aparezca la barra de navegación
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
