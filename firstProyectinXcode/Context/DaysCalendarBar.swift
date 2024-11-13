import SwiftUI

struct DaysCalendarBar: View {
    @State private var selectedDay = Date()
    @State private var currentWeekIndex = 0
    @State private var selectedWeek: [Date] = []
    @State private var filteredLifts: [Lift] = []

    let lifts: [Lift]

    // Color dinámico dependiendo del modo
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                // Navegación de semanas
                HStack {
                    Button(action: goToPreviousWeek) {
                        Text("Semana Anterior")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(8)
                    }

                    Text("Semana \(currentWeekIndex + 1)")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()

                    Button(action: goToNextWeek) {
                        Text("Próxima Semana")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Mostrar los días de la semana
                HStack {
                    ForEach(0..<selectedWeek.count, id: \.self) { index in
                        let day = selectedWeek[index]
                        VStack {
                            Text("\(Calendar.current.component(.day, from: day)) Nov")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(selectedDay == day ? Color.blue : Color.gray)
                                .onTapGesture {
                                    setSelectedDay(day)
                                }
                        }
                    }
                }
                .padding(.top)

                // Componente Planificador de Carga
                PlanificadorDeCarga(lifts: lifts)

                // Mostrar lifts filtrados
                VStack {
                    ForEach(filteredLifts) { lift in
                        Text("\(lift.nombreEjercicio): \(lift.peso)kg x \(lift.repeticiones) repeticiones")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.bottom, 5)
                    }
                }
                .padding()

            }
            .onAppear(perform: loadWeekDates)
        }
        .background(colorScheme == .dark ? Color.black : Color.white) // Fondo general
    }

    private func goToNextWeek() {
        let newDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedWeek[0])!
        selectedWeek = getWeekDates(from: newDate)
        currentWeekIndex += 1
    }

    private func goToPreviousWeek() {
        let newDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedWeek[0])!
        selectedWeek = getWeekDates(from: newDate)
        currentWeekIndex -= 1
    }

    private func loadWeekDates() {
        selectedWeek = getWeekDates(from: Date())
    }

    private func getWeekDates(from date: Date) -> [Date] {
        let startOfWeek = Calendar.current.date(byAdding: .day, value: -Calendar.current.component(.weekday, from: date) + 1, to: date)!
        return (0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }

    private func setSelectedDay(_ day: Date) {
        selectedDay = day
        filteredLifts = filterLiftsByDate(lifts: lifts, selectedDay: day)
    }

    private func filterLiftsByDate(lifts: [Lift], selectedDay: Date) -> [Lift] {
        return lifts.filter { lift in
            let liftDate = lift.timestamp
            return Calendar.current.isDate(liftDate, inSameDayAs: selectedDay)
        }
    }
}

struct Lift: Identifiable {
    let id: String
    let nombreEjercicio: String
    let peso: Int
    let repeticiones: Int
    let timestamp: Date
}

struct PlanificadorDeCarga: View {
    var lifts: [Lift]

    var body: some View {
        VStack {
            Text("Planificador de carga aquí")
                .font(.headline)
                .padding()

            EstadisticsInfo() // Este puede ser otro componente con estadísticas
        }
    }
}

struct DaysCalendarBar_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLifts: [Lift] = [
            Lift(id: "1", nombreEjercicio: "Squat", peso: 100, repeticiones: 5, timestamp: Date()),
            Lift(id: "2", nombreEjercicio: "Deadlift", peso: 120, repeticiones: 4, timestamp: Date())
        ]
        DaysCalendarBar(lifts: sampleLifts)
    }
}
