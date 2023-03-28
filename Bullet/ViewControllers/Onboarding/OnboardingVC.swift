//
//  OnboardingVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 17/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class OnboardingVC: UIViewController, OnboardingLanguageVCDelegate, OnboardingRegionnsVCDelegate, userTopicVCDelegate {
    
    
    //CollectionViews outlets 
//    @IBOutlet weak var collectionViewLanguage: UICollectionView!
//    @IBOutlet weak var collectionViewLanguage1: UICollectionView!
    @IBOutlet weak var collectionViewRegion: UICollectionView!
    @IBOutlet weak var collectionViewRegion1: UICollectionView!
    @IBOutlet weak var collectionViewTopics: UICollectionView!
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    
    
 //   @IBOutlet weak var lblNewsContent: UILabel!
    @IBOutlet weak var lblSelectRegion: UILabel!
    @IBOutlet weak var lblFollowTopic: UILabel!
    
    
    var topicsArr : [TopicData]?
    var locationsMainArr : [Location]?
    var locationsArr : [Location]?
    var locationsArr1 : [Location]?
    var languagesMainArr : [languagesData]?
    var languagesArr : [languagesData]?
    var languagesArr1 : [languagesData]?
    
    var selectedTopicsArr = [String]()
    var selectedLocationsArr = [String]()
    var selectedLanguagesArr = [String]()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedManager.shared.setSelectedReelsCategory(category: .foryou)
        SharedManager.shared.performWSToGetReelsData { status in
            print(status)
        }
        
        btnContinue.backgroundColor = "707070".hexStringToUIColor()
        registerCell()
        performWSToGetOnboarding()
        
        if SharedManager.shared.isFromTabbarVC {
    
            self.btnBack.isHidden = true
            self.imgBack.isHidden = true
            
        }
        
        setLocalizations()
    }
    
    
    func setLocalizations() {
        
     //   lblNewsContent.text = NSLocalizedString("News Content Language", comment: "")
        lblSelectRegion.text = NSLocalizedString("Select Regions/Places", comment: "")
        
        lblFollowTopic.text = NSLocalizedString("Follow at least 3 topics", comment: "")
    }
    
    
    func registerCell() {
        
//        collectionViewLanguage.register(UINib(nibName: "OnboardingLanguageCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingLanguageCC")
//        collectionViewLanguage1.register(UINib(nibName: "OnboardingLanguageCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingLanguageCC")
        collectionViewRegion.register(UINib(nibName: "RegionsCC", bundle: nil), forCellWithReuseIdentifier: "RegionsCC")
        collectionViewRegion1.register(UINib(nibName: "RegionsCC", bundle: nil), forCellWithReuseIdentifier: "RegionsCC")
        collectionViewTopics.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")
    }
    
    //MARK:-Buttons action
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSearchActions(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Language Button
            let vc = OnboardingLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
            vc.selectedLanguagesArr = self.selectedLanguagesArr
            if let languagesMainArray = self.languagesMainArr, languagesMainArray.count > 0 {
                vc.updatedLanguagesArr = languagesMainArray
            }
            vc.delegate = self
          //  vc.isFromProfileVC = true
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
        else if sender.tag == 1 {
            
            //Regions/Places Button
            let vc = OnboardingRegionnsVC.instantiate(fromAppStoryboard: .Onboarding)
            vc.selectedRegionsArr = self.selectedLocationsArr
            if let locationsMainArray = self.locationsMainArr, locationsMainArray.count > 0 {
                vc.updatedlocationsArr = locationsMainArray
            }
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
        else {
            
            //Topics Button
            let vc = userTopicVC.instantiate(fromAppStoryboard: .registration)
            vc.selectedTopicsArr = self.selectedTopicsArr
            if let topicsArray = self.topicsArr, topicsArray.count > 0 {
                vc.updatedTopicsArr = topicsArray
            }
            vc.isFromOnboarding  = true
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        // Load default theme settings
        if self.selectedTopicsArr.count >= 3 {
            
            self.performWSToUpdateUserOnboarding()
        }
        else {
            
            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString("Newsresls", comment: ""), message: NSLocalizedString("Please Follow at least 3 topics", comment: ""))
        }
    }
    
    
    //MARK: -Delegates
    func setLanguagezForAppContent(languages: [languagesData], langName: [String]) {
        
        self.languagesMainArr = languages
        
        let languages = languages.devided()
        self.languagesArr = languages.0
        self.languagesArr1 = languages.1
        
        self.selectedLanguagesArr = langName
//        self.collectionViewLanguage.reloadData()
//        self.collectionViewLanguage1.reloadData()
    }
    
    func setLocationsForAppContent(locations: [Location], locationName: [String]) {
        
        self.locationsMainArr = locations
        
        let locations = locations.devided()
        self.locationsArr = locations.0
        self.locationsArr1 = locations.1
        
        self.selectedLocationsArr = locationName
        self.collectionViewRegion.reloadData()
        self.collectionViewRegion1.reloadData()
        
    }
    
    func setTopicsForAppContent(Topics: [TopicData], TopicsName: [String]) {
        
        self.topicsArr = Topics
        self.selectedTopicsArr = TopicsName
        self.collectionViewTopics.reloadData()
    }
}

