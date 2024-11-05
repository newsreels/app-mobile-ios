//
//  NewAppButton.swift
//  Bullet
//
//  Created by Yeshua Lagac on 7/8/21.
//

import SwiftUI
import Foundation

struct AppURLImage : View {
    
    @ObservedObject private var remoteImage: RemoteImage
    
    init(_ urlString: String?) {
        remoteImage = RemoteImage(urlString: urlString)
    }
    
    var body: some View {
        ZStack {
            switch remoteImage.loadingState {
            case .initial, .inProgress:
                Color.gray
            case .success(let remoteImageType):
                remoteImageType.resizable().clipped()
            case .failure:
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.gray)
                    AppText("Failed")
                }
            }
        }
    }
}

final class RemoteImage: NSObject, ObservableObject {
    
    enum LoadingState {
        case initial
        case inProgress
        case success(_ image: Image)
        case failure
    }
    
    
    @Published var loadingState: LoadingState = .initial
    
    let url: URL?
    
    init(urlString: String?) {
        if let urlString = urlString {
            if urlString.contains("platform-lookaside.fbsbx.com") { // for fb purposes
                self.url = URL(string: urlString)?.fbProfPic
            } else {
                self.url = URL(string: urlString)
            }
        } else {
            url = nil
            loadingState = .failure
        }
        super.init()
        load()
    }
    
    func load() {
        guard let url = url else { return }
        loadingState = .inProgress
//        let imageService = CustomService(customBaseURL: url, method: .get, showLogs: false)
//        print("IMAGE SERVICE = \(imageService)")
//        URLSessionProvider.shared.request(ImageData.self, service: imageService) { [weak self] result in
//            DispatchQueue.main.async {
//                if case let .success(fetchedImage) = result {
//
//                    if let origUIImage = UIImage(data: fetchedImage.data) {
//                       let finalUIImage: UIImage
//                       let finalImageData: Data
//                       if let scaledDownImageData = origUIImage.compressToMaximumIfOver1MB() {
//
//                           if let scaledUIImage =  UIImage(data: scaledDownImageData) {
//                               finalUIImage = scaledUIImage
//                               finalImageData = scaledDownImageData
//                           } else {
//                               finalUIImage = origUIImage
//                               finalImageData = fetchedImage.data
//                           }
//
//                       } else {
//                           finalUIImage = origUIImage
//                           finalImageData = fetchedImage.data
//                       }
//
//
//                        self?.loadingState = .success(Image(uiImage: finalUIImage))
//
//
//                       return
//                   }
//                } else {
//                    print("FAILED URLS = \(url)")
//                    self?.loadingState = .failure
//                }
//            }
//        }


        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    self.loadingState = .success(Image(uiImage: UIImage(data: data) ?? UIImage()))
                } else {
                    self.loadingState = .failure
                }
            }
        }
        task.resume()
        
    }
   
}
