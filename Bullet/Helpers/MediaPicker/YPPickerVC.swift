//
//  YYPPickerVC.swift
//  YPPickerVC
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import Stevia
import Photos

protocol ImagePickerDelegate: AnyObject {
    func noPhotos()
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool
}

open class YPPickerVC: YPBottomPager, YPBottomPagerDelegate {
    
    let albumsManager = YPAlbumsManager()
    var shouldHideStatusBar = false
    var initialStatusBarHidden = false
    weak var imagePickerDelegate: ImagePickerDelegate?
    
    override open var prefersStatusBarHidden: Bool {
        return (shouldHideStatusBar || initialStatusBarHidden) && YPConfig.hidesStatusBar
    }
    
    /// Private callbacks to YPImagePicker
    public var didClose:(() -> Void)?
    public var didSelectItems: (([YPMediaItem]) -> Void)?
    
    enum Mode {
        case library
        case libraryPhotoOnly
        case libraryVideoOnly
        case camera
        case video
    }
    
    private var libraryVC: YPLibraryVC?
    private var libraryPhotoVC: YPLibraryVC?
    private var libraryVideoVC: YPLibraryVC?
//    private var cameraVC: YPCameraVC?
//    private var videoVC: YPVideoCaptureVC?
    
    var mode = Mode.camera
    
    var capturedImage: UIImage?
    var navView: NavigationBar?
    var lastSelectedAlbumName: String?
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        addCustomNavigationView()
        view.theme_backgroundColor = GlobalPicker.backgroundColor//YPConfig.colors.safeAreaBackgroundColor
        
        delegate = self
        
        // Force Library only when using `minNumberOfItems`.
        if YPConfig.library.minNumberOfItems > 1 {
            YPImagePickerConfiguration.shared.screens = [.library]
        }
        
        // Library
        if YPConfig.screens.contains(.library) {
            libraryVC = YPLibraryVC()
            libraryVC?.selectionType = .all
            libraryVC?.delegate = self
        }
        
        if YPConfig.screens.contains(.libraryPhotoOnly) {
            libraryPhotoVC = YPLibraryVC()
            libraryPhotoVC?.selectionType = .photo
            libraryPhotoVC?.delegate = self
        }
        
        if YPConfig.screens.contains(.libraryVideoOnly) {
            libraryVideoVC = YPLibraryVC()
            libraryVideoVC?.selectionType = .video
            libraryVideoVC?.delegate = self
        }
        
        // Camera
        if YPConfig.screens.contains(.photo) {
//            cameraVC = YPCameraVC()
//            cameraVC?.didCapturePhoto = { [weak self] img in
//                self?.didSelectItems?([YPMediaItem.photo(p: YPMediaPhoto(image: img,
//                                                                        fromCamera: true))])
//            }
        }
        
        // Video
        if YPConfig.screens.contains(.video) {
//            videoVC = YPVideoCaptureVC()
//            videoVC?.didCaptureVideo = { [weak self] videoURL in
//                self?.didSelectItems?([YPMediaItem
//                    .video(v: YPMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
//                                           videoURL: videoURL,
//                                           fromCamera: true))])
//            }
        }
        
        // Show screens
        var vcs = [UIViewController]()
        for screen in YPConfig.screens {
            switch screen {
            case .library:
                if let libraryVC = libraryVC {
                    vcs.append(libraryVC)
                }
            case .photo:
                break
//                if let cameraVC = cameraVC {
//                    vcs.append(cameraVC)
//                }
            case .video:
                break
//                if let videoVC = videoVC {
//                    vcs.append(videoVC)
//                }
            case .libraryPhotoOnly:
                if let libraryVC = libraryPhotoVC {
                    vcs.append(libraryVC)
                }
            case .libraryVideoOnly:
                if let libraryVC = libraryVideoVC {
                    vcs.append(libraryVC)
                }
            }
        }
        controllers = vcs
        
        // Select good mode
        if YPConfig.screens.contains(YPConfig.startOnScreen) {
            switch YPConfig.startOnScreen {
            case .library:
                mode = .library
            case .photo:
                mode = .camera
            case .video:
                mode = .video
            case .libraryPhotoOnly:
                mode = .libraryPhotoOnly
            case .libraryVideoOnly:
                mode = .libraryVideoOnly
            }
        }
        
        // Select good screen
        if let index = YPConfig.screens.firstIndex(of: YPConfig.startOnScreen) {
            startOnPage(index)
        }
        
