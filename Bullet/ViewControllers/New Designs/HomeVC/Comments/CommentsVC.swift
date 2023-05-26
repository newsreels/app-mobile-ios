//
//  CommentsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 06/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol CommentsVCDelegate: class {
    func commentsVCDismissed(articleID: String)
}

class CommentsVC: UIViewController {
    
    @IBOutlet var fieldContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtViewComment: AutoExpandingTextView!
    @IBOutlet weak var btnSendButton: UIButton!
    @IBOutlet weak var btnCloseButton: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    //    @IBOutlet weak var constraintTxtViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var constraintViewTop: NSLayoutConstraint!
    @IBOutlet weak var viewTypeTextContainer: UIView!
    @IBOutlet weak var constraintTxtBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewCommentUnderLine: UIView!
    
    @IBOutlet var navView: UIView!
    public var minimumVelocityToHide: CGFloat = 1500
    public var minimumScreenRatioToHide: CGFloat = 0.5
    public var animationDuration: TimeInterval = 0.2
    let lblPlaceHolder = UILabel()
    var panGestureRecognizer = UIPanGestureRecognizer()
    let normalTextViewBotttomSpace = 0
    var articleID = ""
    var commentArray = [Comment]()
    var isApiCallAlreadyRunning = false
    var nextPageData = ""
    var isViewFirstTimeLoaded = false
    weak var delegate: CommentsVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
        registerCells()
        setupUI()
        //        addGestureRecognizer()
        txtViewComment.inputAccessoryView = nil
        setLocalization()
        addTextViewPlaceHolderLabel()
        txtViewComment.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        performWSToGetCommentsData(articleID: articleID, page: "", isRefreshData: false)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if isViewFirstTimeLoaded {
            nextPageData = ""
            performWSToGetCommentsData(articleID: articleID, page: "", isRefreshData: true)
        }
        isViewFirstTimeLoaded = true
         navView.clipsToBounds = true
        navView.layer.cornerRadius = 10
        navView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.commentsVCDismissed(articleID: self.articleID)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewWillLayoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblPlaceHolder.semanticContentAttribute = .forceRightToLeft
                self.lblPlaceHolder.textAlignment = .right
                self.txtViewComment.semanticContentAttribute = .forceRightToLeft
                self.txtViewComment.textAlignment = .right
                self.lblPlaceHolder.frame.origin = CGPoint(x: 0, y: (self.txtViewComment.font?.pointSize)! / 2)
                self.lblPlaceHolder.frame.size.width  = self.txtViewComment.frame.size.width - 5
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblPlaceHolder.semanticContentAttribute = .forceLeftToRight
                self.lblPlaceHolder.textAlignment = .left
                self.txtViewComment.semanticContentAttribute = .forceLeftToRight
                self.txtViewComment.textAlignment = .left
                self.lblPlaceHolder.frame.origin = CGPoint(x: 5, y: ((self.txtViewComment.font?.pointSize)! / 2) + 1.5)
                self.lblPlaceHolder.frame.size.width  = self.txtViewComment.frame.size.width
            }
        }
        
    }
    
    
    // MARK: - Methods
    
    @IBAction func reactionsTapped(_ sender: UIButton) {
        let reactions = ["❤️", "🙌", "🔥", "👏", "😢", "😍", "😮", "😂"]
        self.txtViewComment.text.append(contentsOf: reactions[sender.tag])
    }
    
    func setLocalization() {
        
        lblTitle.text = NSLocalizedString(commentArray.count > 0 ? "\(commentArray.count) Comment\(commentArray.count > 1 ? "s" : "")" : "Comments", comment: "")
    }
    
    
    func setupUI() {
        
        txtViewComment.text = ""
        
        self.fieldContainerView.layer.cornerRadius = 8
        self.fieldContainerView.layer.borderWidth = 1
        self.fieldContainerView.layer.borderColor = UIColor.init(hexString: "#DEE8F2").cgColor
        
        self.viewCommentUnderLine.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.viewCommentUnderLine.layer.shadowRadius = 1
        self.viewCommentUnderLine.layer.shadowOpacity = 0.25
        self.viewCommentUnderLine.layer.shadowColor = UIColor.black.cgColor
        //        self.viewCommentUnderLine.layer.transform = CATransform3DMakeScale(1, -1, 1)
        
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "CommentsCC", bundle: nil), forCellReuseIdentifier: "CommentsCC")
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
            self.keyboardControl(notification, isShowing: true)
        } else {
            self.view.endEditing(true)
            resetTextViewContent()
            showPopUpProfileNotFound()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.keyboardControl(notification, isShowing: false)
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)

        switch gestureRecognizer.state {
        case .began, .changed:
            if translation.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            let velocity = gestureRecognizer.velocity(in: view)

            if translation.y > view.bounds.height * 0.3 || velocity.y > 1000 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                }
            }
        default:
            break
        }
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
            if #available(iOS 11.0, *) {
                pureheightOffset = pureheightOffset + view.safeAreaInsets.bottom
            }
        }
        
        // Here change you Consrant
        self.constraintTxtBottomSpace?.constant = -pureheightOffset
        
        UIView.animate(
            withDuration: duration!,
            delay: 0,
            options: options,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { bool in
                
            })
        
        // Enble / Disable pan gesture based on keyboard
        if self.constraintTxtBottomSpace.constant <= 0 {
            if self.panGestureRecognizer.isEnabled == false {
                self.panGestureRecognizer.isEnabled = true
            }
        } else {
            if self.panGestureRecognizer.isEnabled {
                self.panGestureRecognizer.isEnabled = false
            }
        }
        
    }
    
    
    
    
    func addGestureRecognizer() {
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    func resetTextViewContent() {
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
    
    func openReply() {
        
    }
    
    // MARK: - Swipe to dismiss methods
    func slideViewVerticallyTo(_ y: CGFloat) {
        self.view.frame.origin = CGPoint(x: 0, y: y)
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        
        if tableView.contentOffset.y > 0 {
            return
        }
        
        switch panGesture.state {
            
        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: view)
            let y = max(0, translation.y)
            slideViewVerticallyTo(y)
            
        case .ended:
            // If pan ended, decide it we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) ||
            (velocity.y > minimumVelocityToHide)
            
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    // If closing, animate to the bottom of the view
                    self.slideViewVerticallyTo(self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        // Dismiss the view when it dissapeared
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                // If not closing, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    self.slideViewVerticallyTo(0)
                })
            }
            
        default:
            // If gesture state is undefined, reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                self.slideViewVerticallyTo(0)
            })
            
        }
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen;
        modalTransitionStyle = .coverVertical;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overFullScreen;
        modalTransitionStyle = .coverVertical;
    }
    
    
    // MARK: - Actions
    @IBAction func didTapBtnClose(_ sender: Any) {
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSendButton(_ sender: Any) {
        
        self.view.endEditing(true)
        if txtViewComment.text.trimmingCharacters(in: .whitespaces).isEmpty == false {
            performWSToAddNewCommentsData(articleID: articleID, comment: txtViewComment.text)
        }
        
        resetTextViewContent()
    }
    
}

