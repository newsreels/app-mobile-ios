//
//  WalletWebviewVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 29/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import WebKit

class WalletWebviewVC: UIViewController {

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    
    @IBOutlet weak var lblErrorTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblRetry: UILabel!
    @IBOutlet weak var viewNoData: UIView!
    @IBOutlet weak var viewWebContainer: UIView!
    @IBOutlet weak var imgError: UIImageView!
    
    var viewWeb: WKWebView?
    var webURL = ""
    var titleWeb = ""
    let doStuffMessageHandler = "closeHandler"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
        
        imgBack.theme_image = GlobalPicker.imgBack
        lblTitle.text = titleWeb

        lblTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblErrorTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblSubTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        
        imgError.theme_image = GlobalPicker.errorMessageIcon
        
        
        setLocalization()
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = MyThemes.current == .dark ? "#FCFCFC".hexStringToUIColor() : "#1A1A1A".hexStringToUIColor()
        indicator.lineWidth = 3
        
        
        self.lblRetry.theme_textColor = GlobalPicker.textColor
        self.lblRetry.layer.cornerRadius = lblRetry.bounds.height / 2
        self.lblRetry.layer.borderWidth = 2.5
        self.lblRetry.layer.borderColor = Constant.appColor.purple.cgColor
        self.lblRetry.addTextSpacing(spacing: 2.5)
        
        
        self.viewNoData.isHidden = true
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        let currTheme = MyThemes.current == .dark ? "dark" : "light"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //"https://www.w3schools.com/"
            self.webURL = "\(self.webURL)?authorization=\(userToken)&theme=\(currTheme)"
            self .webViewSetup()
        }
    }
    
    func setLocalization() {
        
        self.lblTitle.text = NSLocalizedString("Wallet", comment: "")
        self.lblRetry.text = NSLocalizedString("Retry", comment: "")
        
        self.lblErrorTitle.text = NSLocalizedString("We're sorry", comment: "")
        self.lblSubTitle.text = NSLocalizedString("An error occured while loading your wallet. Please try again later.", comment: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            }
        }
        else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
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
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapRetry(_ sender: Any) {
        
        self.viewNoData.isHidden = true
        self.viewWebContainer.isHidden = false
        self.webViewSetup()
    }
}


//MARK: - WebView delegates and setup for loading
extension WalletWebviewVC: WKUIDelegate ,WKNavigationDelegate  {
    
    
    func webViewSetup() {
        
        if self.webURL.isEmpty {
            
            if self.indicator.isAnimating {
                
                self.indicator.stopAnimating()
            }
        }
        else{
            
            self.loadWebView()
        }
    }
    
    //Loading setup...
    func loadWebView() {
        
    
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController.add(self, name: doStuffMessageHandler)
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.allowsInlineMediaPlayback = true
        
        //Webview with auto lauout
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        if viewWeb == nil {
            self.viewWeb = WKWebView (frame: customFrame , configuration: webConfiguration)
            viewWeb?.translatesAutoresizingMaskIntoConstraints = false
            
            viewWeb?.backgroundColor = .clear
            viewWebContainer.backgroundColor = .clear
            webViewContainer.backgroundColor = .clear
            
            
            self.webViewContainer.addSubview(viewWeb!)
            viewWeb?.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
            viewWeb?.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
            viewWeb?.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
            viewWeb?.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
            viewWeb?.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        
            viewWeb?.uiDelegate = self
            viewWeb?.navigationDelegate = self
            viewWeb?.scrollView.bounces = false
            viewWeb?.scrollView.bouncesZoom = false
            
        }
        
        
        indicator.startAnimating()
        
        if let escapedString = webURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let myURL = URL(string: escapedString) {
                let myRequest = URLRequest(url: myURL)
                viewWeb?.load(myRequest)
            }
        }
        else {
            
            if let myURL = URL(string: webURL) {
                let myRequest = URLRequest(url: myURL)
                viewWeb?.load(myRequest)
            }
        }
    }
    
    //WKNavigationDelegate...
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            
            
        }
        self.viewNoData.isHidden = false
        self.viewWebContainer.isHidden = true
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    
//        self.indicator.startAnimating()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//            if self.indicator.isAnimating {
//
//                self.indicator.stopAnimating()
//            }
//        }
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

        }
        self.viewNoData.isHidden = false
        self.viewWebContainer.isHidden = true
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if let serverTrust = challenge.protectionSpace.serverTrust {

            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
    
}

extension WalletWebviewVC:WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {

        if message.name == doStuffMessageHandler {
            
            self.didTapBackButton(self)
        }
    }
}
