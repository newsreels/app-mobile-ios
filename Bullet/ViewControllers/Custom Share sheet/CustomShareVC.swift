//
//  CustomShareVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 25/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import MessageUI
import FBSDKShareKit
//import SCSDKCreativeKit
import AssetsLibrary


class CustomShareVC: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var lblShareViaLink: UILabel!
    @IBOutlet weak var lblShareOriginal: UILabel!
    @IBOutlet weak var lblReport: UILabel!
    @IBOutlet weak var lblSaveToDevice: UILabel!
    @IBOutlet weak var lblFavorite: UILabel!
    @IBOutlet weak var lblNotInterested: UILabel!
    
    @IBOutlet weak var viewShareContainer: UIView!
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var viewBottomView: UIView!
    
    @IBOutlet weak var clvShareOriginalBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var clvShareOriginal: UICollectionView!
    @IBOutlet weak var clvShareViaLink: UICollectionView!
    
    
    var dismissShareSheet: ((_ resume: Bool) -> Void)?
    var didTapFlag: (() -> Void)?
    var didTapSaveToDeviceVideo: (() -> Void)?
    var didTapAddToFavoriteVideo: (() -> Void)?
    var didTapNotInterested: (() -> Void)?
    var openFacebookForVideo: (() -> Void)?
    var didTapSendVideoOnWhatsapp: ((_ type:String, _ sourceName:String, _ media:String) -> Void)?
    var didTapShareInInstaStories: (() -> Void)?
    var didTapShareOnInstaFeeds: (() -> Void)?
    
    
    var optionsArr: [ShareItem] = []
    var optionsShareOriginalArr: [ShareItem] = []
    struct ShareItem {
        var title: String?
        var image: UIImage?
        var type: ShareItemType?
    }
    
    enum ShareItemType: String {
        case instagram, stories, whatsapp, whatsappStories, twitter, sms, whatsapp_status, snapchat, facebook, others
    }
    
    var mediaWatermark = MediaWatermark()
    var shareText = ""
    var shareArticle: articlesData?
    
//    var snapAPI: SCSDKSnapAPI?
    var articleArchived: Bool = false
    var cellSize = CGSize(width: 80.0, height: 80.0)
    var isForArticles = false
    var mediaImage = ""
    var shareSheetType = ""
    
    private let storiesURL = URL(string: "instagram-stories://share")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isForArticles {
            
            self.clvShareOriginalBottomSpace.constant = 30
            self.viewBottomView.isHidden = true
        }
        else {
            
            self.clvShareOriginalBottomSpace.constant = 135
            self.viewBottomView.isHidden = false
        }
        populateOptions()
        setLocalization()
        registerCell()
        