//MARK: - CollectionView Delegates and dataSources
extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        if collectionView == collectionViewLanguage {
//
//            //Language CollectionView
//            return self.languagesArr?.count ?? 0
//
//        }
//        else if collectionView == collectionViewLanguage1 {
//
//            //Language CollectionView
//            return self.languagesArr1?.count ?? 0
//
//        }
//        else
        if collectionView == collectionViewRegion {
            
            //Region CollectionView
            return self.locationsArr?.count ?? 0
        }
        else if collectionView == collectionViewRegion1 {
            
            //Region CollectionView
            return self.locationsArr1?.count ?? 0
        }
        else {
            
            //Topics CollectionView
            return self.topicsArr?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        if collectionView == collectionViewLanguage {
//
//            //Language CollectionView
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingLanguageCC", for: indexPath) as! OnboardingLanguageCC
//
//            if let languages = self.languagesArr?[indexPath.row] {
//
//                let isFav = self.selectedLanguagesArr.contains(languages.id ?? "")
//                cell.setupLanguageCell(language: languages, isFave: isFav ? true : false)
//            }
//            return cell
//        }
//        else if collectionView == collectionViewLanguage1 {
            
            //Language CollectionView
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingLanguageCC", for: indexPath) as! OnboardingLanguageCC
//
//            if let languages = self.languagesArr1?[indexPath.row] {
//
//                let isFav = self.selectedLanguagesArr.contains(languages.id ?? "")
//                cell.setupLanguageCell(language: languages, isFave: isFav ? true : false)
//            }
//            return cell
//        }
//        else
    if collectionView == collectionViewRegion {
            
            //Regions CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionsCC", for: indexPath) as! RegionsCC
            
            if let locations = self.locationsArr?[indexPath.row] {
                
                let isFav = self.selectedLocationsArr.contains(locations.id ?? "")
                cell.lblRegion.text = locations.name?.capitalized ?? ""
                cell.imgFav.image = isFav ? UIImage(named: "tickUnselected") : UIImage(named: "plus")
                
                cell.viewBG.cornerRadius = 24
                cell.lblRegion.textColor = .white
                cell.viewBG.borderWidth = 1.0
                cell.viewBG.borderColor = .customViewGreyColor
                
                
            //    cell.setupRegionnCell(region: locations,isFav: isFav ? true : false)
                
             //   cell.layoutIfNeeded()
            }

            return cell
        }
        else if collectionView == collectionViewRegion1 {
            
            //Regions CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionsCC", for: indexPath) as! RegionsCC
            
            if let locations = self.locationsArr1?[indexPath.row] {
           
                let isFav = self.selectedLocationsArr.contains(locations.id ?? "")
                cell.lblRegion.text = locations.name?.capitalized ?? ""
                cell.imgFav.image = isFav ? UIImage(named: "tickUnselected") : UIImage(named: "plus")
                
                cell.viewBG.cornerRadius = 24
                cell.lblRegion.textColor = .white
                cell.viewBG.borderWidth = 1.0
                cell.viewBG.borderColor = .customViewGreyColor
            }

            return cell
        }
        else {
            
            //Topics CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
            
           
            if let topic = self.topicsArr?[indexPath.row] {
                
                let isFav = self.selectedTopicsArr.contains(topic.id ?? "")
                cell.setupTopicCell(topic: topic, isFavorite: isFav ? true : false)
                
            }
            cell.btnFav.isHidden = true
            self.updateContinueButton()
            return cell
        }
    }
    
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        if collectionView == collectionViewLanguage {
//
//            //Language CollectionView
//            if let languageName = self.languagesArr?[indexPath.row].name {
//
//                let itemSize = languageName.size(withAttributes: [
//
//                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "ENGLISH (US)"
//                ])
//                if itemSize.width < 70 {
//
//                    if let languageSample = self.languagesArr?[indexPath.row].sample {
//
//                        let languageSampleSize = languageSample.size(withAttributes: [
//
//                            NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_REGULAR, size: 10) ?? "ENGLISH (US)"
//                        ])
//                        if languageSampleSize.width > itemSize.width {
//
//                            return CGSize(width: 80 + 92, height: 63)
//                        }
//                        else {
//
//                            return CGSize(width: 70 + 92, height: 63)
//                        }
//                    }
//                }
//                else {
//
//                    return CGSize(width: itemSize.width + 92, height: 63)
//                }
//            }
//        }
//        else if collectionView == collectionViewLanguage1 {
//
//            //Language CollectionView
//            if let languageName = self.languagesArr1?[indexPath.row].name {
//
//                let itemSize = languageName.size(withAttributes: [
//
//                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "ENGLISH (US)"
//                ])
//                if itemSize.width < 70 {
//
//                    if let languageSample = self.languagesArr1?[indexPath.row].sample {
//
//                        let languageSampleSize = languageSample.size(withAttributes: [
//
//                            NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_REGULAR, size: 10) ?? "ENGLISH (US)"
//                        ])
//                        if languageSampleSize.width > itemSize.width {
//
//                            return CGSize(width: 80 + 92, height: 63)
//                        }
//                        else {
//
//                            return CGSize(width: 70 + 92, height: 63)
//                        }
//                    }
//                }
//                else {
//
//                    return CGSize(width: itemSize.width + 92, height: 63)
//                }
//            }
//        }
//        else
        if collectionView == collectionViewRegion {
            
            //Region CollectionView
            if let locationName = self.locationsArr?[indexPath.row].name {
                
                let itemSize = locationName.size(withAttributes: [
                    
                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "CALIFORNIA"
                ])
                return CGSize(width: itemSize.width + 80, height: 60)
            }
        }
        else if collectionView == collectionViewRegion1 {
            
            //Region CollectionView
            if let locationName = self.locationsArr1?[indexPath.row].name {
                
                let itemSize = locationName.size(withAttributes: [
                    
                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "CALIFORNIA"
                ])
                return CGSize(width: itemSize.width + 80, height: 60)
            }
        }
        else {
            
            //Topics CollectionView
            return CGSize(width: 245 , height: 116)

        }
        //Defualt case. never executed
        return CGSize(width: 200, height: 96)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if collectionView == collectionViewLanguage {
//
//            let cell = collectionViewLanguage.cellForItem(at: indexPath) as? OnboardingLanguageCC
//
//            if let language = self.languagesArr?[indexPath.row] {
//
//                if self.selectedLanguagesArr.contains(language.id ?? "") {
//
//
//                    self.selectedLanguagesArr.remove(object: language.id ?? "")
//                    cell?.imgFav.image = UIImage(named: "plus")
//                }
//                else {
//
//                    self.selectedLanguagesArr.append(language.id ?? "")
//                    cell?.imgFav.image = UIImage(named: "tickUnselected")
//                }
//            }
//        }
//        else if collectionView == collectionViewLanguage1 {
//
//            let cell = collectionViewLanguage1.cellForItem(at: indexPath) as? OnboardingLanguageCC
//
//            if let language = self.languagesArr1?[indexPath.row] {
//
//                if self.selectedLanguagesArr.contains(language.id ?? "") {
//
//
//                    self.selectedLanguagesArr.remove(object: language.id ?? "")
//                    cell?.imgFav.image = UIImage(named: "plus")
//                }
//                else {
//
//                    self.selectedLanguagesArr.append(language.id ?? "")
//                    cell?.imgFav.image = UIImage(named: "tickUnselected")
//                }
//            }
//        }
//        else
        if collectionView == collectionViewRegion {
            
            let cell = collectionViewRegion.cellForItem(at: indexPath) as? RegionsCC
            
            if let language = self.locationsArr?[indexPath.row] {
               
                if self.selectedLocationsArr.contains(language.id ?? "") {
            
                    
                    self.selectedLocationsArr.remove(object: language.id ?? "")
                    cell?.imgFav.image = UIImage(named: "plus")
                }
                else {
                    
                    self.selectedLocationsArr.append(language.id ?? "")
                    cell?.imgFav.image = UIImage(named: "tickUnselected")
                }
            }
        }
        else if collectionView == collectionViewRegion1 {
         
            let cell = collectionViewRegion1.cellForItem(at: indexPath) as? RegionsCC
            
            if let language = self.locationsArr1?[indexPath.row] {
               
                if self.selectedLocationsArr.contains(language.id ?? "") {
            
                    
                    self.selectedLocationsArr.remove(object: language.id ?? "")
                    cell?.imgFav.image = UIImage(named: "plus")
                }
                else {
                    
                    self.selectedLocationsArr.append(language.id ?? "")
                    cell?.imgFav.image = UIImage(named: "tickUnselected")
                }
            }
        }
        else {
            
            let cell = collectionViewTopics.cellForItem(at: indexPath) as? OnboardingTopicsCC
            if let language = self.topicsArr?[indexPath.row] {
               
                if self.selectedTopicsArr.contains(language.id ?? "") {
            
                    
                    self.selectedTopicsArr.remove(object: language.id ?? "")
                    cell?.imgFav.image = UIImage(named: "plus")
                }
                else {
                    
                    self.selectedTopicsArr.append(language.id ?? "")
                    cell?.imgFav.image = UIImage(named: "tickUnselected")
                }
            }
            
            self.updateContinueButton()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collectionViewRegion {
            collectionViewRegion1.contentOffset = collectionViewRegion.contentOffset
        }
        else if scrollView == collectionViewRegion1 {
        
            collectionViewRegion.contentOffset = collectionViewRegion1.contentOffset
        }
        
//        else if scrollView == collectionViewLanguage {
//            collectionViewLanguage1.contentOffset = collectionViewLanguage.contentOffset
//        }
//        else if scrollView == collectionViewLanguage1 {
//
//            collectionViewLanguage.contentOffset = collectionViewLanguage1.contentOffset
//        }
    }
    
    //Language favourite button Action
    @objc func didTapLanguageFavButton(sender: UIButton) {
        
//        if let cell = collectionViewLanguage.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? FollowingChannelCC {
//
//            cell.isUserInteractionEnabled = false
//        }
    }
    
    func updateContinueButton() {
        
        if self.selectedTopicsArr.count >= 3 {
           
            self.btnContinue.backgroundColor = "#E01335".hexStringToUIColor()
        }
        else{
            
            self.btnContinue.backgroundColor = "707070".hexStringToUIColor()
        }
    }
}

//MARK: - Channels Webservices
extension OnboardingVC {
    
    //Followrd Channels
    func performWSToGetOnboarding() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/onboarding", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(OnboardingDC.self, from: response)
                
                if let topics = FULLResponse.topics {
                    
                    self.topicsArr = topics
                    for topic in topics {
                        
                        if topic.favorite == true {
                            
                            self.selectedTopicsArr.append(topic.id ?? "")
                        }
                    }
                    self.collectionViewTopics.reloadData()
                }
                if let languages = FULLResponse.languages {
                    
                    self.languagesMainArr = languages
                    
                    for languge in languages {
                        
                        if languge.favorite == true {
                            
                            self.selectedLanguagesArr.append(languge.id ?? "")
                        }
                    }
                
                    let languages = languages.devided()
                    
                    self.languagesArr = languages.0
                    self.languagesArr1 = languages.1
                    
//                    self.collectionViewLanguage.reloadData()
//                    self.collectionViewLanguage1.reloadData()
                }
                if let locations = FULLResponse.locations {
                    
                    self.locationsMainArr = locations
               
                    for location in locations {
                        
                        if location.favorite == true {
                            
                            self.selectedLocationsArr.append(location.id ?? "")
                        }
                    }
                    
                    let locations = locations.devided()
                    
                    self.locationsArr = locations.0
                    self.locationsArr1 = locations.1
                    
                    self.collectionViewRegion.reloadData()
                    self.collectionViewRegion1.reloadData()
                }
                
                ANLoader.hide()
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateUserOnboarding() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["topics":self.selectedTopicsArr, "regions":self.selectedLocationsArr, "languages": [SharedManager.shared.languageId]]
        
      
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        print("PARAMS = \(params)")
        
        WebService.URLResponseJSONRequest("news/onboarding", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                
                SharedManager.shared.setThemeAutomatic()
                self.appDelegate.setHomeVC()
                if let status = FULLResponse.message?.uppercased() {
                    
                    print("read status", status)
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            print("error parsing json objects",error)
        }

    }
}
