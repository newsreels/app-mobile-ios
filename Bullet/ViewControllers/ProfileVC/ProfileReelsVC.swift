//
//  ProfileReelsVC.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ProfileReelsVC: UIViewController, ReelsVCDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgNoPost: UIImageView!
    @IBOutlet weak var lblNoPost: UILabel!
    @IBOutlet weak var viewNoPost: UIView!
    @IBOutlet weak var imgUploadBorder: UIImageView!
    @IBOutlet weak var btnUpload: UIButton!
    
    @IBOutlet weak var appLoaderView: UIView!
    @IBOutlet weak var loaderView: GMView!
    @IBOutlet weak var loaderViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var seachNoDataView: UIView!
    
    
    var dismissKeyboard : (()-> Void)?
    var authorID = ""
    var channelInfo: ChannelInfo?
    var isOwnChannel = false
    var isFromChannelView = false

    var reelsArray = [Reel]()
    var isApiCallAlreadyRunning = false
    var nextPageData = ""
    var isFirstTimeCalled = false

    var isFromDrafts = false
    var isFromSaveArticles = false
    var isOpenForTopics = false
    var context = ""
    var searchText = ""
    var isOnSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .clear
        
        registerCells()
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        performWSToGetMyOwnReelsData(page: "")
        setupNoPostView()
        
        seachNoDataView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isFirstTimeCalled {
            reelsArray.removeAll()
            nextPageData = ""
            collectionView.reloadData()
            performWSToGetMyOwnReelsData(page: "")
        }
        
    }

    func registerCells() {
        collectionView.register(UINib(nibName: "ReelsPreviewCC", bundle: nil), forCellWithReuseIdentifier: "ReelsPreviewCC")
    }

    
    func setupNoPostView() {
        //#212123
        viewNoPost.isHidden = true
        
        if isFromChannelView {
            
            //For Channels view
            if isOwnChannel == false {
                
                imgUploadBorder.isHidden = true
                btnUpload.isHidden = true
                lblNoPost.text = NSLocalizedString("No Posts Yet", comment: "")
                
                imgNoPost.image = UIImage(named: "NoPost")
                imgNoPost.theme_tintColor = GlobalPicker.noPostColor
                lblNoPost.theme_textColor = GlobalPicker.noPostColor
                
            } else {
                
                imgUploadBorder.isHidden = false
                btnUpload.isHidden = false
                lblNoPost.text = NSLocalizedString("Upload", comment: "")
                
                imgUploadBorder.theme_tintColor = GlobalPicker.backgroundColorBlackWhite
                imgNoPost.image = UIImage(named: "UploadPost")
                imgNoPost.theme_tintColor = GlobalPicker.uploadPostColor
                lblNoPost.theme_textColor = GlobalPicker.uploadPostColor
            }
        }
        else {
            
            if authorID != SharedManager.shared.userId {
                
                imgUploadBorder.isHidden = true
                btnUpload.isHidden = true
                lblNoPost.text = NSLocalizedString("No Posts Yet", comment: "")
                
                imgNoPost.image = UIImage(named: "NoPost")
                imgNoPost.theme_tintColor = GlobalPicker.noPostColor
                lblNoPost.theme_textColor = GlobalPicker.noPostColor
                
            } else {
                
                imgUploadBorder.isHidden = false
                btnUpload.isHidden = false
                lblNoPost.text = NSLocalizedString("Upload", comment: "")
                
                imgUploadBorder.theme_tintColor = GlobalPicker.backgroundColorBlackWhite
                imgNoPost.image = UIImage(named: "UploadPost")
                imgNoPost.theme_tintColor = GlobalPicker.uploadPostColor
                lblNoPost.theme_textColor = GlobalPicker.uploadPostColor
            }
        }
    }
    
    @IBAction func didTapUpload(_ sender: Any) {
        
        if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                        
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        else {
            
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
                
                if SharedManager.shared.community == false {

                    let vc = CommunityGuideVC.instantiate(fromAppStoryboard: .Schedule)
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    
                    let vc = UploadArticleBottomSheetVC.instantiate(fromAppStoryboard: .Schedule)
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true)
                }
            }
            else {
                
                let vc = PopupVC.instantiate(fromAppStoryboard: .Home)
                vc.isFromProfileView = true
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}


