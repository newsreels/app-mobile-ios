//
//  AddLocationVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 22/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AddLocationVCDelegate: AnyObject {
    
    func locationListUpdated()
}

class AddLocationVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var searchContainerView: UIView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var navView: UIView!
    
    var locationsArray = [Location]()
    var suggestedLocationsArray = [Location]()
    var nextPaginate = ""
//    var selectedLocArray = [Location]()
    
    weak var delegate:  AddLocationVCDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerCell()
        setLocalization()
        setupUI()
        
        performWSToGetSuggestedLocations()
        
    }
    

    // MARK: - Methods
    
    func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchContainerView.layer.cornerRadius = 8

        searchContainerView.layer.borderWidth = 1

        searchContainerView.layer.borderColor = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
        
        searchTextField.textColor = .black
        searchTextField.placeholderColor = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        subTitleLabel.text = "Suggested locations"
        
    }
    
    func registerCell() {
        
        tableView.register(UINib(nibName: "AddLocationCC", bundle: nil), forCellReuseIdentifier: "AddLocationCC")
    }
    
    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Add Location", comment: "")
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        subTitleLabel.text = NSLocalizedString("Suggested locations", comment: "")
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.searchTextField {
            
            nextPaginate = ""
            SharedManager.shared.cancelAllCurrentAlamofireRequests()
            if textField.text == "" {
                subTitleLabel.text = "Suggested locations"
                locationsArray = suggestedLocationsArray
                self.tableView.reloadData()
            }
            else {
                subTitleLabel.text = ""
                self.performWSToSearchPlaces(textField.text ?? "")
            }
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    
    @IBAction func didTapSave(_ sender: Any) {
        
        SharedManager.shared.isTabReload = true
        performWSToUpdateUserOnboarding()
    }
    
    
}

extension AddLocationVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddLocationCC", for: indexPath) as! AddLocationCC
        cell.setupCellLocations(loc: locationsArray[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if searchTextField.text ?? "" != "" {
            if indexPath.row == locationsArray.count - 1, nextPaginate != "" {
                self.performWSToSearchPlaces(searchTextField.text ?? "")
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        locationsArray[indexPath.row].favorite = !(locationsArray[indexPath.row].favorite ?? false)
//        if let index = selectedLocArray.firstIndex(where: {$0.id == locationsArray[indexPath.row].id ?? ""}) {
//            selectedLocArray[index].favorite = locationsArray[indexPath.row].favorite
//        }
//        else {
//            selectedLocArray.append(locationsArray[indexPath.row])
//        }
        // unfollow location
        if locationsArray[indexPath.row].favorite == false {
            
            SharedManager.shared.performWSToUpdateUserFollow(id: [locationsArray[indexPath.row].id ?? ""], isFav: false, type: .locations) { status in
                
                if status {
                    print("status", status)
                } else {
                    print("status", status)
                }
            }
        }
        self.tableView.reloadData()
    }
    
}

extension AddLocationVC {
    
    func performWSToGetSuggestedLocations() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        self.showLoaderInVC()
        WebService.URLResponse("news/locations/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let suggested = FULLResponse.locations {
                    
                    self.suggestedLocationsArray = suggested
                    self.locationsArray = suggested
                }
                self.tableView.reloadData()
                
            } catch let jsonerror {
                
                self.hideLoaderVC()
                SharedManager.shared.logAPIError(url: "news/locations/suggested", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToSearchPlaces(_ searchText: String) {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let searchText = searchText.encodeUrl()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        searchButton.showLoader(color: Constant.appColor.lightRed, padding: 15)
//        searchImageView.isHidden = true
        WebService.URLResponse("news/locations?query=\(searchText)&page=\(nextPaginate)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
//            self.searchImageView.isHidden = false
            self.searchButton.hideLoaderView()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                self.locationsArray.removeAll()
                if let locs = FULLResponse.locations {
                    
                    self.locationsArray = locs
                }
       
                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
                // load current selections
//                if self.selectedLocArray.count > 0 {
//                    for (index,loc) in self.locationsArray.enumerated() {
//
//                        if let indexSelected = self.selectedLocArray.firstIndex(where: {$0.id == loc.id} ) {
//                            self.locationsArray[index].favorite = self.selectedLocArray[indexSelected].favorite ?? false
//                        }
//                    }
//                }
                
                self.tableView.reloadData()
  
            } catch let jsonerror {
//                self.searchImageView.isHidden = false
                self.searchButton.hideLoaderView()
                SharedManager.shared.logAPIError(url: "news/locations?query=\(searchText)&page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
//            self.searchImageView.isHidden = false
            self.searchButton.hideLoaderView()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToUpdateUserOnboarding() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let selectedArray = locationsArray.filter( {$0.favorite == true} )
        var selectedLocations = [String]()
        for loc in selectedArray {
            selectedLocations.append(loc.id ?? "")
        }
        
        self.showLoaderInVC()
        SharedManager.shared.performWSToUpdateUserFollow(id: selectedLocations, isFav: true, type: .locations) { status in
            
            self.hideLoaderVC()
            self.delegate?.locationListUpdated()
            self.dismiss(animated: true)
        }
        

    }
    
    
}
