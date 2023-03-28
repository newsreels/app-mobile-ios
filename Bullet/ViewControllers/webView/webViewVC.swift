//
//  RegistrationVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 02/07/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import WebKit

//protocol webViewVCDelegate: class {
//    func dismissWebViewVC()
//}

class webViewVC: UIViewController, WKUIDelegate ,WKNavigationDelegate  {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var lblUrl: UILabel!
//    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    
    var viewWeb: WKWebView!
    var webURL = ""
    var titleWeb = ""
    
//    weak var delegateVC: webViewVCDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        SharedManager.shared.isLoadWebFromArticles = true
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.bulletPlayer?.currentTime = 0
        SharedManager.shared.articleURLPageLoaded = true
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.theme_textColor = GlobalPicker.textColor
//        imgBack.theme_image = GlobalPicker.imgBack
//        lblUrl.theme_textColor = GlobalPicker.textColor
        
        lblTitle.text = titleWeb
//        lblUrl.text = ""
      //  lblTitle.adjustsFontSizeToFitWidth = true

        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#1A1A1A".hexStringToUIColor()
        indicator.lineWidth = 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            if self.webURL.isEmpty {
                
                if self.indicator.isAnimating {
                    
                    self.indicator.stopAnimating()
                }
            }
            else{

                self.loadWebView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.bulletPlayer?.currentTime = 0
        
        SharedManager.shared.articleURLPageLoaded = true
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SharedManager.shared.articleURLPageLoaded = false
    }
    override func viewWillLayoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
//                self.lblUrl.semanticContentAttribute = .forceRightToLeft
//                self.lblUrl.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
//                self.lblUrl.semanticContentAttribute = .forceLeftToRight
//                self.lblUrl.textAlignment = .left
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
  
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true) {
//            self.delegateVC?.dismissWebViewVC()
        }
    }
    
    func loadWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        // webConfiguration.mediaPlaybackRequiresUserAction = false
        webConfiguration.allowsInlineMediaPlayback = true
        
        //Webview with auto lauout
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        self.viewWeb = WKWebView (frame: customFrame , configuration: webConfiguration)
        viewWeb.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addSubview(viewWeb)
        viewWeb.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        viewWeb.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
        viewWeb.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
        viewWeb.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        viewWeb.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        
        viewWeb.uiDelegate = self
        viewWeb.navigationDelegate = self
        
        if let escapedString = webURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let myURL = URL(string: escapedString) {
                let myRequest = URLRequest(url: myURL)
                viewWeb.load(myRequest)
            }
        }
        else {
            
            if let myURL = URL(string: webURL) {
                let myRequest = URLRequest(url: myURL)
                viewWeb.load(myRequest)
            }
        }
    }
    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            
            if webURL.contains("https") {
                webURL = "http" + webURL.dropFirst(5)
            }
            else {
                webURL = "https" + webURL.dropFirst(4)
            }
            
            if let myURL = URL(string: webURL) {
                let myRequest = URLRequest(url: myURL)
                viewWeb.load(myRequest)
            }
        }
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {

            if self.indicator.isAnimating {
                
                self.indicator.stopAnimating()
            }
        }
        print("Strat to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
        }
        print("finish to load")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            
            if webURL.contains("https") {
                webURL = "http" + webURL.dropFirst(5)
            }
            else {
                webURL = "https" + webURL.dropFirst(4)
            }
            
            if let myURL = URL(string: webURL) {
                let myRequest = URLRequest(url: myURL)
                viewWeb.load(myRequest)
            }

        }
        print(error.localizedDescription)

    }
    
}