extension ProfileReelsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reelsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsPreviewCC", for: indexPath) as! ReelsPreviewCC
        
        //Check Upload Processing/scheduled on Article by User
        let reel = reelsArray[indexPath.row]
        
        let status = reel.status ?? ""
        if status == Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
            
            cell.isUserInteractionEnabled = false
            cell.viewProcessingBG.isHidden = false
            cell.viewScheduleBG.isHidden = true
        }
        else if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
            
            cell.isUserInteractionEnabled = false
            cell.viewProcessingBG.isHidden = true
            cell.viewScheduleBG.isHidden = false
            cell.lblScheduleTime.text = SharedManager.shared.utcToLocal(dateStr: reel.publishTime ?? "")
        }
        else {
         
            cell.isUserInteractionEnabled = true
            cell.viewProcessingBG.isHidden = true
            cell.viewScheduleBG.isHidden = true
        }

        cell.setupCell(model: reel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let lineSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        let width = ((collectionView.frame.size.width - (lineSpacing * 2))/3)
        let height: CGFloat = width * 1.48//160 //(width * 2) - lineSpacing
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 40, right: 0)
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == reelsArray.count - 1 && isApiCallAlreadyRunning == false && nextPageData.isEmpty == false {
            performWSToGetMyOwnReelsData(page: nextPageData)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
        vc.isBackButtonNeeded = true
        vc.modalPresentationStyle = .overFullScreen
        vc.reelsArray = self.reelsArray
        print("REELS ARRAY COUNT = \(reelsArray.count)")
        if isFromChannelView {
            vc.isFromChannelView = true
            vc.channelInfo = channelInfo
        } else {
            vc.isShowingProfileReels = true
        }
        vc.delegate = self
        vc.userSelectedIndexPath = indexPath
        vc.nextPageData = nextPageData
        vc.authorID = reelsArray[indexPath.row].authors?.first?.id ?? ""
        vc.scrollToItemFirstTime = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ReelsVC Delagates
    func loaderShowing(status: Bool) {
    }
    
    //Back button from reelVC
    func backButtonPressed(_ isUpdateSavedArticle: Bool) {
        
        if isUpdateSavedArticle {
            
            reelsArray.removeAll()
            nextPageData = ""
            collectionView.reloadData()
            performWSToGetMyOwnReelsData(page: "")
        }
    }
    func switchBackToForYou() {
        
    }
    
    func changeScreen(pageIndex: Int) {
    }
    
    func currentPlayingVideoChanged(newIndex: IndexPath) {
    }
}


// MARK: - Webservices
extension ProfileReelsVC {
    
    
    func performWSToGetMyOwnReelsData(page: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        var url = ""
        
        if isOnSearch {
            url = "news/reels?query=\(searchText)"
        }
        else if isOpenForTopics {
            url = "news/reels?context=\(context)"
        }
        else if isFromDrafts {
            
            url = ""
        }
        else if isFromSaveArticles {
            url = "news/reels/archive"
        }
        else if isFromChannelView {
            
            //For Channels view
            if isOwnChannel {
                url = "studio/reels?source=\(self.channelInfo?.id ?? "")"
            }
            else {
                url = "news/reels?context=\(self.channelInfo?.context ?? "")"
            }
        }
        else {
            
            url = "studio/reels?source"
            if authorID != SharedManager.shared.userId {
                url = "news/authors/\(authorID)/reels"
            }
        }
        
        
        if page == "" {
            if isOnSearch {
                self.showCustomLoader()
            }
            else {
                self.showLoaderInVC()
            }
        }
        
        let param = ["page": page]
        
        WebService.URLResponse(url, method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            
            self?.hideCustomLoader()
            self?.hideLoaderVC()
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ReelsModel.self, from: response)
                if let reelsData = FULLResponse.reels, reelsData.count > 0 {
                    self.viewNoPost.isHidden = true
                    
                    if self.reelsArray.count == 0 {
                        self.reelsArray = reelsData
                        self.collectionView.reloadData()
                    } else {
//                        let newIndex = self.reelsArray.count
                        self.reelsArray = self.reelsArray + reelsData
                        self.collectionView.reloadData()
                    }
                
                    
                } else {
                    
                    if self.isOnSearch {
                        self.reelsArray.removeAll()
                        if self.searchText != "" {
                            self.seachNoDataView.isHidden = false
                        }
                    }
                    else {
                        if page == "" {
                            self.reelsArray.removeAll()
                            self.viewNoPost.isHidden = false
                        }
                    }
                    
                   
                    
                    print("Empty Result")
                    self.collectionView.reloadData()
                }
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                self.hideCustomLoader()
                self.hideLoaderVC()
                self.isApiCallAlreadyRunning = false
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            self.hideCustomLoader()
            self.hideLoaderVC()
            self.isApiCallAlreadyRunning = false
            print("error parsing json objects",error)
        }
    }
    
}


//MARK:- CommunityGuideVC Delegate
extension ProfileReelsVC: CommunityGuideVCDelegate {
    
    func dimissCommunityGuideApprovedDelegate() {
        
        SharedManager.shared.performWSToCommunityGuide()

        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
            
            let vc = UploadArticleBottomSheetVC.instantiate(fromAppStoryboard: .Schedule)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
        else {
            
            let vc = PopupVC.instantiate(fromAppStoryboard: .Home)
            vc.isFromProfileView = true
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }

    }
}


//MARK:- UploadArticleBottomSheetVC Delegate
extension ProfileReelsVC: UploadArticleBottomSheetVCDelegate {
    
    func UploadArticleSelectedTypeDelegate(type: Int) {
        
        if type == 0 {
            //Media
            print("Media")
            openMediaPicker(isForReels: false)
            
        }
        else if type == 1 {
            
            //Newsreels
            print("Newsreels")
            openMediaPicker(isForReels: true)
        }
        else {
            
            //Youtube
            print("Youtube")
            let vc = YoutubeArticleVC.instantiate(fromAppStoryboard: .Schedule)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }

    }
}


