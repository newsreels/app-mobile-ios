//
//  ViewProfileVC.swift
//  Bullet
//
//  Created by Mahesh on 08/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AuthorProfileVCDelegate: AnyObject {
    
    func updateAuthorWhenDismiss(article: articlesData)
}

class AuthorProfileVC: UIViewController {
    
    var pageContrlVC = AuthorPageViewController()
    var authors: [Authors]?
    var content: articlesData?
    var author: Author?

    weak var delegateVC: AuthorProfileVCDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "authorEmbedSegue" {
            
            pageContrlVC = segue.destination as! AuthorPageViewController
            pageContrlVC.delegateAPVC = self
            pageContrlVC.authors = self.authors
            pageContrlVC.author = self.author
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
//        print("viewDidDisappear called")
//        ProfileReelsVC, ProfileArticlesVC
        if let vc = pageContrlVC.currentViewController as? ProfileArticlesVC {
            vc.updateProgressbarStatus(isPause: true)
        }
        
    }
    
}

extension AuthorProfileVC: AuthorPageVCDelegate {
    
    func updateAuthorWhenDismiss(author: Author) {
        
        if var content = content {
            
            if let row = content.suggestedAuthors?.firstIndex(where: { $0.id == author.id }) {
                content.suggestedAuthors?[row] = author
            }
            
            self.delegateVC?.updateAuthorWhenDismiss(article: content)
        }
        
    }
}