        YPHelper.changeBackButtonIcon(self)
        YPHelper.changeBackButtonTitle(self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        cameraVC?.v.shotButton.isEnabled = true
        
        updateMode(with: currentController)
        
        navigationController?.navigationBar.isHidden = false
        addCustomNavigationView()
        
    }
    
    
    func addCustomNavigationView() {
        
        navigationController?.navigationBar.theme_barTintColor = GlobalPicker.backgroundColor
        if navView == nil {
            navView = NavigationBar(frame: navigationController?.navigationBar.frame ?? .zero)
            navView?.delegate = self
            self.view.bringSubviewToFront(navView!)
            self.navigationController?.view.addSubview(navView!)
            if lastSelectedAlbumName != nil {
                navView?.titleLabel.text = lastSelectedAlbumName
            }
        }
        navView?.frame = navigationController?.navigationBar.frame ?? .zero
        navView?.frame.size.height += 6
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldHideStatusBar = true
        initialStatusBarHidden = true
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        addCustomNavigationView()
    }
    
    internal func pagerScrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    func modeFor(vc: UIViewController) -> Mode {
        switch vc {
        case is YPLibraryVC:
            if (vc as? YPLibraryVC)?.selectionType == .photo {
                return .libraryPhotoOnly
            } else if (vc as? YPLibraryVC)?.selectionType == .video {
                return .libraryVideoOnly
            }
            return .library
//        case is YPCameraVC:
//            return .camera
//        case is YPVideoCaptureVC:
//            return .video
        default:
            return .camera
        }
    }
    
    func pagerDidSelectController(_ vc: UIViewController) {
        updateMode(with: vc)
    }
    
    func updateMode(with vc: UIViewController) {
        stopCurrentCamera()
        
        // Set new mode
        mode = modeFor(vc: vc)
        
        // Re-trigger permission check
        if let vc = vc as? YPLibraryVC {
            vc.checkPermission()
        }
//        else if let cameraVC = vc as? YPCameraVC {
//            cameraVC.start()
//        } else if let videoVC = vc as? YPVideoCaptureVC {
//            videoVC.start()
//        }
    
        updateUI()
    }
    
