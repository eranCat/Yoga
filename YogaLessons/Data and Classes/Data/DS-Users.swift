//
//  DS-Users.swift
//  YogaLessons
//
//  Created by Eran karaso on 12/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Firebase

extension DataSource{
    
    func convertValuesToUsers(_ values:[DataSnapshot]) {
        
        self.usersList.removeAll()
        self.teachersList.removeAll()
        
        for child in values{
            guard let userDict = child.value as? JSON,
                let userTypeRV = userDict[YUser.Keys.type] as? Int,
                let userType = UserType(rawValue: userTypeRV)
                else{return}
            
            
            switch userType{
            case .student:
                let user = YUser(userDict)
                self.usersList[user.id] = user
            case .teacher:
                let teacher = Teacher(userDict)
                self.teachersList[teacher.id] = teacher
            }
        }
    }
    
    func loadUsers(done:DSTaskListener?) {
        let usersRef = ref.child(TableNames.users.rawValue)
        let query = usersRef.queryOrdered(byChild: YUser.Keys.name)
        
        query.observe(.value) { (snapshot) in
            guard let values = snapshot.children.allObjects as? [DataSnapshot]
                else{
                    done?(JsonErrors.castFailed)
                    return
                }
            self.convertValuesToUsers(values)
            
            done?(nil)
        }
    }
    
    func setLoggedUser()->Bool {
        guard let uid = Auth.auth().currentUser?.uid,
        let user = usersList[uid] ?? teachersList[uid]
            else{ return false}
        
        //find first in users/teachers
        
        YUser.currentUser = user
        
        return true
    }
    
    /*func fetchLoggedUser(forceDownload:Bool = false,done:((YUser?)->Void)? = nil) {
        guard let uid = Auth.auth().currentUser?.uid
            else{done?(nil); return }
        
        //kind of caching
        if !forceDownload, let user = YUser.currentUser{
            done?(user)
            return
        }
        
        ref.child(TableNames.users)
            .child(uid)
            .observeSingleEvent(of: .value){snapshot in
                
                guard let value = snapshot.value as? JSON,
                    let typeRV = value[YUser.Keys.type] as? Int,//raw value
                    let type = UserType(rawValue: typeRV)
                    else {return}
                
                let user:YUser
                
                switch type{
                case .student:
                    user = .init(value)
                case .teacher:
                    user = Teacher(value)
                }
                YUser.currentUser = user
                done?(user)
            }
    }*/
    
    
    func getTeacher(by uid:String) -> Teacher? {
        return teachersList[uid]
    }
    
    /*func fetchTeacher(by uid:String,done:@ escaping (Teacher?)->Void) {
        Database.database()
            .reference(withPath: TableNames.users)
            .child(uid)
            .observeSingleEvent(of: .value){snapshot in
                
                guard let value = snapshot.value as? JSON,
                    let typeRV = value[YUser.Keys.type] as? Int
                    else {return}
                
                let type = UserType.allCases[typeRV]
                
                switch type{
                    case .student:
                        done(nil)
                    case .teacher:
                        done(Teacher(value))
                }
        }
    }*/
    
    
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
    
    func saveUserToDb(user: YUser,_ completion:@escaping ()->Void) {
        
        let encoded:JSON
        
        switch user.type {
        case .student:
            encoded = user.encode()
            
        case .teacher:
            encoded = Teacher(user: user).encode()
        }
        
        let ref = Database.database().reference()
        
        ref.child(TableNames.users.rawValue).child(user.id)
            .setValue(encoded){error,FBRef in
                if let err = error{
                    ErrorAlert.show(message: err.localizedDescription)
                }
                
                completion()
        }
    }
    
    func getUser(by id:String) -> YUser? {
        return usersList[id] ?? teachersList[id]
    }
}
