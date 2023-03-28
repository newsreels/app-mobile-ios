//
//  OnboardingPageVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 03/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol OnboardingPageVCDelegate: AnyObject {
    
    func didChangePage()
}

class OnboardingPageVC: UIPageViewController {

    var viewControllersArray = [UIViewController?]()
    var selectedIndex = 0
    weak var delegatePage: OnboardingPageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // initialize array
        let vc1 = OnboardingContentVC.instantiate(fromAppStoryboard: .OnboardingSB)
        vc1.selectedPage = 0
        let vc2 = OnboardingContentVC.instantiate(fromAppStoryboard: .OnboardingSB)
        vc2.selectedPage = 1
        let vc3 = OnboardingContentVC.instantiate(fromAppStoryboard: .OnboardingSB)
        vc3.selectedPage = 2

        viewControllersArray = [vc1, vc2, vc3]
        self.delegate = self
        self.dataSource = self
        
        setViewControllerAtIndex(index: selectedIndex, isAnimated: false)
        
        self.view.isUserInteractionEnabled = false
    }
    
    
    func setViewControllerAtIndex(index: Int, isAnimated: Bool) {
        
        if let vc = viewControllersArray[index] {
            setViewControllers([vc],direction: .forward,animated: isAnimated,completion: nil)
        }
        
    }

}


extension OnboardingPageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllersArray.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllersArray.count > previousIndex else {
            return nil
        }
        
        return viewControllersArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllersArray.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let viewControllersCount = viewControllersArray.count
        
        guard viewControllersCount != nextIndex else {
            return nil
        }
        
        guard viewControllersCount > nextIndex else {
            return nil
        }
        
        return viewControllersArray[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            if let viewControllerIndex = self.viewControllersArray.firstIndex(of: self.viewControllers?.first) {
                self.selectedIndex = viewControllerIndex
                
                self.delegatePage?.didChangePage()
            }
            
        }
        
    }
    
}
