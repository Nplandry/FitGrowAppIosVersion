//
//  AuthState.swift
//  firstProyectinXcode
//
//  Created by usuario on 10-11-24.
//

import FirebaseAuth
import SwiftUI

class AuthState: ObservableObject {
    @Published var isAuthenticated = false

    init() {
        checkAuthState()
    }

    func checkAuthState() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
        }
    }
}
