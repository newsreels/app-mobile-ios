//
//  SelectTopicsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 10/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
//import CoreLocation
protocol SelectTopicsVCDelegate: AnyObject {
    
    func didTapClose()
}

class SelectTopicsVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
//    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var closeButton: UIButton!
//    @IBOutlet weak var saveButton: UIButton!
    
//    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    var topicsArray = [TopicData]()
    var locationsArray = [Location]()
    weak var delegate: SelectTopicsVCDelegate?
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

//    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        registerCell()
        setLocalization()
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.topicsArray.removeAll()
            self.locationsArray.removeAll()
            self.performWSToGetOnboarding()
        }
        
        self.navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        saveButton.layer.cornerRadius = 15
    }
    
    
    // MARK: - Methods
    func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setSaveButton()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        view.backgroundColor = UIColor(displayP3Red: 252.0/255, green: 252.0/255, blue: 252.0/255, alpha: 1)
        
    }
    
    func registerCell() {
        
        tableView.register(UINib(nibName: "HomeCategoriesCC", bundle: nil), forCellReuseIdentifier: "HomeCategoriesCC")
        
        
    }
    
    
    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Pick 3 topics and start following reels and articles", comment: "")
        descLabel.text = NSLocalizedString("Discover curated content from you fav places", comment: "")
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        
    }
    
    func openSelectLocations() {
        let vc = SelectRegionsVC.instantiate(fromAppStoryboard: .RegistrationSB)
        vc.topicsArray = topicsArray.filter({ $0.favorite == true })
        vc.locationsArray = locationsArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setSaveButton() {
        
        let selectedTopicsArray = topicsArray.filter( { $0.favorite == true } )
        if selectedTopicsArray.count >= 3 {
            saveButton.backgroundColor = Constant.appColor.lightRed
            saveButton.setTitleColor( .white, for: .normal)
        }
        else {
            saveButton.backgroundColor = Constant.appColor.buttonLightGaryText
            saveButton.setTitleColor(UIColor.white, for: .normal)
            
        }
    }
    
    // MARK: - Actions

    @IBAction func didTapSave(_ sender: Any) {
        
        let selectedTopicsArray = topicsArray.filter( { $0.favorite == true } )
        if selectedTopicsArray.count >= 3 {
            /*
            let status = CLLocationManager.authorizationStatus()
            if status == .notDetermined {
                
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                locationManager.delegate = self
            } else {
                openSelectLocations()
            }
            */
//            openSelectLocations()
            performWSToUpdateUserOnboarding()
            
        }
        else {
            // need atleast 3 topics
            
            SharedManager.shared.showAlertLoader(message: "Please select atleast 3 topics", type: .error)
        }
    }
    
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true)
        
        self.delegate?.didTapClose()
    }

    
    
}


extension SelectTopicsVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        self.delegate?.didTapClose()
    }
}

/*
extension SelectTopicsVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            openSelectLocations()
        }
    }
}*/

extension SelectTopicsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if topicsArray.count > 0 {
//            self.loaderView.isHidden = true
//            return 4
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let emptyCell = UITableViewCell()
        emptyCell.selectionStyle = .none
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCategoriesCC") as! HomeCategoriesCC
        
        cell.setupCell(listArray: topicsArray)
        
        
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}

extension SelectTopicsVC {
    
    //Followrd Channels
    func performWSToGetOnboarding() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/onboarding", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(OnboardingDC.self, from: response)
                
                if let topics = FULLResponse.topics {
                    
                    self.topicsArray = topics
                    
                    self.tableView.reloadData()
                }
                // Get locations data for next page
                if let locations = FULLResponse.locations {
                    
                    self.locationsArray = locations
                }
                
                self.setSaveButton()
                self.hideLoaderVC()
            } catch let jsonerror {
                
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
}


extension SelectTopicsVC {
    
    func performWSToUpdateUserOnboarding() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        var selectedTopicsArray = [String]()
        for topic in self.topicsArray.filter({ $0.favorite == true }) {
            selectedTopicsArray.append(topic.id ?? "")
        }
        
        
        let params = ["topics":selectedTopicsArray, "languages": [SharedManager.shared.languageId]]
        print("PARAMS = \(params)")
      
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
    
        self.view.isUserInteractionEnabled = false
        self.saveButton.showLoader()
        
        WebService.URLResponseJSONRequest("news/onboarding", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            self.saveButton.hideLoaderView()
            self.view.isUserInteractionEnabled = true
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                SharedManager.shared.isOnboardingPreferenceLoaded = true
                SharedManager.shared.isSavedPreferenceAlertRequired = true
                SharedManager.shared.setThemeAutomatic()
                self.appDelegate?.setHomeVC()
                if let status = FULLResponse.message?.uppercased() {
                    
                    print("read status", status)
                }
                
            } catch let jsonerror {
                self.view.isUserInteractionEnabled = true
                self.saveButton.hideLoaderView()
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            self.view.isUserInteractionEnabled = true
            self.saveButton.hideLoaderView()
            print("error parsing json objects",error)
        }

    }
}

extension SelectTopicsVC: HomeCategoriesCCDelegate {
    
    func didSelectedCell(cell: HomeCategoriesCC, itemIndex: Int, isOpenForReels: Bool) {
        
        if topicsArray[itemIndex].favorite == false {
            topicsArray[itemIndex].favorite = true
        }
        else {
            topicsArray[itemIndex].favorite = false
        }
        tableView.reloadData()
        
        setSaveButton()
        
    }
}
