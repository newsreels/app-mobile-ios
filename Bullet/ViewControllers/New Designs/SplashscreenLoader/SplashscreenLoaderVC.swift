//
//  SplashscreenLoaderVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 19/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Firebase

protocol SplashscreenLoaderVCDelegate: AnyObject {
    
    func dismissSplashscreenLoaderVC()
}

class SplashscreenLoaderVC: UIViewController {
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    weak var delegate: SplashscreenLoaderVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
}

extension SplashscreenLoaderVC {
    func checkUpdate() {
        /*fetchAppVerionFromFB { apiVersion in
            if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               self.compareVersions(currentVersion, apiVersion.version) == .orderedAscending {
                self.showForceUpdateAlert(isForced: apiVersion.force_update)
            } else {
                DispatchQueue.main.async {
                    self.delegate?.dismissSplashscreenLoaderVC()
                }
            }
        }*/
        DispatchQueue.main.async {
            self.delegate?.dismissSplashscreenLoaderVC()
        }
    }
    
    func showForceUpdateAlert(isForced: Bool) {
        let alertController = UIAlertController(title: "Update Available", message: isForced ? " There is a new version of Newsreels is available. please update for better performance." : "A new version of Newsreels is available. Would you like to update?", preferredStyle: .alert)
        let Update = UIAlertAction(title: "Update", style: .default) { _ in
            let appStoreURL = URL(string: "https://itunes.apple.com/app/id1540932937")
            UIApplication.shared.open(appStoreURL!, options: [:], completionHandler: nil)
            self.showForceUpdateAlert(isForced: isForced)
        }
        let Later = UIAlertAction(title: "Later", style: .default) { _ in
            self.delegate?.dismissSplashscreenLoaderVC()
        }
        alertController.addAction(Update)
        if !isForced {
            alertController.addAction(Later)
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func fetchAppVerionFromFB(complition: @escaping (_ apiVersion: RemoteVersion.IosVersion) -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                remoteConfig.activate { changed, error in
                    if let json = remoteConfig.configValue(forKey: "app_version").stringValue,
                       let apiVersion = self.parseVersion(json: json)?.ios {
                        complition(apiVersion)
                    } else if let json = remoteConfig.defaultValue(forKey: "app_version")?.stringValue,
                              let apiVersion = self.parseVersion(json: json)?.ios  {
                        complition(apiVersion)
                    } else {
                        self.delegate?.dismissSplashscreenLoaderVC()
                    }
                    
                }
            } else {
                if let json = remoteConfig.defaultValue(forKey: "app_version")?.jsonValue as? String,
                   let apiVersion = self.parseVersion(json: json)?.ios  {
                    complition(apiVersion)
                } else {
                    self.delegate?.dismissSplashscreenLoaderVC()
                }
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    func parseVersion(json: String) -> RemoteVersion? {
        let jsonData = json.data(using: .utf8)!
        do {
            let remoteVersion = try JSONDecoder().decode(RemoteVersion.self, from: jsonData)
            return remoteVersion
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let v1Components = version1.components(separatedBy: ".")
        let v2Components = version2.components(separatedBy: ".")
        for i in 0..<max(v1Components.count, v2Components.count) {
            let v1Value = i < v1Components.count ? Int(v1Components[i]) ?? 0 : 0
            let v2Value = i < v2Components.count ? Int(v2Components[i]) ?? 0 : 0
            if v1Value < v2Value {
                return .orderedAscending
            } else if v1Value > v2Value {
                return .orderedDescending
            }
        }
        return .orderedSame
    }
}
