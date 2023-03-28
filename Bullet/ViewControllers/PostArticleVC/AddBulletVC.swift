//
//  AddBulletVC.swift
//  Bullet
//
//  Created by Mahesh on 09/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation

protocol AddBulletVCDelegate: class {
    
    func setBulletOnDismissAction(_ bulletNo: Int, bullet: [String: AnyObject]?, isDeleted: Bool)
}

class AddBulletVC: UIViewController {

    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtHeadline: UITextView!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var imgPost: UIImageView!
    
    @IBOutlet weak var viewSave: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblBullet: UILabel!
    @IBOutlet weak var imgBullet: UIImageView!
    @IBOutlet weak var viewUploadBG: UIView!
    @IBOutlet weak var viewUploadImg: UIView!
    @IBOutlet weak var lblUploadImg: UILabel!
    
    @IBOutlet weak var viewDeleteBullet: UIView!
    @IBOutlet weak var lblDeleteBullet: UILabel!
    @IBOutlet weak var lblSave: UILabel!
    
    @IBOutlet weak var viewReplaceImgBG: UIView!
    @IBOutlet weak var viewDeleteImgBG: UIView!
    @IBOutlet weak var lblDelete: UILabel!
    @IBOutlet weak var lblReplace: UILabel!

    //    @IBOutlet weak var ctViewHeadlineTopToSuperView: NSLayoutConstraint!
//    @IBOutlet weak var ctViewHeadlineTopToViewUploadBottom: NSLayoutConstraint!
    
    var imageURL = ""
    var stBullet = ""
    var noOfBullet = 0
    var isEditable = false
    
    weak var delegate: AddBulletVCDelegate?
    var selectedItems = [YPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        imgBack.theme_image = GlobalPicker.imgBack

        self.viewUploadBG.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        self.imgPost.theme_image = GlobalPicker.imgAddBulletArrow
        self.viewDeleteBullet.theme_backgroundColor = GlobalPicker.listViewSelectedBG
        
//        if isEditable {
//
//            self.viewUploadBG.isHidden = true
//            self.ctViewHeadlineTopToSuperView.priority = .defaultHigh
//            self.ctViewHeadlineTopToViewUploadBottom.priority = .defaultLow
//        }
//        else {
//
//            self.viewUploadBG.isHidden = false
//            self.ctViewHeadlineTopToSuperView.priority = .defaultLow
//            self.ctViewHeadlineTopToViewUploadBottom.priority = .defaultHigh
//        }
//        self.view.layoutIfNeeded()
        if self.imageURL.isEmpty {
            viewReplaceImgBG.isHidden = true
            viewDeleteImgBG.isHidden = true
            self.imgBullet.image = nil
        }
        else {
            self.viewUploadImg.isHidden = true
            viewReplaceImgBG.isHidden = false
            viewDeleteImgBG.isHidden = false
            self.imgBullet.sd_setImage(with: URL(string: self.imageURL), placeholderImage: nil)
        }
        
        if noOfBullet == 0 || noOfBullet == 1 {
            self.viewDeleteBullet.isHidden = true
        }
        
        self.setupLocalization()
        self.setDisableSaveButtonState()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        viewUploadImg.addDashedBorder()
    }
    
