//
//  ProfilePageViewController.swift
//  Bullet
//
//  Created by Mahesh on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import ActiveLabel

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

protocol ProfilePageViewControllerDelegate: AnyObject {
    func shouldShowTitle(_ condition: Bool)
}

class ProfilePageViewController: AquamanPageViewController {

    weak var delegate: ProfilePageViewControllerDelegate?

    var isMenuOnTop = false
    var titles = [String]()
    var authorID = ""
    var author: Author?
    var selectedChannel: ChannelInfo?
    var isOwnChannel = false
    var isFromChannelView = false
    var isOpenForTopics = false
    var extraHeight: CGFloat = 10.0
    var context = ""
    
    var followCount = 0
    var isFav = false
    var channelDescription = ""
    var isFullText = false
    let seemoreType = ActiveType.custom(pattern: "\(NSLocalizedString("See more", comment: ""))$")
    let lessType = ActiveType.custom(pattern: "\(NSLocalizedString("Less", comment: ""))$")

    //VARIABLES
    var picker = UIImagePickerController()
    var alert = UIAlertController(title: NSLocalizedString("Choose Image", comment: ""), message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    let imagePicker = ImagePicker()
        
    lazy var menuView: TridentMenuView = {
        let view = TridentMenuView(parts:
            .normalTextColor("#23204A".hexStringToUIColor()),
            .selectedTextColor("#23204A".hexStringToUIColor()),
            .normalTextFont(UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 14)!),
            .selectedTextFont(UIFont(name: Constant.FONT_ROBOTO_BOLD, size: 14)!),
            .itemSpace(15),
            .sliderStyle(
                SliderViewStyle(parts:
                                        .backgroundColor(Constant.appColor.lightRed),
                    .height(4),
                    .cornerRadius(0),
                    .position(.bottom),
                    .extraWidth( -0.0 ),
                    .shape( .line )
                )
            ),
            .bottomLineStyle(
                BottomLineViewStyle(parts:
                    .backgroundColor(UIColor.init(hexString: "E6E6E6")),
                                    .height(isMenuOnTop ? 0 : 1)
                )
            )
        )
        
        view.delegate = self
        
        if isOpenForTopics == false {
            
//            view.normalImage1 = UIImage(named: "ChannelDetailsReels")!.imageWithColor(color: UIColor(hexString: "BECAD8"))
            view.normalImage1 = UIImage(named: "ChannelDetailsReels")!
            view.normalImage2 = UIImage(named: "ChannelDetailsArticles")!
            view.normalImage3 = UIImage(named: "ChannelDetailsLikes")!

            //        view.normalImage3 = UIImage(named: "")
            if isMenuOnTop {
                view.selectedImage1 = UIImage(named: "ChannelDetailsReelsSelected")!
                view.selectedImage2 = UIImage(named: "ChannelDetailsArticlesSelected")!
                view.selectedImage3 = UIImage(named: "ChannelDetailsLikesSelected")!
            } else {
                view.selectedImage1 = UIImage(named: "ChannelDetailsReelsSelected")!
                view.selectedImage2 = UIImage(named: "ChannelDetailsArticlesSelected")!
//                view.selectedImage3 = UIImage(named: "ChannelDetailsLikesSelected")!.imageWithColor(color: UIColor(hexString: "23204A"))
                view.selectedImage3 = UIImage(named: "ChannelDetailsLikesSelected")!
            }
        }
//        view.selectedImage3 = UIImage(named: "")
        
        view.titles = titles
        view.itemSpace = 0
        return view
    }()

