//
//  ReelsVC+SetupViews.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import UIKit

extension ReelsVC {
    func openReelsTutorial() {
          DispatchQueue.main.async {
              let vc = TutorialVC.instantiate(fromAppStoryboard: .Reels)
              vc.delegate = self
              self.isViewControllerVisible = false
              self.present(vc, animated: true, completion: nil)
          }
      }
}
