import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ProfilePage: View {
    @State private var userData = UserData(nombre: "", carrera: "", universidad: "", descripcion: "")
    
    struct UserData {
        var nombre: String
        var carrera: String
        var universidad: String
        var descripcion: String
    }

    // Función para obtener los datos del usuario desde Firestore
    func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userDocRef = db.collection("usuarios").document(user.uid)
        
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                userData = UserData(
                    nombre: data["nombre"] as? String ?? "Nombre",
                    carrera: data["carrera"] as? String ?? "Carrera",
                    universidad: data["universidad"] as? String ?? "Universidad",
                    descripcion: data["descripcion"] as? String ?? "Descripción"
                )
            } else {
                print("No se encontró el documento.")
            }
            if let error = error {
                print("Error al obtener los datos del usuario: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Imagen del perfil
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 144, height: 144)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    
                    // Ícono de edición
                    Button(action: {
                        // Acción de editar perfil
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.black)
                            .background(Color.white.clipShape(Circle()))
                            .font(.system(size: 24))
                            .offset(x: 52, y: 25)
                    }
                }
                .padding(.top, 30)
                
                // Nombre de usuario
                Text(userData.nombre)
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                
                // Información del usuario
                VStack(spacing: 10) {
                    InfoCard(title: "Objetivo", content: userData.carrera)
                    InfoCard(title: "Personal Records!", content: userData.universidad)
                    InfoCard(title: "Descripción", content: userData.descripcion)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Botones de Cerrar Sesión y Cerrar Cuenta
                VStack(spacing: 10) {
                    Button(action: {
                        // Acción de cerrar sesión
                    }) {
                        HStack {
                            Image(systemName: "arrow.backward.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                            Text("Cerrar Sesión")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                    
                    Button(action: {
                        // Acción de cerrar cuenta
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Cerrar Cuenta")
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                fetchUserData()
            }
        }
    }
}

// Subvista para mostrar tarjetas de información del usuario
struct InfoCard: View {
    var title: String
    var content: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 2)
            Text(content)
                .foregroundColor(.white)
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
    }
}
