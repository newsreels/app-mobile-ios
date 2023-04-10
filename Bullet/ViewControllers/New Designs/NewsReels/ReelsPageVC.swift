//
//  ReelsPageVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 15/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ReelsPageVC: UIPageViewController {
    
    var viewControllersArray = [UIViewController]()
    
    var reelsContVC: ReelsContainerVC?
    
    override func viewDidLoad() {
        
        self.dataSource = self
        self.delegate = self
//        self.transitionStyle = .scroll
        
        self.isDoubleSided = false
         let startingViewController = self.viewControllerAtIndex(index: 0) as UIViewController
        let secondViewController = self.viewControllerAtIndex(index: 1) as UIViewController
        
        viewControllersArray.append(startingViewController)
        viewControllersArray.append(secondViewController)
        
        
        self.setViewControllers([startingViewController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        
        let reelsVC = ReelsVC.instantiate(fromAppStoryboard: .Reels)
        reelsVC.currentPageIndex = index
        reelsVC.fromMain = true
        if index == 1 {
            reelsVC.isOnFollowing = true
        }
        reelsVC.delegate = reelsContVC
        return reelsVC
        
    }
    
    
    func changeViewController(index: Int) {
        let vc = viewControllersArray[index]
        self.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
}


extension ReelsPageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
