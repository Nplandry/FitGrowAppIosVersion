import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
