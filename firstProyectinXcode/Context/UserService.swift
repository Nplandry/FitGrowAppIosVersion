import Firebase
import FirebaseStorage
import FirebaseFirestore

class UserService {
    static let shared = UserService()  // Singleton para fácil acceso en toda la app
    
    private init() {}  // Asegura que solo haya una instancia
    
    func loadUserData(userId: String, completion: @escaping (String, String?) -> Void) {
        let db = Firestore.firestore()
        let userDocRef = db.collection("usuarios").document(userId)
        
        // Obtener el nombre del usuario
        userDocRef.getDocument { document, error in
            guard let document = document, document.exists, let name = document.data()?["nombre"] as? String else {
                completion("No Name", nil)
                return
            }
            
            // Obtener la URL de la imagen de perfil del usuario
            let storage = Storage.storage()
            let storageRef = storage.reference().child("profile_images/\(userId).jpg")
            
            storageRef.downloadURL { url, error in
                completion(name, url?.absoluteString)
            }
        }
    }
}
