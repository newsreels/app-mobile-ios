//
//  registerProfileUploadVC.swift
//  Bullet
//
//  Created by Mahesh on 09/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class registerProfileUploadVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var viewSkip: UIView!
    @IBOutlet weak var lblSkip: UILabel!

    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var userProfileImage: UIImage?

    var picker = UIImagePickerController()
    var alert = UIAlertController(title: NSLocalizedString("Choose Image", comment: ""), message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    let imagePicker = ImagePicker()

    var isOpenFromCreateChannel = false
    var channelName = ""
    var channelDescription = ""
    var imageURL = ""
//    var isFromMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black
        
        lblTitle.text = NSLocalizedString("Ok, last thing is", comment: "")
        if isOpenFromCreateChannel {
            
            lblTitle2.text = NSLocalizedString("your channel image", comment: "")
            
            view.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
            lblTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
            lblTitle2.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        } else {
            
            lblTitle2.text = NSLocalizedString("your profile image", comment: "")
        }
        
        lblSkip.text = NSLocalizedString("SKIP", comment: "")
        lblSkip.addTextSpacing(spacing: 2.0)
        
        viewSkip.backgroundColor = "#84838B".hexStringToUIColor()
        viewSkip.cornerRadius  = viewSkip.frame.size.height / 2
        viewSkip.cornerRadius  = viewSkip.frame.size.height / 2
        imgProfile.cornerRadius = imgProfile.frame.height / 2
        imgProfile.layer.theme_borderColor = GlobalPicker.backgroundColorBlackWhiteCG
        imgProfile.layer.borderWidth = 2
        imgProfile.contentMode = .scaleAspectFill
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if SharedManager.shared.selectedChannelImageURL != "" {
            
            self.imageURL = SharedManager.shared.selectedChannelImageURL
            imgProfile?.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
            
            setContinue()
            
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblTitle2.semanticContentAttribute = .forceRightToLeft
                self.lblTitle2.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblTitle2.semanticContentAttribute = .forceLeftToRight
                self.lblTitle2.textAlignment = .left
            }
        }
    }
    
    @IBAction func didTapSkip(_ sender: UIButton) {
        
        if isOpenFromCreateChannel {
            
            let vc = ChannelProfilePreviewVC.instantiate(fromAppStoryboard: .Channel)
//            vc.isFromMode = isFromMode
            vc.channelName = channelName
            vc.channelDescription = channelDescription
            vc.imageURL = self.imageURL
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            self.performWSToUserConfig()
        }
        
    }
    
    @IBAction func didTapUploadProfile(_ sender: UIButton) {
        
        //profile image
        self.setImage(true)
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //set image
    func setImage(_ isTapOnProfile: Bool) {
        
        imagePicker.viewController = self
        imagePicker.onPick = { [weak self] image in
            
            if self?.isOpenFromCreateChannel ?? false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.uploadImage(image)
                }
            } else {
                self?.uploadImage(image)
            }
            
            
        }
        //imagePicker.viewController?.modalPresentationStyle = .overFullScreen
        imagePicker.show()
    }

    func uploadImage(_ chosenImage: UIImage) {
        
        self.imgProfile.cornerRadius = imgProfile.frame.height / 2
        self.imgProfile.contentMode = .scaleAspectFill
        self.imgProfile.image = chosenImage
        self.userProfileImage = chosenImage
        
        if isOpenFromCreateChannel {
            
            if userProfileImage != nil {
                performWSToUploadImage(userProfileImage!) { [weak self] url  in
                    if url != nil {
                        
                        self?.imageURL = url ?? ""
                        self?.viewSkip.theme_backgroundColor = GlobalPicker.themeCommonColor
                        self?.lblSkip.text = NSLocalizedString("CONTINUE", comment: "")
                        self?.lblSkip.addTextSpacing(spacing: 2.0)
                    } else {
                        self?.imageURL = ""
                    }
                    
                    
                    SharedManager.shared.selectedChannelImageURL = self?.imageURL ?? ""
                }
            }
            
        } else {
            
            setContinue()
            
            performWebUpdateProfile()
            
        }
    }
    
    
    func setContinue() {
        
        viewSkip.theme_backgroundColor = GlobalPicker.themeCommonColor
        lblSkip.text = NSLocalizedString("CONTINUE", comment: "")
        lblSkip.addTextSpacing(spacing: 2.0)
    }
    
    func performWSToUploadImage(_ image: UIImage, completionHandler: @escaping (_ imageURL: String?) -> Void) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        var dicSelectedImages = [String: UIImage]()
        dicSelectedImages["image"] = image
        
        WebService.URLRequestBodyParams("media/images", method: .post, parameters: nil, headers: token, ImageDic: dicSelectedImages) { (response) in
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(UploadSuccessDC.self, from: response)
                
                if FULLResponse.success == true {
                    
                    completionHandler(FULLResponse.results ?? "")
                }
                else {
                    completionHandler("")
                }
                
                ANLoader.hide()
            } catch let jsonerror {
                ANLoader.hide()
                completionHandler("")
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "media/images", error: jsonerror.localizedDescription, code: "")
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            completionHandler("")
            print("error parsing json objects",error)
        }
        
    }
    
    func performWebUpdateProfile() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        var dicSelectedImages = [String: UIImage]()
        
        if userProfileImage != nil {
            dicSelectedImages["profile_image"] = userProfileImage
        }
                
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: nil, headers: token, ImageDic: dicSelectedImages) { (response) in
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(updateProfileDC.self, from: response)
                
                if let user = FULLResponse.user {

                    SharedManager.shared.userId = user.id ?? ""

                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(user) {
                        SharedManager.shared.userDetails = encoded
                    }
                }
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Profile updated successfully", comment: ""), type: .alert)
                
                ANLoader.hide()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUserConfig() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigDC.self, from: response)
                
                if let ads = FULLResponse.ads {
    
                    UserDefaults.standard.set(ads.enabled, forKey: Constant.UD_adsAvailable)
                    UserDefaults.standard.set(ads.ad_unit_key, forKey: Constant.UD_adsUnitKey)
                    UserDefaults.standard.set(ads.type, forKey: Constant.UD_adsType)
                    SharedManager.shared.adsInterval = ads.interval ?? 10
                    
                    if ads.type?.uppercased() == "FACEBOOK" {
                        
                        UserDefaults.standard.set(ads.facebook?.feed, forKey: Constant.UD_adsUnitFeedKey)
                        UserDefaults.standard.set(ads.facebook?.reel, forKey: Constant.UD_adsUnitReelKey)
                    } else {
                        
                        UserDefaults.standard.set(ads.admob?.feed, forKey: Constant.UD_adsUnitFeedKey)
                        UserDefaults.standard.set(ads.admob?.reel, forKey: Constant.UD_adsUnitReelKey)
                    }
                }
                
                //For Community Guildelines
                if let terms = FULLResponse.terms {
                    SharedManager.shared.community = terms.community ?? true
                }
                
                if let preference = FULLResponse.home_preference {
                    
                    SharedManager.shared.isTutorialDone = preference.tutorial_done ?? false
                    SharedManager.shared.bulletsAutoPlay = preference.bullets_autoplay ?? false
                    SharedManager.shared.reelsAutoPlay = preference.reels_autoplay ?? false
                    SharedManager.shared.videoAutoPlay = preference.videos_autoplay ?? false
                    SharedManager.shared.readerMode = preference.reader_mode ?? false
                    SharedManager.shared.speedRate = preference.narration?.speed_rate ?? ["1.0x":1]
                    
//                    if let mode = preference.view_mode {
//
//                        SharedManager.shared.menuViewModeType = mode
//
//                    }
                    
                    if let narrMode = preference.narration?.mode {
                        
                        SharedManager.shared.showHeadingsOnly = narrMode

                    }
                }
                
                if let rating = FULLResponse.rating {
                    
                    let interval = rating.interval ?? 100
                    let nextInt = rating.next_interval ?? 100
                    
                    if interval > SharedManager.shared.appUsageCount ?? 0 {
                        UserDefaults.standard.setValue(interval, forKey: Constant.ratingTimeIntervel)
                    }
                    else {
                        UserDefaults.standard.setValue(nextInt, forKey: Constant.ratingTimeIntervel)
                    }
                }
                
                SharedManager.shared.isLinkedUser = FULLResponse.user?.guestValid ?? false
                
                // Load default theme settings
                SharedManager.shared.setThemeAutomatic()
                
                let userLang = FULLResponse.user?.language ?? "en"
                let code = UserDefaults.standard.string(forKey: Constant.UD_languageSelected) ?? "en"
                
                if userLang != code {
                        
                    var id = ""
                    if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
                        
                        if let selectedIndex = lang.firstIndex(where: { $0.code == code }) {
                            
                            id = lang[selectedIndex].id ?? ""
                        }
                        
                    }
                    
                    ANLoader.showLoading(disableUI: true)
                    SharedManager.shared.performWSToUpdateLanguage(id: id, isRefreshedToken: true, completionHandler: { status in
                        ANLoader.hide()
                        if status {
                            print("language updated successfully")
                        } else {
                            print("language updated failed")
                        }
                    })
                }
                else {
                }
                
            } catch let jsonerror {
            
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}
