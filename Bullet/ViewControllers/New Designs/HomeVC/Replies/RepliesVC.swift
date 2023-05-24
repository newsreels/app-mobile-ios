//
//  RepliesVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class RepliesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewTextViewContainer: UIView!
    @IBOutlet weak var txtViewComment: AutoExpandingTextView!
    @IBOutlet weak var btnSendButton: UIButton!
    @IBOutlet weak var btnCloseButton: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var constraintTxtViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var constraintViewTop: NSLayoutConstraint!
    @IBOutlet weak var viewTypeTextContainer: UIView!
    @IBOutlet weak var constraintTxtBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewTitleUnderLine: UIView!
    @IBOutlet weak var viewCommentUnderLine: UIView!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var lblReplyText: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintReplyingToViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblReplyToUserText: UILabel!
    @IBOutlet weak var viewKeyboarInfo: UIView!
    @IBOutlet weak var btnCancelReply: UIButton!
//    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var viewVerticalLine: UIView!
    @IBOutlet weak var imgUserDP: UIImageView!
    
    @IBOutlet var fieldContainerView: UIView!
    let lblPlaceHolder = UILabel()
    
    var currentlySelectedCellIndex: IndexPath?
    var currentlySelectedNestedCellIndex: IndexPath?
    var parentID = ""
    var selectedComment: Comment?
    var articleID = ""
    var commentArray = [Comment]()
    var isApiCallAlreadyRunning = false
    var nextPageData = ""
    var childNextPageData = [String: String]()
    
    var currentlySelectedSection: Int?
    var currentlySelectedRow: Int?
    var isReplyTagRequired = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        registerCells()
        setLocalization()
        setupUI()
        txtViewComment.inputAccessoryView = nil
        addTextViewPlaceHolderLabel()
        txtViewComment.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight =  UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight =  200
                
        lblName.text = selectedComment?.user?.name?.capitalized ?? ""
        if selectedComment?.user?.image?.isEmpty ?? false {
            imgUser.theme_image = GlobalPicker.imgUserPlaceholder
        }
        else {
            imgUser.sd_setImage(with: URL(string: selectedComment?.user?.image ?? "") , placeholderImage: nil)
        }
        
        if let publishDate = selectedComment?.createdAt {
            lblTime.text = SharedManager.shared.generateDatTimeOfNewsShortType(publishDate)
        }
        
        lblReply.text = selectedComment?.comment ?? ""
        constraintReplyingToViewHeight.constant = 0
        
        performWSToGetCommentsData(articleID: articleID, parentID: parentID, page: "", isLoadingChildData: false)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        viewWillLayoutSubviews()
        self.view.layoutIfNeeded()
        viewWillLayoutSubviews()
        
        if isReplyTagRequired {
            txtViewComment.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()

        
////        var tableSize : CGFloat = 0
////        if tableView.numberOfSections > 0 {
////            if self.tableView.contentSize.height + viewBackground.frame.size.height > self.scrollView.frame.size.height {
////                tableSize = self.tableView.contentSize.height
////                self.constraintTableViewHeight.constant = tableSize
////            } else {
////                tableSize = self.scrollView.frame.size.height - viewBackground.frame.size.height
////                self.constraintTableViewHeight.constant = tableSize
////            }
////        } else {
////            self.constraintTableViewHeight.constant = tableSize
////        }
////
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            if self.constraintTableViewHeight.constant == 0 && self.tableView.numberOfSections > 0{
//                self.viewWillLayoutSubviews()
//            }
//        }
        
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblName.semanticContentAttribute = .forceRightToLeft
                self.lblName.textAlignment = .right
                self.lblPlaceHolder.semanticContentAttribute = .forceRightToLeft
                self.lblPlaceHolder.textAlignment = .right
                self.txtViewComment.semanticContentAttribute = .forceRightToLeft
                self.txtViewComment.textAlignment = .right
                self.btnSendButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.lblPlaceHolder.frame.origin = CGPoint(x: 0, y: (self.txtViewComment.font?.pointSize)! / 2)
                self.lblPlaceHolder.frame.size.width  = self.txtViewComment.frame.size.width - 5
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblName.semanticContentAttribute = .forceLeftToRight
                self.lblName.textAlignment = .left
                self.lblPlaceHolder.semanticContentAttribute = .forceLeftToRight
                self.lblPlaceHolder.textAlignment = .left
                self.txtViewComment.semanticContentAttribute = .forceLeftToRight
                self.txtViewComment.textAlignment = .left
                self.btnSendButton.transform = CGAffineTransform.identity
                self.lblPlaceHolder.frame.origin = CGPoint(x: 5, y: (self.txtViewComment.font?.pointSize)! / 2)
                self.lblPlaceHolder.frame.size.width  = self.txtViewComment.frame.size.width
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        viewWillLayoutSubviews()
    }
    
    // MARK: - Methods
    
    @IBAction func reactionsTapped(_ sender: UIButton) {
        let reactions = ["❤️", "🙌", "🔥", "👏", "😢", "😍", "😮", "😂"]
        self.txtViewComment.text.append(contentsOf: reactions[sender.tag])
    }
    
    
    func setLocalization() {
        if self.commentArray.count > 0 {
            lblTitle.text = NSLocalizedString("\(self.commentArray.count) Replies", comment: "")
        } else {
            lblTitle.text = NSLocalizedString("Replies", comment: "")
        }
    }
    
    
    func setupUI() {
        
        txtViewComment.text = ""

        self.lblReplyToUserText.theme_textColor = GlobalPicker.commentVCTitleColor
        self.btnCancelReply.theme_setTitleColor(GlobalPicker.themeCommonColor, forState: .normal)
    
        self.fieldContainerView.layer.cornerRadius = 8
        self.fieldContainerView.layer.borderWidth = 1
        self.fieldContainerView.layer.borderColor = UIColor.init(hexString: "#DEE8F2").cgColor

    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "RepliesCC", bundle: nil), forCellReuseIdentifier: "RepliesCC")
        tableView.register(UINib(nibName: "ReplyViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "ReplyViewHeader")
    }
    
    func showPopUpProfileNotFound() {
        
        if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                        
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        else {
            
            let vc = PopupVC.instantiate(fromAppStoryboard: .Home)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    // Keyboard methods
    @objc func keyboardWillShow(notification: Notification) {
        
        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
            if currentlySelectedSection != nil && currentlySelectedRow != nil {
                let userName = commentArray[currentlySelectedSection!].replies?[currentlySelectedRow!].user?.name?.capitalized ?? ""
                lblReplyToUserText.text = "\(NSLocalizedString("Replying to", comment: "")) \(userName)"
                constraintReplyingToViewHeight.constant = 0
            } else if currentlySelectedSection != nil && currentlySelectedRow == nil {
                let userName = commentArray[currentlySelectedSection!].user?.name?.capitalized ?? ""
                lblReplyToUserText.text = "\(NSLocalizedString("Replying to", comment: "")) \(userName)"
                constraintReplyingToViewHeight.constant = 0
            } else {
                
                let userName = selectedComment?.user?.name?.capitalized ?? ""
                lblReplyToUserText.text = "\(NSLocalizedString("Replying to", comment: "")) \(userName)"
                constraintReplyingToViewHeight.constant = 0
                
            }
            self.keyboardControl(notification, isShowing: true)
        } else {
            self.view.endEditing(true)
            resetTextViewContent()
            showPopUpProfileNotFound()
        }
        
        isReplyTagRequired = false
        
    }

     @objc func keyboardWillHide(notification: Notification) {
         constraintReplyingToViewHeight.constant = 0
         self.keyboardControl(notification, isShowing: false)
     }
     

     private func keyboardControl(_ notification: Notification, isShowing: Bool) {
         
         
         /* Handle the Keyboard property of Default*/
         
         let userInfo = notification.userInfo!
         let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
         let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value
         
         let convertedFrame = self.view.convert(keyboardRect!, from: nil)
         let heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
         let options = UIView.AnimationOptions(rawValue: UInt(curve!) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
         let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
         
         
         
         var  pureheightOffset : CGFloat = -heightOffset
         
         if isShowing { /// Wite space of save area in iphonex ios 11
             pureheightOffset = pureheightOffset + view.safeAreaInsets.bottom
         }
         
         // Here change you Consrant
         self.constraintTxtBottomSpace?.constant = pureheightOffset
         print("self.constraintTxtBottomSpace?.constant == \(-(self.constraintTxtBottomSpace?.constant ?? 0))")
         UIView.animate(
             withDuration: duration!,
             delay: 0,
             options: options,
             animations: {
                 self.view.layoutIfNeeded()
             },
             completion: { bool in
                 
             })

         
     }
     
    
    
    func resetTextViewContent() {
        currentlySelectedSection = nil
        currentlySelectedRow = nil
        txtViewComment.text = ""
        txtViewComment.adjustSize()
        txtViewComment.resignFirstResponder()
    }
    
    
    func addTextViewPlaceHolderLabel() {
        lblPlaceHolder.text = NSLocalizedString("Add a comment...", comment: "")
        lblPlaceHolder.font = UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        lblPlaceHolder.sizeToFit()
        txtViewComment.addSubview(lblPlaceHolder)
        lblPlaceHolder.textColor = UIColor(hexString: "#BECAD8")
        lblPlaceHolder.isHidden = !txtViewComment.text.isEmpty
        
        viewWillLayoutSubviews()
    }
    
    // MARK: - Actions
    @IBAction func didTapBtnClose(_ sender: Any) {
        
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapSendButton(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if txtViewComment.text.trimmingCharacters(in: .whitespaces).isEmpty == false {
            
            if currentlySelectedSection != nil && currentlySelectedRow == nil {
                let parentID = commentArray[currentlySelectedSection!].id
                performWSToAddNewCommentsData(articleID: articleID, parentID: parentID ?? "", comment: txtViewComment.text ?? "", isAddingChildData: true)
            } else if currentlySelectedSection != nil && currentlySelectedRow != nil {
                
                let parentID = commentArray[currentlySelectedSection!].id
                performWSToAddNewCommentsData(articleID: articleID, parentID: parentID ?? "", comment: txtViewComment.text ?? "", isAddingChildData: true)
            } else {
                
                performWSToAddNewCommentsData(articleID: articleID, parentID: self.parentID, comment: txtViewComment.text ?? "", isAddingChildData: false)
            }
            
        }
        
        
        
        resetTextViewContent()
    }
    
    @IBAction func didTapReplyButton(_ sender: Any) {
        
        currentlySelectedSection = nil
        currentlySelectedRow = nil
        
        isReplyTagRequired = true
        txtViewComment.becomeFirstResponder()
        
    }
    
    @IBAction func cancelKeyboard(_ sender: Any) {
        
        self.view.endEditing(true)
        currentlySelectedSection = nil
        currentlySelectedRow = nil
        
    }
    
    
}

// MARK: - ScrollView Delegates
extension RepliesVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        viewBackground.layer.masksToBounds = false
        viewBackground.layer.shadowRadius = 4
        viewBackground.layer.shadowColor = UIColor.black.cgColor
        viewBackground.layer.shadowOffset = CGSize(width: 0 , height: 4)
        viewBackground.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                             y: viewBackground.bounds.maxY - viewBackground.layer.shadowRadius,
                                                             width: viewBackground.bounds.width,
                                                             height: viewBackground.layer.shadowRadius)).cgPath

        
        if scrollView.contentOffset.y > 0 {
            viewBackground.layer.shadowOpacity = 0.25
        } else {
            viewBackground.layer.shadowOpacity = 0
        }
    }
}

