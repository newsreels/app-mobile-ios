//
//  YoutubeArticle.swift
//  Bullet
//
//  Created by Mahesh on 10/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol YoutubeArticleVCDelegate: AnyObject {
    
    func submitYoutubeArticlePost(_ article: articlesData)
}

class YoutubeArticleVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var viewNextButton: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var txtLink: UITextField!
    @IBOutlet weak var viewSearchBG: UIView!
    @IBOutlet weak var btnIcon: UIButton!
    @IBOutlet weak var imgIcon: UIImageView!
    
    weak var delegate: YoutubeArticleVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()

        self.viewContainer.theme_backgroundColor = GlobalPicker.backgroundDiscoverHeader
        viewSearchBG.theme_backgroundColor = GlobalPicker.searchBGViewColor

        lblTitle.theme_textColor = GlobalPicker.textColor        
        viewNextButton.theme_backgroundColor = GlobalPicker.themeCommonColor
        self.viewNextButton.cornerRadius = self.viewNextButton.frame.size.height / 2
        lblContinue.addTextSpacing(spacing: 2)
        
        txtLink.theme_tintColor = GlobalPicker.textColor
        txtLink.theme_textColor = GlobalPicker.textColor
        imgIcon.theme_image = GlobalPicker.btnYoutubeImg
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("YouTube Article", comment: "")
        lblMessage.text = NSLocalizedString("Paste a YouTube link to upload a video from YouTube.", comment: "")
        txtLink.placeholder = NSLocalizedString("Paste a YouTube link to take import", comment: "")

        lblContinue.text = NSLocalizedString("IMPORT", comment: "")
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapContinue(_ sender: Any) {
        
        self.view.endEditing(true)
        performWSToPreviewYoutubeArticle()
    }
    
    func performWSToPreviewYoutubeArticle() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let link = txtLink.text ?? ""
        if link.isEmpty {
            
            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter Youtube link", comment: ""))
            return
        }
        
        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)

        let params = ["headline": "",
                      "youtube_id": link,
                      "source": "",
                      "id": ""] as [String : Any]
        
        WebService.URLResponseJSONRequest("studio/articles/youtube", method: .post, parameters: params, headers: token) { (response) in
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(postArticlesDC.self, from: response)
                
                ANLoader.hide()
                if let article = FULLResponse.article {
                                        
                    self.dismiss(animated: true, completion: {
                        
                        self.delegate?.submitYoutubeArticlePost(article)
                    })
                }
                else {
                    
                    if let message = FULLResponse.message {
                        SharedManager.shared.showAlertLoader(message: message, type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Invalid Youtube link", comment: ""), type: .alert)
                    }
                }

            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/articles/youtube", error: jsonerror.localizedDescription, code: "")
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

