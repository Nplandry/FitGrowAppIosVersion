import SwiftUI

struct DaysCalendarBar: View {
    @State private var selectedDay = Date()
    @State private var currentWeekIndex = 0
    @State private var selectedWeek: [Date] = []
    @State private var filteredLifts: [Lift] = []

    let lifts: [Lift]

    var body: some View {
        VStack {
            // Week Navigation
            HStack {
                Button(action: goToPreviousWeek) {
                    Text("Semana Anterior")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                }

                Text("Semana \(currentWeekIndex + 1)")
                    .foregroundColor(.white)
                    .padding()

                Button(action: goToNextWeek) {
                    Text("Próxima Semana")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }

            // Week Days Display
            HStack {
                ForEach(0..<selectedWeek.count, id: \.self) { index in
                    let day = selectedWeek[index]
                    VStack {
                        Text("\(Calendar.current.component(.day, from: day)) Nov")
                            .foregroundColor(.black)
                        Circle()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                setSelectedDay(day)
                            }
                    }
                }
            }
            .padding(.top)

            // Lift planner component
            PlanificadorDeCarga(lifts: lifts)

            // Display filtered lifts
            List(filteredLifts) { lift in
                Text("\(lift.nombreEjercicio): \(lift.peso)kg x \(lift.repeticiones) repeticiones")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.bottom, 5)
            }
            .padding()
        }
        .onAppear(perform: loadWeekDates)
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
        Text("Planificador de carga aquí")
            .padding()
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

