//
//  CustomTextField.swift
//  firstProyectinXcode
//
//  Created by usuario on 10-11-24.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)
            .padding(.horizontal)
    }
}