    private let headerView: ChannelDetailsHeaderView = UIView.fromNib()
    private let headerViewProfile: ViewProfileHeaderView = UIView.fromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromChannelView  {
            self.initWithChannelData(info: selectedChannel)
            performGetChannelDetails(id: selectedChannel?.id ?? "")
        }
        else {
            self.setupViewProfileData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        if SharedManager.shared.isSelectedLanguageRTL() {
//            DispatchQueue.main.async {
//
//                self.headerView.lblDescription.semanticContentAttribute = .forceRightToLeft
//                self.headerView.lblDescription.textAlignment = .right
//            }
//
//        } else {
//            DispatchQueue.main.async {
//
//                self.headerView.lblDescription.semanticContentAttribute = .forceLeftToRight
//                self.headerView.lblDescription.textAlignment = .left
//            }
//        }
    }

    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        
        if isOpenForTopics {
            return UIView.init(frame: .zero)
        }
        return isFromChannelView ? headerView : headerViewProfile
    }

    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        
//        return isFromChannelView ? headerView.viewBG.frame.height + extraHeight : headerViewProfile.frame.height + (extraHeight * 2)
        if isOpenForTopics {
            return 0
        }
        return isFromChannelView ? headerView.viewBG.frame.height : headerViewProfile.frame.height + (extraHeight * 2)
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        
        if isOpenForTopics {
            titles = ["Reels", "Articles", "Channels"]
        }
        else if isFromChannelView {
            
            let hasReel = self.selectedChannel?.hasReel ?? false
            if hasReel ||  isOwnChannel {
//                titles = [NSLocalizedString("Newsreels", comment: ""), NSLocalizedString("Articles", comment: "")]
//                titles = ["", "", ""]
                titles = [""]
            }
            else {
//                titles = [NSLocalizedString("Articles", comment: "")]
                titles = [""]
            }
        }
        else {
            
//            titles = [NSLocalizedString("Newsreels", comment: ""), NSLocalizedString("Articles", comment: "")]
//            titles = ["", ""]
            titles = [""]
           // titles = [NSLocalizedString("Newsreels", comment: ""), NSLocalizedString("Articles", comment: ""), NSLocalizedString("Following", comment: "")]
        }
        return titles.count
    }

    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {

        //first view controller
        if isFromChannelView {
            
            let hasReel = self.selectedChannel?.hasReel ?? false
            
            if hasReel || isOwnChannel {
                
                if index == 0 {

                    let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
                    vc.authorID = authorID
                    vc.channelInfo = selectedChannel
                    vc.isOwnChannel = isOwnChannel
                    vc.isFromChannelView = isFromChannelView
                    return vc
                } else if index == 1{

                    let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
                    vc.authorID = authorID
                    vc.channelInfo = selectedChannel
                    vc.isOwnChannel = isOwnChannel
                    vc.isFromChannelView = isFromChannelView
                    return vc
                    
                } else {
                    
                    // This is for the likes - need to create new viewcontroller for this
                    let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
                    vc.authorID = authorID
                    vc.channelInfo = selectedChannel
                    vc.isOwnChannel = isOwnChannel
                    vc.isFromChannelView = isFromChannelView
                    return vc
                    
                }
            }
            else {
//
//                let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
//                vc.authorID = authorID
//                vc.channelInfo = selectedChannel
//                vc.isOwnChannel = isOwnChannel
//                vc.isFromChannelView = isFromChannelView
                
                let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
                vc.authorID = authorID
                vc.channelInfo = selectedChannel
                vc.isOwnChannel = isOwnChannel
                vc.isFromChannelView = isFromChannelView
                return vc
                
                return vc
            }
        }
        
        else {
            
            if index == 0 {

                let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
                vc.authorID = authorID
                vc.channelInfo = selectedChannel
                vc.isOwnChannel = isOwnChannel
                vc.isFromChannelView = isFromChannelView
                vc.context = context
                vc.isOpenForTopics = isOpenForTopics
                return vc
            }

            //second view controller
            else if index == 1 {

                let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
                vc.authorID = authorID
                vc.channelInfo = selectedChannel
                vc.isOwnChannel = isOwnChannel
                vc.isFromChannelView = isFromChannelView
                vc.context = context
                vc.isOpenForTopics = isOpenForTopics
                return vc
            }

            //third view controller
            else {
//                UserFollowingVC
//                let vc = ProfileFollowingVC.instantiate(fromAppStoryboard: .Main)
                let vc = UserFollowingVC.instantiate(fromAppStoryboard: .Reels) 
                return vc
            }

        }
    }

    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return menuView
    }

    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        
        if isFromChannelView {
            
            let hasReel = self.selectedChannel?.hasReel ?? false
//
//            if !hasReel && !isOwnChannel {
//                return 0
//            }
            
            return 67
        }
        return 67
    }

    override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }

    override func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool) {
//        menuView.theme_backgroundColor = isAdsorption ? GlobalPicker.backgroundColor : GlobalPicker.backgroundColor
        menuView.backgroundColor = .white
    }

    override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        menuView.checkState(animation: true)
    }

}


