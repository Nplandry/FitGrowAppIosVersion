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
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: email) { newValue in
                        email = newValue.lowercased()
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
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(isLoading)
                .padding()
                
                // Enlace a la página de registro
                NavigationLink(destination: RegisterPage(isAuthenticated: $isAuthenticated, isRegistering: $isRegistering)) {
                    Text("¿No tienes cuenta? Regístrate")
                        .foregroundColor(.blue)
                        .padding()
                }
                
                // Indicador de carga
                if isLoading {
                    ProgressView("Iniciando sesión...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
            .padding()
            .alert(isPresented: .constant(errorMessage != nil), content: {
                Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK"), action: {
                    errorMessage = nil
                }))
            })
        }
    }
    
    // Función para validar la entrada del usuario
    private func validateInput() -> Bool {
        if email.isEmpty || !email.contains("@") {
            errorMessage = "Por favor ingresa un correo válido."
            return false
        }
        if password.count < 6 {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return false
        }
        return true
    }
    
    // Función de inicio de sesión con Firebase
    private func handleSignIn() {
        guard validateInput() else { return }
        Task { @MainActor in
            isLoading = true
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                isAuthenticated = true
                errorMessage = nil
            } catch {
                isLoading = false
                
            }
        }
    }
    
    // Manejo de errores de autenticación
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(isAuthenticated: .constant(false), isRegistering: .constant(false))
    }
}
