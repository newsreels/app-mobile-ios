//
//  YPAlert.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

struct YPAlert {
    static func videoTooLongAlert(_ sourceView: UIView) -> UIAlertController {
        let msg = String(format: NSLocalizedString("Video too long", comment: ""),
                         "\(YPConfig.video.libraryTimeLimit)")
        let alert = UIAlertController(title: NSLocalizedString("Video duration", comment: ""),
                                      message: msg,
                                      preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX,
												  y: sourceView.bounds.midY,
												  width: 0,
												  height: 0)
            popoverController.permittedArrowDirections = []
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    static func videoTooShortAlert(_ sourceView: UIView) -> UIAlertController {
        let msg = String(format: NSLocalizedString("Video too short", comment: ""),
                         "\(YPConfig.video.minimumTimeLimit)")
        let alert = UIAlertController(title: NSLocalizedString("Video duration", comment: ""),
                                      message: msg,
                                      preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX,
												  y: sourceView.bounds.midY,
												  width: 0,
												  height: 0)
            popoverController.permittedArrowDirections = []
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
}
