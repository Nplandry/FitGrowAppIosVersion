import SwiftUI

struct MainTabView: View {
    @Binding var isAuthenticated: Bool
    
    let sampleLifts: [Lift] = [
        Lift(id: "1", nombreEjercicio: "Squat", peso: 100, repeticiones: 5, timestamp: Date()),
        Lift(id: "2", nombreEjercicio: "Deadlift", peso: 120, repeticiones: 4, timestamp: Date())
    ]
    
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
            DaysCalendarBar(lifts: sampleLifts)
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
        .padding(.bottom, -50)  // Ajuste para el fondo de la barra de tabulación
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        // Vista previa de MainTabView con un estado simulado de autenticación
        MainTabView(isAuthenticated: .constant(true))
            .previewDevice("iPhone 14") // Puedes especificar el dispositivo si lo deseas
    }
}
