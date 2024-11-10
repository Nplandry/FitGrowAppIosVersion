import SwiftUI

struct GroupView: View {
    var group: Group
    
    var body: some View {
        VStack {
            Text(group.name)
                .font(.title)
                .padding()

            // Iterar sobre los participantes
            ForEach(group.participants) { participant in
                Text(participant.name)
                    .padding()
            }

            // Iterar sobre los ejercicios
            ForEach(group.exercises, id: \.self) { exercise in
                Text(exercise)
                    .padding()
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding()
    }
}
