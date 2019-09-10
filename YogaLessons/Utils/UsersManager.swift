//
//  UsersManager.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseAuth

class UsersManager {
    
    static let shared = UsersManager()
    
    let auth:Auth
    
    private init() {
        self.auth = Auth.auth()
    }
    
    func createUser(withEmail email: String, password pass: String,user:YUser,
                    profileImage pic:UIImage?,callback:AuthDataResultCallback?){
        
        auth.createUser(withEmail: email, password: pass){(res, error) in
            
            if let error = error{
                callback?(nil,error)
                return
            }
            
            guard let id = res?.user.uid else{return}
            
            user.id = id
            
            DataSource.shared
                .saveUserToDb(user : user){
                    YUser.currentUser = user
                
                    StorageManager.shared.saveCurrentUser(profileImage: pic)
                    
                    callback?(res,error)
            }
        }
    }
    
    func sendResetPassword(completion:((Error?)->Void)?){
        guard let email = auth.currentUser?.email
            else{return}
        auth.sendPasswordReset(withEmail: email,completion: completion)
    }
}
