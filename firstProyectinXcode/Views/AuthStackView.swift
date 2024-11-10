//
//  AuthStackView.swift
//  firstProyectinXcode
//
//  Created by usuario on 10-11-24.
//

import SwiftUI

struct AuthStackView: View {
    @State private var isAuthenticated: Bool = false
    @State private var isRegistering: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Login", destination: LoginPage(isAuthenticated: $isAuthenticated, isRegistering: $isRegistering))
                NavigationLink("Registrarse", destination: RegisterPage(isAuthenticated: $isAuthenticated, isRegistering: $isRegistering))
            }
            .navigationBarTitle("Autenticación")
        }
    }
}

struct AuthStackView_Previews: PreviewProvider {
    static var previews: some View {
        AuthStackView()
    }
}