    func setupLocalization() {
                
        if stBullet.isEmpty {
            txtHeadline.textColor = "#67676B".hexStringToUIColor()
            txtHeadline.tintColor = "#67676B".hexStringToUIColor()
            txtHeadline.text = NSLocalizedString("Add Bullet", comment: "")
            lblCount.text = "0/250"
        }
        else {
            txtHeadline.theme_textColor = GlobalPicker.textColor
            txtHeadline.theme_tintColor = GlobalPicker.textColor
            txtHeadline.text = stBullet
            lblCount.text = "\(stBullet.count)/250"
        }
        
        lblTitle.text = NSLocalizedString("Add Bullet", comment: "") + " \(noOfBullet + 1)"
        lblBullet.text = NSLocalizedString("Bullet", comment: "") + " \(noOfBullet + 1)"
        lblUploadImg.text = NSLocalizedString("Upload bullet image (optional)", comment: "")
        
        lblDelete.text = NSLocalizedString("Delete", comment: "")
        lblReplace.text = NSLocalizedString("Replace", comment: "")
        lblDeleteBullet.text = NSLocalizedString("Delete Bullet", comment: "")

        lblSave.text = NSLocalizedString("SAVE", comment: "")
        lblSave.addTextSpacing(spacing: 2.0)

        lblDelete.textDropShadow()
        lblReplace.textDropShadow()
        
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func didTapUploadImage(_ sender: Any) {
        
        self.openMediaPicker()
    }
    
    @IBAction func didTapImgDelete(_ sender: Any) {
        
        self.viewUploadImg.isHidden = false
        self.imgBullet.image = nil
        self.viewDeleteImgBG.isHidden = true
        self.viewReplaceImgBG.isHidden = true
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        
//        let bullet = (txtHeadline.text ?? "").trim()
//
//        if bullet == NSLocalizedString("Add Bullet", comment: "") || bullet.isEmpty {
//
//            //SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter Bullet", comment: ""))
//            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please add bullet", comment: ""), duration: 1.0, position: .bottom)
//            return
//        }
        
        self.performWSToUploadImage(self.imgBullet.image)
    }
    
    @IBAction func didTapDeleteBullet(_ sender: Any) {
        
        self.delegate?.setBulletOnDismissAction(self.noOfBullet, bullet: nil, isDeleted: true)
        self.navigationController?.popViewController(animated: true)
    }

}

//====================================================================================================
// MARK:- Web Services
//====================================================================================================
extension AddBulletVC {
    
    func performWSToUploadImage(_ image: UIImage?) {
        
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
                    
                    self.imageURL = FULLResponse.results ?? ""
                }
                else {
                    self.imageURL = ""
                }
                
                let bullText = self.txtHeadline.text.trim()
                if bullText != NSLocalizedString("Add Bullet", comment: "") && !(bullText.isEmpty) {
                    self.delegate?.setBulletOnDismissAction(self.noOfBullet, bullet: ["data" : bullText as AnyObject, "image": self.imageURL as AnyObject], isDeleted: false)
                }
                
                self.navigationController?.popViewController(animated: true)
                
                ANLoader.hide()
            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "media/images", error: jsonerror.localizedDescription, code: "")
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//MARK:- UITextView Delegate
extension AddBulletVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == txtHeadline {
            
            textView.text = textView.text == NSLocalizedString("Add Bullet", comment: "") ? nil : textView.text
            textView.theme_textColor = GlobalPicker.textColor
            textView.theme_tintColor = GlobalPicker.textColor

        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            if textView == self.txtHeadline {
                
                lblCount.text = "0/250"
                textView.text = NSLocalizedString("Add Bullet", comment: "")
                textView.textColor = "#67676B".hexStringToUIColor()
                textView.tintColor = "#67676B".hexStringToUIColor()
            }
        }

    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == self.txtHeadline {
            
            //lblCount.text = "0/250"
            self.updateCharacterCount()
            self.setDisableSaveButtonState()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView == self.txtHeadline {
            
            //self.setDisableSaveButtonState()
            return textView.text.count +  (text.count - range.length) <= 250
        }
        return false
    }
    
    private func updateCharacterCount() {
        
        let descriptionCount = self.txtHeadline.text.count
        if txtHeadline.text == NSLocalizedString("Add Bullet", comment: "") {
            self.lblCount.text = "0/250"
        }
        else {
            self.lblCount.text = "\((0) + descriptionCount)/250"
        }
    }
    
    func setDisableSaveButtonState() {
        
        let bullet = (txtHeadline.text ?? "").trim()
        
        if bullet == NSLocalizedString("Add Bullet", comment: "") || bullet.isEmpty {
            
            self.btnSave.isUserInteractionEnabled = false
            viewSave.theme_backgroundColor = GlobalPicker.newsHeaderBGColor

            if MyThemes.current == .dark {
                lblSave.textColor = "#393737".hexStringToUIColor()
            }
            else {
                lblSave.textColor = "#84838B".hexStringToUIColor()
            }
        }
        else {
            
            self.btnSave.isUserInteractionEnabled = true
            viewSave.theme_backgroundColor = GlobalPicker.themeCommonColor
            lblSave.textColor = .white
        }
    }
}

// MARK : - Media Picker
extension AddBulletVC: YPImagePickerDelegate {
    
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
        
