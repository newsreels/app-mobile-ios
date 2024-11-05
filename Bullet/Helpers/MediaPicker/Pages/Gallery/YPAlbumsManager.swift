//
//  YPAlbumsManager.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import Foundation
import Photos
import UIKit

class YPAlbumsManager {
    
    private var cachedAlbums: [YPAlbum]?
    private var cachedAlbumsPhotosOnly: [YPAlbum]?
    private var cachedAlbumsVideosOnly: [YPAlbum]?
    
    func fetchAlbums(selectionType: YPLibraryVC.mediaType) -> [YPAlbum] {
        
        if selectionType == .photo {
            if let cachedAlbums = cachedAlbumsPhotosOnly {
                return cachedAlbums
            }
        } else if selectionType == .video {
            if let cachedAlbums = cachedAlbumsVideosOnly {
                return cachedAlbums
            }
        } else {
            if let cachedAlbums = cachedAlbums {
                return cachedAlbums
            }
        }
        
        
        var albums = [YPAlbum]()
        let options = PHFetchOptions()
        
        let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                        subtype: .any,
                                                                        options: options)
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .any,
                                                                   options: options)
        for result in [smartAlbumsResult, albumsResult] {
            result.enumerateObjects({ assetCollection, _, _ in
                var album = YPAlbum()
                album.title = assetCollection.localizedTitle ?? ""
                album.numberOfItems = self.mediaCountFor(collection: assetCollection, selectionType: selectionType)
                if album.numberOfItems > 0 {
                    let r = PHAsset.fetchKeyAssets(in: assetCollection, options: nil)
                    if let first = r?.firstObject {
                        let deviceScale = UIScreen.main.scale
                        let targetSize = CGSize(width: 78*deviceScale, height: 78*deviceScale)
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        options.deliveryMode = .opportunistic
                        PHImageManager.default().requestImage(for: first,
                                                              targetSize: targetSize,
                                                              contentMode: .aspectFill,
                                                              options: options,
                                                              resultHandler: { image, _ in
                                                                album.thumbnail = image
                        })
                    }
                    album.collection = assetCollection
                    
                    if selectionType == .photo {
                        if YPConfig.libraryPhotoOnly.mediaType == .photo {
                            if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
                                || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                                albums.append(album)
                            }
                        } else {
                            albums.append(album)
                        }
                    } else if selectionType == .video {
                        if YPConfig.libraryVideoOnly.mediaType == .photo {
                            if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
                                || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                                albums.append(album)
                            }
                        } else {
                            albums.append(album)
                        }
                    } else {
                        if YPConfig.library.mediaType == .photo {
                            if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
                                || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                                albums.append(album)
                            }
                        } else {
                            albums.append(album)
                        }
                    }
                    
                    
                }
            })
        }
        if selectionType == .photo {
            cachedAlbumsPhotosOnly = albums
        } else if selectionType == .video {
            cachedAlbumsVideosOnly = albums
        } else {
            cachedAlbums = albums
        }
        
        
        return albums
    }
    
    func mediaCountFor(collection: PHAssetCollection, selectionType: YPLibraryVC.mediaType) -> Int {
        let options = PHFetchOptions()
        
        if selectionType == .photo {
            options.predicate = YPConfig.libraryPhotoOnly.mediaType.predicate()
        } else if selectionType == .video {
            options.predicate = YPConfig.libraryVideoOnly.mediaType.predicate()
        } else {
            options.predicate = YPConfig.library.mediaType.predicate()
        }
        
        let result = PHAsset.fetchAssets(in: collection, options: options)
        return result.count
    }
    
}

extension YPlibraryMediaType {
    func predicate() -> NSPredicate {
        switch self {
        case .photo:
            return NSPredicate(format: "mediaType = %d",
                               PHAssetMediaType.image.rawValue)
        case .video:
            return NSPredicate(format: "mediaType = %d",
                               PHAssetMediaType.video.rawValue)
        case .photoAndVideo:
            return NSPredicate(format: "mediaType = %d || mediaType = %d",
                               PHAssetMediaType.image.rawValue,
                               PHAssetMediaType.video.rawValue)
        }
    }
}
