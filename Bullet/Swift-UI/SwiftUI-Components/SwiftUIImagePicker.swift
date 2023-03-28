//
//  SwiftUIImagePicker.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/23/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import SwiftUI
import MobileCoreServices

struct VideoPicker : UIViewControllerRepresentable {
    enum MediaTypesToShow {
        case videoOnly, imageOnly, imageAndVieo
    }
    
    class Coordinator : NSObject , UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent : VideoPicker
            
        init(_ parent : VideoPicker){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiimage = info[.editedImage] as? UIImage{
                parent.image = uiimage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image : UIImage?
    @State var source : UIImagePickerController.SourceType = .camera
    var allowsEditing: Bool = true
//    var mediaTypesToShow: MediaTypesToShow = .videoOnly
    
//    init(image: Binding<UIImage?>, source: UIImagePickerController.SourceType, mediaTypesToShow: MediaTypesToShow = .imageAndVieo) {
//        self._image = image
//        self.source = source
//        self.mediaTypesToShow = mediaTypesToShow
//    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = source
        picker.allowsEditing = allowsEditing
        picker.mediaTypes = [String (kUTTypeMovie)]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
}

struct SwiftUIImagePicker : UIViewControllerRepresentable {
    
    enum MediaTypesToShow {
        case videoOnly, imageOnly, imageAndVieo
    }
    
    class Coordinator : NSObject , UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent : SwiftUIImagePicker
            
        init(_ parent : SwiftUIImagePicker ){
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let uiimage = info[parent.allowsEditing ? .editedImage : .originalImage] as? UIImage{
                parent.image = uiimage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    

    @Environment(\.presentationMode) var presentationMode
    @Binding var image : UIImage?
    @State var source : UIImagePickerController.SourceType = .camera
    var allowsEditing: Bool = true
    /// WARNING: Setting this variable while **source** is not set as `.camera` will produce a crash
    var cameraDevice: UIImagePickerController.CameraDevice? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = source
        if let cameraDevice = cameraDevice {
            picker.cameraDevice = cameraDevice
        }
        picker.allowsEditing = allowsEditing
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
}


