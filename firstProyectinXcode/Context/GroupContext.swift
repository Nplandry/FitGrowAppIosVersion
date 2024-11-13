import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

class GroupService {
    
    private var db = Firestore.firestore()
    
    // Unirse a un grupo
    func unirseAGrupo(groupId: String, user: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        let participantesRef = db.collection("groups").document(groupId).collection("participantes")
        participantesRef.addDocument(data: user) { error in
            if let error = error {
                print("Error al unirse al grupo:", error)
                completion(.failure(error))
            } else {
                print("Usuario se unió al grupo \(groupId) correctamente.")
                completion(.success("Usuario se unió al grupo"))
            }
        }
    }
    
    // Salir de un grupo
    func salirDelGrupo(groupId: String, userName: String, completion: @escaping (Result<String, Error>) -> Void) {
        let participantesRef = db.collection("groups").document(groupId).collection("participantes")
        
        // Buscar al usuario por nombre
        participantesRef.whereField("nombre", isEqualTo: userName).getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener los participantes:", error)
                completion(.failure(error))
            } else if let snapshot = snapshot, let document = snapshot.documents.first {
                document.reference.delete() { error in
                    if let error = error {
                        print("Error al eliminar al participante:", error)
                        completion(.failure(error))
                    } else {
                        print("Usuario \(userName) salió del grupo \(groupId).")
                        completion(.success("Usuario salió del grupo"))
                    }
                }
            } else {
                print("No se encontró el usuario en el grupo.")
                completion(.failure(NSError(domain: "GroupService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado en el grupo"])))
            }
        }
    }
    
    // Obtener los grupos
    func fetchGroups(completion: @escaping (Result<[Grupo], Error>) -> Void) {
        let groupsRef = db.collection("groups")
        
        groupsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener los grupos:", error)
                completion(.failure(error))
            } else {
                var grupos: [Grupo] = []
                let dispatchGroup = DispatchGroup()
                
                snapshot?.documents.forEach { doc in
                    dispatchGroup.enter()
                    
                    let groupData = doc.data()
                    let groupId = doc.documentID
                    
                    // Obtener los participantes de cada grupo
                    self.fetchParticipants(groupId: groupId) { result in
                        switch result {
                        case .success(let participantes):
                            let grupo = Grupo(
                                id: groupId,
                                name: groupData["nombre"] as? String ?? "Nombre no disponible",
                                isPrivate: groupData["isPrivate"] as? Bool ?? false,
                                description: groupData["descripcion"] as? String,
                                etiquetas: groupData["etiquetas"] as? [String] ?? [],
                                creatorId: groupData["creatorId"] as? String ?? "",
                                participantes: participantes
                            )
                            grupos.append(grupo)
                        case .failure(let error):
                            print("Error al obtener los participantes:", error)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(grupos))
                }
            }
        }
    }
    
    // Obtener los participantes de un grupo
    private func fetchParticipants(groupId: String, completion: @escaping (Result<[Participante], Error>) -> Void) {
        let participantesRef = db.collection("groups").document(groupId).collection("participantes")
        
        participantesRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener los participantes:", error)
                completion(.failure(error))
            } else {
                let participantes = snapshot?.documents.map { doc in
                    Participante(id: doc.documentID, nombre: doc.data()["nombre"] as? String ?? "Nombre no disponible")
                } ?? []
                completion(.success(participantes))
            }
        }
    }
}