//        snapAPI = SCSDKSnapAPI()
        
        self.view.layoutIfNeeded()
        viewShareContainer.addBottomShadow()
        viewShare.roundCorners(corners: [.topLeft,.topRight], radius: 14)
        
    }
    
    func registerCell() {
        
        clvShareOriginal.register(UINib(nibName: "ShareIconCC", bundle: nil), forCellWithReuseIdentifier: "ShareIconCC")
        clvShareViaLink.register(UINib(nibName: "ShareIconCC", bundle: nil), forCellWithReuseIdentifier: "ShareIconCC")
    }
    
    func setLocalization() {
        
        lblShareViaLink.text = NSLocalizedString("Share via link", comment: "")
        if isForArticles {
            
            lblShareOriginal.text = NSLocalizedString("Share media", comment: "")
        }
        else {
            
            lblShareOriginal.text = NSLocalizedString("Share original newsreel", comment: "")
        }
        lblReport.text = NSLocalizedString("Report", comment: "")
        lblSaveToDevice.text = NSLocalizedString("Save to\n device", comment: "")
        lblNotInterested.text = NSLocalizedString("Not interested", comment: "")
        lblFavorite.text = articleArchived ? NSLocalizedString("Remove from\n favorites", comment: "") : NSLocalizedString("Add to favorites", comment: "")
    }
    
    
    //MARK: -Buttons Action
    @IBAction func didTapSheetsAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        if sender.tag == 1 {
            //Report
            
            didTapFlag?()
        }
        else if sender.tag == 2 {
            //Save to device
            
            didTapSaveToDeviceVideo?()
            
        }
        else if sender.tag == 3 {
            //Add to favorites
            
            didTapAddToFavoriteVideo?()
        }
        else if sender.tag == 4 {
            //Not interested
            
            didTapNotInterested?()
        }
    }
    
    
    @IBAction func didTapCancel(_ sender: Any) {
        
        dismissShareSheet?(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK : - Methods
    private func populateOptions() {
        // Instagram // Stories // WhatsApp // Twitter // SMS // Others
        
        if schemeAvailable(scheme: "whatsapp://") {
            optionsArr.append(ShareItem(title: shareText, image: nil, type: .whatsapp))
            optionsShareOriginalArr.append(ShareItem(title: shareText, image: nil, type: .whatsapp))
        }
        optionsArr.append(ShareItem(title: shareText, image: nil, type: .sms))
        
        //        if schemeAvailable(scheme: "whatsapp://") {
        //            optionsArr.append(ShareItem(title: "WhatsApp status", image: nil, type: .whatsapp_status))
        //        }
        if schemeAvailable(scheme: "twitter://") {
            optionsArr.append(ShareItem(title: shareText, image: nil, type: .twitter))
         //   optionsShareOriginalArr.append(ShareItem(title: shareText, image: nil, type: .twitter))
            
        }
        
        if schemeAvailable(scheme: "instagram://app") {
            //   optionsArr.append(ShareItem(title: shareText, image: nil, type: .instagram))
            optionsShareOriginalArr.append(ShareItem(title: shareText, image: nil, type: .instagram))
        }
        
        if schemeAvailable(scheme: "whatsapp://") {
            
            optionsShareOriginalArr.append(ShareItem(title: shareText, image: nil, type: .whatsappStories))
        }
        
        if schemeAvailable(scheme: "instagram-stories://share") {
            // optionsArr.append(ShareItem(title: shareText, image: nil, type: .whatsapp))
            optionsShareOriginalArr.append(ShareItem(title: shareText, image: nil, type: .stories))
        }
        
        //        if schemeAvailable(scheme: "snapchat://") {
        //            optionsArr.append(ShareItem(title: shareText, image: nil, type: .snapchat))
        //        }
        
        if schemeAvailable(scheme: "fb://") {
            optionsArr.append(ShareItem(title: shareText, image: nil, type: .facebook))
            optionsShareOriginalArr.append(ShareItem(title: shareText, image: nil, type: .facebook))
        }
        
        optionsArr.append(ShareItem(title: shareText, image: nil, type: .others))
        optionsShareOriginalArr.append(ShareItem(title: shareText, image: nil, type: .others))
        
        
        
        self.clvShareOriginal.reloadData()
        self.clvShareViaLink.reloadData()
    }
    
    func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}


extension CustomShareVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == clvShareOriginal {
            
            return optionsShareOriginalArr.count
        }
        else {
            
            return optionsArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareIconCC", for: indexPath) as! ShareIconCC
        
        
        //We will Share the video and image
        if collectionView == clvShareOriginal {
            
            cell.setUpCell(type: optionsShareOriginalArr[indexPath.row].type ?? .others)
            cell.didTapIconButton = { [weak self] (selectedCell) in
                
                if let indexPathSel = collectionView.indexPath(for: selectedCell) {
                    let selectdOption = self?.optionsShareOriginalArr[indexPathSel.row]
                    
                    if selectdOption?.type == .sms {
                        self?.openMessageComposer(messageText: selectdOption?.title ?? "")
                    }
                    else if selectdOption?.type == .whatsapp {
                        
                        self?.didTapSendVideoOnWhatsapp?(self?.shareSheetType ?? "", "", self?.mediaImage ?? "")
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .whatsappStories {
                        
                        self?.didTapSendVideoOnWhatsapp?(self?.shareSheetType ?? "", "", self?.mediaImage ?? "")
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .twitter {
                        self?.openTwitter(text: selectdOption?.title ?? "")
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .instagram {
                        
                        self?.didTapShareOnInstaFeeds?()
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .stories {
                        
                        self?.didTapShareInInstaStories?()
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .facebook {
                        
                        self?.openFacebookForVideo?()
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                        //    self?.openFB(text: selectdOption?.title ?? "")
                    }
                    else {
                        self?.openDefaultShareSheet(shareTitle: selectdOption?.title ?? "")
                    }
                    
                }
            }
        }
        else {
            
            cell.setUpCell(type: optionsArr[indexPath.row].type ?? .others)
            cell.didTapIconButton = { [weak self] (selectedCell) in
                
                if let indexPathSel = collectionView.indexPath(for: selectedCell) {
                    let selectdOption = self?.optionsArr[indexPathSel.row]
                    
                    if selectdOption?.type == .sms {
                        self?.openMessageComposer(messageText: selectdOption?.title ?? "")
                    }
                    else if selectdOption?.type == .whatsapp {
                        
                        self?.openWhatsapp(text: selectdOption?.title ?? "")
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .twitter {
                        self?.openTwitter(text: selectdOption?.title ?? "")
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .instagram {
                        
                        self?.openInstaForURL(text: selectdOption?.title ?? "")
                        //  self?.openInsta(text: selectdOption?.title ?? "")
                        self?.dismissShareSheet?(true)
                        self?.dismiss(animated: true, completion: nil)
                    }
                    else if selectdOption?.type == .facebook {
                        self?.openFB(text: selectdOption?.title ?? "")
                    }
                    else {
                        self?.openDefaultShareSheet(shareTitle: selectdOption?.title ?? "")
                    }
                }
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellSize
    }
    func openTwitter(text: String) {
        
        let shareString = "https://twitter.com/intent/tweet?text=\(text)"
        
        
        if let escapedString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: escapedString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.open(whatsappURL, options: [: ], completionHandler: nil)
                } else {
					debugPrint("Error please install WhatsApp")
                }
            }
        }
    }
    
    
    func openFB(text: String) {
        
        // Same as previous session
        let content = ShareLinkContent()
        content.contentURL = URL(string: "https://www.newsinbullets.app/")!
        content.quote = text
        let messageDialog = ShareDialog(fromViewController: self, content: content, delegate: self)
        messageDialog.show()
        
    }
    
    
    func openInstaForURL(text: String) {
        
        // let Username =  text // Your Instagram Username here
        let instagramUrl = URL(string: "instagram://app")
        //   let appURL = URL(string: "instagram://user?username=\(Username)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(instagramUrl!) {
            application.open(instagramUrl!)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            //            let webURL = URL(string: "https://instagram.com/\(Username)")!
            //            application.open(webURL)
        }
    }
    
    
    func openWhatsapp(text: String) {
        
        var queryCharSet = NSCharacterSet.urlQueryAllowed
        
        // if your text message contains special characters like **+ and &** then add this line
        queryCharSet.remove(charactersIn: "+&")
        
        if let escapedString = text.addingPercentEncoding(withAllowedCharacters: queryCharSet) {
            if let whatsappURL = URL(string: "whatsapp://send?text=\(escapedString)") {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    UIApplication.shared.open(whatsappURL, options: [: ], completionHandler: nil)
                } else {
                }
            }
        }
        
    }
    
    fileprivate func openEmailComposer(messageText: String) {
        guard MFMailComposeViewController.canSendMail() else {
            // TODO: app not available
            return
        }
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setMessageBody(messageText, isHTML: false)
        self.present(mailComposerVC, animated: true, completion: nil)
    }
    
    fileprivate func openMessageComposer(messageText: String) {
        
        guard MFMessageComposeViewController.canSendText() else {
            // TODO: app not available
            return
        }
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate  = self
        messageController.body = messageText
        
        //        if let attachment = shareItem[.attachment] as? UIImage {
        //            let imageData = attachment.jpegData(compressionQuality: 1)
        //            messageController.addAttachmentData(imageData!, typeIdentifier: "image/JPEG", filename: "invitation.png")
        //        }
        
        
        self.present(messageController, animated: true)
    }
    
    func openDefaultShareSheet(shareTitle: String) {
        
        DispatchQueue.main.async {
            
            //Share
            let shareContent: [Any] = [shareTitle]
            
            let activityVc = UIActivityViewController(activityItems: shareContent, applicationActivities: [])
            activityVc.excludedActivityTypes = [.assignToContact, .print, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .openInIBooks, .markupAsPDF]
            
            activityVc.completionWithItemsHandler = { activity, success, items, error in
                
                if activity == nil || success == true {
                    // User canceled
                    //                    self.playCurrentCellVideo()
                    self.dismissShareSheet?(true)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                // User completed activity
            }
            
            self.present(activityVc, animated: true)
        }
        
    }
    
    
}


extension CustomShareVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            break
            
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
        self.dismissShareSheet?(true)
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomShareVC: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
        self.dismissShareSheet?(true)
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomShareVC: SharingDelegate {
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("shared")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.didTapCancel(self)
        }
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("didFailWithError")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.didTapCancel(self)
        }
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("sharerDidCancel")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.didTapCancel(self)
        }
    }
}

