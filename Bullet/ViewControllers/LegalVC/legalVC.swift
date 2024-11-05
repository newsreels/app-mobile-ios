//
//  legalVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 08/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class legalVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var listArray = [NSLocalizedString("TERMS AND CONDITIONS", comment: ""), NSLocalizedString("PRIVACY POLICY", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        imgBack.theme_image = GlobalPicker.btnImgBack
        
        self.tableView.reloadData()
    }
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Legal", comment: "")
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
       
           self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITablview Delegates and DataSource
extension legalVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 56
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCC") as! SettingsCC
        
        cell.lblItem.text = listArray[indexPath.row]
        cell.lblItem.addTextSpacing(spacing: 1.45)
        cell.imgArrow.image = UIImage(named: MyThemes.current == .dark ? "tbFroword" : "tbFrowordLight")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = listArray[indexPath.row]
       
        if item == NSLocalizedString("TERMS AND CONDITIONS", comment: "") {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.termsClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/terms/?header=false"
            vc.titleWeb = NSLocalizedString("Terms & Conditions", comment: "")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
            
        else if item == NSLocalizedString("PRIVACY POLICY", comment: "") {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.policyClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/privacy/?header=false"
            vc.titleWeb = NSLocalizedString("Privacy Policy", comment: "")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}
