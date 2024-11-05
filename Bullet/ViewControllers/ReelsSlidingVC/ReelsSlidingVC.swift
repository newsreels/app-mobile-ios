//
//  ReelsSlidingVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 07/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ReelsSlidingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let controller = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
//        controller.modalPresentationStyle = .overFullScreen
//        self.present(controller, animated: true, completion: nil)
                
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let controller = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
