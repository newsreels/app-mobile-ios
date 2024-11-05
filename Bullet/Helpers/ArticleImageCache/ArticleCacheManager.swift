//
//  ArticleCacheManager.swift
//  Bullet
//
//  Created by Abdullah Tariq on 21/11/2022.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import GCDWebServer

protocol ArticleCacheManagerDelegate: NSObject {
    func cachingCompleted(article: articlesData, position: Int)
}


class ArticleCacheManager {
    
    static let shared = ArticleCacheManager()
    let queue = DispatchQueue(label: "serial")
    private init(){
    }
    weak var delegate: ArticleCacheManagerDelegate?
    var article: articlesData!
    
    
    func begin(article: articlesData, position: Int){

        queue.async { [weak self] in
            self?.downloadChunkAndStore(article, position)
        }
    }
    
    func downloadChunkAndStore(_ article: articlesData, _ position: Int){
        
        let imageUrl = article.image ?? ""
        if imageUrl != "" {
            let url = URL(string: imageUrl)!
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                
                let pathArticles = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask)[0].appendingPathComponent("ArticleFiles")
                
                
                if !self.directoryExistsAtPath(pathArticles.absoluteString){
                    self.createDirIfNeeded(dirName: "ArticleFiles")
                    
                }
                
                let finalArticleFileName = "\(position)_" + (article.id ?? "") + "_" + String(imageUrl.components(separatedBy: "/").last ?? "")
                let fileUrlArticle = pathArticles.appendingPathComponent(finalArticleFileName)
                
                do {
                    try data.write(to: fileUrlArticle)
                    self.article = article
                    self.article.image = fileUrlArticle.absoluteString
                    self.delegate?.cachingCompleted(article: self.article, position: position)
                    
                } catch {
                    print("Error", error)
                    return
                }
            }
            task.resume()
        }
    }
    
    func createDirIfNeeded(dirName: String) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(dirName + "/")
        do {
            try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    func clearDiskCache() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ArticleFiles")
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
}
