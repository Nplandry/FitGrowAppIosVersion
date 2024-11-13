import SwiftUI

struct MainTabView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        TabView {
            // Pestaña de inicio
            HomePage(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Label("Inicio", systemImage: "house")
                }
            
            // Pestaña de Feed
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
            
            // Pestaña de Estadísticas
            EstadisticsView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
            
            // Pestaña de Grupos
            GroupMainPage()
                .tabItem {
                    Label("Grupos", systemImage: "person.2")
                }
            
            // Pestaña de Perfil
            ProfilePage()
                .tabItem {
                    Label("Perfil", systemImage: "person")
                }
        }
        .padding(.bottom, -50) 
        
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(isAuthenticated: .constant(true))
    }
}