// MARK: - TextView Delegates
extension RepliesVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - TableView Delegates
extension RepliesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.commentArray.count > 0 {
            viewVerticalLine.isHidden = false
        } else {
            viewVerticalLine.isHidden = true
        }
        return self.commentArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentArray[section].replies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepliesCC") as! RepliesCC
//        cell.delegate = self
        if let reply = commentArray[indexPath.section].replies?[indexPath.row] {
            let comment = commentArray[indexPath.section]
            let isLast = self.commentArray.count - 1 == indexPath.section ? true : false
            cell.setupCell(replyModel: reply, commentModel: comment, indexpath: indexPath, isLastTopComment: isLast)
        }
        
        cell.delegate = self
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ReplyViewHeader") as! ReplyViewHeader
        let isLast = self.commentArray.count - 1 == section ? true : false
        header.setupHeader(model: commentArray[section], section: section, isLastComment: isLast)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
}

extension RepliesVC: RepliesCCDelegate {
    
    func didTapViewMoreReplies(cell: RepliesCC) {
        
        var page = ""
        if childNextPageData["\(cell.parentID)"] != nil {
            page = childNextPageData["\(cell.parentID)"] ?? ""
        }
        performWSToGetCommentsData(articleID: articleID, parentID: cell.parentID, page: page, isLoadingChildData: true)
        
    }
    