extension ProfileReelsVC: PopupVCDelegate {
    
    func popupVCDismissed() {

        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


// MARK : - Media Picker
extension ProfileReelsVC: YPImagePickerDelegate {
    
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
        
    func openMediaPicker(isForReels: Bool) {
        
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
        if isForReels {
            config.screens = [.libraryVideoOnly]
        } else {
            config.screens = [.library, .libraryPhotoOnly, .libraryVideoOnly]
        }
        

        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Defines the time limit for recording videos.
           Default is 30 seconds. */
        // config.video.recordingTimeLimit = 5.0

        /* Defines the time limit for videos from the library.
           Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 14400

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

        
        config.isForReels = isForReels
        
        
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

//            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
//                    self.selectedImageV.image = photo.image
                    picker.dismiss(animated: true, completion: { [weak self] in
                        //                        self?.present(playerVC, animated: true, completion: nil)
                        //                        print("resolutionForLocalVideo 😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                        
                        if let ptcTBC = self?.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.imgPhoto = photo.originalImage
                        vc.postArticleType = .media
                        vc.selectedMediaType = .photo
                        vc.selectedChannel = self!.channelInfo
                        vc.modalPresentationStyle = .fullScreen
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    })
                case .video(let video):
//                    self.selectedImageV.image = video.thumbnail

                    let assetURL = video.url
//                    let playerVC = AVPlayerViewController()
//                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
//                    playerVC.player = player

                    picker.dismiss(animated: true, completion: { [weak self] in
//                        self?.present(playerVC, animated: true, completion: nil)
//                        print("resolutionForLocalVideo 😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                        
                        if let ptcTBC = self?.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.videoURL = assetURL
                        vc.selectedChannel = self!.channelInfo
                        vc.imgPhoto = video.thumbnail
                        vc.uploadingFileTaskID = video.taskID ?? ""
                        
                        
                        if isForReels {
                            vc.postArticleType = .reel
                        }
                        else {
                            vc.postArticleType = .media
                            vc.selectedMediaType = .video
                        }
                        vc.modalPresentationStyle = .fullScreen
                        self?.navigationController?.pushViewController(vc, animated: true)

                    })
                }
            }
        }

        /* Single Photo implementation. */
        // picker.didFinishPicking { [unowned picker] items, _ in
        //     self.selectedItems = items
        //     self.selectedImageV.image = items.singlePhoto?.image
        //     picker.dismiss(animated: true, completion: nil)
        // }

        /* Single Video implementation. */
        //picker.didFinishPicking { [unowned picker] items, cancelled in
        //    if cancelled { picker.dismiss(animated: true, completion: nil); return }
        //
        //    self.selectedItems = items
        //    self.selectedImageV.image = items.singleVideo?.thumbnail
        //
        //    let assetURL = items.singleVideo!.url
        //    let playerVC = AVPlayerViewController()
        //    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
        //    playerVC.player = player
        //
        //    picker.dismiss(animated: true, completion: { [weak self] in
        //        self?.present(playerVC, animated: true, completion: nil)
        //        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
        //    })
        //}

        present(picker, animated: true, completion: nil)
    }
}

extension ProfileReelsVC: YoutubeArticleVCDelegate {
    
    func submitYoutubeArticlePost(_ article: articlesData) {
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(false, animated: true)
        }
        
        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
        vc.yArticle = article
        vc.postArticleType = .youtube
        vc.selectedChannel = self.channelInfo
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- ScrollView Delegate
extension ProfileReelsVC: AquamanChildViewController {

    func aquamanChildScrollView() -> UIScrollView {
        return collectionView
    }

}

extension ProfileReelsVC {
    
    
    // MARK : - Search Methods
    func refreshVC() {
        
        seachNoDataView.isHidden = true
        searchText = ""
        hideCustomLoader(isAnimated: false)
        hideLoaderVC()
        nextPageData = ""
        reelsArray.removeAll()
        self.collectionView.reloadData()

    }
    
    func getSearchContent(search: String) {
        
        refreshVC()
        searchText = search
        self.performWSToGetMyOwnReelsData(page: "")

    }
    
    
    func appEnteredBackground() {
    }
    
    
    func appLoadedToForeground() {
    }
    
    func stopAll() {
    }
    
    func showCustomLoader() {
        
        self.appLoaderView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.loaderViewHeightConstraint.constant = 100
            self.view.layoutIfNeeded()
        } completion: { status in
        }
    }
    
    func hideCustomLoader(isAnimated: Bool = true) {
        
        if isAnimated {
            UIView.animate(withDuration: 0.25) {
//                self.loaderViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { status in
                self.appLoaderView.isHidden = true
            }
        }
        else {
//            self.loaderViewHeightConstraint.constant = 0
            self.appLoaderView.isHidden = true
        }
        
    }
    
}
