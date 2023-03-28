//
//  GenericTableView.swift
//  Bullet
//
//  Created by Khadim Hussain on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

 protocol GenericTableViewDelegate: class {
    
    func didTapShareBtn(article: articlesData )
    func didTapGoToSourceBtn(article: articlesData)
    func didTapArticle(article: articlesData)
    func didTapCommentsButton(article: articlesData, index: Int)
    func didTapLikeButton(article: Discover?, index: Int)
}

class GenericTableView: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var tbList: UITableView!
    
    var articlesArr: [articlesData]?
    
    weak var delegate: GenericTableViewDelegate?
    var index: Int = 0
    var model: Discover?
    var isLikeApiRunning = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.theme_textColor = GlobalPicker.textSubColorDiscover
        self.lblSubTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        self.viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        self.tbList.backgroundColor = .clear
        self.tbList.register(UINib(nibName: "GenericListCell", bundle: nil), forCellReuseIdentifier: "GenericListCell")
        self.selectionStyle = .none
        self.viewBG.addBottomShadowForDiscoverPage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblSubTitle.semanticContentAttribute = .forceRightToLeft
                self.lblSubTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblSubTitle.semanticContentAttribute = .forceLeftToRight
                self.lblSubTitle.textAlignment = .left
            }
        }
    }
    
    
    func setupCell(model: Discover?) {
        self.model = model
        self.lblTitle.text = model?.subtitle?.uppercased() ?? ""
        self.lblSubTitle.text = model?.title ?? ""
        if let articles = model?.data?.articles {
            
            self.articlesArr = articles
            self.tbList.reloadData()
        }
    }
}

//MARK:- CARD VIEW TABLE DELEGATE
extension GenericTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.articlesArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let content = self.articlesArr?[indexPath.row]
        
        let articelListCell = tableView.dequeueReusableCell(withIdentifier: "GenericListCell", for: indexPath) as! GenericListCell
        articelListCell.langCode = content?.language ?? ""
        articelListCell.delegateLikeComment = self
        
        articelListCell.btnShare.tag = indexPath.row
        articelListCell.btnSource.tag = indexPath.row
        articelListCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
        articelListCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
        
        articelListCell.contentView.backgroundColor = .clear
        articelListCell.backgroundColor = .clear
        articelListCell.setupCell(model: content, isOpenFromTopNews: false)
        articelListCell.viewSeperatorLine.isHidden = false
        if self.articlesArr?.count == indexPath.row + 1 {
            
            articelListCell.viewSeperatorLine.isHidden = true
        }
        return articelListCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let content = self.articlesArr?[indexPath.row] {
            
            self.delegate?.didTapArticle(article: content)
        }
    }
    
    @objc func didTapShare(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        let index = button.tag
        if let content = self.articlesArr?[index] {
            
            self.delegate?.didTapShareBtn(article: content)
        }
    }
    
    @objc func didTapSource(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
       
        button.isUserInteractionEnabled = false
        let index = button.tag

        if let content = self.articlesArr?[index] {
            
            self.delegate?.didTapGoToSourceBtn(article: content)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            button.isUserInteractionEnabled = true
        }
    }
}

extension GenericTableView: LikeCommentDelegate {
    
    func didTapCommentsButton(cell: UITableViewCell) {
        
        guard let indexPath = tbList.indexPath(for: cell) else {return}
        if let content = self.articlesArr?[indexPath.row] {
            
            self.delegate?.didTapCommentsButton(article: content, index: index)
        }
        
    }
    
    func didTapLikeButton(cell: UITableViewCell) {
        
        guard let indexPath = tbList.indexPath(for: cell) else {return}
        if let contentObj = self.articlesArr?[indexPath.row] {
            
            var content = contentObj
            var likeCount = content.info?.likeCount
            if (content.info?.isLiked ?? false) {
                likeCount = (likeCount ?? 0) - 1
            } else {
                likeCount = (likeCount ?? 0) + 1
            }
            let info = Info(viewCount: content.info?.viewCount, likeCount: likeCount, commentCount: content.info?.commentCount, isLiked: !(content.info?.isLiked ?? false))
            content.info = info
            self.articlesArr?[indexPath.row].info = info
            model?.data?.articles = self.articlesArr
            
            (cell as? GenericListCell)?.setLikeComment(model: self.articlesArr?[indexPath.row].info)
            
            
            
            self.performWSToLikePost(article_id: content.id ?? "", isLike: content.info?.isLiked ?? false)
            self.delegate?.didTapLikeButton(article: model, index: index)
        }
    }
    
    func didTapCommentsButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapLikeButtonCollectionView(cell: UITableViewCell) {
    }
    
    
    func performWSToLikePost(article_id: String, isLike: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
//            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["like": isLike]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isLikeApiRunning = true
        WebService.URLResponseJSONRequest("social/likes/article/\(article_id)", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            self.isLikeApiRunning = false
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    print("like status", status)
//                    if status == Constant.STATUS_SUCCESS_LIKE {
//                        print("Successfull")
//                    }
//                    else {
////                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
//                    }
                }
                
            } catch let jsonerror {
                self.isLikeApiRunning = false
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "social/likes/article/\(article_id)", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.isLikeApiRunning = false
            print("error parsing json objects",error)
        }

    }
}

