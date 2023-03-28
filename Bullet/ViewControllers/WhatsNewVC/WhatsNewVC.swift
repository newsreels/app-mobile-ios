//
//  WhatsNewVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 17/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class WhatsNewVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgAlertIcon: UIImageView!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.theme_textColor = GlobalPicker.textColor
        buttonContinue.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        self.viewContainer.theme_backgroundColor = GlobalPicker.backgroundColor
        
        view.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.view.isOpaque = false
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        
        buttonContinue.layer.borderWidth = 2.5
        buttonContinue.layer.borderColor = Constant.appColor.purple.cgColor
        buttonContinue.layer.cornerRadius = buttonContinue.bounds.height / 2
        buttonContinue.addTextSpacing(spacing: 2)
        
        
        if let alert = SharedManager.shared.userAlert {
            
            self.lblTitle.text = alert.title ?? ""
            self.lblDescription.text = alert.message ?? ""
            self.imgAlertIcon.sd_setImage(with: URL(string: alert.image ?? "") , placeholderImage: UIImage(named: "icn_placeholder_light"))
    
        }
    }
    
    @IBAction func didTapOK(_ sender: Any) {
    
        if let id = SharedManager.shared.userAlert?.id {
            
            self.performWSToUpdateStaus(ID: id)
        }
        else {
           
            self.view.backgroundColor = .clear
            self.dismiss(animated: true, completion: nil)
        }
        SharedManager.shared.userAlert = nil
    }
    
    func performWSToUpdateStaus(ID: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("alert/view/\(ID)", method: .post, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            SharedManager.shared.isPauseAudio = false
            NotificationCenter.default.post(name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
                    
                    self.view.backgroundColor = .clear
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "alert/view/\(ID)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}
