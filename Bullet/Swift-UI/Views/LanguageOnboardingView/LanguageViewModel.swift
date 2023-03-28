//
//  LanguageSelectorViewModel.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/24/22.
//

import Foundation
import SwiftUI

class LanguageViewModel: ObservableObject {
        
    @Published var selectedRegion: NewRegion? = nil
    @Published var selectedLanguage: NewLanguage? = nil
    @Published var selectedSecondaryLanguage: NewLanguage? = nil
    @Published var regions: [NewRegion] = []
    @Published var languages: [NewLanguage] = []
    
    func getAllRegions() {
        
        URLSessionProvider.shared.request(NewRegionResponse.self, service: LanguageService.getPublicRegions) { result in
            switch result {
            case .failure(let error):
                print("ERROR || Failed to get regions \(error.localizedDescription)")
            case .success(let regionResponse):
                DispatchQueue.main.async {
                    self.regions = regionResponse.regions
                    if let region = LanguageHelper.shared.getSavedRegion() {
                        self.selectedRegion = region
                    } else {
                        self.selectedRegion = regionResponse.regions.first
                    }
                    self.getLanguage(withRegionID: self.selectedRegion?.id, completion: nil)
                }
            }
        }
    }
    
    func getLanguage(withRegionID regionId: String?, completion: (() -> Void)?){
        if let regionId = regionId {
            URLSessionProvider.shared.request(NewLanguageResponse.self, service: LanguageService.getPublicLanguages(regionId)) { result in
                switch result {
                case .failure(let error):
                    print("ERROR || Failed to get languages \(error.localizedDescription)")
                case .success(let languageResponse):
                    DispatchQueue.main.async {
                        self.languages = languageResponse.languages
                        if let selectedLanguage = LanguageHelper.shared.getSavedLanguage() {
                            self.selectedLanguage = selectedLanguage
                        } else {
                            self.selectedLanguage = self.languages.first
                        }
                        
                        if let completion = completion {
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func saveSelectedRegionAndLanguage(isInSettings: Bool = false, completion: (() -> Void)?) {
        if let selectedRegion = selectedRegion, let selectedLanguage = selectedLanguage {
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
            
            SharedManager.shared.performWSToUpdateRegion(selectedRegion.id) { status in
            
                SharedManager.shared.performWSToUpdateLanguage(id: selectedLanguage.id, isRefreshedToken: true, completionHandler: { status in
                    if let completion = completion {
                        completion()
                    }
                    if status {
                        print("language updated successfully")
                    } else {
                        print("language updated failed")
                    }
                })
            }
        } else {
            
            SharedManager.shared.performWSToUpdateRegion(selectedRegion?.id ?? "475a0f0d-e3f4-4277-9ee4-3633e53c34c3") { status in
            
                SharedManager.shared.performWSToUpdateLanguage(id: "ee4add73-b717-4e32-bffb-fecbf82ee6d9", isRefreshedToken: true, completionHandler: { status in
                    if let completion = completion {
                        completion()
                    }
                    if status {
                        print("language updated successfully")
                    } else {
                        print("language updated failed")
                    }
                })
            }
        }
        
     
       
        UserDefaults.standard.setValue(true, forKey: Constant.UD_new_has_selected_language)
    }
  
}

class LanguageHelper {
    static let languageShared = LanguageViewModel()
    static let shared = LanguageHelper()
    
    func getSavedLanguage() -> NewLanguage? {
        if let data = UserDefaults.standard.data(forKey: Constant.UD_new_languageSelected) {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(NewLanguage.self, from: data)
                print("GET SAVED LANGUAGE = \(data)")
                return data
            } catch {
                print("Unable to Decode Note (\(error))")
                return nil
            }
        }
        return nil
    }
    
    func getSavedRegion() -> NewRegion? {
        if let data = UserDefaults.standard.data(forKey: Constant.UD_new_region_Selected) {
            do {
                let decoder = JSONDecoder()
                
                let data = try decoder.decode(NewRegion.self, from: data)
                return data
            } catch {
                print("Unable to Decode Note (\(error))")
                return nil
            }
        }
        return nil
    }
    
    func getSecondaryLanguage() -> NewLanguage? {
        if let data = UserDefaults.standard.data(forKey: Constant.UD_new_secondary_language) {
            do {
                let decoder = JSONDecoder()
                
                let data = try decoder.decode(NewLanguage.self, from: data)
                return data
            } catch {
                print("Unable to Decode Note (\(error))")
                return nil
            }
        }
        return nil
    }
    
    func saveRegion(region: NewRegion) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            
            // Encode Note
            let data = try encoder.encode(region)
            
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: Constant.UD_new_region_Selected)
            
        } catch {
            print("Unable to Encode Note (\(error))")
        }
        
    }

    func saveLanguage(language: NewLanguage, isInSettings: Bool = false) {
        do {
            let encoder = JSONEncoder()
            
            let data = try encoder.encode(language)
            
            UserDefaults.standard.set(data, forKey: Constant.UD_new_languageSelected)
            
            SharedManager.shared.performWSToUpdateLanguage(id: language.id, isRefreshedToken: true, completionHandler: { status in
                if status {
                    print("language updated successfully")

                } else {
                    print("language updated failed")
                }
            })
            
            if isInSettings {
                performWSToUpdateUserContentLanguages(isPrimary: true, completionHandler: {})
            }

            
        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }
    
    func saveSecondaryLanguage(language: NewLanguage, isInSettings: Bool = false) {
        do {
            let encoder = JSONEncoder()
            
            let data = try encoder.encode(language)
            
            UserDefaults.standard.set(data, forKey: Constant.UD_new_secondary_language)
            
            if isInSettings {
                performWSToUpdateUserContentLanguages(isPrimary: false, completionHandler: {})
            }
            
        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }
    
    
    func performWSToUpdateUserContentLanguages(isPrimary: Bool = true, completionHandler: @escaping () -> Void) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let token = UserDefaults.standard.object(forKey: Constant.UD_userToken) as? String ?? ""
        let params = ["language": isPrimary ? self.getSavedLanguage()?.id : self.getSecondaryLanguage()?.id,
                      "tag" : isPrimary ? "primary" : "secondary"]
            
        WebService.URLResponseJSONRequest("news/languages/", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                
                if FULLResponse.message?.lowercased() == "success" {
                    SharedManager.shared.isTabReload = true
                    completionHandler()
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                completionHandler()
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
            completionHandler()

        }
    }
}
