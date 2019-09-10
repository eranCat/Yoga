//
//  StorageManager.swift
//  YogaLessons
//
//  Created by Eran karaso on 04/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage
import SVProgressHUD

class StorageManager {
    
    static let shared = StorageManager()
    
    let storage:Storage
    
    let USERS_IMAGES = "Users/images/profile"
    let EVENTS_IMAGES = "Events/images"

    private init(){
        self.storage = Storage.storage()
    }
    
    func saveCurrentUser(profileImage img:UIImage?,completion:((Error?)->Void)? = nil) {
        
        guard let image = img else {return}
        
        guard let uid = Auth.auth().currentUser?.uid
        else{
            completion?(UserErrors.noUserFound)
            return
        }
        
        // Create a reference to the file you want to upload
        let userImgByID = storage.reference(withPath: USERS_IMAGES).child(uid)
        
        guard let imgData = image.jpegData(compressionQuality: 0.0) else {
            completion?(JsonErrors.castFailed)//image data for storage
            return
        }
        
        userImgByID.putData(imgData,metadata: nil){(metadata, error) in
            // Fetch the download URL
            userImgByID.downloadURL { url, error in
                    if let error = error {
                        completion?(error)
                        return
                    }
                    // Get the download URL for 'images/stars.jpg'
                
                    guard let path = url?.absoluteString else{
                        completion?(StorageErrors.problemWithUrl)
                        return
                    }
                
                    self.saveImgToDB(from: path,completion: completion)
            }
        }
    }
    
    var userImageRef : DatabaseReference {
        
        let uid = YUser.currentUser!.id
        
        let path =
            [DataSource.TableNames.users.rawValue,uid,YUser.Keys.profileImg]
            .joined(separator: "/")
        
        return Database.database().reference().child(path)
    }
    
    private func saveImgToDB(from path:String,completion:((Error?)->Void)?){
        
        guard let currentUser = YUser.currentUser
        else {
            completion?(UserErrors.noUserFound)
            return
        }
        
        //save the image url in current users obj
        currentUser.profileImageUrl = path
        
        //save to DB
        userImageRef.setValue(path){err,_ in
            completion?(err)
        }
    }
    
    func setProfileImage(imgView:UIImageView){
        if let url = YUser.currentUser?.profileImageUrl{
            setImage(withUrl: url, imgView: imgView,placeHolderImg: #imageLiteral(resourceName: "camera"))
        }
    }
    
    func setImage(withUrl url:String?,imgView:UIImageView,
                  placeHolderImg:UIImage? = nil,completion:((Error?,UIImage?)->Void)? = nil ){
        
        setImage(withUrl: URL(string: url!), imgView: imgView,placeHolderImg: placeHolderImg,completion: completion)
    }
    func setImage(withUrl url:URL?,imgView:UIImageView,
                  placeHolderImg:UIImage? = nil,completion:((Error?,UIImage?)->Void)? = nil ){
        
        imgView.showActivityIndicator()
        
        imgView.sd_setImage(with: url,placeholderImage: placeHolderImg)
        { (image, error, type, url) in
            
            imgView.hideActivityIndicator()
            completion?(error,image)
        }
    
    }
    
    func setImage(of aClass:Class, imgView:UIImageView){
        
        guard let teacher = DataSource.shared.getTeacher(by: aClass.uid),
                let url = teacher.profileImageUrl
                else{return}
                
        setImage(withUrl: url, imgView: imgView)
    }
    
    
    func removeCurrentUserProfileImage(completion:((Error?)->Void)?) {
        guard let uid = Auth.auth().currentUser?.uid
            else{
                completion?(UserErrors.noUserFound)
                return
        }
        
        // remove the file from storage
        storage.reference(withPath: USERS_IMAGES)
            .child(uid).delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    completion?(error)
                } else {
                    // File deleted successfully
                    self.removeUserProfileImageFromDB(completion:completion)
                }
        }
    }
    
    private func removeUserProfileImageFromDB(completion:((Error?)->Void)?){
        guard let currentUser = YUser.currentUser
            else {
                completion?(UserErrors.noUserFound)
                return}
        
        //save the image url in current users obj
        currentUser.profileImageUrl = nil
        
        //upadte in DB
        userImageRef.removeValue(){err,_ in completion?(err)}
    }
}
