import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct UserBar: View {
    @State private var userName = "Loading..."
    @State private var profileImageUri: String?
    @State private var isLoading = true

    var body: some View {
        HStack {
            // Imagen de perfil
            if let profileImageUri = profileImageUri,
               let url = URL(string: profileImageUri) {
                AsyncImage(url: url) { image in
                    image.resizable()
                         .scaledToFill()
                         .clipShape(Circle())
                         .frame(width: 50, height: 50)
                } placeholder: {
                    Circle().fill(Color.gray)
                        .frame(width: 50, height: 50)
                }
            }
            
            VStack(alignment: .leading) {
                Text("Hello \(userName)!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .onAppear(perform: loadUserData)
        .padding()
        .background(Color.black)
        .cornerRadius(10)
    }

    func loadUserData() {
        // Obtén el usuario actual desde Firebase Auth
        guard let user = Auth.auth().currentUser else {
            self.isLoading = false
            return
        }

        // Accede a Firestore para obtener el nombre de usuario
        let db = Firestore.firestore()
        let userDocRef = db.collection("usuarios").document(user.uid)
        
        userDocRef.getDocument { document, error in
            if let document = document, document.exists {
                // Aquí actualizamos el nombre del usuario
                if let name = document.data()?["nombre"] as? String {
                    self.userName = name
                }
            } else {
                self.userName = "No Name"
            }

            // Accede a Firebase Storage para obtener la imagen de perfil
            let storage = Storage.storage()
            let storageRef = storage.reference().child("profile_images/\(user.uid).jpg")
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error al obtener la URL de la imagen: \(error.localizedDescription)")
                    self.profileImageUri = nil
                } else if let url = url {
                    self.profileImageUri = url.absoluteString
                }
                
                // Actualizamos el estado de carga
                self.isLoading = false
            }
        }
    }
}
