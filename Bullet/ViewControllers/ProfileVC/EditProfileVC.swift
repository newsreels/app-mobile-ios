//
//  EditProfileVC.swift
//  Bullet
//
//  Created by Mahesh on 08/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol EditProfileVCDelegate: AnyObject {
    
    func setProfileData()
}

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var imgSmallUSer: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblProfileSettings: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var lblProName: UILabel!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var lblFirstNameCount: UILabel!

    @IBOutlet weak var lblCoverPhoto: UILabel!
    @IBOutlet var viewCollection: [UIView]!

    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btCover: UIButton!
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var lblUsernameCount: UILabel!
//    @IBOutlet weak var lblErrorMsg: UILabel!
    @IBOutlet weak var imgError: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //VARIABLES
    var userProfileImage: UIImage?
    var userCoverImage: UIImage?
    var picker = UIImagePickerController()
    var alert = UIAlertController(title: NSLocalizedString("Choose Image", comment: ""), message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    let imagePicker = ImagePicker()
    var uname = ""
    
    weak var delegate: EditProfileVCDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.stopAnimating()
        txtFirstName.delegate = self
        txtFirstName.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        txtUsername.delegate = self
        txtUsername.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        self.setLocalization()
        self.setDesignView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleUploadCoverImgTap(_:)))
        imgCover.isUserInteractionEnabled = true
        imgCover.addGestureRecognizer(tap)
                
        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {

            let profile = user.profile_image ?? ""
            let cover = user.cover_image ?? ""

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

            txtFirstName.text = user.first_name ?? ""
            textFieldDidChange(txtFirstName)
            
            uname = user.username ?? ""
            txtUsername.text = uname
            textFieldDidChange(txtUsername)
        }
    }
    
    func setDesignView() {
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        viewUser.theme_backgroundColor = GlobalPicker.backgroundColorEdition
        imgSmallUSer.theme_image = GlobalPicker.imgSmallUser
        imgBack.theme_image = GlobalPicker.imgBack

        btnProfile.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)
        btCover.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)

        imgProfile.cornerRadius = imgProfile.frame.height / 2
        imgProfile.contentMode = .scaleAspectFill

        viewBG.theme_backgroundColor = GlobalPicker.backgroundColorEdition
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblCoverPhoto.addTextSpacing(spacing: 2.0)
        lblCoverPhoto.theme_textColor = GlobalPicker.textColor
        
        lblProfileSettings.theme_textColor = GlobalPicker.textColor
        txtFirstName.theme_textColor = GlobalPicker.textColor
        txtFirstName.theme_tintColor = GlobalPicker.textColor
        txtUsername.theme_textColor = GlobalPicker.textColor
        txtUsername.theme_tintColor = GlobalPicker.textColor
    }
    
    func setLocalization() {
        
        lblTitle.text = NSLocalizedString("Edit Profile", comment: "")
        lblProfileSettings.text = NSLocalizedString("Profile Settings", comment: "")
        lblDesc.text = NSLocalizedString("Edit what viewers see in your profile.", comment: "")
        
        lblCoverPhoto.text = NSLocalizedString("COVER PHOTO", comment: "")
        lblProName.text = NSLocalizedString("Profile Name", comment: "")
        lblUsername.text = NSLocalizedString("Username", comment: "")

        txtFirstName.placeholder = NSLocalizedString("Name", comment: "")
        txtUsername.placeholder = NSLocalizedString("Username", comment: "")
    }
    
    func setImage(_ isTapOnProfile: Bool) {
        
        imagePicker.viewController = self
        imagePicker.onPick = { [weak self] image in
            self?.uploadImage(image, isTapOnProfile: isTapOnProfile)
        }
        imagePicker.show()

    }

    func uploadImage(_ image: UIImage, isTapOnProfile: Bool) {
        
        if isTapOnProfile {
            
            self.userProfileImage = image
            self.imgProfile.image = image
            self.imgProfile.cornerRadius = imgProfile.frame.height / 2
            self.imgProfile.contentMode = .scaleAspectFill
        }
        else {
            self.userCoverImage = image
            self.imgCover.image = image
            self.imgCover.contentMode = .scaleAspectFill
        }
        
        performWebUpdateProfile()
    }

    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackAction(_ sender: Any) {
        
        //performWebUpdateProfile()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapProfileAction(_ sender: UIButton) {
        print("didTapProfileAction....")
        self.setImage(true)
    }
    
    @IBAction func didTapCoverAction(_ sender: UIButton) {
        print("didTapCoverAction....")
        self.setImage(false)
    }
    
    @objc func handleUploadCoverImgTap(_ sender: UITapGestureRecognizer? = nil) {
        
        print("handleUploadCoverImgTap....")
        self.setImage(false)
    }
        
}

//MARK:-  Text Field Delegate
extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if !(textField.text?.isEmpty ?? false) {
            self.performWebUpdateProfile()
        }
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == txtFirstName {
            
            let strLength = textField.text?.count ?? 0
            if strLength == 0 {
                
                lblFirstNameCount.text = "25"
            }
            else {
              
                lblFirstNameCount.text = "\(strLength)/25"
            }
        }
        else if textField == txtUsername {
            
            //lblErrorMsg.text = ""
            let strLength = textField.text?.count ?? 0
            if strLength == 0 {
                
                lblUsernameCount.text = "25"
            }
            else {
                
                lblUsernameCount.text = "\(strLength)/25"
            }
            
            self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
        }
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        let text = textField.text ?? ""
        if text.isEmpty || uname == text { return }
        performWSCheckUsername(text)
    }
    
    func performWSCheckUsername(_ text: String) {
        
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let param = ["username": text]
        activityIndicator.startAnimating()
        imgError.isHidden = true
        WebService.URLResponseAuth("auth/username", method: .post, parameters: param, headers: token, withSuccess: { (response) in
            
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                self.activityIndicator.stopAnimating()
                let valid = FULLResponse.valid ?? false
                self.imgError.isHidden = false
                self.imgError.image = UIImage(named: valid ? "icn_valid_username" : "icn_invalid_username")
                
            } catch let jsonerror {
                
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: "auth/username", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}

//MARK:-  Web Services
extension EditProfileVC {
    
    func performWebUpdateProfile() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        var dicSelectedImages = [String: UIImage]()
        
        if userProfileImage != nil {
            dicSelectedImages["profile_image"] = userProfileImage
        }
        
        if userCoverImage != nil {
            dicSelectedImages["cover_image"] = userCoverImage
        }
        
        let params = ["first_name": txtFirstName.text?.trim() ?? "",
                      "username": txtUsername.text?.trim() ?? "",
                      "mobile_number": ""] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: params, headers: token, ImageDic: dicSelectedImages) { (response) in
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
                        self.delegate?.setProfileData()
                    }
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Profile updated successfully", comment: ""))
                }
                
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
    
}
