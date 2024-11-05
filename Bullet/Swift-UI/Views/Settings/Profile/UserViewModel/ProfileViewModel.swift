//
//  ProfileViewModel.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/21/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewModel: ObservableObject {
    func deleteAccount() {

        URLSessionProvider.shared.request(service: UserService.deleteAccount) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("ERROR || Failed to delete account \(error.localizedDescription)")
                case .success(let response):
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logout()
                }
            }
        }
    }
    
}
