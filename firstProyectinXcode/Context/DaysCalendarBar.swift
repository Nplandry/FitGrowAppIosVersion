import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DaysCalendarBar: View {
    @State private var selectedDay = Date()
    @State private var currentWeekIndex = 0
    @State private var selectedWeek: [Date] = []
    @State private var liftsForSelectedDay: [Lift] = [] // Lifts para el día seleccionado
    
    @State private var loading = true
    @State private var error: String? = nil
    @Environment(\.colorScheme) var colorScheme
    let groupId = "dhIVNt5BulJTYc0aVmqf"
    
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
                            Text("\(day.formatted(.dateTime.day().month(.wide)))")
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
                PlanificadorDeCarga(lifts: liftsForSelectedDay)
                
                // Mostrar lifts filtrados
                if loading {
                    ProgressView("Cargando ejercicios...")
                        .padding()
                } else if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VStack {
                        ForEach(liftsForSelectedDay) { lift in
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
        setSelectedDay(Date()) // Selecciona el día de hoy por defecto
    }
    
    private func getWeekDates(from date: Date) -> [Date] {
        let startOfWeek = Calendar.current.date(byAdding: .day, value: -Calendar.current.component(.weekday, from: date) + 1, to: date)!
        return (0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }
    
    private func setSelectedDay(_ day: Date) {
        selectedDay = day
        fetchLiftsForSelectedDay()
    }
    
    private func fetchLiftsForSelectedDay() {
        loading = true
        error = nil // Restablece el mensaje de error al hacer un nuevo fetch
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDay)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Asegúrate de convertir startOfDay y endOfDay en Timestamps de Firestore
        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)
        
        // Imprimir las fechas de inicio y fin para depuración
        print("Start of day: \(startOfDay)")
        print("End of day: \(endOfDay)")
        
        // Realizar la consulta para obtener todos los ejercicios del grupo
        db.collection("groups")
            .document(groupId)
            .collection("ejercicios")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.error = "Error al cargar los ejercicios: \(error.localizedDescription)"
                    self.loading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.error = "No se encontraron ejercicios para este grupo"
                    self.loading = false
                    return
                }
                
                // Imprimir los documentos que obtuvimos de Firestore
                print("Documentos obtenidos de ejercicios: \(documents)")
                
                // Filtrar los ejercicios que están dentro del rango de fechas
                let filteredLifts = documents.compactMap { doc -> Lift? in
                    let data = doc.data()
                    
                    // Imprimir los datos del documento para cada ejercicio
                    print("Datos del ejercicio: \(data)")
                    
                    if let nombreEjercicio = data["nombreEjercicio"] as? String,
                       let peso = data["peso"] as? Int,
                       let repeticiones = data["repeticiones"] as? Int,
                       let timestamp = data["timestamp"] as? Timestamp,
                       let nombre = data["nombre"] as? String,
                       let ejercicioGroupId = data["groupId"] as? String {
                        
                        // Comprobar si el timestamp está dentro del rango de fechas
                        let ejercicioDate = timestamp.dateValue()
                        print("Fecha del ejercicio: \(ejercicioDate)")
                        /**if ejercicioDate >= startOfDay && ejercicioDate < endOfDay {**/
                        if true {
                            // Retorna el ejercicio si cumple con el filtro de fecha
                            print("Ejercicio filtrado: \(nombreEjercicio), \(peso), \(repeticiones), \(ejercicioDate)")
                            return Lift(id: doc.documentID,
                                        nombreEjercicio: nombreEjercicio,
                                        peso: peso,
                                        repeticiones: repeticiones,
                                        timestamp: ejercicioDate,
                                        nombreUsuario: nombre,
                                        groupId: ejercicioGroupId)
                        } else {
                            print("Ejercicio fuera del rango de fechas: \(ejercicioDate)")
                        }
                    }
                    return nil // Si no cumple, no se agrega a la lista
                }
                
                // Imprimir los ejercicios filtrados
                print("Ejercicios filtrados: \(filteredLifts)")
                
                // Asigna los ejercicios filtrados
                self.liftsForSelectedDay = filteredLifts
                self.loading = false
            }
    }
}
struct Lift: Identifiable {
    let id: String
    let nombreEjercicio: String
    let peso: Int
    let repeticiones: Int
    let timestamp: Date
    let nombreUsuario: String
    let groupId: String
}

struct PlanificadorDeCarga: View {
    var lifts: [Lift]

    var totalPeso: Int {
        lifts.reduce(0) { $0 + $1.peso * $1.repeticiones }
    }

    var totalReps: Int {
        lifts.reduce(0) { $0 + $1.repeticiones }
    }

    var body: some View {
        VStack {
            Text("Planificador de carga")
                .font(.headline)
                .padding()

            Text("Total de peso levantado: \(totalPeso) kg")
                .font(.subheadline)
                .padding(.top, 4)

            Text("Total de repeticiones: \(totalReps) reps")
                .font(.subheadline)
                .padding(.top, 2)

            Divider().padding(.vertical)

            // Aquí puedes agregar más detalles si es necesario
        }
        .padding()
    }
}

struct DaysCalendarBar_Previews: PreviewProvider {
    static var previews: some View {
        DaysCalendarBar()
    }
}
