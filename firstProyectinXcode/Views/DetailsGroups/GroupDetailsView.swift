import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GroupDetailsView: View {
    var groupId: String
    @State private var group: Group?
    @State private var loading = true
    @State private var error: String? = nil

    struct Group: Identifiable {
        let id: String
        let name: String
        let isPrivate: Bool
        let description: String
        let etiquetas: [String]
        let creatorId: String
        let participantes: [Participante]
    }
    
    struct Participante: Identifiable {
        let id: String
        let nombre: String
        let puntos: Int
    }

    var body: some View {
        VStack {
            if loading {
                ProgressView("Cargando...")
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if let group = group {
                Text("Group: \(group.name)")
                    .font(.headline)
                    .padding()
                
                Text("Descripción: \(group.description)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Participantes del grupo")
                    .font(.subheadline)
                    .bold()
                    .padding(.top)
                
                List(group.participantes) { participante in
                    HStack {
                        Text(participante.nombre)
                            .font(.body)
                        Spacer()
                        Text("Puntos: \(participante.puntos)")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                Text("No se encontró información del grupo.")
                    .foregroundColor(.gray)
            }
        }
        .onAppear(perform: fetchGroupDetails)
    }

    private func fetchGroupDetails() {
        loading = true
        error = nil
        
        let db = Firestore.firestore()
        db.collection("groups").document(groupId).getDocument { document, err in
            if let err = err {
                self.error = "No se pudo cargar el grupo: \(err.localizedDescription)"
                self.loading = false
                return
            }
            
            guard let document = document, document.exists else {
                self.error = "El grupo no existe"
                self.loading = false
                return
            }
            
            let data = document.data()
            fetchParticipantes(groupId: document.documentID) { participantes in
                // Ordenar los participantes por puntos de mayor a menor
                let sortedParticipantes = participantes.sorted { $0.puntos > $1.puntos }
                
                let loadedGroup = Group(
                    id: document.documentID,
                    name: data?["nombre"] as? String ?? "Nombre no disponible",
                    isPrivate: data?["isPrivate"] as? Bool ?? false,
                    description: data?["descripcion"] as? String ?? "Descripción no disponible",
                    etiquetas: data?["etiquetas"] as? [String] ?? [],
                    creatorId: data?["creatorId"] as? String ?? "",
                    participantes: sortedParticipantes
                )
                
                self.group = loadedGroup
                self.loading = false
            }
        }
    }
    
    private func fetchParticipantes(groupId: String, completion: @escaping ([Participante]) -> Void) {
        let db = Firestore.firestore()
        db.collection("groups").document(groupId).collection("participantes").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else {
                completion([])
                return
            }
            
            let participantes = docs.map { doc in
                Participante(
                    id: doc.documentID,
                    nombre: doc.data()["nombre"] as? String ?? "Nombre no disponible",
                    puntos: doc.data()["puntos"] as? Int ?? 0
                )
            }
            
            completion(participantes)
        }
    }
}
