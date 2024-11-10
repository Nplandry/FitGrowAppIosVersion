import SwiftUI
import Firebase

struct LoginPage: View {
    @Binding var isAuthenticated: Bool
    @Binding var isRegistering: Bool

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Iniciar sesión")
                    .font(.largeTitle)
                    .padding()

                // Campo de correo electrónico (convertir a minúsculas automáticamente)
                TextField("Correo electrónico", text: $email)
                    .onChange(of: email) { newValue in
                        email = newValue.lowercased()  // Convierte el correo a minúsculas
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Campo de contraseña
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Mostrar mensaje de error si es necesario
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Botón de inicio de sesión
                Button(action: {
                    handleSignIn()
                }) {
                    Text("Ingresar")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                // Enlace a la página de registro
                NavigationLink(destination: RegisterPage(isAuthenticated: $isAuthenticated, isRegistering: $isRegistering)) {
                    Text("¿No tienes cuenta? Regístrate")
                        .foregroundColor(.blue)
                        .padding()
                }

                // Indicador de carga
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
            .padding()
        }
    }

    // Función de inicio de sesión con Firebase
    private func handleSignIn() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                // Simplificación del manejo de errores
                switch error._code {
                case AuthErrorCode.wrongPassword.rawValue:
                    errorMessage = "Contraseña incorrecta. Por favor, intenta de nuevo."
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Correo electrónico inválido. Revisa tu correo."
                case AuthErrorCode.userNotFound.rawValue:
                    errorMessage = "No se encontró una cuenta con ese correo."
                default:
                    errorMessage = "Error al iniciar sesión. Intenta nuevamente más tarde."
                }
            } else {
                // Inicio de sesión exitoso
                isAuthenticated = true
                errorMessage = nil
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(isAuthenticated: .constant(false), isRegistering: .constant(false))
    }
}
