import SwiftUI

struct ProgressDayBar: View {
    var daysCompleted: Int
    let totalDays = 7

    var body: some View {
        VStack {
            // Título con los días completados
            Text("Days Completed: \(daysCompleted)/\(totalDays)")
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            // Barra de progreso
            ZStack(alignment: .leading) {
                // Fondo gris de la barra
                Rectangle()
                    .fill(Color.gray.opacity(0.3)) // Fondo más suave
                    .frame(height: 10) // Aumenté el tamaño de la barra
                    .cornerRadius(5)
                
                // Barra azul de progreso
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat(daysCompleted) / CGFloat(totalDays) * 300, height: 10)
                    .cornerRadius(5)
                    .animation(.easeInOut(duration: 0.5), value: daysCompleted) // Animación suave
            }
            .frame(width: 300) // El ancho se mantiene fijo
        }
        .padding()
    }
}

