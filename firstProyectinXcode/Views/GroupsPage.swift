import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct GroupMainPage: View {
    @State private var filter: FilterType = .publicGroups
    @State private var groupsData: [Group] = []
    @State private var loading = true
    @State private var error: String? = nil
    @State private var userName: String = "Invitado"
    @State private var userProfileImageURL: String? = nil // Nueva propiedad para la URL de la imagen de perfil

    enum FilterType {
        case all, privateGroups, publicGroups
    }

    struct Group: Identifiable {
        let id: String
        let name: String
        let isPrivate: Bool
        let description: String
        let etiquetas: [String]
        let creatorId: String
        let participantes: [Participante]
    }

    struct Participante: Identifiable {
        let id: String
        let nombre: String
    }

    var filteredGroups: [Group] {
        groupsData.filter { group in
            switch filter {
            case .privateGroups:
                return group.isPrivate && group.participantes.contains(where: { $0.nombre == userName })
            case .publicGroups:
                return !group.isPrivate
            case .all:
                return true
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if loading {
                    ProgressView("Cargando...")
                } else if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else {
                    GroupListView()
                }
            }
            .onAppear(perform: fetchGroups)
            .onAppear {
                if let userId = Auth.auth().currentUser?.uid {
                    UserService.shared.loadUserData(userId: userId) { name, imageURL in
                        self.userName = name
                        self.userProfileImageURL = imageURL // Actualiza la URL de la imagen de perfil
                    }
                }
            }
            .navigationTitle("Grupos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: OpcionesGrupoView()) {
                        Text("+")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func GroupListView() -> some View {
        VStack {
            Picker("", selection: $filter) {
                Text("Públicos").tag(FilterType.publicGroups)
                Text("Privados").tag(FilterType.privateGroups)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List(filteredGroups) { group in
                NavigationLink(destination: GroupDetailsView(groupId: group.id)) {
                    VStack(alignment: .leading) {
                        Text(group.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(group.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }

    private func fetchGroups() {
        loading = true
        error = nil

        let db = Firestore.firestore()
        db.collection("groups").getDocuments { snapshot, err in
            if let err = err {
                self.error = "No se pudieron cargar los grupos: \(err.localizedDescription)"
                self.loading = false
                return
            }

            guard let documents = snapshot?.documents else {
                self.error = "No se encontraron grupos"
                self.loading = false
                return
            }

            var tempGroups: [Group] = []
            let dispatchGroup = DispatchGroup()

            for doc in documents {
                dispatchGroup.enter()

                let data = doc.data()
                fetchParticipantes(groupId: doc.documentID) { participantes in
                    let group = Group(
                        id: doc.documentID,
                        name: data["nombre"] as? String ?? "Nombre no disponible",
                        isPrivate: data["isPrivate"] as? Bool ?? false,
                        description: data["descripcion"] as? String ?? "Descripción no disponible",
                        etiquetas: data["etiquetas"] as? [String] ?? [],
                        creatorId: data["creatorId"] as? String ?? "",
                        participantes: participantes
                    )

                    tempGroups.append(group)
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.groupsData = tempGroups
                self.loading = false
            }
        }
    }

    private func fetchParticipantes(groupId: String, completion: @escaping ([Participante]) -> Void) {
        let db = Firestore.firestore()
        db.collection("groups").document(groupId).collection("participantes").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else {
                completion([])
                return
            }

            let participantes = docs.map { doc in
                Participante(id: doc.documentID, nombre: doc.data()["nombre"] as? String ?? "Nombre no disponible")
            }

            completion(participantes)
        }
    }
}

struct GroupMainPage_Previews: PreviewProvider {
    static var previews: some View {
        GroupMainPage()
    }
}