    func stopCurrentCamera() {
        switch mode {
        case .library:
            libraryVC?.pausePlayer()
            libraryVideoVC?.pausePlayer()
        case .camera: break
//            cameraVC?.stopCamera()
        case .video: break
//            videoVC?.stopCamera()
        case .libraryPhotoOnly:
            libraryVC?.pausePlayer()
            libraryVideoVC?.pausePlayer()
        case .libraryVideoOnly:
            libraryVC?.pausePlayer()
            libraryVideoVC?.pausePlayer()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldHideStatusBar = false
        stopAll()
        
        lastSelectedAlbumName = navView?.titleLabel.text
        navView?.removeFromSuperview()
        navView = nil
    }
    
    @objc
    func navBarTapped() {
        
        var selectedType: YPLibraryVC.mediaType = .all
        if mode == .libraryPhotoOnly {
            selectedType = .photo
        } else if mode == .libraryVideoOnly {
            selectedType = .video
        }
        
        let vc = YPAlbumVC(albumsManager: albumsManager, selectedType: selectedType)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.tintColor = .ypLabel
        
        vc.didSelectAlbum = { [weak self] album in
            if self?.mode == .libraryPhotoOnly {
                self?.libraryPhotoVC?.setAlbum(album)
            } else if self?.mode == .libraryVideoOnly {
                self?.libraryVideoVC?.setAlbum(album)
            } else {
                self?.libraryVC?.setAlbum(album)
            }
            self?.setTitleViewWithTitle(aTitle: album.title)
            navVC.dismiss(animated: true, completion: nil)
        }
        present(navVC, animated: true, completion: nil)
    }
    
    func setTitleViewWithTitle(aTitle: String) {
        navView?.titleLabel.text = aTitle
//        let titleView = UIView()
//        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
//
//        let label = UILabel()
//        label.text = aTitle
//        // Use YPConfig font
//        label.font = YPConfig.fonts.pickerTitleFont
//
//        // Use custom textColor if set by user.
//        if let navBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[.foregroundColor] as? UIColor {
//            label.textColor = navBarTitleColor
//        }
//
//        if YPConfig.library.options != nil {
//            titleView.sv(
//                label
//            )
//            |-(>=8)-label.centerHorizontally()-(>=8)-|
//            align(horizontally: label)
//        } else {
//            let arrow = UIImageView()
//            arrow.image = YPConfig.icons.arrowDownIcon
//            arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
//            arrow.tintColor = .ypLabel
//
//            let attributes = UINavigationBar.appearance().titleTextAttributes
//            if let attributes = attributes, let foregroundColor = attributes[.foregroundColor] as? UIColor {
//                arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
//                arrow.tintColor = foregroundColor
//            }
//
//            let button = UIButton()
//            button.addTarget(self, action: #selector(navBarTapped), for: .touchUpInside)
//            button.setBackgroundColor(UIColor.white.withAlphaComponent(0.5), forState: .highlighted)
//
//            titleView.sv(
//                label,
//                arrow,
//                button
//            )
//            button.fillContainer()
//            |-(>=8)-label.centerHorizontally()-arrow-(>=8)-|
//            align(horizontally: label-arrow)
//        }
//
//        label.firstBaselineAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -14).isActive = true
//
//        titleView.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        navigationItem.titleView = titleView
    }
    
    func updateUI() {
        
//		if !YPConfig.hidesCancelButton {
//			// Update Nav Bar state.
//			navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""),
//                                                           style: .plain,
//                                                           target: self,
//                                                           action: #selector(close))
//		}
        switch mode {
        case .library:
            setTitleViewWithTitle(aTitle: libraryVC?.title ?? "")
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
//                                                                style: .done,
//                                                                target: self,
//                                                                action: #selector(done))
//            navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
//
//            // Disable Next Button until minNumberOfItems is reached.
//            navigationItem.rightBarButtonItem?.isEnabled =
//				libraryVC!.selection.count >= YPConfig.library.minNumberOfItems

        case .camera:
            navigationItem.titleView = nil
//            title = cameraVC?.title
            navigationItem.rightBarButtonItem = nil
        case .video:
            navigationItem.titleView = nil
//            title = videoVC?.title
            navigationItem.rightBarButtonItem = nil
        case .libraryPhotoOnly:
            setTitleViewWithTitle(aTitle: libraryPhotoVC?.title ?? "")
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
//                                                                style: .done,
//                                                                target: self,
//                                                                action: #selector(done))
//            navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
//
//            // Disable Next Button until minNumberOfItems is reached.
//            navigationItem.rightBarButtonItem?.isEnabled =
//                libraryPhotoVC!.selection.count >= YPConfig.library.minNumberOfItems
        case .libraryVideoOnly:
            setTitleViewWithTitle(aTitle: libraryVideoVC?.title ?? "")
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""),
//                                                                style: .done,
//                                                                target: self,
//                                                                action: #selector(done))
//            navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
//
//            // Disable Next Button until minNumberOfItems is reached.
//            navigationItem.rightBarButtonItem?.isEnabled =
//                libraryVideoVC!.selection.count >= YPConfig.library.minNumberOfItems
        }

//        navigationItem.rightBarButtonItem?.setFont(font: YPConfig.fonts.rightBarButtonFont, forState: .normal)
//        navigationItem.rightBarButtonItem?.setFont(font: YPConfig.fonts.rightBarButtonFont, forState: .disabled)
//        navigationItem.leftBarButtonItem?.setFont(font: YPConfig.fonts.leftBarButtonFont, forState: .normal)
        
    }
    
    @objc
    func close() {
        // Cancelling exporting of all videos
        if let libraryVC = libraryVC {
            libraryVC.mediaManager.forseCancelExporting()
        } else if let libraryVideoVC = libraryVideoVC {
            libraryVideoVC.mediaManager.forseCancelExporting()
        }
        self.didClose?()
    }
    
    // When pressing "Next"
    @objc
    func done() {
        
        if mode == .library {
            
            guard let libraryVC = libraryVC else {  return }
            
            libraryVC.doAfterPermissionCheck { [weak self] in
                libraryVC.selectedMedia(photoCallback: { photo in
                    self?.didSelectItems?([YPMediaItem.photo(p: photo)])
                }, videoCallback: { video in
                    self?.didSelectItems?([YPMediaItem
                        .video(v: video)])
                }, multipleItemsCallback: { items in
                    self?.didSelectItems?(items)
                })
            }
        }
        
        if mode == .libraryPhotoOnly {
            
            guard let libraryPhotoVC = libraryPhotoVC else { return }
            
            libraryPhotoVC.doAfterPermissionCheck { [weak self] in
                libraryPhotoVC.selectedMedia(photoCallback: { photo in
                    self?.didSelectItems?([YPMediaItem.photo(p: photo)])
                }, videoCallback: { video in
                    self?.didSelectItems?([YPMediaItem
                        .video(v: video)])
                }, multipleItemsCallback: { items in
                    self?.didSelectItems?(items)
                })
            }
        }
        
        if mode == .libraryVideoOnly {
            
            guard let libraryVideoVC = libraryVideoVC else {  return }
            
            libraryVideoVC.doAfterPermissionCheck { [weak self] in
                libraryVideoVC.selectedMedia(photoCallback: { photo in
                    self?.didSelectItems?([YPMediaItem.photo(p: photo)])
                }, videoCallback: { video in
                    self?.didSelectItems?([YPMediaItem
                        .video(v: video)])
                }, multipleItemsCallback: { items in
                    self?.didSelectItems?(items)
                })
            }
        }
    }
    
