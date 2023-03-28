//
//  AppTextField.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI

struct AppTextField: View {
    var title: String? = nil
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        VStack (alignment: .leading, spacing: 8){
            if let title = title {
                AppText(title, weight: .robotoSemiBold, size: 14)
                    .padding(.horizontal, 12)
            }
            TextField(placeholder, text: $text, onCommit: {
                  Utilities.endEditing()
              }
            )
            .keyboardType(keyboardType)
            .textFieldStyle(.plain)
            .font(.custom(Nunito.regular, size: 14))
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))

        }
        .onTapGesture {
            Utilities.endEditing()
        }
       
    }
}

struct AppTextField_Previews: PreviewProvider {
    static var previews: some View {
        AppTextField(title: "Name", placeholder: "john@mail.com", text: .constant(""))
    }
}
