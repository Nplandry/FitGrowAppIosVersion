import SwiftUI
import Firebase
import FirebaseFirestore

// Modelos
struct Participante: Identifiable {
    let id: String
    let nombre: String
}

struct Grupo: Identifiable {
    let id: String
    let name: String
    let isPrivate: Bool
    let description: String?
    let etiquetas: [String]
    let creatorId: String
    let participantes: [Participante]
}

struct Imagen: Identifiable {
    let id: String
    let url: String
    let ejercicio: String
    let userUId: String
    let fechaActual: String
}

// Vista principal para mostrar los grupos y las imágenes
struct FeedView: View {
    @State private var groupsData: [Grupo] = []
    @State private var imagenesData: [Imagen] = []
    @State private var loading: Bool = true
    @State private var error: String? = nil
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            VStack {
                if loading {
                    ProgressView("Cargando...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    ScrollView {
                        if let error = error {
                            Text(error)
                                .foregroundColor(.red)
                        } else {
                            if imagenesData.isEmpty {
                                Text("No hay imágenes disponibles.")
                                    .padding()
                            } else {
                                ForEach(imagenesData) { image in
                                    VStack {
                                        AsyncImage(url: URL(string: image.url)) { phase in
                                            if let image = phase.image {
                                                image.resizable()
                                                     .scaledToFill()
                                                     .frame(width: UIScreen.main.bounds.width, height: 200)
                                                     .cornerRadius(12)
                                            } else {
                                                ProgressView()
                                            }
                                        }
                                        .padding()
                                        Text("Ejercicio: \(image.ejercicio)")
                                        Text("Subido por: \(image.userUId)")
                                        Text("Subido el: \(image.fechaActual)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.bottom)
                                }
                            }
                        }
                    }
                    .navigationBarTitle("Grupos y Ejercicios")
                }
            }
            .onAppear {
                Task {
                    await loadData()
                }
            }
        }
    }
    
    // Función para cargar los datos de Firebase
    private func loadData() async {
        loading = true
        error = nil
        
        do {
            let groups = await fetchGroups()
            await fetchImagesForGroups(groups: groups)
        } catch {
            self.error = "Error al cargar los datos: \(error.localizedDescription)"
            self.loading = false
        }
    }
    
    // Función para obtener grupos
    private func fetchGroups() async -> [Grupo] {
        do {
            // Usamos 'try await' para llamar a Firestore de manera asincrónica.
            let snapshot = try await db.collection("groups").getDocuments()
            var grupos: [Grupo] = []
            
            for document in snapshot.documents {
                let data = document.data()
                // Se llama a la función asincrónica fetchParticipants usando 'await'.
                let participantes = await fetchParticipants(forGroupId: document.documentID)
                
                let group = Grupo(
                    id: document.documentID,
                    name: data["nombre"] as? String ?? "Nombre no disponible",
                    isPrivate: data["isPrivate"] as? Bool ?? false,
                    description: data["descripcion"] as? String,
                    etiquetas: data["etiquetas"] as? [String] ?? [],
                    creatorId: data["creatorId"] as? String ?? "",
                    participantes: participantes
                )
                grupos.append(group)
            }
            
            return grupos
        } catch {
            // Captura el error si algo sale mal.
            self.error = "No se pudieron cargar los grupos: \(error.localizedDescription)"
            self.loading = false
            return []
        }
    }
    
    // Función para obtener imágenes de cada grupo
    private func fetchImagesForGroups(groups: [Grupo]) async {
        var imagenes: [Imagen] = []
        
        let groupIds = groups.map { $0.id }
        
        for groupId in groupIds {
            do {
                // Llamada asincrónica para obtener las imágenes de Firestore.
                let snapshot = try await db.collection("groups/\(groupId)/imagenes").getDocuments()
                
                for document in snapshot.documents {
                    let data = document.data()
                    let image = Imagen(
                        id: document.documentID,
                        url: data["url"] as? String ?? "",
                        ejercicio: data["ejercicio"] as? String ?? "Ejercicio desconocido",
                        userUId: data["userUId"] as? String ?? "Usuario desconocido",
                        fechaActual: data["fechaActual"] as? String ?? "Fecha no disponible"
                    )
                    imagenes.append(image)
                }
                
                // Actualiza los datos de las imágenes.
                self.imagenesData = imagenes
                self.loading = false
            } catch {
                self.error = "No se pudieron cargar las imágenes: \(error.localizedDescription)"
                self.loading = false
            }
        }
    }
    
    // Función para obtener los participantes de un grupo
    private func fetchParticipants(forGroupId groupId: String) async -> [Participante] {
        var participantes: [Participante] = []
        
        do {
            // Llamada asincrónica para obtener los participantes.
            let participantesRef = db.collection("groups/\(groupId)/participantes")
            let snapshot = try await participantesRef.getDocuments()
            
            for document in snapshot.documents {
                let data = document.data()
                let participante = Participante(id: document.documentID, nombre: data["nombre"] as? String ?? "Nombre no disponible")
                participantes.append(participante)
            }
        } catch {
            self.error = "No se pudieron cargar los participantes: \(error.localizedDescription)"
            self.loading = false
        }
        
        return participantes
    }
}

// Vista previa
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
