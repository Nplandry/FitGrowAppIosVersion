import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DaysCalendarBar: View {
    @State private var selectedDay = Date()
    @State private var currentWeekIndex = 0
    @State private var selectedWeek: [Date] = []
    @State private var filteredLifts: [Lift] = []
    @State private var allLifts: [Lift] = [] // Todos los lifts de todos los grupos
    @State private var loading = true
    @State private var error: String? = nil
    @State private var userName: String = ""
    @State private var userId: String = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    private var db = Firestore.firestore() // Firestore instance

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
                PlanificadorDeCarga(lifts: filteredLifts)

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
            .onAppear {
                if let userId = Auth.auth().currentUser?.uid {
                    loadUserData(userId: userId) // Cargar los datos del usuario
                    loadAllLifts() // Cargar todos los lifts
                }
            }
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
        filteredLifts = filterLiftsByDate(lifts: allLifts, selectedDay: day)
    }

    private func filterLiftsByDate(lifts: [Lift], selectedDay: Date) -> [Lift] {
        let calendar = Calendar.current

        // Normalizar la fecha seleccionada (establecer la hora a las 00:00:00)
        let startOfDay = calendar.startOfDay(for: selectedDay)

        return lifts.filter { lift in
            let liftDate = lift.timestamp
            // Normalizar la fecha del lift (establecer la hora a las 00:00:00)
            let startOfLiftDay = calendar.startOfDay(for: liftDate)

            // Comparar solo las fechas (sin horas)
            return startOfLiftDay == startOfDay
        }
    }

    private func loadAllLifts() {
        let db = Firestore.firestore()
        db.collection("ejercicios").getDocuments { snapshot, error in
            if let error = error {
                self.error = "Error al cargar los lifts: \(error.localizedDescription)"
                self.loading = false
                return
            }

            guard let documents = snapshot?.documents else {
                self.error = "No se encontraron lifts"
                self.loading = false
                return
            }

            var tempLifts: [Lift] = []
            for doc in documents {
                let data = doc.data()
                if let nombreEjercicio = data["nombreEjercicio"] as? String,
                   let peso = data["peso"] as? Int,
                   let repeticiones = data["repeticiones"] as? Int,
                   let timestamp = data["timestamp"] as? Timestamp,
                   let nombre = data["nombre"] as? String,
                   let groupId = data["groupId"] as? String {
                    let lift = Lift(id: doc.documentID, nombreEjercicio: nombreEjercicio, peso: peso, repeticiones: repeticiones, timestamp: timestamp.dateValue(), nombreUsuario: nombre, groupId: groupId)
                    tempLifts.append(lift)
                }
            }

            // Verifica que los lifts estén bien cargados
            print("Lifts obtenidos desde Firestore: \(tempLifts.count)")
            for lift in tempLifts {
                print("Lift cargado: \(lift.nombreEjercicio), \(lift.peso)kg, \(lift.repeticiones) repeticiones")
            }

            // Filtra los lifts por grupo
            let groupIdFilter = "POTO" // El grupo que quieres filtrar
            self.allLifts = tempLifts.filter { $0.groupId == groupIdFilter }
            print("Lifts filtrados por grupo \(groupIdFilter): \(self.allLifts.count)")
            for lift in self.allLifts {
                print("Lift filtrado: \(lift.nombreEjercicio), \(lift.peso)kg, \(lift.repeticiones) repeticiones")
            }

            self.loading = false
        }
    }

    private func loadUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error al cargar datos del usuario: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No se encontraron datos del usuario")
                return
            }

            if let name = data["nombre"] as? String {
                self.userName = name
            }

            print("Datos del usuario cargados - ID: \(userId), Nombre: \(userName)")
        }
    }
}

struct Lift: Identifiable {
    let id: String
    let nombreEjercicio: String
    let peso: Int
    let repeticiones: Int
    let timestamp: Date
    let nombreUsuario: String // Campo que guarda el nombre del usuario que realizó el ejercicio
    let groupId: String // ID del grupo al que pertenece el lift
}

struct PlanificadorDeCarga: View {
    var lifts: [Lift]

    var body: some View {
        VStack {
            Text("Planificador de carga aquí")
                .font(.headline)
                .padding()

            EstadisticsInfo() // Usar tu componente EstadisticsView para mostrar estadísticas
        }
    }
}

struct DaysCalendarBar_Previews: PreviewProvider {
    static var previews: some View {
        DaysCalendarBar() // No se pasa lifts desde el exterior
    }
}
