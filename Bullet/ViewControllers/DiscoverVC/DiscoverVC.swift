//
//  DiscoverVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 07/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class DiscoverVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var discoverList: [Discover]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self .performWSToDiscoverList()
    }
}

// MARK:- UITableView Delegates and DataSource
extension DiscoverVC: UITableViewDelegate,UITableViewDataSource, DiscoverTableViewDelegate {
   
    func updateDiscoverList() {
        
        self .performWSToDiscoverList()
    }
    
    func didTapTopicAndSouces(discoverInfo: discoverData) {
  
        if discoverInfo.local_type == "topic" {
            
            SharedManager.shared.isShowTopic = true
            SharedManager.shared.isShowSource = false
            self.performTabSubTopic(discoverInfo)
        }
        else {
           
            SharedManager.shared.isShowTopic = false
            SharedManager.shared.isShowSource = true
            self.performTabSubSource(discoverInfo)
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return self.discoverList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTableViewCC") as! DiscoverTableViewCC
        let discover = self.discoverList?[indexPath.section]
        cell.lblTitle.text = discover?.title ?? ""
        cell.discoverList = discover?.data
        cell.typeArray?.append(discover?.type ?? "")
        
        cell.isSmallView = false
        if discover?.view?.lowercased() == "small" {
            
            cell.isSmallView = true
        }
        cell.delegate = self
        cell.collectionView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let discover = self.discoverList?[indexPath.section]
        
        if discover?.view?.lowercased() == "small" {
            
            return 86 + 65
        }
        else {
            
            return self.view.frame.size.width + 25
//            return self.view.frame.size.width + 65
        }
    }
}

//MARK: - Webservices
extension DiscoverVC {
    
    func performWSToDiscoverList() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/discover", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DiscoverDC.self, from: response)
            
                if var discovers = FULLResponse.discover {
                
                    //self.discoverList = discovers
                    
                    var arrData: [discoverData]?
                    for (i, item) in discovers.enumerated() {
                        
                        let type = item.type ?? ""
                        arrData = [discoverData]()
                        if let dataArr = item.data {
                            for obj in dataArr {
                                let d = discoverData.init(id: obj.id, name: obj.name, icon: obj.icon, image: obj.image, color: obj.color, local_type: type, favorite: obj.favorite)
                                arrData?.append(d)
                            }
                        }
                        discovers[i].data = arrData
                    }
                    
                    self.discoverList = discovers
                    self.tableView.reloadData()
                    
                }
                ANLoader.hide()

            } catch let jsonerror {

                print("error parsing json objects",jsonerror)
            }
            ANLoader.hide()

        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performTabSubTopic(_ topic: discoverData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        let id = topic.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/topics/related/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(SubTopicDC.self, from: response)
                
                ANLoader.hide()
                DispatchQueue.main.async {
                                        
                    if var topics = FULLResponse.topics {
                        
                        if topics.count > 0 {
                            
                            topics.insert(TopicData(id: topic.id, name: topic.name, icon: topic.icon, image: topic.image, color: topic.color, favorite: topic.favorite), at: 0)
                        }
                        else {
                            topics.insert(TopicData(id: topic.id, name: "", icon: topic.icon, image: topic.image, color: topic.color, favorite: topic.favorite), at: 0)
                        }
                        
                        SharedManager.shared.subTopicsList = topics
                        let detailsVC = MainTopicSourceVC.instantiate(fromAppStoryboard: .Main)
                        detailsVC.selectedID = topic.id ?? ""
                        detailsVC.isFav = topic.favorite ?? false
                        self.navigationController?.pushViewController(detailsVC, animated: true)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performTabSubSource(_ source: discoverData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        let id = source.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/headlines/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(SubSourcesDC.self, from: response)
                
                DispatchQueue.main.async {
                                        
                    if var sources = FULLResponse.headlines {
                        
                        SharedManager.shared.subSourcesTitle = source.name ?? ""
                        if sources.count > 0 {
                            let all = sourcesData(id: source.id, name: source.name, link: source.icon, image: source.image, favorite: source.favorite)
                            sources.insert(all, at: 0)
                        }
                        else {
                            let all = sourcesData(id: source.id, name: source.name, link: source.icon, image: source.image, favorite: source.favorite)
                            sources.insert(all, at: 0)
                        }
                        SharedManager.shared.subSourcesList = sources
                        let detailsVC = MainTopicSourceVC.instantiate(fromAppStoryboard: .Main)
                        detailsVC.selectedID = source.id ?? ""
                        detailsVC.isFav = source.favorite ?? false
                        self.navigationController?.pushViewController(detailsVC, animated: true)

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
