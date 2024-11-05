//
//  HomePageVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 21/03/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class HomePageVC: UIPageViewController {
    
    var viewControllersArray = [UIViewController]()
    
    var homeContVC: HomeContainerVC?
    
    override func viewDidLoad() {
        
        self.dataSource = self
        self.delegate = self
//        self.transitionStyle = .scroll
        
        self.isDoubleSided = false
        let startingViewController = self.viewControllerAtIndex(index: 0)
        let secondViewController = self.viewControllerAtIndex(index: 1)
        
        viewControllersArray.append(startingViewController!)
        viewControllersArray.append(secondViewController!)
        
        self.setViewControllers([startingViewController!], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        
        let homeVC = HomeVC.instantiate(fromAppStoryboard: .Main)
        homeVC.currentPageIndex = index
        if index == 1 {
            homeVC.isOnFollowing = true
        }
        homeVC.delegate = homeContVC
        return homeVC
        
    }
    
    
    func changeViewController(index: Int) {
        let vc = viewControllersArray[index]
        self.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
    }
    
}



extension HomePageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
