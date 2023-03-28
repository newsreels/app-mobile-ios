//
//  SearchPageViewController.swift
//  Bullet
//
//  Created by Faris Muhammed on 06/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class SearchPageViewController: AquamanPageViewController {

    private var titles = [NSLocalizedString("All", comment: ""),NSLocalizedString("Reels", comment: ""), NSLocalizedString("Articles", comment: ""), NSLocalizedString("Channels", comment: ""), NSLocalizedString("Places", comment: ""), NSLocalizedString("Topics", comment: "")]
    
    
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
    var dismissKeyboard : (()-> Void)?
    
    enum searchType {
        case all
        case reels
        case article
        case channels
        case locations
        case topics
    }
    var currentSearchSelection = searchType.all
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        menuView.isHidden = true
    }
    

//    func setMenuViewVisiblity() {
//        if search.isEmpty {
//            menuView.isHidden = true
//        }
//        else {
//            menuView.isHidden = false
//        }
//        menuView.isHidden = true
//    }
    
    // MARK : - Search Methods
    func refreshVC() {
        
        menuView.isHidden = true
        
        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        if let vc = self.currentViewController as? RelevantVC {
            vc.refreshVC()
        }
        else if let vc = self.currentViewController as? ProfileReelsVC {
            vc.refreshVC()
        }
        else if let vc = self.currentViewController as? ProfileArticlesVC {
            vc.refreshVC()
        }
        else if let vc = self.currentViewController as? UserFollowingVC {
            vc.refreshVC()
        }

    }
    
    func getSearchContent(search: String) {
        
        if search.isEmpty {
            menuView.isHidden = true
        }
        else {
            menuView.isHidden = false
        }
        
        if let vc = self.currentViewController as? RelevantVC {
            vc.getSearchContent(search: search)
        }
        else if let vc = self.currentViewController as? ProfileReelsVC {
            vc.getSearchContent(search: search)
        }
        else if let vc = self.currentViewController as? ProfileArticlesVC {
            vc.getSearchContent(search: search)
        }
        else if let vc = self.currentViewController as? UserFollowingVC {
            vc.getSearchContent(search: search)
        }
    }
    
    
    func appEnteredBackground() {
        

        if let vc = self.currentViewController as? RelevantVC {
            vc.appEnteredBackground()
        }
        else if let vc = self.currentViewController as? ProfileReelsVC {
            vc.appEnteredBackground()
        }
        else if let vc = self.currentViewController as? ProfileArticlesVC {
            vc.appEnteredBackground()
        }
        else if let vc = self.currentViewController as? UserFollowingVC {
            vc.appEnteredBackground()
        }
    }
    
    
    func appLoadedToForeground() {
        
        if let vc = self.currentViewController as? RelevantVC {
            vc.appLoadedToForeground()
        }
        else if let vc = self.currentViewController as? ProfileReelsVC {
            vc.appLoadedToForeground()
        }
        else if let vc = self.currentViewController as? ProfileArticlesVC {
            vc.appLoadedToForeground()
        }
        else if let vc = self.currentViewController as? UserFollowingVC {
            vc.appLoadedToForeground()
        }
    }
    
    func stopAll() {
        
        
        if let vc = self.currentViewController as? RelevantVC {
            vc.stopAll()
        }
        else if let vc = self.currentViewController as? ProfileReelsVC {
            vc.stopAll()
        }
        else if let vc = self.currentViewController as? ProfileArticlesVC {
            vc.stopAll()
        }
        else if let vc = self.currentViewController as? UserFollowingVC {
            vc.stopAll()
        }

    }
    
    
    
    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        
        return UIView()
    }

    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        
        return .zero
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        if currentSearchSelection != .all {
            return 1
        }
        return titles.count
    }

    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
        var showIndex = index
        if currentSearchSelection != .all {
            if currentSearchSelection == .reels {
                showIndex = 1
            }
            else if currentSearchSelection == .article {
                showIndex = 2
            }
            else if currentSearchSelection == .channels {
                showIndex = 3
            }
            else if currentSearchSelection == .locations {
                showIndex = 4
            }
            else if currentSearchSelection == .topics {
                showIndex = 5
            }
            
        }
        
        if showIndex == 0 {
            let vc = RelevantVC.instantiate(fromAppStoryboard: .Main)
//            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            vc.dismissKeyboard = {
                    self.dismissKeyboard?()
            }
            return vc
        }
        else if showIndex == 1 {
            let vc = ProfileReelsVC.instantiate(fromAppStoryboard: .Main)
//            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            vc.isOnSearch = true
            vc.dismissKeyboard = {
                    self.dismissKeyboard?()
            }
            return vc
        }
        else if showIndex == 2 {
            let vc = ProfileArticlesVC.instantiate(fromAppStoryboard: .Main)
//            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            vc.isOnSearch = true
            vc.dismissKeyboard = {
                    self.dismissKeyboard?()
            }
            return vc
        }
        else if showIndex == 3 {
            
            let vc = UserFollowingVC.instantiate(fromAppStoryboard: .Reels)
            vc.currentSelection = .channel
//            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            vc.isOnSearch = true
            vc.dismissKeyboard = {
                    self.dismissKeyboard?()
            }
            return vc
            
        }
        else if showIndex == 4 {
            
            let vc = UserFollowingVC.instantiate(fromAppStoryboard: .Reels)
            vc.currentSelection = .place
//            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            vc.isOnSearch = true
            vc.dismissKeyboard = {
                    self.dismissKeyboard?()
            }
            return vc
            
        }
        else {
            
            let vc = UserFollowingVC.instantiate(fromAppStoryboard: .Reels)
            vc.currentSelection = .topic
//            vc.authorID = self.authors?.first?.id ?? self.author?.id ?? ""
            vc.isOnSearch = true
            vc.dismissKeyboard = {
                    self.dismissKeyboard?()
            }
            return vc
            
        }
        

    }

    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return menuView
    }

    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        if currentSearchSelection != .all {
            return 0
        }
        return 52.0
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


extension SearchPageViewController: TridentMenuViewDelegate {

    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < titles.count else {
            return
        }
        setSelect(index: index, animation: true)
    }
}

