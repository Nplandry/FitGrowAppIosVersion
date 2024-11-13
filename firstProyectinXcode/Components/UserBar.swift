import SwiftUI
import Firebase

struct UserBar: View {
    @State private var userName = "Loading..."
    @State private var profileImageUri: String?
    @State private var isLoading = true

    var body: some View {
        HStack {
            if let profileImageUri = profileImageUri, let url = URL(string: profileImageUri) {
                AsyncImage(url: url) { image in
                    image.resizable()
                         .scaledToFill()
                         .clipShape(Circle())
                         .frame(width: 50, height: 50)
                } placeholder: {
                    Circle().fill(Color.gray)
                        .frame(width: 50, height: 50)
                }
            }
            
            VStack(alignment: .leading) {
                Text("Hello \(userName)!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .onAppear(perform: loadUserData)
        .padding()
        .background(Color.black)
        .cornerRadius(10)
    }

    private func loadUserData() {
        guard let user = Auth.auth().currentUser else {
            self.isLoading = false
            return
        }

        UserService.shared.loadUserData(userId: user.uid) { name, profileImageUri in
            self.userName = name
            self.profileImageUri = profileImageUri
            self.isLoading = false
        }
    }
}
