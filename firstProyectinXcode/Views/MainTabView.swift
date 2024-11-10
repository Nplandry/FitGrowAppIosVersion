import SwiftUI

struct MainTabView: View {
    // Estado para gestionar la autenticación
    @State private var isAuthenticated = false
    
    var body: some View {
        TabView {
            // Vista de Home, pasando el estado de autenticación como binding
            HomePage(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Label("Inicio", systemImage: "house")
                }
            
            // Vista de Feed
            FeedPage()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
            
            // Vista de Estadísticas
            EstadisticsPage()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
            
            // Vista de Perfil
            ProfilePage()
                .tabItem {
                    Label("Perfil", systemImage: "person")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
