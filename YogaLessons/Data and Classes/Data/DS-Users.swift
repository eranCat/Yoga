//
//  DS-Users.swift
//  YogaLessons
//
//  Created by Eran karaso on 12/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Firebase

extension DataSource{
    
    func convertUser(from snapshot:DataSnapshot) -> YUser? {
        guard let userDict = snapshot.value as? JSON,
            let userTypeRV = userDict[YUser.Keys.type] as? Int,
            let userType = UserType(rawValue: userTypeRV)
        else{return nil}
        
        switch userType{
        case .student:
            return YUser(userDict)
        case .teacher:
           return Teacher(userDict)
        }
    }
    
    func loadUsers(done:DSTaskListener?) {
        let usersRef = ref.child(TableNames.users.rawValue)
        let query = usersRef.queryOrdered(byChild: YUser.Keys.type)

        query.observeSingleEvent(of: .value) { (snapshot) in
            guard let values = snapshot.children.allObjects as? [DataSnapshot]
                else{
                    done?(JsonErrors.castFailed)
                    return
                }
            self.usersList.removeAll()
            //        self.teachersList.removeAll()
            values.forEach{ self.usersList[$0.key] = self.convertUser(from: $0) }

            done?(nil)
        }
    }

//    func setLoggedUser()->Bool {
//        guard let uid = Auth.auth().currentUser?.uid,
//        let user = usersList[uid]
//            else{ return false}
//
//        //find first in users/teachers
//
//        YUser.currentUser = user
//
//        return true
//    }
    
    func fetchLoggedUser(forceDownload:Bool = false,done:((YUser?,Error?)->Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid
            else{
                done?(nil,UserErrors.noUserFound)
                return
        }

        //kind of caching
        if !forceDownload, let user = YUser.currentUser{
            done?(user,nil)
            return
        }

        fetchUserIfNeeded(by: uid) { user, err in
            YUser.currentUser = user
            done?(user,err)
        }
    }
    
    func fetchUserIfNeeded(by id:String,done:@escaping (YUser?,Error?)->Void) {
        if let user = usersList[id] {
            done(user,nil)
            return
        }
        
        ref.child(TableNames.users.rawValue)
            .child(id)
            .observeSingleEvent(of: .value){snapshot in
                
                guard let user = self.convertUser(from: snapshot)
                    else{
                        done(nil,JsonErrors.castFailed)
                        return
                }
                self.usersList[user.id] = user
                done(user,nil)
        }
    }
    
    func updateCurrentUserValue(forKey key:YUser.UserKeys,_ value:Any) {
        
        guard let uid = Auth.auth().currentUser?.uid
            ,let currentUser = YUser.currentUser
            else {return}
        
        let ref = Database.database()
            .reference(withPath: TableNames.users.rawValue)
            .child(uid)
        
        guard let val = currentUser.setValue(value, forKey: key)
            else{return}
        
        
        usersList[uid] = currentUser
        
        
        ref.updateChildValues([key.rawValue:val]){error,dbRef in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            print("\(key) updated -> [\(value):\(type(of: value))]")
        }
    }
    
    func saveUserToDb(user: YUser,_ completion:@escaping (Error?)->Void) {
        
        ref.child(TableNames.users.rawValue)
            .child(user.id).setValue(user.encode()){error,_ in
                completion(error)
            }
    }
    
    func getUser(by id:String) -> YUser? {
        return usersList[id]
    }

    func getTeacher(by uid:String) -> Teacher? {
        return getUser(by: uid) as? Teacher
    }
}
