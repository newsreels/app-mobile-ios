//
//  ChannelCoverPhotoVC.swift
//  Bullet
//
//  Created by Mahesh on 21/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ChannelCoverPhotoVC: UIViewController {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgPortrait: UIImageView!

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblProName: UILabel!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var lblPortrait: UILabel!
    
    @IBOutlet weak var lblCoverPhoto: UILabel!
    @IBOutlet var viewCollection: [UIView]!

    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btCover: UIButton!
    @IBOutlet weak var btnPortrait: UIButton!
    
    //VARIABLES
    var picker = UIImagePickerController()
    var alert = UIAlertController(title: NSLocalizedString("Choose Image", comment: ""), message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    let imagePicker = ImagePicker()
    
    var channelInfo: ChannelInfo?
    var isFromModerator = false
    
    //#1A1A1A
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtFirstName.isUserInteractionEnabled = false

        self.setLocalization()
        self.setDesignView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleUploadCoverImgTap(_:)))
        imgCover.isUserInteractionEnabled = true
        imgCover.addGestureRecognizer(tap)
        
        let tapPortrait = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnPortraitImage(_:)))
        imgPortrait.isUserInteractionEnabled = true
        imgPortrait.addGestureRecognizer(tapPortrait)

                
        let profile = channelInfo?.icon ?? ""
        let cover = channelInfo?.image ?? ""
        let portrait = channelInfo?.portrait_image ?? ""

        if profile.isEmpty {
            imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
        }
        else {
            imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
        }

        if cover.isEmpty {
            imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
        }
        else {
            imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
        }
        
        if portrait.isEmpty {
            imgPortrait.theme_image = GlobalPicker.imgCoverPlaceholder
        }
        else {
            imgPortrait.sd_setImage(with: URL(string: portrait), placeholderImage: nil)
        }

        txtFirstName.text = channelInfo?.name?.capitalized
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblCoverPhoto.semanticContentAttribute = .forceRightToLeft
                self.lblCoverPhoto.textAlignment = .right
                self.lblProName.semanticContentAttribute = .forceRightToLeft
                self.lblProName.textAlignment = .right
                self.lblPortrait.semanticContentAttribute = .forceRightToLeft
                self.lblPortrait.textAlignment = .right

            } else {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblCoverPhoto.semanticContentAttribute = .forceLeftToRight
                self.lblCoverPhoto.textAlignment = .left
                self.lblProName.semanticContentAttribute = .forceLeftToRight
                self.lblProName.textAlignment = .left
                self.lblPortrait.semanticContentAttribute = .forceLeftToRight
                self.lblPortrait.textAlignment = .left
            }
        }
    }
    
    func setDesignView() {
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        imgBack.theme_image = GlobalPicker.imgBack

        btnProfile.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)
        btCover.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)
        btnPortrait.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)

        self.imgProfile.cornerRadius = imgProfile.frame.height / 2
        self.imgProfile.contentMode = .scaleAspectFill

        viewBG.theme_backgroundColor =
            GlobalPicker.backgroundColorEdition
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblCoverPhoto.addTextSpacing(spacing: 2.0)
        lblCoverPhoto.theme_textColor = GlobalPicker.textColor
        
        lblPortrait.addTextSpacing(spacing: 2.0)
        lblPortrait.theme_textColor = GlobalPicker.textColor

        txtFirstName.theme_textColor = GlobalPicker.textColor
    }
    
    func setLocalization() {
        
        lblTitle.text = NSLocalizedString("channel and cover photo", comment: "").uppercased()
        
        lblCoverPhoto.text = NSLocalizedString("COVER PHOTO", comment: "")
        lblProName.text = NSLocalizedString("channel name", comment: "").capitalized
        lblPortrait.text = NSLocalizedString("PORTRAIT PHOTO", comment: "")
        //txtFirstName.placeholder = NSLocalizedString("Channel Name", comment: "")
    }
    
    func setImage(_ isTapOnProfile: Bool, isPortrait: Bool) {
        
        imagePicker.viewController = self
        imagePicker.onPick = { [weak self] image in
            self?.uploadImage(image, isTapOnProfile: isTapOnProfile, isPortrait: isPortrait)
        }
        imagePicker.show()

    }

    func uploadImage(_ image: UIImage, isTapOnProfile: Bool, isPortrait: Bool) {
        
        if isPortrait {
            self.imgPortrait.image = image
            self.imgPortrait.contentMode = .scaleAspectFill
        }
        else if isTapOnProfile {
            
            self.imgProfile.image = image
            self.imgProfile.cornerRadius = imgProfile.frame.height / 2
            self.imgProfile.contentMode = .scaleAspectFill
        }
        else {
            self.imgCover.image = image
            self.imgCover.contentMode = .scaleAspectFill
        }
        
        performWSToUploadImage(image) { [weak self] url  in
            if url != nil, let url = url {
                
                let cname = self?.channelInfo?.name ?? ""
                var params = [String: String]()
                if isPortrait {
                    params = ["portrait": url, "name": cname]
                }
                else if isTapOnProfile {
                    params = ["icon": url, "name": cname]
                }
                else {
                    params = ["cover": url, "name": cname]
                }
                    
                self?.performWebUpdateChannelImage(params)
            } else {
                
            }
        }
    }

    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackAction(_ sender: Any) {
        
        //performWebUpdateProfile()
        if isFromModerator {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapProfileAction(_ sender: UIButton) {
        print("didTapProfileAction....")
        self.setImage(true, isPortrait: false)
    }
    
    @IBAction func didTapCoverAction(_ sender: UIButton) {
        print("didTapCoverAction....")
        self.setImage(false, isPortrait: false)
    }
    
    @IBAction func didTapPortraitAction(_ sender: UIButton) {
        print("didTapCoverAction....")
        self.setImage(false, isPortrait: true)
    }

    
    @objc func handleUploadCoverImgTap(_ sender: UITapGestureRecognizer? = nil) {
        
        print("handleUploadCoverImgTap....")
        self.setImage(false, isPortrait: false)
    }
        
    @objc func handleTapOnPortraitImage(_ sender: UITapGestureRecognizer? = nil) {
        
        print("handleUploadCoverImgTap....")
        self.setImage(false, isPortrait: true)
    }

}

//MARK:-  Web Services
extension ChannelCoverPhotoVC {
    
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
    
    func performWebUpdateChannelImage(_ params: [String: String]) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        ANLoader.showLoading(disableUI: false)
        
        let channelId = self.channelInfo?.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponse("studio/channels/\(channelId)", method: .patch, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                if let channel = FULLResponse.channel {
                    self.channelInfo = channel
                }
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Channel updated succesfully", comment: ""), type: .alert)

            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/channels", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
//    func performWebUpdateChannel() {
//
//        if !(SharedManager.shared.isConnectedToNetwork()) {
//
//            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
//            return
//        }
//
//        ANLoader.showLoading()
//        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
//        var dicSelectedImages = [String: UIImage]()
//
//        if userProfileImage != nil {
//            dicSelectedImages["icon"] = userProfileImage
//        }
//
//        if userCoverImage != nil {
//            dicSelectedImages["cover"] = userCoverImage
//        }
//
//        let query = "studio/channels/\(channelInfo?.id ?? "")"
//
//        WebService.multiParamsULResponseMultipleImages(query, method: .patch, parameters: nil, headers: token, ImageDic: dicSelectedImages) { (response) in
//            do{
//
//                let FULLResponse = try
//                    JSONDecoder().decode(ChannelListDC.self, from: response)
//
//                if let channel = FULLResponse.channel {
//                    self.channelInfo = channel
//                }
//
//                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Channel updated succesfully", comment: ""), type: .alert)
//
//                ANLoader.hide()
//            } catch let jsonerror {
//
//                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
//                ANLoader.hide()
//                print("error parsing json objects",jsonerror)
//            }
//        } withAPIFailure: { (error) in
//            ANLoader.hide()
//            print("error parsing json objects",error)
//        }    }
    
}
