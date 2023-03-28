//
//  TermsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import WebKit
import Heimdallr

class TermsVC: UIViewController, WKUIDelegate ,WKNavigationDelegate  {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var viewWeb: WKWebView!
    var webURL = ""
    var titleWeb = ""
    
    var email = ""
    var password = ""
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
        }
    }
    
    // MARK: - Methods
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
    
    
    // MARK: - Actions
    @IBAction func didTapDisagree(_ sender: Any) {
        
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapAgree(_ sender: Any) {
        
        performWSToRegistorUser()
    }
    
    
    
}


extension TermsVC {
    

    func performWSToRegistorUser() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        
        let params = ["email":email,
                      "password": password,
                      "termsandcondition": true] as [String : Any]
        
        WebService.URLResponseAuth("auth/register", method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            
            self.hideLoaderVC()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.success == true {
                    
                    print("user_id: ",FULLResponse.user_id ?? "")
                    
                    let vc = RegistrationCompletedVC.instantiate(fromAppStoryboard: .RegistrationSB)
                    vc.email = self.email
                    vc.password = self.password
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                else {
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Something went wrong", comment: ""), type: .error)
                }
                
            } catch let jsonerror {
                
                self.hideLoaderVC()
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/account-setpassword", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            self.hideLoaderVC()
            
            print("error parsing json objects",error)
        }
    }
    
    
}
