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
    
    func saveCurrentUser(profileImage img:UIImage?,completion:(()->Void)? = nil) {
        
        guard let image = img else {return}
        
        guard let uid = Auth.auth().currentUser?.uid
        else{
            print("no user found to save image for!")
            return
        }
        
        // Create a reference to the file you want to upload
        let userImgByID = storage.reference(withPath: USERS_IMAGES).child(uid)
        
        guard let imgData = image.jpegData(compressionQuality: 0.0) else {return }
        
        userImgByID.putData(imgData,metadata: nil){(metadata, error) in
            // Fetch the download URL
            userImgByID.downloadURL { url, error in
                    if let error = error {
                        // Handle any errors
                        ErrorAlert.show(message: error.localizedDescription)
                        completion?()
                    } else {
                        // Get the download URL for 'images/stars.jpg'
                        
                        guard let path = url?.absoluteString else{return}
                        
                        self.saveImgToDB(from: path,completion: completion)
                    }
                }
            
        }
    }
    
    fileprivate func getUserImageRef(_ uid: String) -> DatabaseReference {
        let path = [DataSource.TableNames.users.rawValue,
                    uid,
                    YUser.Keys.profileImg]
            .joined(separator: "/")
        
        return Database.database().reference().child(path)
    }
    
    private func saveImgToDB(from path:String,completion:(()->Void)?){
        
        guard let currentUser = YUser.currentUser,
                let uid = currentUser.id
        else {return}
        
        //save the image url in current users obj
        currentUser.profileImageUrl = path
        
        //save to DB
        getUserImageRef(uid).setValue(path){(error,childRef) in
                
                if let err = error{
                    ErrorAlert.show(message: err.localizedDescription)
                    completion?()
                    return
                }
                
                print("Image successfully updated in DB")
                completion?()
        }
    }
    
    func setProfileImage(imgView:UIImageView){
        if let url = YUser.currentUser?.profileImageUrl{
            setImage(withUrl: url, imgView: imgView,placeHolderImg: #imageLiteral(resourceName: "camera"))
        }
    }
    
    func setImage(withUrl url:String?,imgView:UIImageView,placeHolderImg:UIImage? = nil,completion:((UIImage?, Error?, URL?)->Void)? = nil ){
    
        guard let url = url, let imgUrl = URL(string: url)
            else {return}//check to not show indicator
        
        setImage(withUrl: imgUrl, imgView: imgView,placeHolderImg: placeHolderImg,completion: completion)
    }
    func setImage(withUrl url:URL?,imgView:UIImageView,placeHolderImg:UIImage? = nil,completion:((UIImage?, Error?, URL?)->Void)? = nil ){
        
//        SVProgressHUD.setContainerView(imgView)
//        SVProgressHUD.show()
       
        imgView.showActivityIndicator()
        
        imgView.sd_setImage(with: url,placeholderImage: placeHolderImg)
        { (image, error, type, url) in
//            SVProgressHUD.dismiss()
            
            imgView.hideActivityIndicator()
            
            completion?(image,error,url)
        }
    
    }
    
    func setImage(of aClass:Class, imgView:UIImageView){
        
        guard let teacher = DataSource.shared.getTeacher(by: aClass.uid),
                let url = teacher.profileImageUrl
                else{return}
                
        setImage(withUrl: url, imgView: imgView)
    }
    
    
    func removeCurrentUserProfileImage(completion:(()->Void)?) {
        guard let uid = Auth.auth().currentUser?.uid
            else{
                print("no user found to save image for!")
                return
        }
        
        // remove the file from storage
        storage.reference(withPath: USERS_IMAGES)
            .child(uid).delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    ErrorAlert.show(message: error.localizedDescription)
                    completion?()
                } else {
                    // File deleted successfully
                    self.removeUserProfileImageFromDB(completion:completion)
                }
        }
    }
    
    private func removeUserProfileImageFromDB(completion:(()->Void)?){
        guard let currentUser = YUser.currentUser,
            let uid = currentUser.id
            else {return}
        
        //save the image url in current users obj
        currentUser.profileImageUrl = nil
        
        //upadte in DB
        getUserImageRef(uid).removeValue(){(error,childRef) in
                
                if let err = error{
                    ErrorAlert.show(message: err.localizedDescription)
                    completion?()
                    return
                }
            
                completion?()
        }
    }
}
