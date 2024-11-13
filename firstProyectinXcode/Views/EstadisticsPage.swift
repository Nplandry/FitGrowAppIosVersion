import SwiftUI
import Firebase
import FirebaseFirestore

struct EstadisticsView: View {
    @State private var groupsData: [Group] = []
    @State private var participantsData: [ParticipantsData] = []
    @State private var liftsData: [Lift] = []
    @State private var error: String? = nil
    @State private var loading: Bool = true
    
    private var db = Firestore.firestore()
    
    struct Group: Identifiable {
        let id: String
        let nombre: String
        let descripcion: String
        let etiquetas: [String]
        let groupId: String
        let isPrivate: Bool
    }
    
    struct ParticipantsData {
        let groupId: String
        let participants: [Participant]
        let nombre: String
    }
    
    struct Participant: Identifiable {
        let id: String
        let nombre: String
    }
    
    struct Lift: Identifiable {
        let id = UUID()
        let groupId: String
        let nombre: String
        let nombreEjercicio: String
        let peso: Int
        let repeticiones: Int
        let timestamp: Timestamp
    }

    var body: some View {
        VStack {
            if loading {
                ProgressView("Cargando...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding()
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    DaysCalendarBar(lifts: liftsData, renderItem: renderLiftItem)
                    VStack {
                        Text("Progresión de tus ejercicios:")
                            .font(.title)
                            .padding(.top)
                        ForEach(calcularProgresionPorEjercicio(), id: \.nombreEjercicio) { liftProgresado in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(liftProgresado.nombreEjercicio):")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("\(liftProgresado.repeticiones) repeticiones x \(liftProgresado.peso) kg")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.bottom, 5)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: loadData)
        .padding()
    }
    
    func calcularProgresionPorEjercicio() -> [Lift] {
        // Agrupar lifts por ejercicio
        let liftsPorEjercicio = Dictionary(grouping: liftsData) { $0.nombreEjercicio }
        
        // Calcular progresión
        var liftsProgresados: [Lift] = []
        
        for (_, lifts) in liftsPorEjercicio {
            if let liftMasPesado = obtenerLiftMasPesado(lifts: lifts) {
                let progresion = siguienteCarga(lift: liftMasPesado)
                let liftProgresado = Lift(
                    groupId: liftMasPesado.groupId,
                    nombre: liftMasPesado.nombre,
                    nombreEjercicio: liftMasPesado.nombreEjercicio,
                    peso: progresion.nuevoPeso,
                    repeticiones: progresion.nuevasRepeticiones,
                    timestamp: liftMasPesado.timestamp
                )
                liftsProgresados.append(liftProgresado)
            }
        }
        
        return liftsProgresados
    }
    
    func siguienteCarga(lift: Lift) -> (nuevoPeso: Int, nuevasRepeticiones: Int) {
        var nuevoPeso = lift.peso
        var nuevasRepeticiones = lift.repeticiones
        
        if lift.repeticiones > 7 {
            nuevoPeso += 5
            nuevasRepeticiones = 3
        } else {
            nuevasRepeticiones += 1
        }
        
        return (nuevoPeso, nuevasRepeticiones)
    }
    
    func obtenerLiftMasPesado(lifts: [Lift]) -> Lift? {
        let maxPeso = lifts.map { $0.peso }.max() ?? 0
        let liftsConMaxPeso = lifts.filter { $0.peso == maxPeso }
        return liftsConMaxPeso.max { $0.repeticiones < $1.repeticiones }
    }

    func loadData() {
        loading = true
        error = nil
        
        fetchGroups { groups in
            self.groupsData = groups
            fetchParticipants(for: groups) { participantsData in
                self.participantsData = participantsData
                fetchLiftsData(for: groups) { liftsData in
                    self.liftsData = liftsData
                    self.loading = false
                }
            }
        }
    }
    
    func fetchGroups(completion: @escaping ([Group]) -> Void) {
        db.collection("groups").getDocuments { snapshot, err in
            if let err = err {
                self.error = "Error al cargar los grupos: \(err.localizedDescription)"
                self.loading = false
            } else {
                let groups = snapshot?.documents.map { doc in
                    Group(
                        id: doc.documentID,
                        nombre: doc["nombre"] as? String ?? "",
                        descripcion: doc["descripcion"] as? String ?? "",
                        etiquetas: doc["etiquetas"] as? [String] ?? [],
                        groupId: doc["groupId"] as? String ?? "",
                        isPrivate: doc["isPrivate"] as? Bool ?? false
                    )
                } ?? []
                completion(groups)
            }
        }
    }

    func fetchParticipants(for groups: [Group], completion: @escaping ([ParticipantsData]) -> Void) {
        var participantsData: [ParticipantsData] = []
        
        for group in groups {
            db.collection("groups").document(group.id).collection("participants").getDocuments { snapshot, err in
                if let err = err {
                    self.error = "Error al cargar los participantes: \(err.localizedDescription)"
                    self.loading = false
                } else {
                    let participants = snapshot?.documents.map { doc in
                        Participant(
                            id: doc.documentID,
                            nombre: doc["nombre"] as? String ?? ""
                        )
                    } ?? []
                    
                    participantsData.append(ParticipantsData(groupId: group.id, participants: participants, nombre: group.nombre))
                }
                if participantsData.count == groups.count {
                    completion(participantsData)
                }
            }
        }
    }

    func fetchLiftsData(for groups: [Group], completion: @escaping ([Lift]) -> Void) {
        var liftsData: [Lift] = []
        
        for group in groups {
            db.collection("groups").document(group.id).collection("lifts").getDocuments { snapshot, err in
                if let err = err {
                    self.error = "Error al cargar los lifts: \(err.localizedDescription)"
                    self.loading = false
                } else {
                    let lifts = snapshot?.documents.map { doc in
                        Lift(
                            groupId: doc["groupId"] as? String ?? "",
                            nombre: doc["nombre"] as? String ?? "",
                            nombreEjercicio: doc["nombreEjercicio"] as? String ?? "",
                            peso: doc["peso"] as? Int ?? 0,
                            repeticiones: doc["repeticiones"] as? Int ?? 0,
                            timestamp: doc["timestamp"] as? Timestamp ?? Timestamp()
                        )
                    } ?? []
                    
                    liftsData.append(contentsOf: lifts)
                }
                if liftsData.count == groups.count {
                    completion(liftsData)
                }
            }
        }
    }
    
    func renderLiftItem(lift: Lift) -> AnyView {
        AnyView(
            VStack {
                Text("\(lift.nombreEjercicio): \(lift.peso) kg x \(lift.repeticiones) repeticiones")
                    .font(.subheadline)
                    .padding(.bottom, 2)
                Text("Fecha: \(lift.timestamp.dateValue(), formatter: DateFormatter.shortDateFormatter)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .padding([.top, .bottom], 5)
        )
    }
}

struct DaysCalendarBar: View {
    var lifts: [EstadisticsView.Lift]
    var renderItem: (EstadisticsView.Lift) -> AnyView
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(lifts) { lift in
                    renderItem(lift)
                }
            }
        }
    }
}

extension DateFormatter {
    static var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

struct EstadisticsView_Previews: PreviewProvider {
    static var previews: some View {
        EstadisticsView()
    }
}
 