// MARK: - Delegates

extension CommentsVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

// MARK: - TextView Delegates
extension CommentsVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - ScrollView Delegates
extension CommentsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        navView.layer.masksToBounds = false
        navView.layer.shadowRadius = 4
        navView.layer.shadowColor = UIColor.black.cgColor
        navView.layer.shadowOffset = CGSize(width: 0 , height: 4)
        navView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                             y: navView.bounds.maxY - navView.layer.shadowRadius,
                                                             width: navView.bounds.width,
                                                             height: navView.layer.shadowRadius)).cgPath
        
        
        if scrollView.contentOffset.y > 0 {
            navView.layer.shadowOpacity = 0.25
        } else {
            navView.layer.shadowOpacity = 0
        }
    }
}

// MARK: - TableView Delegates
extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCC") as! CommentsCC
        cell.delegate = self
        cell.setupCell(model: commentArray[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == commentArray.count - 1 {  //numberofitem count
            callWebsericeToGetComments()
        }
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // delete your item here and reload table view
            }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete the item here
            completionHandler(true)
        }
        deleteAction.image = UIImage(named: "trash_ic")
        deleteAction.backgroundColor = UIColor.init(hexString: "F73458")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}


extension CommentsVC: CommentsCCDelegate {
    
    
    func didTapTypeReply(cell: CommentsCC) {
        
        openReplies(isReplyTagRequired: false, cell: cell)
    }
    
    func didTapOpenReply(cell: CommentsCC) {
        
        openReplies(isReplyTagRequired: false, cell: cell)
        
    }
    
    func openReplies(isReplyTagRequired: Bool, cell: CommentsCC) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let vc = RepliesVC.instantiate(fromAppStoryboard: .Home)
        let comment = commentArray[indexPath.row]
        vc.selectedComment = comment
        vc.articleID = self.articleID
        vc.parentID = comment.id ?? ""
        vc.isReplyTagRequired = isReplyTagRequired
        let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc.modalTransitionStyle = modalStyle
        // Set up a custom transition animation
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.view.isHidden = true
        }
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Webservice
extension CommentsVC {
    
    func callWebsericeToGetComments() {
        if isApiCallAlreadyRunning == false {
            if nextPageData.isEmpty == false {
                performWSToGetCommentsData(articleID: articleID, page: nextPageData, isRefreshData: false)
            }
        }
    }
    
    
    func performWSToGetCommentsData(articleID: String, page: String, isRefreshData: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if self.commentArray.count == 0 {
            ANLoader.showLoading()
        }
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        WebService.URLResponse("social/comments/articles/\(articleID)?page=\(page)", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            
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
                
                if isRefreshData {
                    self.commentArray.removeAll()
                }
                if let commentsData = FULLResponse.comments, commentsData.count > 0 {
                    if self.commentArray.count == 0 {
                        self.commentArray = commentsData
                        self.tableView.reloadData()
                    } else {
                        //                        let newIndex = self.reelsArray.count
                        self.commentArray = self.commentArray + commentsData
                        self.tableView.reloadData()
                    }
                    
                } else {
                    
                    print("Empty Result")
                    self.tableView.reloadData()
                }
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }
                
            } catch let jsonerror {
                self.isApiCallAlreadyRunning = false
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "social/comments/articles/\(articleID)?page=\(page)", error: jsonerror.localizedDescription, code: "")
                
            }
            
            self.setLocalization()
            
        }) { (error) in
            self.isApiCallAlreadyRunning = false
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToAddNewCommentsData(articleID: String, comment: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        
        //        var encodedComment = ""
        //        encodedComment = comment
        
        let params =
        [
            "ArticleID": articleID,
            "Comment": comment
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
                
                if let commentsData = FULLResponse.comments, commentsData.count > 0 {
                    if let newComment = commentsData.first {
                        
                        self.commentArray.insert(newComment, at: 0)
                    }
                    
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                    self.setLocalization()
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

extension CommentsVC: PopupVCDelegate {
    func popupVCDismissed() {
        //        self.dismiss(animated: true, completion: nil)
        //        performWSToUserConfig()
        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
