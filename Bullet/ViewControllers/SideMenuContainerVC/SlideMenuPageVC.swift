//
//  SlideMenuPageVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class SlideMenuPageVC: UIPageViewController {
    
    var viewControllersArray = [UIViewController]()
    
//    var channelVC: ChannelDetailsVC?
//    var userProfileVC: AuthorProfileVC?
    
    override func viewDidLoad() {
        
        self.dataSource = self
        self.delegate = self
//        self.transitionStyle = .scroll
        
        self.isDoubleSided = false
        let startingViewController = self.viewControllerAtIndex(index: 0)
        let secondViewController = self.viewControllerAtIndex(index: 1)
        let thirdViewController = self.viewControllerAtIndex(index: 2)
        
        viewControllersArray.append(startingViewController!)
        viewControllersArray.append(secondViewController!)
        viewControllersArray.append(thirdViewController!)
        
        self.setViewControllers([startingViewController!], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        
        if index == 0 {
            let userProfileVC = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
//            userProfileVC.currentPageIndex = index
//            userProfileVC.isOnCommunity = true
            return userProfileVC
        } else if index == 1 {
            let channelVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
//            channelVC.currentPageIndex = index
//            channelVC.isOnCommunity = true
            return channelVC
        } else {
            
            let userProfileVC = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
            return userProfileVC
            
        }
        
    }
    
    func changeViewController(index: Int) {
        let vc = viewControllersArray[index]
        self.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
    
    func showAuthorVC(authors: [Authors]?) {
        let aId = authors?.first?.id ?? ""
        if aId == SharedManager.shared.userId {
            
            let userProfileVC = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
            self.setViewControllers([userProfileVC], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
        else {
            
            let userProfileVC = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
            userProfileVC.authors = authors
            self.setViewControllers([userProfileVC], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
        
    }
    
    func showChannelDetailsVC(source: ChannelInfo, channelInfo: ChannelInfo?) {
        
        let channelVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        if channelInfo == nil {
            channelVC.channelInfo = ChannelInfo(id: source.id, context: source.context, name: source.name, channelDescription: nil, link: source.link, icon: source.icon, name_image: source.name_image, portrait_image: source.portrait_image, image: source.image, updateCount: nil, channelModelType: nil, follower_count: nil, post_count: nil, own: nil, hasReel: nil, hasArticle: nil, verified: nil, favorite: nil)
            performGoToSource(source: source)
        } else {
            channelVC.channelInfo = channelInfo
        }
        self.setViewControllers([channelVC], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
}


extension SlideMenuPageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        return nil
        
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            if completed {
//                let cvc = pageViewController.viewControllers!.first as! ReelsVC
//                let newIndex = cvc.currentPageIndex
            }
        }
        
    }
    
}

extension SlideMenuPageVC {
    
    func performGoToSource(source: ChannelInfo) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(source.id ?? "")", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let info = FULLResponse.channel {
                        
                        self.showChannelDetailsVC(source: source, channelInfo: info)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Related Sources not available", comment: ""))
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/data/\(source.id ?? "")", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
}
