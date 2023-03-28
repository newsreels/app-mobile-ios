
//
//  blockListVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 05/07/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme

class blockListVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewSources: UIView!
    @IBOutlet weak var clvChannel: UICollectionView!
    @IBOutlet weak var lblNoData: UILabel!

    var sourcesArray = [ChannelInfo]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //PAGINATION VARIABLES
    var isTopicsList = true
    var name : String? = "CodingBull"
    var nextPageData = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        clvChannel.register(UINib(nibName: "AuthorsFollowingCell", bundle: nil), forCellWithReuseIdentifier: "AuthorsFollowingCell")
        
        setupLocalization()

        lblTitle.theme_textColor = GlobalPicker.textColor
        lblNoData.theme_textColor = GlobalPicker.textColor
//        imgBack.theme_image = GlobalPicker.imgBack

        self.view.backgroundColor = .white
//        view.theme_backgroundColor = GlobalPicker.backgroundColor

        nextPageData = ""
        
        //Sources
        viewSources.isHidden = false
        performWSToGetBlockedSources(pageString: "")
        
        
    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("Block List", comment: "")
        lblNoData.text = NSLocalizedString("You haven't blocked anything yet", comment: "")
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
       
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    

}

//MARK:- Webservice
extension blockListVC {
    
    func performWSToGetBlockedSources(pageString: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let param = ["page": pageString]

        if pageString == "" {
            self.sourcesArray.removeAll()
        }
        
        self.showLoaderInVC()
      
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/blocked", method: .get, parameters: param, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let sources = FULLResponse.sources {
          
                    self.lblNoData.isHidden = sources.count == 0 ? false : true
                    self.sourcesArray.removeAll()
                    self.sourcesArray += sources
                    
                    
                    for (indexV,obj) in self.sourcesArray.enumerated() {
                        self.sourcesArray[indexV].isUserBlocked = true
                    }
                    self.clvChannel.reloadData()
                }
                
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }

            } catch let jsonerror {
                
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/blocked", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
        
    }
    
}

extension blockListVC {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let selectedThemeType = UserDefaults.standard.bool(forKey: Constant.UD_isLocalTheme)
        
        if selectedThemeType == false {
            
            if #available(iOS 13.0, *) {
                if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                    if traitCollection.userInterfaceStyle == .dark {
                        
                        //Dark
                        MyThemes.switchTo(theme: .dark)
                    }
                    else {
                        //Light
                        MyThemes.switchTo(theme: .light)
                    }
                    
                }
            }
            MyThemes.saveLastTheme()
        }
    }
}

//MARK: - CollectionView delegates and data sources
extension blockListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return sourcesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorsFollowingCell", for: indexPath) as! AuthorsFollowingCell
        
        let channel = sourcesArray[indexPath.row]
        cell.setupCellForBlockList(model: channel)
        cell.delegate = self
        
        cell.layoutIfNeeded()
        return cell
    }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: (collectionView.frame.size.width - 55)/3, height: 200)
        //CGSize(width: (collectionView.frame.size.width / 2), height: (collectionView.frame.size.width / 2) + 20)
    }
            
//    //VERTICAL
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 10 }
//
//    //HORIZONTAL
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 10 }
    
}


extension blockListVC: AuthorsFollowingCellDelegate {
    
    
    func didTapFollow(cell: AuthorsFollowingCell) {
        // not working properly
        guard let rowIndexPath = clvChannel.indexPath(for: cell) else { return }
        self.sourcesArray[rowIndexPath.item].isShowingLoader = true
        self.clvChannel.reloadItems(at: [rowIndexPath])
        
        let blockStatus = !(sourcesArray[rowIndexPath.item].isUserBlocked ?? false)
        SharedManager.shared.performWSToUpdateUserBlock(id: [sourcesArray[rowIndexPath.item].id ?? ""], isBlock: blockStatus, type: .sources) { status in
            self.sourcesArray[rowIndexPath.item].isShowingLoader = false
            if status {
                self.sourcesArray[rowIndexPath.item].isUserBlocked = blockStatus
            }
            self.clvChannel.reloadItems(at: [rowIndexPath])
            
            if blockStatus == false {
                self.sourcesArray.remove(at: rowIndexPath.item)
                self.clvChannel.reloadData()
            }
        }
    }
    
}