extension ProfilePageViewController: TridentMenuViewDelegate {

    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < titles.count else {
            return
        }
        setSelect(index: index, animation: true)
    }

}

extension ProfilePageViewController {

    func initWithChannelData(info: ChannelInfo?) {
                
        self.setDesignView()
        self.setupLocalization()
        self.setChannelDetailsData()
        
        SharedManager.shared.bulletPlayer = nil
        
        //headerView.layoutIfNeeded()
    }
    
    func setDesignView() {

        headerView.backgroundColor = .clear
//        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
        //view.theme_backgroundColor = GlobalPicker.backgroundColor

        //headerView.btnBack.addTarget(self, action: #selector(didTapBackAction(_:)), for: .touchUpInside)
//        headerView.btnProfile.addTarget(self, action: #selector(didTapUploadProfile(_:)), for: .touchUpInside)
//        headerView.btnCover.addTarget(self, action: #selector(didTapUploadCover(_:)), for: .touchUpInside)
        headerView.btnFollow.addTarget(self, action: #selector(didTapFollowChannel(_:)), for: .touchUpInside)
        headerView.btnModTools.addTarget(self, action: #selector(didTapModeTools(_:)), for: .touchUpInside)

//        headerView.btnFollowers.addTarget(self, action: #selector(didTapFollowersAction(_:)), for: .touchUpInside)
//        headerView.btnPosts.addTarget(self, action: #selector(didTapPostsAction(_:)), for: .touchUpInside)

        headerView.imgProfile.cornerRadius = headerView.imgProfile.frame.height / 2
        headerView.imgProfile.contentMode = .scaleAspectFill

        //headerView.imgBack.theme_image = GlobalPicker.imgBack
        
//        headerView.btnProfile.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)
//        headerView.btnCover.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)
//        headerView.lblDescription.theme_textColor = GlobalPicker.textColor
        
//        headerView.viewModeTools.theme_backgroundColor = GlobalPicker.bgLoginColor
//        headerView.viewFollow.theme_backgroundColor = GlobalPicker.themeCommonColor

//        headerView.imgTools.image = UIImage(named: "icn_mode_tools")?.withRenderingMode(.alwaysTemplate)
//        headerView.imgTools.theme_tintColor = GlobalPicker.textColor
                
        //headerView.lblNavTitle.theme_textColor = GlobalPicker.textColor
//        headerView.lblModeTools.theme_textColor = GlobalPicker.textColor
        //.theme_textColor = GlobalPicker.textColor
//        headerView.lblFollowers.theme_textColor = GlobalPicker.textColor
//        headerView.lblPost.theme_textColor = GlobalPicker.textColor
    }
    
    func setupLocalization() {
        
//        headerView.lblModeTools.text = NSLocalizedString("Mod Tools", comment: "")
    }
    
    func followChannel(isFollow: Bool) {
        
        if isFollow {
            headerView.btnFollow.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
            headerView.btnFollow.backgroundColor = Constant.appColor.lightRed
        }
        else {
            headerView.btnFollow.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
            headerView.btnFollow.backgroundColor = Constant.appColor.buttonUnselected
        }
        
    }
    
    func setChannelDetailsData() {
        
        isFav = self.selectedChannel?.favorite ?? false
        if isFav {
//            headerView.lblFollow.text = NSLocalizedString("Unfollow Channel", comment: "")
            followChannel(isFollow: false)
        }
        else {
//            headerView.lblFollow.text = NSLocalizedString("Follow Channel", comment: "")
            followChannel(isFollow: true)
            
        }
        

        let own = self.selectedChannel?.own ?? false
        /*
        if own {
            headerView.viewFollow.isHidden = true
            headerView.viewModeTools.isHidden = false
            
            headerView.viewPhotoBG.isHidden = false
            headerView.viewCoverPhotoBG.isHidden = false
        }
        else {
            headerView.viewFollow.isHidden = false
            headerView.viewModeTools.isHidden = true
            
            headerView.viewPhotoBG.isHidden = true
            headerView.viewCoverPhotoBG.isHidden = true
        }*/
              
        //headerView.lblNavTitle.text = self.selectedChannel?.name ?? ""
        headerView.lblChannelName.text = self.selectedChannel?.name ?? ""
        headerView.lblusername.text = "@\(self.selectedChannel?.name ?? "")"
        followCount = self.selectedChannel?.follower_count ?? 0
        headerView.lblFollowers.text = "\(followCount.formatUsingAbbrevation())"
        headerView.lblPost.text = "\((self.selectedChannel?.post_count ?? 0).formatUsingAbbrevation())"

        
        channelDescription = self.selectedChannel?.channelDescription ?? ""
        isFullText = false
        setSeeMoreLabel()

        let photo = self.selectedChannel?.icon ?? ""
//        let cover = self.selectedChannel?.image ?? ""
        
        if photo.isEmpty {
            headerView.imgProfile.image = UIImage(named: "icn_profile_placeholder_light")
        }
        else {
            headerView.imgProfile.sd_setImage(with: URL(string: photo), placeholderImage: nil)
        }
                
        headerView.imgVerified.isHidden = !(selectedChannel?.verified ?? false)
        
//        if cover.isEmpty {
//            headerView.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
//        }
//        else {
//            headerView.imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
//        }
        
    }
    
    func setSeeMoreLabel() {
               
        var shortString = channelDescription
        if channelDescription.length > 150 {
            let trimToCharacter = 50
            if isFullText == false {
                //self.viewTransparentBG.isHidden = true
                shortString = String(channelDescription.prefix(trimToCharacter)) + "... " + NSLocalizedString("See more", comment: "")
            } else {
                //self.viewTransparentBG.isHidden = false
                shortString = channelDescription + " " + NSLocalizedString("Less", comment: "")
            }
        }
                
        headerView.lblDescription.customize { (label) in

            label.text = shortString
            label.numberOfLines = 0
            label.enabledTypes = [seemoreType,lessType]
            label.customColor = [seemoreType : "#E01335".hexStringToUIColor(), lessType : "#E01335".hexStringToUIColor()]
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                atts[NSAttributedString.Key.font] = UIFont(name: Constant.FONT_Mulli_Semibold, size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
                return atts
            }
            
            label.handleCustomTap(for: seemoreType, handler: { [weak self] (string) in
                // action
                self?.isFullText = true
                UIView.animate(withDuration: 0.5) {
//                    self?.viewTransparentBG.isHidden = false
                    self?.setSeeMoreLabel()
//                    self?.setupGradient()
//                    self?.headerView.layoutIfNeeded()
                }
                
            })
            
            label.handleCustomTap(for: lessType, handler: { [weak self] (string) in
                // action
                self?.isFullText = false
                UIView.animate(withDuration: 0.5) {
//                    self?.viewTransparentBG.isHidden = true
                    self?.setSeeMoreLabel()
//                    self?.setupGradient()
//                    self?.headerView.layoutIfNeeded()
                }
            })
        }
        
        headerView.layoutIfNeeded()
        self.headerViewHeight = headerView.viewBG.frame.height + extraHeight
        self.updateHeaderViewHeight(animated: true,
                                    duration: 0.25) { (finish) in
            //do something here
        }
    }
    
    //set image
    func setImage(_ isTapOnProfile: Bool) {
        
        imagePicker.viewController = self
        imagePicker.onPick = { [weak self] image in
            self?.uploadImage(image, isTapOnProfile: isTapOnProfile)
        }
        //imagePicker.viewController?.modalPresentationStyle = .overFullScreen
        imagePicker.show()

    }

    func uploadImage(_ chosenImage: UIImage, isTapOnProfile: Bool) {
                
        if isFromChannelView {
            
            if isTapOnProfile {
                
                headerView.imgProfile.cornerRadius = headerView.imgProfile.frame.height / 2
                headerView.imgProfile.contentMode = .scaleAspectFill
                headerView.imgProfile.image = chosenImage
            }
            else {
                
//                headerView.imgCover.contentMode = .scaleAspectFill //3
//                headerView.imgCover.image = chosenImage //4
            }

            performWSToUploadImage(chosenImage) { [weak self] url  in
                if url != nil, let url = url {
                    
                    let params = isTapOnProfile ? ["icon": url] : ["cover": url]
                    self?.performWebUpdateChannelImage(params)
                } else {
                    
                }
            }
        }
        else {
            
            var dicSelectedImg = [String: UIImage]()
            
            if isTapOnProfile {
                
                headerViewProfile.imgProfile.cornerRadius = headerViewProfile.imgProfile.frame.height / 2
                headerViewProfile.imgProfile.contentMode = .scaleAspectFill
                headerViewProfile.imgProfile.image = chosenImage
                dicSelectedImg["profile_image"] = chosenImage
            }
            else {
                
                headerViewProfile.imgCover.contentMode = .scaleAspectFill //3
                headerViewProfile.imgCover.image = chosenImage //4
                dicSelectedImg["cover_image"] = chosenImage
            }

            self.performWebUpdateProfile(dicSelectedImg)
        }
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapModeTools(_ sender: Any) {
             
        let vc = ModeratorVC.instantiate(fromAppStoryboard: .Schedule)
        vc.isFromMode = true
        vc.channelInfo = self.selectedChannel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapFollowChannel(_ sender: Any) {
        
        let cid = self.selectedChannel?.id ?? ""
        
        headerView.btnFollow.showLoader()
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [cid], isFav: !isFav, type: .sources) { success in
            self.headerView.btnFollow.hideLoaderView()
            
            self.isFav = !self.isFav
            if self.isFav {
                self.selectedChannel?.favorite = true
                self.followCount += 1
    //            headerView.lblFollow.text = NSLocalizedString("Unfollow Channel", comment: "")
                
                self.followChannel(isFollow: false)
            }
            else {
                self.selectedChannel?.favorite = false
                self.followCount -= 1
                self.followChannel(isFollow: true)
            }
            self.headerView.lblFollowers.text = "\(max(self.followCount, 0).formatUsingAbbrevation())"
            
        }
        
        
        
    }
    
    
    @IBAction func didTapBackAction(_ sender: Any) {
        
        
        SharedManager.shared.bulletPlayer = nil
        if let vc = self.currentViewController as? ProfileArticlesVC {
            vc.updateProgressbarStatus(isPause: true)
        }
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapUploadProfile(_ sender: UIButton) {
        
        //profile image
        self.setImage(true)
    }
    
    @IBAction func didTapUploadCover(_ sender: UIButton) {
        
        //cover image
        self.setImage(false)
    }
}

//MARK:- Webservices
extension ProfilePageViewController {
    
    func performWSToUploadImage(_ image: UIImage, completionHandler: @escaping (_ imageURL: String?) -> Void) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
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
                
                self.hideLoaderVC()
            } catch let jsonerror {
                self.hideLoaderVC()
                completionHandler("")
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "media/images", error: jsonerror.localizedDescription, code: "")
            }
        } withAPIFailure: { (error) in
            self.hideLoaderVC()
            completionHandler("")
            print("error parsing json objects",error)
        }
        
    }
    
