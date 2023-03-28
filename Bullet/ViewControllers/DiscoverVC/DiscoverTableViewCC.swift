//
//  DiscoverTableViewCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 07/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol DiscoverTableViewDelegate: class {
    
    func updateDiscoverList()
    func didTapTopicAndSouces(discoverInfo: discoverData)
}

class DiscoverTableViewCC: UITableViewCell {

    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: DiscoverTableViewDelegate?
    var discoverList: [discoverData]?
    var isSmallView = false
    var typeArray: [String]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.theme_textColor = GlobalPicker.textColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension DiscoverTableViewCC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return discoverList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let discover = discoverList?[indexPath.row]
        if self.isSmallView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverListCC", for: indexPath) as! DiscoverCC
            cell.viewTopicShadow.theme_backgroundColor = GlobalPicker.cellBGColor
            cell.lblTopic.theme_textColor = GlobalPicker.textColor
            cell.viewTopicShadow.addRoundedShadowWithColor(color: MyThemes.current == .dark ? UIColor.clear : UIColor(red: 58.0/255.0, green: 217.0/255.0, blue: 210.0/255.0, alpha: 0.50))
            cell.viewTopicShadow.cornerRadious = 8
            cell.viewTopicShadow.clipsToBounds = true
            
            cell.imgTopic.sd_setImage(with: URL(string: discover?.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            cell.lblTopic.text = discover?.name ?? ""
            if discover?.favorite ?? false {

                cell.imgTopicState.theme_image = GlobalPicker.imgBookmarkSelected//UIImage(named: "bookmarkSelected")
            }
            else {

                cell.imgTopicState.theme_image = GlobalPicker.imgBookmark //UIImage(named: "bookmark")
            }
            
            cell.btnSelectTopic.tag = indexPath.row
            cell.btnSelectTopic.addTarget(self, action: #selector(didTapAddRemoveDiscover), for: .touchUpInside)
            
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCC", for: indexPath) as! DiscoverCC
            cell.viewShadow.theme_backgroundColor = GlobalPicker.cellBGColor
            cell.lblTitle.theme_textColor = GlobalPicker.textColor
            cell.viewShadow.addRoundedShadowWithColor(color: MyThemes.current == .dark ? UIColor.clear : UIColor(red: 58.0/255.0, green: 217.0/255.0, blue: 210.0/255.0, alpha: 0.50))
            
            cell.imgSource.sd_setImage(with: URL(string: discover?.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            cell.imgSource.cornerRadious = cell.imgSource.frame.size.width / 2
            cell.imgSource.clipsToBounds = true
            cell.lblTitle.text = discover?.name ?? ""
            
            if discover?.favorite ?? false {

                cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmarkSelected//UIImage(named: "bookmarkSelected")
            }
            else {

                cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmark //UIImage(named: "bookmark")
            }
            
            cell.btnSelectSource.tag = indexPath.row
            cell.btnSelectSource.addTarget(self, action: #selector(didTapAddRemoveDiscover), for: .touchUpInside)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let discover = discoverList?[indexPath.row]{
            
            self.delegate?.didTapTopicAndSouces(discoverInfo: discover)
        }
    }
    
    @objc func didTapAddRemoveDiscover(sender: UIButton) {
        
        let row = sender.tag
        let discover = discoverList?[row]
        if discover?.local_type?.lowercased() == "topic" {
            
            if discover?.favorite ?? false {
                
                self.performTabUserTopicUnfollow(discover?.id ?? "")
            }
            else {
                
                self.performWSToUserFollowTopics(discover?.id ?? "")
            }
        }
        else {
            
            if discover?.favorite ?? false {
                
                self.performUnFollowUserSource(discover?.id ?? "")
            }
            else {
                
                self.performWSToFollowSources(id: discover?.id ?? "")
            }
        }
    }
}

extension DiscoverTableViewCC : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.isSmallView {
            
            let discover = discoverList?[indexPath.row]
          //  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverListCC", for: indexPath) as! DiscoverCC
            let label = UILabel(frame: CGRect.zero)
            label.font = Constant.font_unSelectedTitle
            label.text = discover?.name ?? ""
            label.sizeToFit()
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            print("local Width: ", label.frame.width + 90)
            return CGSize(width: label.frame.width + 90, height: 43)
            
//            cell.lblTopic.text = discover?.name ?? ""
//            var lblWidth = cell.textlabel.intrinsicContentSize.width
//            lblWidth = lblWidth + 90
//            return CGSize(width: 150, height: 43)
        }
        else {
            
            return CGSize(width: (collectionView.frame.width / 2) - 20, height: (collectionView.frame.width / 2 - 20))
        }
    }
}

// MARK: - WebServices
extension DiscoverTableViewCC {
    
    func performWSToUserFollowTopics(_ id: String, searchSource: searchSourceData = searchSourceData(), indexPath: IndexPath = IndexPath(row: 0, section: 0)) {
    
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics": "\(id)"]
       
        WebService.URLResponse("news/topics/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
        
            do{
                let FULLResponse = try
                    JSONDecoder().decode(AddTopicDC.self, from: response)
                
                if (FULLResponse.topics?.first) != nil {
                    
                    self.delegate?.updateDiscoverList()
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
   
            print("error parsing json objects",error)
        }
    }
    
    func performTabUserTopicUnfollow(_ id: String) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics": "\(id)"]
     
        WebService.URLResponse("news/topics/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in

            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteTopicDC.self, from: response)
                
                if let status = FULLResponse.message {
             
                    if status.uppercased() == Constant.STATUS_SUCCESS {
                        
                        self.delegate?.updateDiscoverList()
                    }
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
    
    func performWSToFollowSources(id: String) {

        let params = ["sources": "\(id)"]

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
          
            do{
                let FULLResponse = try
                    JSONDecoder().decode(AddSourceDC.self, from: response)
                
                if let _ = FULLResponse.sources {
                    
                    self.delegate?.updateDiscoverList()
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performUnFollowUserSource(_ id: String) {
    
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
   
        WebService.URLResponse("news/sources/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        self.delegate?.updateDiscoverList()
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
}