    func stopAll() {
        libraryVC?.v.assetZoomableView.videoView.deallocate()
        libraryPhotoVC?.v.assetZoomableView.videoView.deallocate()
        libraryVideoVC?.v.assetZoomableView.videoView.deallocate()
//        videoVC?.stopCamera()
//        cameraVC?.stopCamera()
    }
}

extension YPPickerVC: YPLibraryViewDelegate {
    
    
    public func libraryViewDidTapNextFailedWithError() {
        
        navView?.hideLoader()
    }
    
    
    public func libraryViewDidTapNext() {
        
        if mode == .libraryPhotoOnly {
            libraryPhotoVC?.isProcessing = true
            DispatchQueue.main.async {
                self.v.scrollView.isScrollEnabled = false
                self.libraryPhotoVC?.v.fadeInLoader()
                self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
            }
        } else if mode == .libraryVideoOnly {
            libraryVideoVC?.isProcessing = true
            DispatchQueue.main.async {
                self.v.scrollView.isScrollEnabled = false
                self.libraryVideoVC?.v.fadeInLoader()
                self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
            }
        } else {
            libraryVC?.isProcessing = true
            DispatchQueue.main.async {
                self.v.scrollView.isScrollEnabled = false
                self.libraryVC?.v.fadeInLoader()
                self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
            }
        }
        
    }
    
    public func libraryViewStartedLoadingImage() {
		//TODO remove to enable changing selection while loading but needs cancelling previous image requests.
        if mode == .libraryPhotoOnly {
            libraryPhotoVC?.isProcessing = true
            DispatchQueue.main.async {
                self.libraryPhotoVC?.v.fadeInLoader()
            }
        } else if mode == .libraryVideoOnly {
            libraryVideoVC?.isProcessing = true
            DispatchQueue.main.async {
                self.libraryVideoVC?.v.fadeInLoader()
            }
        } else {
            libraryVC?.isProcessing = true
            DispatchQueue.main.async {
                self.libraryVC?.v.fadeInLoader()
            }
        }
        
    }
    
    public func libraryViewFinishedLoading() {
        
        if mode == .libraryPhotoOnly {
            libraryPhotoVC?.isProcessing = false
            DispatchQueue.main.async {
                self.v.scrollView.isScrollEnabled = YPConfig.isScrollToChangeModesEnabled
                self.libraryPhotoVC?.v.hideLoader()
                self.updateUI()
            }
        } else if mode == .libraryVideoOnly {
            libraryVideoVC?.isProcessing = false
            DispatchQueue.main.async {
                self.v.scrollView.isScrollEnabled = YPConfig.isScrollToChangeModesEnabled
                self.libraryVideoVC?.v.hideLoader()
                self.updateUI()
            }
        } else {
            libraryVC?.isProcessing = false
            DispatchQueue.main.async {
                self.v.scrollView.isScrollEnabled = YPConfig.isScrollToChangeModesEnabled
                self.libraryVC?.v.hideLoader()
                self.updateUI()
            }
        }
        
        
    }
    
    public func libraryViewDidToggleMultipleSelection(enabled: Bool) {
        var offset = v.header.frame.height
        if #available(iOS 11.0, *) {
            offset += v.safeAreaInsets.bottom
        }
        
        v.header.bottomConstraint?.constant = enabled ? offset : 0
        v.layoutIfNeeded()
        updateUI()
    }
    
    public func noPhotosForOptions() {
        self.dismiss(animated: true) {
            self.imagePickerDelegate?.noPhotos()
        }
    }
    
    public func libraryViewShouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return imagePickerDelegate?.shouldAddToSelection(indexPath: indexPath, numSelections: numSelections) ?? true
    }
}


extension YPPickerVC: NavigationBarDelegate {
    
    func didTapNextButton() {
        navView?.showLoader()
        done()
    }
    
    func didTapGallery() {
        navBarTapped()
    }
    
    func didTapCancel() {
        self.close()
    }
    
    
}