    func performWebUpdateChannelImage(_ params: [String: String]) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        self.showLoaderInVC()
        
        let channelId = self.selectedChannel?.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponse("studio/channels/\(channelId)", method: .patch, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            self?.hideLoaderVC()
            guard let self = self else {
                return
            }
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                if let channel = FULLResponse.channel {
                    self.selectedChannel = channel
                }
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Channel updated succesfully", comment: ""), type: .alert)

            } catch let jsonerror {
                
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/channels", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
}


//MARK:- View Profile user
extension ProfilePageViewController {

    func setupViewProfileData() {
        
        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {

            let profile = user.profile_image ?? ""
            let cover = user.cover_image ?? ""
                        
            if profile.isEmpty {
                self.headerViewProfile.imgProfile.image = UIImage(named: "icn_profile_placeholder_light")//theme_image = GlobalPicker.imgUserPlaceholder
            }
            else {
                self.headerViewProfile.imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
            }
            
            if cover.isEmpty {
                self.headerViewProfile.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
            }
            else {
                self.headerViewProfile.imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
            }
                  
            let fullName = (user.first_name ?? "") + " " + (user.last_name ?? "")
            self.headerViewProfile.lblFullname.text = fullName.trim()
            headerViewProfile.lblUsername.text = "@\(user.username ?? "")"
            self.headerViewProfile.lblFollowers.text = "\((user.follower_count ?? 0).formatUsingAbbrevation()) Followers"
            self.headerViewProfile.lblPost.text = "\((user.post_count ?? 0).formatUsingAbbrevation()) Posts"
        }
        else {
            
            self.headerViewProfile.imgProfile.image = UIImage(named: "icn_profile_placeholder_light")
            self.headerViewProfile.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
            
            self.headerViewProfile.lblFollowers.text = "\((0).formatUsingAbbrevation())"
            self.headerViewProfile.lblPost.text = "\((0).formatUsingAbbrevation())"
        }
        
        performWSToGetAuthor(SharedManager.shared.userId)
        self.setDesignViewProfile()
        self.setupLocalization1()
                
        SharedManager.shared.bulletPlayer = nil

    }
    
