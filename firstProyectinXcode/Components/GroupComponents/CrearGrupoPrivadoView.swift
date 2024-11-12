import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CrearGrupoPrivadoView: View {
    @EnvironmentObject var userContext: UserContext
    @State private var modalVisible = false
    @State private var nombreGrupo = ""
    @State private var descripcionGrupo = ""
    @State private var claveAcceso = ""
    @State private var etiquetas: [String] = ["Entrenamiento"]
    @State private var inputEtiqueta = ""
    @State private var grupoId = ""
    @State private var grupoClaveAcceso = ""
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Button(action: {
                self.modalVisible = true
            }) {
                Text("Crear Grupo Privado")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom, 10)
            
            if modalVisible {
                VStack {
                    Text("Nuevo Grupo Privado")
                        .font(.headline)
                        .padding(.bottom)
                    
                    TextField("Nombre del Grupo", text: $nombreGrupo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                    
                    TextField("Descripción del Grupo", text: $descripcionGrupo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                    
                    Text("Actividades del Grupo:")
                        .font(.subheadline)
                    
                    HStack {
                        ForEach(etiquetas, id: \.self) { etiqueta in
                            HStack {
                                Text(etiqueta)
                                    .padding(8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                Button(action: {
                                    eliminarEtiqueta(etiqueta: etiqueta)
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 5)
                    
                    TextField("Agregar actividad", text: $inputEtiqueta, onCommit: agregarEtiqueta)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                    
                    TextField("Clave de Acceso", text: $claveAcceso)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                    
                    Button(action: handleCrearGrupo) {
                        Text("Crear Grupo")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if !grupoId.isEmpty {
                        VStack {
                            Text("ID del Grupo: \(grupoId)")
                            Button(action: { copiarAlPortapapeles(texto: grupoId) }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                            }
                            Text("Clave de Acceso: \(grupoClaveAcceso)")
                            Button(action: { copiarAlPortapapeles(texto: grupoClaveAcceso) }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
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
    
    private func agregarEtiqueta() {
        if !inputEtiqueta.isEmpty {
            etiquetas.append(inputEtiqueta)
            inputEtiqueta = ""
        }
    }
    
    private func eliminarEtiqueta(etiqueta: String) {
        etiquetas.removeAll { $0 == etiqueta }
    }
    
    private func handleCrearGrupo() {
        guard !nombreGrupo.isEmpty, !descripcionGrupo.isEmpty, !claveAcceso.isEmpty else {
            print("Todos los campos son obligatorios.")
            return
        }
        
        crearGrupo(nombreGrupo: nombreGrupo, descripcionGrupo: descripcionGrupo, claveAcceso: claveAcceso, etiquetas: etiquetas) { result in
            if let result = result {
                grupoId = result.id
                grupoClaveAcceso = result.claveAcceso
                modalVisible = true
                limpiarCampos()
            }
        }
    }
    
    private func crearGrupo(nombreGrupo: String, descripcionGrupo: String, claveAcceso: String, etiquetas: [String], completion: @escaping ((id: String, claveAcceso: String)?) -> Void) {
        let grupoData: [String: Any] = [
            "nombre": nombreGrupo,
            "descripcion": descripcionGrupo,
            "claveAcceso": claveAcceso,
            "etiquetas": etiquetas,
            "isPrivate": true
        ]
        
        // Creamos el grupo primero, y luego pasamos a utilizar el grupoRef
        db.collection("groups").addDocument(data: grupoData) { error in
            if let error = error {
                print("Error al crear el grupo: \(error)")
                completion(nil)
            } else {
                // Aquí ya puedes usar el grupoRef correctamente, ya que lo estás obteniendo dentro del closure
                let grupoRef = self.db.collection("groups").document()
                let grupoId = grupoRef.documentID

                // Actualizamos el documento con el campo groupId
                self.db.collection("groups").document(grupoId).updateData(["groupId": grupoId]) { error in
                    if let error = error {
                        print("Error al actualizar el groupId: \(error)")
                        completion(nil)
                    } else {
                        // Datos del participante
                        let participanteData: [String: Any] = [
                            "nombre": self.userContext.userName ?? "Invitado",
                            "email": "", // Agregar el email si está disponible
                            "puntos": 0
                        ]
                        
                        // Agregar al participante
                        self.db.collection("groups/\(grupoId)/participantes").addDocument(data: participanteData) { error in
                            if let error = error {
                                print("Error al agregar participante: \(error)")
                                completion(nil)
                            } else {
                                // Todo ha salido bien, completamos el bloque
                                completion((id: grupoId, claveAcceso: claveAcceso))
                            }
                        }
                    }
                }
            }
        }
    }



    
    private func copiarAlPortapapeles(texto: String) {
        UIPasteboard.general.string = texto
        print("Texto copiado al portapapeles.")
    }
    
    private func limpiarCampos() {
        nombreGrupo = ""
        descripcionGrupo = ""
        claveAcceso = ""
        etiquetas = ["Entrenamiento"]
        inputEtiqueta = ""
    }
}


class UserContext: ObservableObject {
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
