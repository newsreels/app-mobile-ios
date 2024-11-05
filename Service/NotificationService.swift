//
//  NotificationService.swift
//  Service
//
//  Created by Khadim Hussain on 27/01/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

//import UserNotifications
//
//class NotificationService: UNNotificationServiceExtension {
//
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        guard let bestAttemptContent = bestAttemptContent else { return }
//        // Modify the notification content here...
//        bestAttemptContent.title = "\(bestAttemptContent.title)"
//        // Save notification data to UserDefaults
//        let data = bestAttemptContent.userInfo as NSDictionary
//        let pref = UserDefaults.init(suiteName: "group.app.newsreels")
//        pref?.set(data, forKey: "NOTIF_DATA")
//        pref?.synchronize()
//
//        guard let dict = bestAttemptContent.userInfo["fcm_options"] as? NSDictionary, let attachmentURL = dict["image"] as? String else {
//            contentHandler(bestAttemptContent)
//            return
//        }
//
//        do {
//            let imageData = try Data(contentsOf: URL(string: attachmentURL)!)
//            guard let attachment = UNNotificationAttachment.download(imageFileIdentifier: "image.jpg", data: imageData, options: nil) else {
//                contentHandler(bestAttemptContent)
//                return
//            }
//            bestAttemptContent.attachments = [attachment]
//            contentHandler(bestAttemptContent.copy() as! UNNotificationContent)
//        } catch {
//            contentHandler(bestAttemptContent)
//            print("Unable to load data: \(error)")
//        }
//    }
//
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//}
//
//extension UNNotificationAttachment {
//    static func download(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?)
//        -> UNNotificationAttachment? {
//            let fileManager = FileManager.default
//            if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.app.newsreels") {
//                do {
//                    let newDirectory = directory.appendingPathComponent("Images")
//                    if !fileManager.fileExists(atPath: newDirectory.path) {
//                        try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
//                    }
//                    let fileURL = newDirectory.appendingPathComponent(imageFileIdentifier)
//                    do {
//                        try data.write(to: fileURL, options: [])
//                    } catch {
//                        print("Unable to load data: \(error)")
//                    }
//                    let pref = UserDefaults(suiteName: "group.app.newsreels")
//                    pref?.set(data, forKey: "NOTIF_IMAGE")
//                    pref?.synchronize()
//                    let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
//                    return imageAttachment
//                } catch let error {
//                    print("Error: \(error)")
//                }
//            }
//            return nil
//    }
//}


import UserNotifications

import OneSignal

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            //If your SDK version is < 3.5.0 uncomment and use this code:
            /*
            OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
            */
            
            /* DEBUGGING: Uncomment the 2 lines below to check this extension is excuting
                          Note, this extension only runs when mutable-content is set
                          Setting an attachment or action buttons automatically adds this */
            //OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
            //bestAttemptContent.body = "[Modified] " + bestAttemptContent.body
            
            OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignal.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
