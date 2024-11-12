import SwiftUI

struct OpcionesGrupoView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
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
                
                // Navegar a Crear Grupo Privado
                NavigationLink(destination: CrearGrupoPrivadoView()) {
                    Text("Crear Grupo Privado")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Navegar a Unirse a Grupo Privado
                NavigationLink(destination: UnirseAGrupoPrivadoView()) {
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
    }
}

struct OpcionesGrupoView_Previews: PreviewProvider {
    static var previews: some View {
        OpcionesGrupoView()
    }
}