    func didTapReplyTextView(cell: RepliesCC) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        currentlySelectedSection = indexPath.section
        currentlySelectedRow = nil
        
        txtViewComment.becomeFirstResponder()
        
    }
    
    
    func didTapReplyButton(cell: RepliesCC) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        currentlySelectedSection = indexPath.section
        currentlySelectedRow = indexPath.row
        
        txtViewComment.becomeFirstResponder()
    }
    
}


extension RepliesVC {
    
    
    func reloadTableUpdateContentSize() {
        self.view.layoutIfNeeded()
        self.viewWillLayoutSubviews()
        self.tableView.reloadData()
        self.viewWillLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.view.layoutIfNeeded()
            self.viewWillLayoutSubviews()
        }
    }
    
    func reloadTableScrollToTop() {
        self.tableView.reloadData()
        self.viewWillLayoutSubviews()
//        self.scrollView.setContentOffset(.zero, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewWillLayoutSubviews()
        }
    }
    
    func reloadSectionUpdateContentSize(index: Int) {
        self.tableView.reloadSections([index], with: .none)
        self.viewWillLayoutSubviews()
//        let comment = self.commentArray[index]
//        self.tableView.scrollToRow(at: IndexPath(row: (comment.replies?.count ?? 0) - 1, section: index), at: .bottom, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewWillLayoutSubviews()
//            self.tableView.scrollToRow(at: IndexPath(row: (comment.replies?.count ?? 0) - 1, section: index), at: .bottom, animated: true)
        }
    }
    
    
    func callWebsericeToGetComments() {
        if isApiCallAlreadyRunning == false {
            if nextPageData.isEmpty == false {
                performWSToGetCommentsData(articleID: articleID, parentID: parentID, page: nextPageData, isLoadingChildData: false)
            }
        }
    }
    
    
    func performWSToGetCommentsData(articleID: String, parentID: String,  page: String, isLoadingChildData: Bool) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if self.commentArray.count == 0 {
            ANLoader.showLoading(disableUI: false)
        }
        
        if isLoadingChildData {
            ANLoader.showLoading(disableUI: false)
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        WebService.URLResponse("social/comments/articles/\(articleID)?parent_id=\(parentID)&page=\(page)", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ANLoader.hide()
            }
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(CommentsModel.self, from: response)
                
                if isLoadingChildData == false {
                    // Main comments
                    if let commentsData = FULLResponse.comments, commentsData.count > 0 {
                        if self.commentArray.count == 0 {
                            self.commentArray = commentsData
                            self.tableView.reloadData()
                        } else {
    //                        let newIndex = self.reelsArray.count
                            for newComment in commentsData {
                                
                                if self.commentArray.contains(where: {$0.id == newComment.id}) == false {
                                    self.commentArray.append(newComment)
                                }
                            }
                            self.setLocalization()
                            self.reloadTableUpdateContentSize()
                        }
                        
                    } else {
                        
                        print("Empty Result")
                        self.commentArray.removeAll()
                        self.reloadTableUpdateContentSize()
                        
                    }
                    // Meta data
                    if let next = FULLResponse.meta?.next, next.isEmpty == false {
                        self.nextPageData = next
                    } else {
                        self.nextPageData = ""
                    }
                } else {
                    // Child Replies
                    if let commentsData = FULLResponse.comments, commentsData.count > 0 {
                        
                        for (index, comment) in self.commentArray.enumerated() {
                            if comment.id == parentID {
                                self.commentArray[index].moreComment = FULLResponse.parent?.moreComment ?? 0
                                if self.commentArray[index].replies?.count == 0 {
                                    self.commentArray[index].replies = commentsData
                                } else {
                                    
                                    for newComment in commentsData {
                                        //  Load Comments skip duplicates
                                        if self.commentArray[index].replies?.contains(where: {$0.id == newComment.id}) == false {
                                            self.commentArray[index].replies?.append(newComment)
                                        } else {
                                            print("duplicate id", newComment.comment)
                                        }
                                    }
                                    
                                }
                                
                                
                                self.reloadSectionUpdateContentSize(index: index)
                            }
                        }
                        
                    }
                    self.setLocalization()
                    // Meta data
                    if let next = FULLResponse.meta?.next, next.isEmpty == false {
                        self.childNextPageData["\(parentID )"] = next
                    } else {
                        self.childNextPageData["\(parentID )"] = nil
                    }
                    
                }
                
                
            } catch let jsonerror {
                self.isApiCallAlreadyRunning = false
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "social/comments/articles/\(articleID)?parent_id=\(parentID)&page=\(page)", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.isApiCallAlreadyRunning = false
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToAddNewCommentsData(articleID: String, parentID: String, comment: String, isAddingChildData: Bool) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        print("url  ","social/comments/create?ArticleID=\(articleID)&Comment=\(comment)&ParentID=\(parentID)")
//        var encodedComment = ""
//        encodedComment = comment
        let params =
            [
                "ArticleID": articleID,
                "Comment": comment,
                "ParentID":parentID
            ]
        
        WebService.URLResponse("social/comments/create", method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(CommentsModel.self, from: response)
                
                if isAddingChildData == false {
                    
                    if let commentsData = FULLResponse.comments, commentsData.count > 0 {
                        if let newComment = commentsData.first {
                            
                            self.commentArray.insert(newComment, at: 0)
                        }
                        self.setLocalization()
                        self.reloadTableScrollToTop()
                        
                    }
                    
                } else {
                    
                    if let commentsData = FULLResponse.comments, commentsData.count > 0 {
                        
                        for (section, comment) in self.commentArray.enumerated() {
                           
                            if comment.id == parentID {
                                
                                if let newComment = commentsData.first {
                                    
                                    if (self.commentArray[section].replies?.count ?? 0) > 0 {
                                        self.commentArray[section].replies?.append(newComment)
                                    } else {
                                        self.commentArray[section].replies = [newComment]
                                    }
                                    
                                }
                                self.setLocalization()
                                self.reloadSectionUpdateContentSize(index: section)
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
            } catch let jsonerror {
                ANLoader.hide()
                self.isApiCallAlreadyRunning = false
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "social/comments/create", error: jsonerror.localizedDescription, code: "")

            }
        }) { (error) in
            ANLoader.hide()
            self.isApiCallAlreadyRunning = false
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}

extension RepliesVC: ReplyViewHeaderDelegate {
    func didTapHeaderReplyButton(header: ReplyViewHeader) {
        
        currentlySelectedSection = header.section
        currentlySelectedRow = nil
        txtViewComment.becomeFirstResponder()
    }
}

extension RepliesVC: PopupVCDelegate {
    func popupVCDismissed() {
//        self.dismiss(animated: true, completion: nil)
//        performWSToUserConfig()
        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
