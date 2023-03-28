//
//  ProfileView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var isShowDeleteConfirmation: Bool = false
    
    @State private var user: UserProfile?
    @StateObject var settings = PushManager.shared
    
    @State private var isCameraOpen = false
    @State private var isPhotoLibraryOpen = false
    @State private var isEditingPhoto = false
    
    @State var changedImage: UIImage?
    
    var body: some View {
        VStack {
            VStack {
                HStack{Spacer()}
                
                if let changedImage = changedImage {
                     Image(uiImage: changedImage)
                        .resizable()
                        .frame(width: 92, height: 92)
                        .cornerRadius(46)
                        .scaledToFill()
                } else {
                    if let profileImage = user?.profile_image, !profileImage.isEmpty {
                        AppURLImage(profileImage)
                            .frame(width: 92, height: 92)
                            .cornerRadius(46)
                    } else {
                        Image("user_placeholder_ic")
                            .resizable()
                            .frame(width: 91, height: 91)
                            .padding(.top, 34)
                    }
                }
                
                
                Button {
                    isPhotoLibraryOpen = true
                } label: {
                    AppText("Set Your Profile Picture", weight: .nunitoBold, size: 13, color: .AppPinkPrimary)
                }
                .padding(.top, 10.5)
                
                AppTextField(title: "Name", placeholder: "John Doe", text: $name, keyboardType: .emailAddress)
                    .padding(.top, 40)
                
                AppTextField(title: "Username", placeholder: "johndoe", text: $username)
                    .padding(.top, 16)
                
                AppButton(title: "Save", preset: .pinkBG) {
                    performWebUpdateProfile()
                }
                .padding(.top, 64)
                
//                if !isShowDeleteConfirmation {
//                    AppButton(title: "Delete account", preset: .noBGPink) {
//                        isShowDeleteConfirmation = true
//                    }
//                    .padding(.top, 10)
//                } else {
//                    
//                    VStack {
//                        
//                        AppText("Are you sure you want to delete your account? This can't be undone.", alignment: .center)
//                        
//                        HStack {
//                            AppButton(title: "No", textColor: .AppBlue, fontSize: 18, font: .semiBold, bgColor: .clear) {
//                                isShowDeleteConfirmation = false
//                            }
//                            
//                            AppButton(title: "Yes", textColor: .AppRed, fontSize: 18, font: .semiBold, bgColor: .clear) {
//                                logout()
//                                deleteAccount()
//                            }
//                            
//                        }
//                    }
//                    .padding(.top, 20)
//                    
//                }
//                
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 30)
            .onTapGesture {
                Utilities.endEditing()
            }
        }
        .onAppear {
            if let userProfile = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
                user = userProfile
                name = "\(user?.first_name ?? "") \(user?.last_name ?? "")"
                username = user?.username ?? ""
            }
        }
        .background(Color.AppBG)
        .navigationBar(title: "Profile")
        .edgesIgnoringSafeArea(.bottom)
//        .sheet(isPresented: $isCameraOpen) {
//            ImagePicker(image: changedImage.onChange{ _ in
//                isEditingPhoto = true
//            }, source: .camera)
//        }
        .sheet(isPresented: $isPhotoLibraryOpen) {
            SwiftUIImagePicker(image: $changedImage.onChange{ _ in
                isEditingPhoto = true
            }, source: .photoLibrary)
        }
        
    }
    
    private func deleteAccount() {
        ProfileViewModel().deleteAccount()
    }
    
    private func logout() {
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.logoutClick)
        
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        Utilities.showLoader()
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
        let params = ["token": refreshToken]
        
        WebService.URLResponseAuth("auth/logout", method: .post, parameters: params, headers: userToken as? String, withSuccess: { (response) in
            
            Utilities.hideLoader()
            
            do{
                let FULLResponse = try
                JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logout()
                }
                
                
            } catch let jsonerror {
                Utilities.hideLoader()
                SharedManager.shared.logAPIError(url: "auth/logout", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }){ (error) in
            
            Utilities.hideLoader()
            print("error parsing json objects",error)
        }
    }
    
}

extension ProfileView {
    
    func performWebUpdateProfile() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        Utilities.showLoader()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        var dicSelectedImages = [String: UIImage]()
        
        if changedImage != nil {
            dicSelectedImages["profile_image"] = changedImage
        }
        
        let params = ["name": name.trim() ,
                      "username": username.trim() ] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: params, headers: token, ImageDic: dicSelectedImages) { (response) in
            
            //            self.hideLoaderVC()
            Utilities.hideLoader()
            do{
                
                let FULLResponse = try
                JSONDecoder().decode(updateProfileDC.self, from: response)
                
                if FULLResponse.success == true {
                    
                    if let user = FULLResponse.user {
                        
                        SharedManager.shared.userId = user.id ?? ""
                        
                        let encoder = JSONEncoder()
                        if let encoded = try? encoder.encode(user) {
                            SharedManager.shared.userDetails = encoded
                        }
                        
                        
                    }
                    
                    SharedManager.shared.isUserSetup = true
                    
                    
                    
                }
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        } withAPIFailure: { (error) in
            //            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
