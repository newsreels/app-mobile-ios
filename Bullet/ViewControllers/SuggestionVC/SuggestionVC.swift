//
//  SuggestionVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 06/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class SuggestionVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {

//    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtSuggestion: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblSelectFile: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    var userImage: [UIImage]?
    var picker = UIImagePickerController()
    var alert = UIAlertController(title: NSLocalizedString("Choose Image", comment: ""), message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    let imagePicker = ImagePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.txtSuggestion.textColor = UIColor.lightGray
        
        self.userImage = [UIImage]()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.txtEmail.text = UserDefaults.standard.value(forKey: Constant.UD_userEmail) as? String
        txtSuggestion.text = NSLocalizedString("Have feedback? We'd love to hear it, but please don't share sensitive information. Have questions or legal concerns? Try help or support.", comment: "")
        
        showSaveButtonUI(selected: false)
    }
    
    
    func setupLocalization() {
//        lblTitle.text = NSLocalizedString("Suggest an improvement", comment: "")
        lblFrom.text = NSLocalizedString("From:", comment: "")
        txtEmail.placeholder = NSLocalizedString("Enter email", comment: "")
        txtSuggestion.text = NSLocalizedString("Have feedback? We'd love to hear it, but please don't share sensitive information. Have questions or legal concerns? Try help or support.", comment: "")
        lblSelectFile.text = NSLocalizedString("Select file from gallery", comment: "")
        
    }
    
    func showSaveButtonUI(selected: Bool) {
        
        if selected {
            self.continueButton.backgroundColor = Constant.appColor.lightRed
            self.continueButton.layer.cornerRadius = 15
            self.continueButton.setTitleColor(.white, for: .normal)
        }
        else {
            continueButton.backgroundColor = Constant.appColor.lightGray
            continueButton.layer.cornerRadius = 15
            continueButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        
        view.layoutIfNeeded()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
        
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            if textView == self.txtSuggestion {
                
                textView.text = NSLocalizedString("Have feedback? We'd love to hear it, but please don't share sensitive information. Have questions or legal concerns? Try help or support.", comment: "")
            }
            textView.textColor = UIColor.lightGray
            showSaveButtonUI(selected: false)
        }
        else {
            showSaveButtonUI(selected: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        if textField == txtEmail {
            
            txtEmail.becomeFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapUploadImage(_ sender: Any) {
       
        imagePicker.viewController = self
        imagePicker.onPick = { [weak self] image in
            self?.uploadImage(image)
        }
        imagePicker.show()
    }
    
    func uploadImage(_ image: UIImage) {
        
        if let images = userImage {
            if images.count == 6 {
                self.userImage?.removeLast()
            }
            self.userImage?.append(image)
        }
        self.collectionView.reloadData()
    }

    @IBAction func didTapSendSuggestion(_ sender: Any) {
  
        let email = self.txtEmail.text ?? ""
        let sug = self.txtSuggestion.text ?? ""
        if email.isEmpty {
            
            //SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter Email.", comment: ""))
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter Email.", comment: ""), type: .alert)

        }
        else if (sug == NSLocalizedString("Have feedback? We'd love to hear it, but please don't share sensitive information. Have questions or legal concerns? Try help or support.", comment: "") || sug.isEmpty) {

            //SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter your suggestion.", comment: ""))
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter your suggestion.", comment: ""), type: .alert)
        }
        else {
            
            self.view.endEditing(true)
            self.performWebServiceForSuggestions()
        }
    }
}

//====================================================================================================
// MARK:- Web Service for Suggestions
//====================================================================================================
extension SuggestionVC {
    
    func performWebServiceForSuggestions() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
//        var dicSelectedImages = [[String: UIImage]]()
//        if let images = self.userImage, images.count > 0 {
//            for img in images {
//                dicSelectedImages["file"] = img
//                dicSelectedImages.append()
//            }
//        }
        
        let email = txtEmail.text?.trim() ?? ""
        let msg = txtSuggestion.text?.trim() ?? ""
        
        if !email.isValidEmail() {
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Invalid email format", comment: ""), type: .alert)
            return
        }
        
        ANLoader.showLoading()
        let params = ["message": msg, "email" : email]
        
        WebService.multiParamsULResponseMultipleImages("contact/suggestion/new", method: .post, parameters: params, headers: token, ImageArray: self.userImage!) { (response) in
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("feedback sent.", comment: ""))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                       
                        ANLoader.hide()
                        self.didTapBackButton(self)
                    }
                }
                else {
                    
                    ANLoader.hide()
                }
                
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "contact/suggestion/new", error: jsonerror.localizedDescription, code: "")
            }
        } withAPIFailure: { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

extension SuggestionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.userImage?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCC", for: indexPath) as? SuggestionCC else { return UICollectionViewCell() }
 
        var image = self.userImage?[indexPath.row]
  
        if image == nil {
            
        }
        else {
            
            //If image height is greater than image view height then resize image by height
            if ((image?.size.height)! > cell.imgSuggest.frame.height) { //Resize the image
                image = SharedManager.shared.resizeImageByHeight(image!, height: cell.imgSuggest.frame.height)
            }
            cell.imgSuggest.image = image
        }
        
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(didTapAddRemoveTopic), for: .touchUpInside)
        
        return cell
    }
    
    @objc func didTapAddRemoveTopic(sender: UIButton) {
        
        let image = (self.userImage?[sender.tag])!
        
        if let index = self.userImage?.firstIndex(of: image) {
            
            self.userImage?.remove(at: index)
        }
        self.collectionView.reloadData()

    }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.height , height: collectionView.frame.height)
    }
   
}
