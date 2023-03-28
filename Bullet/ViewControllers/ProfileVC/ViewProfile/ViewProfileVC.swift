//
//  ViewProfileVC.swift
//  Bullet
//
//  Created by Mahesh on 08/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ViewProfileVC: UIViewController {
    
    var profileVC = ProfilePageViewController()
    var isFirstLoadView = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SharedManager.shared.bulletPlayer = nil
        isFirstLoadView = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFirstLoadView {
            if let vc = profileVC.currentViewController as? ProfileArticlesVC  {
                if SharedManager.shared.isReloadProfileArticle {
                    vc.viewWillAppear(true)
                }
                else {
                    vc.reloadData()
                }
            }
        }
        isFirstLoadView = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileEmbedSegue" {
            
            profileVC = segue.destination as! ProfilePageViewController
            //profileVC.pageDelegate = self
            profileVC.isFromChannelView = false
            profileVC.authorID = SharedManager.shared.userId
        }
    }
    
}

//MARK:-  Web Services
//extension ViewProfileVC {
//
//    func performWSToGetAuthor(_ id: String) {
//
//        if !(SharedManager.shared.isConnectedToNetwork()){
//
//            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
//            return
//        }
//
//        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
//        WebService.URLResponse("news/authors/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
//
//            do{
//                let FULLResponse = try
//                    JSONDecoder().decode(AuthorDC.self, from: response)
//
////                if let user = FULLResponse.author {
////
////                    let profile = user.profile_image ?? ""
////                    let cover = user.cover_image ?? ""
////
////                    self.imgUserVerified.isHidden = !(user.verified ?? false)
////
////                    if profile.isEmpty {
////                        self.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
////                    }
////                    else {
////                        self.imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
////                    }
////
////                    if cover.isEmpty {
////                        self.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
////                    }
////                    else {
////                        self.imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
////                    }
////
////                    let fullName = (user.first_name ?? "").capitalized + " " + (user.last_name ?? "").capitalized
////                    self.lblUsername.text = fullName.trim()
////                    self.lblFollowers.text = "\((user.follower_count ?? 0).formatUsingAbbrevation()) \(NSLocalizedString("Followers", comment: ""))"
////                    self.lblPost.text = "\((user.post_count ?? 0).formatUsingAbbrevation()) \(NSLocalizedString("Posts", comment: ""))"
////
////                }
////                else {
////
////                    self.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
////                    self.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
////                }
//
//            } catch let jsonerror {
//
//                SharedManager.shared.logAPIError(url: "news/authors/\(id)", error: jsonerror.localizedDescription, code: "")
//                print("error parsing json objects",jsonerror)
//            }
//
//        }) { (error) in
//
//            print("error parsing json objects",error)
//        }
//    }
//
//    func performWebUpdateProfile() {
//
//        if !(SharedManager.shared.isConnectedToNetwork()){
//
//            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
//            return
//        }
//
//        ANLoader.showLoading()
//        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
//        var dicSelectedImages = [String: UIImage]()
//
////        if userProfileImage != nil {
////            dicSelectedImages["profile_image"] = userProfileImage
////        }
////
////        if userCoverImage != nil {
////            dicSelectedImages["cover_image"] = userCoverImage
////        }
//
////        let params = ["first_name": "",
////                      "last_name": "",
////                      "mobile_number": ""] as [String : Any]
//
//        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: nil, headers: token, ImageDic: dicSelectedImages) { (response) in
//            do{
//
//                let FULLResponse = try
//                    JSONDecoder().decode(updateProfileDC.self, from: response)
//
//                if FULLResponse.success == true {
//
//                    if let user = FULLResponse.user {
//
//                        SharedManager.shared.userId = user.id ?? ""
//
//                        let encoder = JSONEncoder()
//                        if let encoded = try? encoder.encode(user) {
//                            SharedManager.shared.userDetails = encoded
//                        }
//                    }
//
//                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Profile updated successfully", comment: ""), duration: 1, position: .bottom)
//                }
//
//                ANLoader.hide()
//            } catch let jsonerror {
//
//                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
//                ANLoader.hide()
//                print("error parsing json objects",jsonerror)
//            }
//        } withAPIFailure: { (error) in
//            ANLoader.hide()
//            print("error parsing json objects",error)
//        }
//    }
//
//}
