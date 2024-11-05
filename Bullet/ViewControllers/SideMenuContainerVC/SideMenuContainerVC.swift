//
//  SideMenuContainerVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class SideMenuContainerVC: UIViewController {

    @IBOutlet weak var reelsContainerView: UIView!

    var pageVC: SlideMenuPageVC?
    var channel: ChannelInfo?
    var currentlyOpenedChannedID = ""
    var currentlyOpenedAuthorID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageVC?.slideMenuDelegate = self
        // Do any additional setup after loading the view.
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SlideMenuPageVC {
            self.pageVC = vc
        }
    }
    
    
    
    func showAuthorProfile(author: [Authors]) {
        currentlyOpenedAuthorID = author.first?.id ?? ""
        self.pageVC?.showAuthorVC(authors: author)
        
    }
    
    
    func showChannelDetails(source: ChannelInfo) {
        currentlyOpenedChannedID = source.id ?? ""
        self.pageVC?.showChannelDetailsVC(source: source, channelInfo: nil)
    }
    
    
    
}

extension SideMenuContainerVC: SlideMenuPageDelegate {
    func didDismiss(channel: ChannelInfo?) {
        self.channel = channel
        print(self.channel)
    }
}
