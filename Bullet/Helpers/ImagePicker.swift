//
//  ImagePicker.swift
//  Bullet
//
//  Created by Khadim Hussain on 29/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ImagePicker: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    typealias Handler = ((UIImage) -> ())
    weak var viewController: UIViewController?
    var onPick: Handler?
    var editingEnabled = false
    
    func show() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let sheet = UIAlertController(title: NSLocalizedString("From where you would like to pick photo?", comment: ""), message: "", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { [weak self] (action) in
            self?.showCamera(picker)
        }
        
        let library = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .default) { [weak self] (action) in
            self?.showPhotoLibrary(picker)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        
        viewController?.showDetailViewController(sheet, sender: viewController)
    }
    
    private func showCamera(_ picker: UIImagePickerController) {
        picker.sourceType = .camera
        picker.allowsEditing = editingEnabled
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            picker.modalPresentationStyle = .overFullScreen
            viewController?.showDetailViewController(picker, sender: viewController)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (status) in
                DispatchQueue.main.async {
                    self?.showCamera(picker)
                }
            }
        case .denied, .restricted:
            showDeniedAlert(with: NSLocalizedString("Access needed for your camera", comment: ""))
        @unknown default: break
        }
    }
    
    private func showPhotoLibrary(_ picker: UIImagePickerController) {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = editingEnabled
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            picker.modalPresentationStyle = .overFullScreen
            viewController?.showDetailViewController(picker, sender: viewController)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                DispatchQueue.main.async {
                    self?.showPhotoLibrary(picker)
                }
            }
        case .denied, .restricted:
            showDeniedAlert(with: NSLocalizedString("Access needed for your photo library", comment: ""))
        case .limited: break
            
        @unknown default:break
            
        }
    }
    
    func showDeniedAlert(with title: String?) {
        let alert = UIAlertController(title: title, message: NSLocalizedString("Kindly open settings and enable access", comment: ""), preferredStyle: .alert)
        let open = UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""), style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(open)
        alert.addAction(cancel)
        viewController?.showDetailViewController(alert, sender: viewController)
    }
    
    func showRestrictedAlert(with title: String?) {
        let alert = UIAlertController(title: title, message: NSLocalizedString("Kindly open settings and enable access", comment: ""), preferredStyle: .alert)
        let open = UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""), style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(open)
        alert.addAction(cancel)
        viewController?.showDetailViewController(alert, sender: viewController)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if editingEnabled {
            if let image = info[.editedImage] as? UIImage {
                onPick?(image)
            }
        }
        else {
            if let image = info[.originalImage] as? UIImage {
                onPick?(image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

