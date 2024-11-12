import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UnirseAGrupoPrivadoView: View {
    @EnvironmentObject var userContext: UserContext
    @State private var modalVisible = false
    @State private var groupId = ""
    @State private var password = ""
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Button(action: {
                self.modalVisible = true
            }) {
                Text("Unirse a un Grupo")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom, 10)
            
            if modalVisible {
                VStack {
                    Text("Unirse a Grupo")
                        .font(.headline)
                        .padding(.bottom)
                    
                    Text("ID del Grupo:")
                        .foregroundColor(.white)
                    
                    TextField("Ingrese el ID del Grupo", text: $groupId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                        .foregroundColor(.white)
                    
                    Text("Clave de Acceso:")
                        .foregroundColor(.white)
                    
                    SecureField("Ingrese la clave de acceso", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                        .foregroundColor(.white)
                    
                    Button(action: handleUnirseGrupo) {
                        Text("Unirse al Grupo")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 10)
                    
                    Button("Cerrar") {
                        modalVisible = false
                    }
                    .padding(.top)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .shadow(radius: 10)
                .padding()
            }
        }
    }
    
    private func handleUnirseGrupo() {
        guard !groupId.isEmpty, !password.isEmpty else {
            print("Todos los campos son obligatorios.")
            return
        }

        // Verificar el grupo y clave de acceso
        db.collection("groups").document(groupId).getDocument { (document, error) in
            if let error = error {
                print("Error al obtener el grupo: \(error)")
                return
            }

            guard let document = document, document.exists else {
                print("Grupo no encontrado.")
                return
            }

            let groupData = document.data()
            if let isPrivate = groupData?["isPrivate"] as? Bool, isPrivate,
               let groupPassword = groupData?["claveAcceso"] as? String, groupPassword == password {
                // Si el grupo es privado y la clave es correcta, unirse al grupo
                let user = [
                    "nombre": userContext.userName ?? "Invitado",
                    "email": "email@example.com", // Añadir el email si está disponible
                    "puntos": 0
                ]
                
                // Agregar al usuario como participante
                self.db.collection("groups/\(self.groupId)/participantes").addDocument(data: user) { error in
                    if let error = error {
                        print("Error al agregar participante: \(error)")
                    } else {
                        print("Te has unido al grupo exitosamente.")
                    }
                }
            } else {
                print("Clave de acceso incorrecta o el grupo es público.")
            }
        }
        
        // Limpiar los campos
        groupId = ""
        password = ""
        modalVisible = false
    }
}

struct UnirseGrupoView_Previews: PreviewProvider {
    static var previews: some View {
        UnirseAGrupoPrivadoView().environmentObject(UserContext())
    }
}

/*class UserContext: ObservableObject {
    @Published var userName: String? = nil
    private var listener: AuthStateDidChangeListenerHandle?
    
    init() {
        let auth = Auth.auth()
        if let user = auth.currentUser {
            fetchUserName(userId: user.uid)
        } else {
            userName = "Invitado"
        }
        
        listener = auth.addStateDidChangeListener { _, user in
            if let user = user {
                self.fetchUserName(userId: user.uid)
            } else {
                self.userName = "Invitado"
            }
        }
    }
    
    deinit {
        if let listener = listener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func fetchUserName(userId: String) {
        let db = Firestore.firestore()
        let userDocRef = db.collection("usuarios").document(userId)
        
        userDocRef.getDocument { snapshot, error in
            if let error = error {
                print("Error al obtener el nombre del usuario: \(error.localizedDescription)")
                self.userName = "Usuario"
            } else if let data = snapshot?.data(), let nombre = data["nombre"] as? String {
                self.userName = nombre
            } else {
                print("No se encontró el documento del usuario")
                self.userName = "Usuario"
            }
        }
    }
}
*/
