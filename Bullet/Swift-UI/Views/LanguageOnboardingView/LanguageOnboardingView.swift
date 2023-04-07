//
//  LanguageOnboardingView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/24/22.
//

import SwiftUI

struct LanguageOnboardingView: View {
    
    var dismiss: (() -> Void)?
    var isPrimary: Bool = true
    var isInSettings: Bool = false
    @State private var isShowRegionSelection : Bool = false
    @StateObject private var viewModel = LanguageHelper.languageShared
    

    var body: some View {
        VStack (spacing: 0){
            Image("logo-straight")
                .padding(.top, 20)
            AppText("Welcome To Newsreels!", weight: .robotoBold, size: 24)
                .padding(.top, 32)
            AppText("Let's get started.", weight: .robotoRegular, size: 14)
                .padding(.top, 8)
            
            VStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(height: 53)
                    .shadow(color: Color.init(hex: "7C7C7C").opacity(0.2), radius: 0, x: 0, y: 0)
                    .shadow(color: Color.init(hex: "7C7C7C").opacity(0.2), radius: 1, x: 0, y: 0)
                    .overlay(HStack {
                        if let region = viewModel.selectedRegion {
                            Image("pin-location-ic")
                            AppText(region.name, weight: .robotoRegular, size: 16)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.black.opacity(0.7))
                        } else {
                            AppText("Loading regions..", weight: .robotoRegular, size: 16)
                        }
                        
                    }.padding(.horizontal, 16))
            }
            .padding(.top, 26)
            .padding(.horizontal, 36)
            .onTapGesture {
                isShowRegionSelection = true
            }
            
            if let languages = viewModel.languages {
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
                        AppButton(title: "Save", preset: .pinkBG, height: 48) {
//                            if isInSettings {
//                                SwiftUIManager.shared.setObserver(name: .SwiftUIDidChangeLanguage, object: isPrimary)
//                            }
//                            if !isPrimary {
//                                if let selectedLanguage = viewModel.selectedLanguage {
//                                    LanguageHelper.shared.saveSecondaryLanguage(language: selectedLanguage)
//                                }
//                            } else {
//                                if let _ = viewModel.selectedLanguage {
//                                    viewModel.saveSelectedRegionAndLanguage(isInSettings: isInSettings, completion: nil)
//                                }
//                            }
                            if let selectedRegion = viewModel.selectedRegion {
                                do {
                                    // Create JSON Encoder
                                    let encoder = JSONEncoder()
                                    
                                    // Encode Note
                                    let data = try encoder.encode(selectedRegion)
                                    
                                    // Write/Set Data
                                    UserDefaults.standard.set(data, forKey: Constant.UD_new_region_Selected)
                                    
                                } catch {
                                    print("Unable to Encode Note (\(error))")
                                }
                            }
                            
                            if let selectedLanguage = viewModel.selectedLanguage {
                                
                                SharedManager.shared.languageId = selectedLanguage.id
                                UserDefaults.standard.set(selectedLanguage.name, forKey: Constant.UD_appLanguageName)
                                UserDefaults.standard.set(selectedLanguage.code, forKey: Constant.UD_languageSelected)
                                UserDefaults.standard.set(selectedLanguage.image, forKey: Constant.UD_languageFlag)
                                UserDefaults.standard.synchronize()
                                Bundle.setLanguage(selectedLanguage.code)

                                do {
                                    let encoder = JSONEncoder()
                                    
                                    let data = try encoder.encode(selectedLanguage)
                                    
                                    UserDefaults.standard.set(data, forKey: Constant.UD_new_languageSelected)
                                    
                                } catch {
                                    print("Unable to Encode Note (\(error))")
                                }
                                                    
                            }
                            
                           
                            UserDefaults.standard.setValue(true, forKey: Constant.UD_new_has_selected_language)
                            
                            if let dismiss = dismiss {
                                dismiss()
                            }
                        }
                        .padding()
                    )
                    .edgesIgnoringSafeArea(.bottom)
                
                
            }
            
        }
        .background(Color.AppBG.edgesIgnoringSafeArea(.all))
        .actionSheet(isPresented: $isShowRegionSelection) {
            ActionSheet(title: Text(NSLocalizedString("Select Your Region", comment: "")), message: Text(NSLocalizedString("Changing Language Description", comment: "")), buttons: actionSheetButtons)
        }
        .onAppear {
            if viewModel.regions.isEmpty {
                viewModel.getAllRegions()
            }
         
            if !isPrimary {
                viewModel.selectedLanguage = LanguageHelper.shared.getSecondaryLanguage()
            }
        }
        
    }
    
    var actionSheetButtons: [ActionSheet.Button] {
        var array : [ActionSheet.Button] = []
        viewModel.regions.map { region in
            array.append(.default(Text(region.name), action: {
                viewModel.selectedRegion = region
                viewModel.selectedLanguage = nil
                viewModel.getLanguage(withRegionID: region.id, completion: nil)
            }))
        }
      
        return array
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
                
                if language.id == viewModel.selectedLanguage?.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.AppPinkPrimary)
                }
                
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white.cornerRadius(20))
            .onTapGesture {
                 viewModel.selectedLanguage = language
            }
            if language.id != viewModel.languages.last?.id {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 0.5)
            }
            
        }
    }
}

struct CustomAlert: View {
    @Environment(\.presentationMode) var presentation
    let message: String
    let titlesAndActions: [(title: String, action: (() -> Void)?)] // = [.default(Text("OK"))]
    
    var body: some View {
        VStack {
            Text(message)
            Divider().padding([.leading, .trailing], 40)
            HStack {
                ForEach(titlesAndActions.indices, id: \.self) { i in
                    Button(self.titlesAndActions[i].title) {
                        (self.titlesAndActions[i].action ?? {})()
                        self.presentation.wrappedValue.dismiss()
                    }
                    .padding()
                }
            }
        }
    }
}


struct LanguageOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageOnboardingView()
    }
}
