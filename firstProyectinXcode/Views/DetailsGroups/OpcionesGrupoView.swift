import SwiftUI

struct OpcionesGrupoView: View {
    @Environment(\.presentationMode) var presentationMode
    // Aquí puedes agregar tus componentes AgregarGrupoComponente y UnirseGrupoComponente para SwiftUI.

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Botón para regresar a la pantalla anterior
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("Opciones de Grupo")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
            }
            
            Divider()
                .background(Color.white.opacity(0.5))
            
            // Agregar Grupo y Unirse Grupo Componente en SwiftUI
            Button(action: crearGrupoPrivado) {
                Text("Crear Grupo Privado")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: unirseAGrupoPrivado) {
                Text("Unirse a Grupo Privado")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.9).edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
    
    // Funciones para mostrar las alertas
    func crearGrupoPrivado() {
        showAlert(title: "Crear Grupo Privado", message: "Función para crear un grupo privado.")
    }
    
    func unirseAGrupoPrivado() {
        showAlert(title: "Unirse a Grupo Privado", message: "Función para unirse a un grupo privado.")
    }
    
    // Función auxiliar para mostrar alertas
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

struct OpcionesGrupo_Previews: PreviewProvider {
    static var previews: some View {
        OpcionesGrupoView()
    }
}
