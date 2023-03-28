//
//  LanguageSelectorView.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/31/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import SwiftUI

struct LanguageSelectorView: View {
    
    let languages: [NewLanguage]
    let navTitle: String
    @State var selectedLanguage: NewLanguage? = nil
    var dismiss: ((NewLanguage) -> Void)
    
    
    var body: some View {
        VStack (spacing: 0){

            ScrollView {
                VStack {
                    ForEach(languages, id: \.id) { language in
                        rowView(language: language)
                    }
                    
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.init(hex: "7C7C7C").opacity(0.2), radius: 0, x: 0, y: 0)
                    .shadow(color: Color.init(hex: "7C7C7C").opacity(0.2), radius: 1, x: 0, y: 0)
            )
            .padding(.horizontal, 36)
            .padding(.vertical, 10)
            
            Spacer()
            
            Rectangle()
                .fill(Color.white)
                .frame(height: 120)
                .overlay(
                    AppButton(title: NSLocalizedString("Save", comment: ""), preset: .pinkBG, height: 48) {
                        if let selectedLanguage = selectedLanguage {
                            dismiss(selectedLanguage)
                        }
                    }
                    .padding()
                )
                .edgesIgnoringSafeArea(.bottom)
            
            
            
        }
        .background(Color.AppBG.edgesIgnoringSafeArea(.all))
        .navigationBar(title: navTitle)
    }

    @ViewBuilder
    func rowView(language: NewLanguage) -> some View {
        VStack (alignment: .leading){
            HStack {
                VStack (alignment: .leading, spacing: 4) {
                    AppText(language.sample , weight: .robotoSemiBold, size: 14)
                    AppText("\(language.name) (\(language.code))", weight: .robotoRegular, size: 9)
                }
                Spacer()
                
                if language.id == selectedLanguage?.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.AppPinkPrimary)
                }
                
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white.cornerRadius(20))
            .onTapGesture {
                selectedLanguage = language
            }
            
            if language.id != languages.last?.id {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 0.5)
            }
        }
    }
}

struct LanguageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageOnboardingView()
    }
}
