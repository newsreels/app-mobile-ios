
# newsreels-iOS

## Table Of Contents:

- [newsreels-iOS](#newsreels-ios)
  * [Table Of Contents:](#table-of-contents-)
  * [About](#about)
  * [Reels Module](#reels-module)
    + [The module components:](#the-module-components-)
    + [Caching](#caching)
    + [Videos Preloading:](#videos-preloading-)
  * [Discover](#discover)
  * [Articles Module](#articles-module)
    + [The module components:](#the-module-components--1)
  * [Tab Bar](#tab-bar)
  * [Profile (SettingsMainview)](#profile--settingsmainview-)
  * [CI/CD](#ci-cd)
  * [important notes](#important-notes)



## About

- Languge: Swift 5.
- Architecture: MVC.
- UI: mainly UIKit with some screens in SwiftUI. 
- Video Player: Native AVPlayer. Away from NRPlayer and AVPlayer there are other players in the code but they aren't used anymore, just as extensions to AVPlayer.
AVFoundation is used for playing and preloading HLS videos. The preloading is made by setting preferredForwardBufferDuration value and making automaticallyWaitsToMinimizeStalling as true. The app preload get executed for the next 3 items forward from the current item in the collection view.
- Communication Pattren: delegates for most cases, and for some functionalities it uses notifications.
- Images Caching: SDWebImage
- Minimum Deployment: iOS 14.0


## Reels Module
'Main' Path: Bullet/ViewControllers/New\ Designs/NewsReels/ReelsVC

### The module components:
ReelsVC: here lays the network requests, app state managment, video preloading, images cache, navigation, collection view delegate, and scroll view controll.
ReelsCC: A basic collection view cell that holds the video player, and interacting buttons. it communicate with the View Controller through delegate.
News Reels Player: Aka NRPlayer, This is an AVPlayer subclass. the idea was to make custom player but there was no enough time for that. 
Bullet Details or View More: This is the details screen that appears when tapping on the video.

### Caching
These are the functions which handle the business of caching

    func saveAllVideosThumbnailsToCache(imageURL: String?) {
    
    if let url = URL(string: imageURL ?? "") {
    
    SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { image, data, error, cacheType, status, url in
    
    if error == nil {
    
    //  print("image downloaded successfully \(cacheType), \(status), \(url?.absoluteString ?? "")")
    
    //  if let cacheKey = SDWebImageManager.shared.cacheKey(for: url) {
    
    //  SDWebImageManager.shared.imageCache.queryImage(forKey: cacheKey, options: [], context: nil, cacheType: .all) { image, data, typ in
    
    //
    
    //  if image != nil {
    
    //  print("image present in cache")
    
    //  }
    
    //
    
    //  }
    
    //  }
    
    }
    
    }
    
    }
    
    }
    
    func loadImageFromCache(imageURL: String?, completionHandler: @escaping (_ image: UIImage?) -> Void) {
    
    if let url = URL(string: imageURL ?? "") {
    
    if let cacheKey = SDWebImageManager.shared.cacheKey(for: url) {
    
    let _ = SDWebImageManager.shared.imageCache.queryImage!(forKey: cacheKey, options: [], context: nil, cacheType: .all) { image, data, typ in
    
    completionHandler(image)
    
    }
    
    }
    
    }
    
    }

every time a new reels data page got featched, the saveAllVideosThumbnailsToCache get called to cache the thumbnail for all the reels in that page.


in the ReelsCC, the setImage calls loadImageFromCache.

    func setImage() {
        if imgThumbnailView.image == nil {
            imgThumbnailView.contentMode = .scaleAspectFill
            imgThumbnailView.frame = playerLayer.bounds
            imgThumbnailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imgThumbnailView.frame = playerLayer.frame
            imgThumbnailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imgThumbnailView.frame = viewContent.frame
            SharedManager.shared.loadImageFromCache(imageURL: reelModel?.image ?? "") { [weak self] image in
                if image == nil {
                    self?.imgThumbnailView?.sd_setImage(with: URL(string: self?.reelModel?.image ?? "") , placeholderImage: nil)
                } else {
                    self?.imgThumbnailView?.image = image
                }
            }
        }
        imgThumbnailView.layoutIfNeeded()
    }


### Videos Preloading:
In the ReelsVC in willDisplay function, the below for loop is buffering the next 3 videos counted from the current index

        if reelsArray.count > 0 {
            if reelsArray[indexPath.row].reelDescription == "", reelsArray[indexPath.row].authors?.count == 0, reelsArray[indexPath.row].iosType == nil {
                reelsArray.remove(at: indexPath.row)
                let indexPathReload = IndexPath(item: indexPath.row, section: 0)
                collectionView.reloadItems(at: [indexPathReload])
            }
            for i in indexPath.item...indexPath.item + 3 {
                if reelsArray.count > i, !SharedManager.shared.players.contains(where: {$0.id == reelsArray[i].id ?? ""}), i != 0 {
                    ReelsCacheManager.shared.begin(reelModel: reelsArray[i], position: i)
                }
            }
        }

the Business logic for the buffering is simple, AVPlayer hold the buffer its resources, so by using that the for loop above is calling this function:

    func begin(reelModel: Reel, position: Int){
        
        if NetworkManager.isReachable {
            resType = NetworkManager.isReachableViaWiFi ? Resolution.Medium : Resolution.Low
        }
        
        queue.async { [weak self] in
            self?.cacheAVPlayerItem(reelModel, position)
        }
        //        queue.waitUntilAllOperationsAreFinished()
    }
    
    func cacheAVPlayerItem(_ reel: Reel,_ position: Int) {
        guard let id = reel.id,
              let media = reel.media,
              let url = URL(string: media) else { return }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredMaximumResolution = CGSize(width: 426, height: 240)
        playerItem.preferredPeakBitRate = Double(200000)
        playerItem.preferredForwardBufferDuration = 3
        let player = NRPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        let preloadModel = PlayerPreloadModel(index: position, timeCreated: Date(), id: id, player: player)
        SharedManager.shared.players.append(preloadModel)
    }

and in the ReelsCC, in the Play function the buffered video is assigned to the cell.
AVPlayer can share the buffered data between diffrent elements, for example if var A buffered video1 from URL1 if you try to creat var B and attemp to play Video1 from the same url (URL1) the AVPlayer will play the buffered data in the var A, so the assigning on the play function in the ReelsCC isn't necessary but just used to improve the resources managment, since they are class types, so when you assign them they will share the refrences for the value instead of creating new value.


## Discover
The UI is made in SwiftUI.
It contains: Trending Reels, Trending Channels, Top News, and search. when opening a reel from the trending reels the same above reels module is used. 


## Articles Module

### The module components:
- ArticlesVC:
this is the main Controller.
- HomeCardCell:
This is for the top big card.
- HomeListView:
Normal size cards.
- BulletDetailsVC
This get opened when you tap on any article card of the above.
- CustomBulletsCC
This contains the article summary.

there are seviral catigories in the Articles, and same as in the reels, each one has its own data but same endpoint to get the data with only different parameters. some categories contains reels, on tapping on any of them the above reels module is used.


## Tab Bar
The PTCardTabBarController is used as a Tab Bar. the class TabbarVC is a high level to manage the tab bar.


## Profile (SettingsMainview)
the profile is designed in SwiftUI. The value of "user?.isGuest" is used to controll visibilty of rows in the view.


## CI/CD
This repository contains piplines for testing and deploying. the piplines are disabled.


## important notes
- the pods had conflict, and the conflict resolved by customizing the pods locally (Pods in Pods directory) so the pod isn't part in the GitIgnored and it's not recommended to reinstall the pods.
the proper solution will be having these pods in a local module. untill we do that avoid reinstalling pods.

- the Service and Content App extensions are disable and removed from the build phases for now since they cause issue on running the app on actual devices. so far this not effection the extensions widgets.

- there are files generated by the Swift compiler. These files contain information about the dependencies between Swift source files and are used by the Swift build system to track changes and optimize build times.

they shouldn't be in the project directory itself, and they probably generated due to one of the build phases.
it's safe to remove them. in order to do that you can run the following command on terminal:

rm *.o; rm *.d; rm *.dia; rm *.swiftdeps~; rm *.swiftdeps

- if you facing error such as "Command SwiftCompile failed with nonzero exit code" to the following steps:
1- make sure you signned in for all targets, including the extensions.
2- make sure you using diffrent bundle id for each target.
3- run on actual device.
4- downgrade XCode to 14.2 or lower.
5- make sure you using the same pods I uploaded without making "pod install" or any modification.

if non of these work:
Delete Xcode from Applications Folder and Empty Trash.

Go to ~/Library/Developer and Delete CoreSimulator, Xcode, XCTestDevices Folder. Empty trash

Goto ~/Library/Caches and delete everything starting with com.apple.dt.Xcode, Empty trash

Then Restart your Mac and reinstall Xcode.
