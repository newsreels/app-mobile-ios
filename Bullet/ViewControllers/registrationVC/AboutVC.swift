//
//  AboutVC.swift
//  Bullet
//
//  Created by Mahesh on 30/07/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReadMore: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var imgAboutGIF: UIImageView!
//    @IBOutlet weak var imgBack: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        //lblDescription.addTextSpacing(spacing: 2.5)
        lblDescription.setLineSpacing(lineSpacing: 7)
        lblDescription.theme_textColor = GlobalPicker.textColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblVersion.theme_textColor = GlobalPicker.textColor
        lblReadMore.theme_textColor = GlobalPicker.textColor
//        imgBack.theme_image = GlobalPicker.imgBack

        lblVersion.text = " \(Bundle.main.releaseVersionNumber ?? "1.0")"
        
        self.imgAboutGIF.loadGif(name: "About Us GIF")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.imgAboutGIF.stopAnimating()
        self.imgAboutGIF.loadGif(name: "")
        self.imgAboutGIF.image = nil
    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("About", comment: "")
        lblReadMore.text = NSLocalizedString(ApplicationAlertMessages.kAppName, comment: "")
        lblTitle.text = NSLocalizedString("About", comment: "")
        lblDescription.text = NSLocalizedString("Keeping updated about the news stories you love should not take too much of your time. Newsreels takes the regular 5-minute read and condense it into easily digestible bullets. Now, you can take in the same news in just a fraction of the time – so you can read more in less time.", comment: "")
    }
    
    @IBAction func didTapBack() {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