    func setDesignViewProfile() {
        
        headerViewProfile.btnBack.addTarget(self, action: #selector(didTapBackAction(_:)), for: .touchUpInside)
        headerViewProfile.btnProfile.addTarget(self, action: #selector(didTapUploadProfile(_:)), for: .touchUpInside)
        headerViewProfile.btnCover.addTarget(self, action: #selector(didTapUploadCover(_:)), for: .touchUpInside)
        headerViewProfile.btnEdit.addTarget(self, action: #selector(didTapEditProfileAction(_:)), for: .touchUpInside)
        
        headerViewProfile.btnFollowers.addTarget(self, action: #selector(didTapFollowersAction(_:)), for: .touchUpInside)
        headerViewProfile.btnPosts.addTarget(self, action: #selector(didTapPostsAction(_:)), for: .touchUpInside)

        headerViewProfile.imgUserVerified.isHidden = true
        
        view.backgroundColor = .white
//        view.theme_backgroundColor = GlobalPicker.backgroundColor
        headerViewProfile.imgBack.image = UIImage(named: "iconBack_Light")//GlobalPicker.imgBackWithCover

        headerViewProfile.btnProfile.setImage(UIImage(named: "icn_camera_light"), for: .normal)
        //theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)
        headerViewProfile.btnCover.setImage(UIImage(named: "icn_camera_light"), for: .normal)
//        theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)

        headerViewProfile.viewEdit.theme_backgroundColor = GlobalPicker.backgroundColorEdition
        headerViewProfile.btnEdit.setTitleColor(.black, for: .normal)
        //theme_setTitleColor(GlobalPicker.textColor, forState: .normal)

        headerViewProfile.imgProfile.cornerRadius = headerViewProfile.imgProfile.frame.height / 2
        headerViewProfile.imgProfile.contentMode = .scaleAspectFill

//        viewProfileBG.theme_backgroundColor = GlobalPicker.textColor
//        viewProfileBG.layer.cornerRadius = viewProfileBG.frame.height / 2
//        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2

        headerViewProfile.lblFullname.textColor = .black//GlobalPicker.textColor
        headerViewProfile.lblUsername.textColor = .black//GlobalPicker.textColor
//        headerViewProfile.lblFollowers.theme_textColor = GlobalPicker.textColor
//        headerViewProfile.lblPost.theme_textColor = GlobalPicker.textColor
        
    }
    
    func setupLocalization1() {
        headerViewProfile.btnEdit.setTitle(NSLocalizedString("Edit Profile", comment: ""), for: .normal)
    }

    
    //MARK:- BUTTON ACTION
    
    @IBAction func didTapEditProfileAction(_ sender: UIButton) {

        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.delegate = self
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapFollowersAction(_ sender: UIButton) {
        
        //Channel View
        if isFromChannelView {
            if !isOwnChannel { return }
        }
        
        let vc = FollowersListVC.instantiate(fromAppStoryboard: .Schedule)
        
        vc.isFromChannel = isFromChannelView
        if isFromChannelView {
            vc.selectedChannel = selectedChannel
        }
        else {
            vc.author = self.author
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func didTapPostsAction(_ sender: UIButton) {
        
//        let vc = FollowersListVC.instantiate(fromAppStoryboard: .Schedule)
//        vc.author = self.author
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true)
    }

}

//MARK:-  Web Services
extension ProfilePageViewController {
    
    func performGetChannelDetails(id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let channel = FULLResponse.channel {
                        print("CHANNEL = \(channel)")
                        self.selectedChannel = channel
                        self.initWithChannelData(info: channel)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: "Related Sources not available")
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetAuthor(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/authors/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(AuthorDC.self, from: response)
                
                if let user = FULLResponse.author {
                    self.author = user
                    
                    let profile = user.profile_image ?? ""
                    let cover = user.cover_image ?? ""
                    
                    self.headerViewProfile.imgUserVerified.isHidden = !(user.verified ?? false)
                    
                    if profile.isEmpty {
                        self.headerViewProfile.imgProfile.image = UIImage(named: "icn_profile_placeholder_light")
                    }
                    else {
                        self.headerViewProfile.imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
                    }
                    
                    if cover.isEmpty {
                        self.headerViewProfile.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
                    }
                    else {
                        self.headerViewProfile.imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
                    }
                          
                    let fullName = (user.first_name ?? "") + " " + (user.last_name ?? "")
                    self.headerViewProfile.lblFullname.text = fullName.trim()
                    
                    let uname = self.headerViewProfile.lblUsername.text ?? ""
                    self.headerViewProfile.lblUsername.text = uname.isEmpty ? "@\(user.username ?? "")" : "\(uname)"

                    self.headerViewProfile.lblFollowers.text = "\((user.follower_count ?? 0).formatUsingAbbrevation()) Followers"
                    self.headerViewProfile.lblPost.text = "\((user.post_count ?? 0).formatUsingAbbrevation()) Posts"

                }
                else {
                    
                    self.headerViewProfile.imgProfile.image = UIImage(named: "icn_profile_placeholder_light")
                    self.headerViewProfile.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
                }

            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/authors/\(id)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWebUpdateProfile(_ dictImage: [String: UIImage]) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
//        let params = ["first_name": "",
//                      "last_name": "",
//                      "mobile_number": ""] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: nil, headers: token, ImageDic: dictImage) { (response) in
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
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Profile updated successfully", comment: ""))
                }
                
                self.hideLoaderVC()
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
            }
        } withAPIFailure: { (error) in
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
}

extension ProfilePageViewController: EditProfileVCDelegate {
    
    func setProfileData() {
        self.setupViewProfileData()
    }
}

extension ProfilePageViewController: UICollectionViewDelegate {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset        
        if offset.y > 150 {
            self.delegate?.shouldShowTitle(true)
        } else {
            self.delegate?.shouldShowTitle(false)
        }
        
        menuView.updateLayout(scrollView)
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        menuView.checkState(animation: true)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            menuView.checkState(animation: true)
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        menuView.checkState(animation: true)
    }
}
