//
//  AuthorPageViewController.swift
//  Bullet
//
//  Created by Mahesh on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

protocol AuthorPageVCDelegate: AnyObject {
    
    func updateAuthorWhenDismiss(author: Author)
}

import UIKit

class AuthorPageViewController: AquamanPageViewController {
    
    //VARIABLES
    var authors: [Authors]?
    var author: Author?
    var isFavAuthor = false
    var followersCount = 0

    //VARIABLES
    var userProfileImage: UIImage?
    var userCoverImage: UIImage?
    var picker = UIImagePickerController()
    var alert = UIAlertController(title: NSLocalizedString("Choose Image", comment: ""), message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    let imagePicker = ImagePicker()

    weak var delegateAPVC: AuthorPageVCDelegate?
    private var titles = [String]()
    //private var titles = [NSLocalizedString("Newsreels", comment: ""), NSLocalizedString("Articles", comment: "")]
    
    lazy var menuView: TridentMenuView = {
        let view = TridentMenuView(parts:
            .normalTextColor(MyThemes.current == .dark ? "#8C8B91".hexStringToUIColor() : "#909090".hexStringToUIColor()),
            .selectedTextColor(MyThemes.current == .dark ? .white : .black),
            .normalTextFont(UIFont(name: Constant.FONT_Mulli_BOLD, size: 16)!),
            .selectedTextFont(UIFont(name: Constant.FONT_Mulli_BOLD, size: 16)!),
            .itemSpace(0),
            .sliderStyle(
                SliderViewStyle(parts:
                    .backgroundColor(MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()),
                    .height(2.0),
                    .cornerRadius(1),
                    .position(.bottom),
                    .extraWidth( -0.0 ),
                    .shape( .line )
                )
            ),
            .bottomLineStyle(
                BottomLineViewStyle(parts:
                    .hidden( false )
                )
            )
        )
        
        view.delegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.titles = titles
        view.itemSpace = 0
        return view
    }()

    private let headerView: AuthorProfileHeaderView = UIView.fromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
    }

    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        
        return headerView
    }

    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        
        return headerView.frame.height
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        
        let hasReel = self.author?.has_reel ?? true
        if hasReel {
            titles = [NSLocalizedString("Newsreels", comment: ""), NSLocalizedString("Articles", comment: "")]
        }
        else {
            titles = [NSLocalizedString("Articles", comment: "")]
        }

        return titles.count
    }

    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
        let hasReel = self.author?.has_reel ?? true
        
        if hasReel {
            
            if index == 0 {

                let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
                vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
                return vc
            }

            //second view controller
            else {

                let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
                vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
                return vc
            }
        }
        else {
            
            let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            return vc
        }

    }

    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return menuView
    }

    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        
        let hasReel = self.author?.has_reel ?? true
        if hasReel {
            return 52.0
        }
        return 0
    }


    override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }

    override func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool) {
        menuView.theme_backgroundColor = isAdsorption ? GlobalPicker.backgroundColor : GlobalPicker.backgroundColor
    }

    override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        menuView.checkState(animation: true)
    }

}


//MARK:- TridentMenuView Delegate
extension AuthorPageViewController: TridentMenuViewDelegate {

    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < titles.count else {
            return
        }
        setSelect(index: index, animation: true)
    }
}


//MARK:- Data setup
extension AuthorPageViewController {
    

    func setupData() {

        setDesignView()
        
        if self.author == nil {
            
            let author = authors?.first
            let profile = author?.image ?? ""
            //headerView.imgUserVerified.isHidden = !(user.verified ?? false)

            if profile.isEmpty {
                headerView.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
            }
            else {
                headerView.imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
            }

            headerView.lblUsername.text = author?.username
            headerView.lblFullName.text = author?.name
            headerView.lblFollowers.text = "\((0).formatUsingAbbrevation()) \(NSLocalizedString("Followers", comment: ""))"
            headerView.lblPost.text = "\((0).formatUsingAbbrevation()) \(NSLocalizedString("Posts", comment: ""))"

            performWSToGetAuthor(author?.id ?? "")
        }
        else {
            
            self.isFavAuthor = author?.favorite ?? false
            let profile = author?.profile_image ?? ""
            let cover = author?.cover_image ?? ""
            
            self.headerView.imgUserVerified.isHidden = !(author?.verified ?? false)

            if profile.isEmpty {
                self.headerView.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
            }
            else {
                self.headerView.imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
            }
            
            if cover.isEmpty {
                self.headerView.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
            }
            else {
                self.headerView.imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
            }
            
            self.followersCount = author?.follower_count ?? 0
            self.headerView.lblFullName.text = (author?.first_name ?? "") + " " + (author?.last_name ?? "").trim()
            self.headerView.lblUsername.text = author?.username ?? ""
            self.headerView.lblFollowers.text = "\(self.followersCount.formatUsingAbbrevation()) \(NSLocalizedString("Followers", comment: ""))"
            self.headerView.lblPost.text = "\((author?.post_count ?? 0).formatUsingAbbrevation()) \(NSLocalizedString("Posts", comment: ""))"
            
            self.headerView.lblFollow.text = self.isFavAuthor ? NSLocalizedString("Following", comment: "") : NSLocalizedString("Follow", comment: "")
        }
    }
        
