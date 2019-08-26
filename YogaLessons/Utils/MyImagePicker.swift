//
//  PickImageAlert.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import AVFoundation

open class MyImagePicker:NSObject, ImgPickerD,NavConrollerD {
    
    let imgPicker:UIImagePickerController
    
    var completion:(
    (UIImage?,Bool/*if remove*/)->Void)?
    
    init(allowsEditing:Bool = true,completion:@escaping (UIImage?,Bool)->Void) {
        self.completion = completion
        
        imgPicker = UIImagePickerController()
        imgPicker.allowsEditing = allowsEditing
        imgPicker.sourceType = .photoLibrary
        super.init()
        imgPicker.delegate = self
    }
    
    func show( hasImage:Bool) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        if let action = action(for: .camera, title: "Take a photo") {
            alert.addAction(action)
            action.setValue(#imageLiteral(resourceName: "slr_camera"), forKey: "image")
        }
        
        if let action = action(for: .savedPhotosAlbum, title: "Camera roll") {
            alert.addAction(action)
            action.setValue(#imageLiteral(resourceName: "pictures_folder"), forKey: "image")
        }
        
        if let action = action(for: .photoLibrary, title: "Photo library") {
            alert.addAction(action)
            action.setValue(#imageLiteral(resourceName: "pictures_folder"), forKey: "image")
        }
        
        if hasImage {
            let remove = UIAlertAction(title: "Remove image", style: .destructive) { (action) in
                self.completion?(nil,true)
            }
            let trashImg = UIImage(imageLiteralResourceName: "trash")
            
            remove.setValue(trashImg, forKey: "image")
            
            alert.addAction(remove)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: { _ in}))
        
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
        
        completion?(image,false)
        
        picker.dismiss(animated: true)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completion?(nil,false)
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
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Please change settings of camera access for setting a new picture.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let openSetting = UIAlertAction(title: "Open settings", style: .default) { alert in
            let settingsAppURL = URL(string:UIApplication.openSettingsURLString)!
            
            UIApplication.shared.open(settingsAppURL)
        }
        
        alert.addAction(openSetting)
        
        UIApplication.shared.presentedVC?.present(alert, animated: true, completion: nil)
    }
    
    private func alertCameraAccessNeeded() {
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required for setting a new picture.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .default) { alert in
            self.requestCameraPermission()
        })
        
        UIApplication.shared.presentedVC?.present(alert, animated: true, completion: nil)
    }
}