    func openMediaPicker() {
        
        var config = YPImagePickerConfiguration()

        /* Uncomment and play around with the configuration 👨‍🔬 🚀 */

        /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
         config.library.onlySquare = true

        /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
        // config.onlySquareImagesFromCamera = false

        /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
           resized to fit in a 1024x1024 box. Defaults to original image size. */
        // config.targetImageSize = .cappedTo(size: 1024)

        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        
        config.libraryPhotoOnly.mediaType = .photo
        config.libraryPhotoOnly.itemOverlayType = .grid
        
        config.libraryVideoOnly.mediaType = .video
        config.libraryVideoOnly.itemOverlayType = .grid
        
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        // config.usesFrontCamera = true

        /* Adds a Filter step in the photo taking process. Defaults to true */
         config.showsPhotoFilters = false

        /* Manage filters by yourself */
        // config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        //                   YPFilter(name: "Normal", coreImageFilterName: "")]
        // config.filters.remove(at: 1)
        // config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)

        /* Enables you to opt out from saving new (or old but filtered) images to the
           user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false

        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough

        /* Choose the recordingSizeLimit. If not setted, then limit is by time. */
        // config.video.recordingSizeLimit = 10000000

        /* Defines the name of the album when saving pictures in the user's photo library.
           In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
         config.albumName = ApplicationAlertMessages.kAppName

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
           Default value is `.photo` */
        config.startOnScreen = .library

        /* Defines which screens are shown at launch, and their order.
           Default value is `[.library, .photo]` */
        config.screens = [.libraryPhotoOnly]

        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Defines the time limit for recording videos.
           Default is 30 seconds. */
        // config.video.recordingTimeLimit = 5.0

        /* Defines the time limit for videos from the library.
           Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 14400

        config.video.minimumTimeLimit = 1

        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none//.rectangle(ratio: (16/9))

        /* Defines the overlay view for the camera. Defaults to UIView(). */
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView

        /* Customize wordings */
//        config.wordings.libraryTitle = "Gallery"
//        config.wordings.libraryPhotoTitle = "Photos"
//        config.wordings.libraryVideoTitle = "Videos"
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 1
        config.libraryPhotoOnly.maxNumberOfItems = 1
        config.libraryVideoOnly.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false

        /* Disable scroll to change between mode */
        // config.isScrollToChangeModesEnabled = false
        // config.library.minNumberOfItems = 2

        /* Skip selection gallery after multiple selections */
        // config.library.skipSelectionsGallery = true

        /* Here we use a per picker configuration. Configuration is always shared.
           That means than when you create one picker with configuration, than you can create other picker with just
           let picker = YPImagePicker() and the configuration will be the same as the first picker. */

        /* Only show library pictures from the last 3 days */
        //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        //let toDate = Date()
        //let options = PHFetchOptions()
        // options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //options.sortDescriptors = [sortDescriptor]
        //
        //config.library.options = options

//        config.library.preselectedItems = selectedItems
//        config.libraryPhotoOnly.preselectedItems = selectedItems
//        config.libraryVideoOnly.preselectedItems = selectedItems

        // Customise fonts
        //config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        //config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        //config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        //config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        //config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)

        
        let picker = YPImagePicker(configuration: config)

        picker.imagePickerDelegate = self

        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"

        /* Multiple media implementation */
        picker.didFinishPicking { [unowned picker] items, cancelled in

            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }

            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    
//                    self.performWSToUploadImage(photo.image)
                    
                    if self.imgBullet.image == nil {
                        self.viewUploadImg.isHidden = true
                        self.viewDeleteImgBG.isHidden = false
                        self.viewReplaceImgBG.isHidden = false
                    }
                    self.imgBullet.image = photo.originalImage
                    picker.dismiss(animated: true, completion: nil)
                    
                case .video(let video):

//                    self.performWSToUploadImage(video.thumbnail)

                    if self.imgBullet.image == nil {
                        self.viewUploadImg.isHidden = true
                        self.viewDeleteImgBG.isHidden = false
                        self.viewReplaceImgBG.isHidden = false
                    }
                    self.imgBullet.image = video.thumbnail
                    picker.dismiss(animated: true, completion: nil)
                }
            }
        }

        present(picker, animated: true, completion: nil)
    }
}
