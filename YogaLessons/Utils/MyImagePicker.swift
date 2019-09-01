//
//  PickImageAlert.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import AVFoundation
import UnsplashPhotoPicker

open class MyImagePicker:NSObject, ImgPickerD,NavConrollerD {
    
    let imgPicker:UIImagePickerController
    
    private static let unsplashAccessKey = "68e53687dea3f09526831a1c53b61e8f8abfd26716f92850f8f37388e73c90fe";
    private static let unsplashSecretKey = "4b986b301dd029a522512ed8dfa5662acfce127fc45ac512d306880acc4c7fe4";
    
    private let unsplashVC:UnsplashPhotoPicker
    private var size:UnsplashPhoto.URLKind = .small

    typealias PickerCompletion = (UIImage?,URL?/*url for image search*/,Bool/*if remove*/)->Void
    var completion:PickerCompletion
    
    
    init(allowsEditing:Bool = true,completion:@escaping PickerCompletion) {
        self.completion = completion
        
        imgPicker = UIImagePickerController()
        imgPicker.allowsEditing = allowsEditing
        imgPicker.sourceType = .photoLibrary
        let unsplashConfig = UnsplashPhotoPickerConfiguration(accessKey: MyImagePicker.unsplashAccessKey,secretKey: MyImagePicker.unsplashSecretKey)
        
        unsplashVC = UnsplashPhotoPicker(configuration: unsplashConfig)
        //                                         allowsMultipleSelection: false,
        //                                         memoryCapacity: Int,
        //                                         diskCapacity: Int)
        
        super.init()
        imgPicker.delegate = self
        unsplashVC.photoPickerDelegate = self
    }
    
    func show( hasImage:Bool,size:UnsplashPhoto.URLKind = .small) {
        let alert = UIAlertController.create(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Search photo online".translated, style: .default){ (_) in
            self.size = size
            self.openSplashPicker()
        })
        
        if let action = action(for: .camera, title: "Take a photo".translated) {
            alert.addAction(action)
            action.setValue(#imageLiteral(resourceName: "slr_camera"), forKey: "image")
        }
        
        if let action = action(for: .savedPhotosAlbum, title: "Camera roll".translated) {
            alert.addAction(action)
            action.setValue(#imageLiteral(resourceName: "pictures_folder"), forKey: "image")
        }
        
        if let action = action(for: .photoLibrary, title: "Photo library".translated) {
            alert.addAction(action)
            action.setValue(#imageLiteral(resourceName: "pictures_folder"), forKey: "image")
        }
        
        if hasImage {
            let remove = UIAlertAction(title: "Remove image".translated, style: .destructive) { (action) in
                self.completion(nil,nil,true)
            }
            let trashImg = UIImage(imageLiteralResourceName: "trash")
            
            remove.setValue(trashImg, forKey: "image")
            
            alert.addAction(remove)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".translated, style: .cancel,handler: { _ in}))
        
        guard let sourceVC = UIApplication.shared.presentedVC,
            let srcView = sourceVC.view
            else{return}
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = srcView
            alert.popoverPresentationController?.sourceRect = srcView.bounds
            alert.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        sourceVC.present(alert, animated: true)
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        
        guard UIImagePickerController.isSourceTypeAvailable(type)
        else {return nil}
        
        return UIAlertAction(title: title, style: .default) { _ in
            
            self.imgPicker.sourceType = type
            
            if type == .camera{
                self.checkCamPermission()
                return
            }
            
            UIApplication.shared
                .presentedVC?.present(self.imgPicker, animated: true)
        }
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let infoKey:UIImagePickerController.InfoKey
        = picker.allowsEditing ? .editedImage : .originalImage
        
        let image = info[infoKey] as? UIImage
        
        completion(image,nil,false)
        
        picker.dismiss(animated: true)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completion(nil,nil,false)
    }
    
    private func isCameraAvailble() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    //    MARK: camera
    private func checkCamPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
            
        // The user has previously granted access to the camera.
        case .notDetermined: alertCameraAccessNeeded()
            
            
        // The user has not yet been asked for camera access.
        case .authorized: presentCamera()
        
            
            // The user has previously denied access.
        // The user can't grant access due to restrictions.
        case .restricted, .denied: enableCamPermissionInSetting()
        @unknown default:
            fatalError()
        }
    }
    
    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            imgPicker.sourceType = .camera
            UIApplication.shared.presentedVC?
                .present(self.imgPicker, animated: true)
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video){accessGranted in
            if accessGranted == true {
                self.presentCamera()
            }
        }
    }
    
    
    private func enableCamPermissionInSetting() {
        UIAlertController.create(
            title: "Needs camera access".translated,
            message: "changeCamSetting".translated,
            preferredStyle: .alert
        ).aAction(.init(title: "Cancel".translated, style: .cancel))
        .aAction(.init(title: "Open settings".translated, style: .default) { alert in
            let settingsAppURL = URL(string:UIApplication.openSettingsURLString)!
            
            UIApplication.shared.open(settingsAppURL)
        }).show()
    }
    
    private func alertCameraAccessNeeded() {
        
        UIAlertController.create(
            title: "Needs Camera Access".translated,
            message: "Needs camera access".translated,
            preferredStyle: .alert
        ).aAction(UIAlertAction(title: "Cancel".translated, style: .cancel))
        .aAction(UIAlertAction(title: "Allow Camera".translated, style: .default) { alert in
            self.requestCameraPermission()
        })
        .show()
    }
    
}

extension MyImagePicker:UnsplashPhotoPickerDelegate{
    public func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        
        if let downloadLink = photos.first?.urls[.small]{
            
            completion(nil,downloadLink,false)
        }
        else{
            self.completion(nil,nil,false)
        }
    }
    
    public func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        
    }
    
    func openSplashPicker() {
        UIApplication.shared.presentedVC?.present(unsplashVC, animated: true)
    }
}
