import SwiftUI
import Firebase

struct HomePage: View {
    @Binding var isAuthenticated: Bool  // Usamos @Binding para poder modificar isAuthenticated desde otro componente
    @State private var groupsData: [Group] = [] // Datos de grupos
    @State private var participantsData: [Participant] = [] // Datos de participantes
    @State private var imagesData: [ImageData] = [] // Datos de imágenes
    @State private var filter: FilterType = .all // Tipo de filtro actual
    @State private var loading = true // Estado de carga
    @State private var error: String? // Mensaje de error

    enum FilterType {
        case all, `private`, `public` // Tipos de filtro
    }

    var body: some View {
        VStack {
            // Indicador de carga o error
            if loading {
                ProgressView("Loading...")
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    UserBar()  // Barra de usuario en la parte superior
                    ProgressDayBar(daysCompleted: calculateDaysWithImages()) // Barra de progreso debajo

                    // Botones para seleccionar el filtro
                    HStack {
                        filterButton("Public", filterType: .public)
                        filterButton("Private", filterType: .private)
                        filterButton("All", filterType: .all) // Botón para ver todos los grupos
                    }
                    .padding()

                    // Iterar sobre los grupos filtrados y mostrar sus participantes
                    ForEach(filteredGroupsData) { group in
                        GroupView(group: group)  // Vista de grupo
                    }

                    //ImagePickerView()  // Vista para cargar imágenes
                }
                .padding()
            }
        }
        .onAppear(perform: loadData) // Cargar datos al aparecer la vista
    }

    // Cargar datos desde la fuente (Firebase u otro lugar)
    func loadData() {
        // Simulación de carga de datos (agrega aquí la lógica de Firebase o tu fuente de datos)
        // Aquí deberías cargar los grupos, participantes e imágenes de Firestore o tu fuente
        // Por ejemplo:
        // FirebaseFirestore.firestore().collection("groups").getDocuments { ... }

        // Para propósitos de simulación, usaremos datos dummy
        groupsData = [
            Group(id: "1", name: "Public Group", participants: [Participant(id: "1", name: "John")], exercises: ["Pushups"]),
            Group(id: "2", name: "Private Group", participants: [Participant(id: "2", name: "Jane")], exercises: ["Squats"]),
            Group(id: "3", name: "All Group", participants: [Participant(id: "3", name: "Jake")], exercises: ["Lunges"])
        ]
        loading = false
    }

    // Calcular el número de días con imágenes
    func calculateDaysWithImages() -> Int {
        return imagesData.count // Simplificado
    }
    
    // Función para crear el botón de filtro
    func filterButton(_ title: String, filterType: FilterType) -> some View {
        Button(title) {
            filter = filterType // Cambiar el filtro al hacer clic
        }
        .padding()
        .background(filter == filterType ? Color.black : Color.clear) // Cambiar color al seleccionar
        .foregroundColor(filter == filterType ? .white : .gray)
        .clipShape(Capsule())
    }

    // Filtrar los grupos según el tipo de filtro seleccionado
    var filteredGroupsData: [Group] {
        switch filter {
        case .public:
            return groupsData.filter { $0.name.lowercased().contains("public") } // Filtrar por grupos públicos
        case .private:
            return groupsData.filter { $0.name.lowercased().contains("private") } // Filtrar por grupos privados
        case .all:
            return groupsData // Mostrar todos los grupos
        }
    }
}

// Definición de los tipos de datos
struct Group: Identifiable {
    var id: String
    var name: String
    var participants: [Participant]
    var exercises: [String]
}

struct Participant: Identifiable {
    var id: String
    var name: String
}

struct ImageData: Identifiable {
    var id: String
    var url: String
}
