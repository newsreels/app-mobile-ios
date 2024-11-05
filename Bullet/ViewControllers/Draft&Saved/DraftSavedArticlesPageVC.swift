//
//  DraftSavedArticlesPageVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 11/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

protocol DraftSavedArticlesPageVCDelegate: AnyObject {
    
    func updateAuthorWhenDismiss(author: Author)
}

import UIKit

class DraftSavedArticlesPageVC: AquamanPageViewController {
    
    var isFromDrafts = false
    var isFromSaveArticles = false
    
    weak var delegateAPVC: DraftSavedArticlesPageVCDelegate?
    private var titles = [String]()
    var hasReel = true
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        
        return UIView()
    }

    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        
        return 0
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        
        if hasReel {
            titles = [NSLocalizedString("Newsreels", comment: ""), NSLocalizedString("Articles", comment: "")]
        }
        else {
            titles = [NSLocalizedString("Articles", comment: "")]
        }

        return titles.count
    }

    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
//        let hasReel = self.author?.has_reel ?? true
        
        if hasReel {
            
            if index == 0 {

                let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
                vc.isFromDrafts = isFromDrafts
                vc.isFromSaveArticles = isFromSaveArticles
                
//                vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
                return vc
            }

            //second view controller
            else {

                let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
//                vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
                vc.isFromDrafts = isFromDrafts
                vc.isFromSaveArticles = isFromSaveArticles
                return vc
            }
        }
        else {
            
            let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
//            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            vc.isFromDrafts = isFromDrafts
            vc.isFromSaveArticles = isFromSaveArticles
            return vc
        }

    }

    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return menuView
    }

    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        
//        let hasReel = self.author?.has_reel ?? true
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
extension DraftSavedArticlesPageVC: TridentMenuViewDelegate {

    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < titles.count else {
            return
        }
        setSelect(index: index, animation: true)
    }
}


//MARK:- Data setup
extension DraftSavedArticlesPageVC {

}

//MARK:-  Web Services
extension DraftSavedArticlesPageVC {
    
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
//                    self.author = author

                    let profile = author.profile_image ?? ""
                    let cover = author.cover_image ?? ""
//
//                    self.headerView.imgUserVerified.isHidden = !(author.verified ?? false)
//
//                    if profile.isEmpty {
//                        self.headerView.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
//                    }
//                    else {
//                        self.headerView.imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
//                    }
//
//                    if cover.isEmpty {
//                        self.headerView.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
//                    }
//                    else {
//                        self.headerView.imgCover.sd_setImage(with: URL(string: cover), placeholderImage: nil)
//                    }
//
////                    self.followersCount = author.follower_count ?? 0
//                    self.headerView.lblUsername.text = (author.first_name ?? "") + " " + (author.last_name ?? "").trim()
//                    self.headerView.lblFollowers.text = "\(self.followersCount.formatUsingAbbrevation()) \(NSLocalizedString("Followers", comment: ""))"
//                    self.headerView.lblPost.text = "\((author.post_count ?? 0).formatUsingAbbrevation()) \(NSLocalizedString("Posts", comment: ""))"
//
//                    self.headerView.lblFollow.text = self.isFavAuthor ? NSLocalizedString("Following", comment: "") : NSLocalizedString("Follow", comment: "")
                }
                else {

//                    self.headerView.imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
//                    self.headerView.imgCover.theme_image = GlobalPicker.imgCoverPlaceholder
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
                        SharedManager.shared.showAlertView(source: self, title: NSLocalizedString("Newsreels", comment: ""), message: message)
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
    
}