    func setDesignView() {
        
        view.backgroundColor = .black
        headerView.theme_backgroundColor = GlobalPicker.backgroundColor
        headerView.imgUserVerified.isHidden = true

        headerView.btnBack.addTarget(self, action: #selector(didTapBackAction(_:)), for: .touchUpInside)
        headerView.btnProfile.addTarget(self, action: #selector(didTapUploadProfile(_:)), for: .touchUpInside)
        headerView.btnCover.addTarget(self, action: #selector(didTapUploadCover(_:)), for: .touchUpInside)
        headerView.btnFollow.addTarget(self, action: #selector(didTapFollowAction(_:)), for: .touchUpInside)

        if (author?.id ?? "") == SharedManager.shared.userId {
            headerView.viewPhotoBG.isHidden = false
            headerView.viewCoverBG.isHidden = false
        }
        else {
            headerView.viewPhotoBG.isHidden = true
            headerView.viewCoverBG.isHidden = true
        }
        
        headerView.imgProfile.cornerRadius = headerView.imgProfile.frame.height / 2
        headerView.imgProfile.contentMode = .scaleAspectFill

        headerView.imgBack.theme_image = GlobalPicker.imgBackWithCover
        headerView.btnProfile.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)
        headerView.btnCover.theme_setImage(GlobalPicker.btnImgCamera, forState: .normal)

        headerView.viewFollow.theme_backgroundColor = GlobalPicker.themeCommonColor
        //        btnEdit.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)

//        viewProfileBG.theme_backgroundColor = GlobalPicker.textColor
//        viewProfileBG.layer.cornerRadius = viewProfileBG.frame.height / 2
//        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2

        headerView.lblFullName.theme_textColor = GlobalPicker.textColor
//        headerView.lblFollowers.theme_textColor = GlobalPicker.textColor
//        headerView.lblPost.theme_textColor = GlobalPicker.textColor
        
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
        
        if isTapOnProfile {
            
            headerView.imgProfile.cornerRadius = headerView.imgProfile.frame.height / 2
            headerView.imgProfile.contentMode = .scaleAspectFill
            headerView.imgProfile.image = chosenImage
            self.userProfileImage = chosenImage
        }
        else {
            
            headerView.imgCover.contentMode = .scaleAspectFill //3
            headerView.imgCover.image = chosenImage //4
            self.userCoverImage = chosenImage
        }
        
        performWebUpdateProfile()
    }

    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackAction(_ sender: Any) {
        
        
        SharedManager.shared.bulletPlayer = nil
        if let vc = self.currentViewController as? ProfileArticlesVC {
            vc.updateProgressbarStatus(isPause: true)
        }
        
        if let athr = author {
            self.delegateAPVC?.updateAuthorWhenDismiss(author: athr)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapFollowAction(_ sender: UIButton) {

        if isFavAuthor {
            performWSToAuthorUnFollow(self.author?.id ?? "")
        }
        else {
            performWSToAuthorFollow(self.author?.id ?? "")
        }
        
        isFavAuthor = !self.isFavAuthor
        author?.favorite = self.isFavAuthor

        followersCount = abs(self.isFavAuthor ? followersCount + 1 : followersCount - 1)
        headerView.lblFollowers.text = "\(self.followersCount.formatUsingAbbrevation()) \(NSLocalizedString("Followers", comment: ""))"
        headerView.lblFollow.text = self.isFavAuthor ? NSLocalizedString("Following", comment: "") : NSLocalizedString("Follow", comment: "")
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

//MARK:-  Web Services
extension AuthorPageViewController {
    
    func performWSToGetAuthor(_ id: String) {

        if !(SharedManager.shared.isConnectedToNetwork()) {

            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/authors/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(AuthorDC.self, from: response)

                if let author = FULLResponse.author {
                    self.author = author

                    self.isFavAuthor = author.favorite ?? false
                    let profile = author.profile_image ?? ""
                    let cover = author.cover_image ?? ""

                    self.headerView.imgUserVerified.isHidden = !(author.verified ?? false)

                    if profile.isEmpty {
                        self.headerView.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
                    }
                    else {
                        self.headerView.imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
                    }

                    if cover.isEmpty {
                        self.headerView.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
                    }
                    else {
                        self.headerView.imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
                    }

                    self.followersCount = author.follower_count ?? 0
                    self.headerView.lblUsername.text = author.username ?? ""
                    self.headerView.lblFullName.text = (author.first_name ?? "") + " " + (author.last_name ?? "").trim()
                    self.headerView.lblFollowers.text = "\(self.followersCount.formatUsingAbbrevation()) \(NSLocalizedString("Followers", comment: ""))"
                    self.headerView.lblPost.text = "\((author.post_count ?? 0).formatUsingAbbrevation()) \(NSLocalizedString("Posts", comment: ""))"

                    self.headerView.lblFollow.text = self.isFavAuthor ? NSLocalizedString("Following", comment: "") : NSLocalizedString("Follow", comment: "")
                }
                else {

                    self.headerView.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
                    self.headerView.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
                }

            } catch let jsonerror {

                SharedManager.shared.logAPIError(url: "news/authors/\(id)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }

        }) { (error) in

            print("error parsing json objects",error)
        }
    }
    
    func performWSToAuthorFollow(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["authors": "\(id)"]
        
        //ANLoader.showLoading(disableUI: true)
        WebService.URLResponse("news/authors/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            //ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
                    
                    print("added topic SUCCESSFULLY...")
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/authors/follow", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToAuthorUnFollow(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["authors": "\(id)"]
        
        //ANLoader.showLoading(disableUI: true)
        
        WebService.URLResponse("news/authors/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in

            //ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if let message = FULLResponse.message {
                    
                    if message.uppercased() == Constant.STATUS_SUCCESS {
                        
                        print("Deleted topic SUCCESSFULLY...")
                        
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: message)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/authors/unfollow", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWebUpdateProfile() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
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
        
//        let params = ["first_name": "",
//                      "last_name": "",
//                      "mobile_number": ""] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: nil, headers: token, ImageDic: dicSelectedImages) { (response) in
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



//protocol authorPageViewControllerDelegate: NSObjectProtocol {
//
//    func pageCurrentViewControllerAtIndex(index: Int, pageViewController: AuthorPageViewController)
//}
//
//class AuthorPageViewController: UIPageViewController {
//
//    var index = 0
//    var authorID = ""
//
//    var identifiers: NSArray = ["ProfileReelsVC", "ProfileArticlesVC"]
//    weak var pageDelegate: authorPageViewControllerDelegate?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        dataSource = self
//        delegate = self
//
//        setViewController(index: self.index)
//    }
//
//    func setViewController(index : Int) {
//
//        self.index = index
//        let startingViewController = self.viewControllerAtIndex(index: index)
//        let viewControllers: [UIViewController] = [startingViewController!]
//        self.setViewControllers(viewControllers, direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
//    }
//
//    //view controllers setup
//    func viewControllerAtIndex(index: Int) -> UIViewController! {
//
//        //first view controller
//        if index == 0 {
//
//            let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
//            vc.authorID = self.authorID
//            return vc
//
//        }
//
//        //second view controller
//        else if index == 1 {
//
//            let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
//            vc.authorID = self.authorID
//            return vc
//        }
//
//        return UIViewController()
//    }
//}
//
//
////MARK: Class HomePageViewController extensions
//extension AuthorPageViewController : UIPageViewControllerDataSource {
//
//    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        let identifier = viewController.restorationIdentifier as AnyObject
//        let index = identifiers.index(of: identifier) == NSNotFound ? 0 : identifiers.index(of: identifier)
//
//        //if the index is 0, return nil since we dont want a view controller before the first one
//        if index == 0 {
//
//            return nil
//        }
//
//        //decrement the index to get the viewController before the current one
//        self.index = self.index - 1
//        return self.viewControllerAtIndex(index: self.index)
//    }
//
//    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        let identifier = viewController.restorationIdentifier as AnyObject
//        let index = identifiers.index(of: identifier) == NSNotFound ? 0 : identifiers.index(of: identifier)
//
//        //if the index is the end of the array, return nil since we dont want a view controller after the last one
//        if index == identifiers.count - 1 {
//
//            return nil
//        }
//
//        //increment the index to get the viewController after the current index
//        self.index = self.index + 1
//        return self.viewControllerAtIndex(index: self.index)
//    }
//
//
//    func presentationCountForPageViewController(pageViewController: UIPageViewController!) -> Int {
//
//        return self.identifiers.count
//    }
//
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController!) -> Int {
//
//        return 0
//    }
//}
//
//extension AuthorPageViewController : UIPageViewControllerDelegate {
//
//    // when jumping to another vc
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//
//        if (!completed) {
//            return
//        }
//
//        let identifier = pageViewController.viewControllers!.first!.restorationIdentifier as AnyObject
//        index = identifiers.index(of: identifier) == NSNotFound ? 0 : identifiers.index(of: identifier)
//        pageDelegate?.pageCurrentViewControllerAtIndex(index: index, pageViewController: self)
//    }
//}
