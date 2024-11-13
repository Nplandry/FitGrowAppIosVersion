import SwiftUI
import Firebase
import FirebaseFirestore

struct EstadisticsInfo: View {
    
    @State private var groupsData: [Group] = []
    @State private var participantsData: [ParticipantsData] = []
    @State private var liftsData: [Lift] = []
    @State private var error: String? = nil
    @State private var loading: Bool = true
    
    private var db = Firestore.firestore()

    struct Group: Identifiable {
        let id: String
        let nombre: String
        let descripcion: String?
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
        var id: String?
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
        let liftsPorEjercicio = Dictionary(grouping: liftsData) { $0.nombreEjercicio }
        var liftsProgresados: [Lift] = []

        for (_, lifts) in liftsPorEjercicio {
            if let liftMasPesado = obtenerLiftMasPesado(lifts: lifts) {
                let progresion = siguienteCarga(lift: liftMasPesado)
                let liftProgresado = Lift(
                    id: liftMasPesado.id,
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
        let groupsRef = db.collection("groups")
        
        groupsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener los grupos:", error)
                self.error = "Error al obtener los grupos"
                self.loading = false
            } else {
                var grupos: [Group] = []
                snapshot?.documents.forEach { doc in
                    let groupData = doc.data()
                    let groupId = doc.documentID
                    
                    let grupo = Group(
                        id: groupId,
                        nombre: groupData["nombre"] as? String ?? "Nombre no disponible",
                        descripcion: groupData["descripcion"] as? String,
                        etiquetas: groupData["etiquetas"] as? [String] ?? [],
                        groupId: groupId,
                        isPrivate: groupData["isPrivate"] as? Bool ?? false
                    )
                    grupos.append(grupo)
                }
                completion(grupos)
            }
        }
    }

    private func fetchParticipants(for groups: [Group], completion: @escaping ([ParticipantsData]) -> Void) {
        var participantsData: [ParticipantsData] = []

        let dispatchGroup = DispatchGroup()

        for group in groups {
            dispatchGroup.enter()
            db.collection("groups").document(group.id).collection("participantes").getDocuments { snapshot, error in
                if let error = error {
                    print("Error al obtener los participantes:", error)
                } else {
                    let participantes = snapshot?.documents.map { doc in
                        Participant(id: doc.documentID, nombre: doc.data()["nombre"] as? String ?? "Nombre no disponible")
                    } ?? []
                    participantsData.append(ParticipantsData(groupId: group.id, participants: participantes, nombre: group.nombre))
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(participantsData)
        }
    }

    func fetchLiftsData(for groups: [Group], completion: @escaping ([Lift]) -> Void) {
        var liftsData: [Lift] = []

        let dispatchGroup = DispatchGroup()

        for group in groups {
            dispatchGroup.enter()
            db.collection("groups").document(group.id).collection("ejercicios").getDocuments { snapshot, err in
                if let err = err {
                    self.error = "Error al cargar los lifts: \(err.localizedDescription)"
                    self.loading = false
                } else {
                    let lifts = snapshot?.documents.map { doc in
                        Lift(
                            id: doc.documentID,
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
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(liftsData)
        }
    }
}

struct EstadisticsView_Previews: PreviewProvider {
    static var previews: some View {
        EstadisticsInfo()
    }
}
