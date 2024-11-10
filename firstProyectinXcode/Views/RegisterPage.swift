import SwiftUI
import Firebase

struct RegisterPage: View {
    @Binding var isAuthenticated: Bool
    @Binding var isRegistering: Bool

    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            Text("Registro de Usuario")
                .font(.largeTitle)
                .padding()

            // Campo de nombre de usuario
            TextField("Nombre de usuario", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Campo de correo electrónico
            TextField("Correo electrónico", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Campo de contraseña
            SecureField("Contraseña", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Campo de confirmación de contraseña
            SecureField("Confirmar Contraseña", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Mostrar mensaje de error si es necesario
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Botón de registro
            Button(action: {
                handleRegister()
            }) {
                Text("Registrarse")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            // Indicador de carga mientras se procesa el registro
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .padding()
    }

    // Función de registro con Firebase
    private func handleRegister() {
        isLoading = true
        // Verificación de campos
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Todos los campos son obligatorios."
            isLoading = false
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            isLoading = false
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // Si el registro es exitoso
                isAuthenticated = true
                errorMessage = nil
            }
        }
    }
}

struct RegisterPage_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPage(isAuthenticated: .constant(false), isRegistering: .constant(false))
    }
}
