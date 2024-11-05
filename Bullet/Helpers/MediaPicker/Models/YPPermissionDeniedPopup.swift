//
//  YPPermissionDeniedPopup.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/03/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

class YPPermissionDeniedPopup {
    func popup(cancelBlock: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title:
            NSLocalizedString("This feature requires photo access", comment: ""),
                                      message: NSLocalizedString("in phone settings, tap Newsreels and turn on Photos", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Not Now", comment: ""),
                          style: UIAlertAction.Style.cancel,
                          handler: { _ in
                            cancelBlock()
            }))
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""),
                          style: .default,
                          handler: { _ in
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            } else {
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            }
            }))
        return alert
    }
    
    
    func popupNoPhotos(cancelBlock: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title:
            NSLocalizedString("No photos on this device", comment: ""),
                                      message: NSLocalizedString("if you want to change photo access settings, go to phone settings, tap Newsreels and turn on Photos", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Not Now", comment: ""),
                          style: UIAlertAction.Style.cancel,
                          handler: { _ in
                            cancelBlock()
            }))
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""),
                          style: .default,
                          handler: { _ in
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            } else {
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            }
            }))
        return alert
    }
    
}
