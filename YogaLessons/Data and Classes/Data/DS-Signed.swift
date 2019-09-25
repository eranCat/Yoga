//
//  DS-Signed.swift
//  YogaLessons
//
//  Created by Eran karaso on 08/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension DataSource{
//   not in use since the signed is loaded inside of load_all func
    func loadSigned(_ dType:DataType) {
        
        //MARK: fetch list of classes by id from user signed classes
        guard let user = YUser.currentUser
            else{return}
        
        
        switch dType {
        case .classes:
            guard !user.signedClassesIDS.isEmpty
                else{return}
            
            let today = Date()
            mainDict[.signed]![.classes]!.removeAll()
            
            for key in user.signedClassesIDS.keys{
                guard let aClass = mainDict[.all]![.classes]!.first(where: {$0.id == key}) as? Class,
                    aClass.endDate >= today || !isFilteringToday
                    else{continue}
                
                if aClass.status != .cancled{
                    mainDict[.signed]![.classes]!.insert(aClass, at: 0)
                }else{
                    mainDict[.signed]![.classes]!.append(aClass)
                }
            }

        case .events:
            guard !user.signedEventsIDS.isEmpty
                else{return}

            let today = Date()
            mainDict[.signed]![.events]!.removeAll()
            
            for key in user.signedEventsIDS.keys{
                guard let event = mainDict[.all]![.events]!.first(where: {$0.id == key}) as? Event,
                    event.endDate >= today || !isFilteringToday
                    else{continue}
                
                if event.status != .cancled{
                    mainDict[.signed]![.events]!.insert(event, at: 0)
                }else{
                    mainDict[.signed]![.events]!.append(event)
                }
            }
        }
    }
    
    
    fileprivate func check(age: Int,data: Aged) {
        if age < data.minAge{
            data.minAge = age
        }else if age > data.maxAge{
            data.maxAge = age
        }else{
            data.minAge = age
            data.maxAge = age
        }
    }
    func signTo(_ dType:DataType,dataObj:DynamicUserCreateable ,taskDone:DSTaskListener?) {
        
        guard let cu = YUser.currentUser
            else{
                taskDone?(UserErrors.noUserFound)//no user error
                return
            }
        
        let uid = cu.id//user id
        let objId = dataObj.id // data id
        
        ref.child(TableNames.name(for: dType)).child(objId)
        .runTransactionBlock(){ (currentData: MutableData) -> TransactionResult in
            guard let json = currentData.value as? JSON
                else{
                    taskDone?(JsonErrors.castFailed)
                    return TransactionResult.abort()
                }
            
                dataObj.update(from: json)
                var data = dataObj as! (Participateable & Aged & Unique & DBCodable & Statused)
            
                
                switch data.status{
                    
                case .open:
                    //save to DB
                    data.numOfParticipants += 1
                    if data.maxParticipants != -1 &&// limited
                        data.numOfParticipants >= data.maxParticipants{
                        
                        data.status = .full
                    }
                    
                    let age = cu.bDate.age
                    self.check(age: age, data: data)
                    
                    data.signed[uid] = age
                    
                    //save to signed array locally and remotely
                    currentData.value = data.encode()
                    
                    self.addToCurrentUserSigned(dType, cu, objId, taskDone, dataObj, uid)
                        
                case .full:
                    taskDone?(SigningErrors.noPlaceLeft)
                case .cancled:
                    taskDone?(SigningErrors.cantSignToCancled(dType))
                }
            
                return TransactionResult.success(withValue: currentData)
            }
    
    }
    
    
    private func addToCurrentUserSigned(_ dType: DataType, _ cu: YUser, _ objId: String, _ taskDone: DSTaskListener?, _ dataObj: DynamicUserCreateable, _ uid: String) {
        //add to local users list of id's
        let arrKey:String
        let idsArr:[String:Bool]
        switch dType {
        case .classes:
            
            if cu.signedClassesIDS[objId] != nil{
                taskDone?(SigningErrors.alreadySignedToClass)
                return
            }
            cu.signedClassesIDS[objId] = true
            
            arrKey = YUser.Keys.signedC
            idsArr = cu.signedClassesIDS
            mainDict[.signed]![.classes]!.insert(dataObj as! Class, at: 0)
        case .events:
            
            if cu.signedEventsIDS[objId] != nil{
                taskDone?(SigningErrors.alreadySignedToEvent)
                return
            }
            cu.signedEventsIDS[objId] = true
            
            arrKey = YUser.Keys.signedE
            idsArr = cu.signedEventsIDS
            mainDict[.signed]![.events]!.insert(dataObj as! Event,at: 0)
        }
        ref.child(TableNames.users.rawValue).child(uid)//might need to set value
            .child(arrKey).setValue(idsArr)
            { err,childRef in
                
                if let error = err{
                    ErrorAlert.show(message: error.localizedDescription)
                    taskDone?(error)
                    return
                }
                
                self.showReminderAlert(dataObj: dataObj)
                
                NotificationCenter.default
                    .post(name: ._signedDataAdded,userInfo: ["type":dType])
                
                
                taskDone?(nil)
        }
    }
    
    func unsignFrom(_ dType:DataType,data:DynamicUserCreateable,taskDone:DSTaskListener?){
        
        let list: [DynamicUserCreateable] = getList(sourceType: .signed, dType: dType)
        guard let i = list.firstIndex(where: {$0.id == data.id})
            else{return}
        
        unsignFrom(dType, at: IndexPath(row: i, section: 0), taskDone: taskDone)
    }
    
    func unsignFrom(_ dType:DataType,at index:IndexPath? ,taskDone:DSTaskListener?) {
        
        guard let cu = YUser.currentUser
            else{
                taskDone?(UserErrors.noUserFound)
                return
        }
        let uid = cu.id//user id
        
        guard let indexPath = index else{return}
        
        typealias NeededProtocols = Statused & Participateable & DynamicUserCreateable & Aged
        var data:NeededProtocols
        
        switch dType {
        case .classes:
            data = mainDict[.signed]![.classes]!.remove(at: indexPath.row) as! NeededProtocols
        case .events:
            data = mainDict[.signed]![.events]!.remove(at: indexPath.row) as! NeededProtocols
        }
        
        
        ref.child(TableNames.name(for: dType)).child(data.id)
        .runTransactionBlock { (currentData) -> TransactionResult in
            guard var post = currentData.value as? JSON
                else{
                    taskDone?(JsonErrors.castFailed)
                    return TransactionResult.success(withValue: currentData)
            }
            
            data.update(from: post)

            data.signed[uid] = nil
            
            if data.numOfParticipants > 0{
                
                data.numOfParticipants -= 1
                
                if data.status != .cancled{
                    data.status = .open
                }
            }
            let age = cu.bDate.age
            if age == data.minAge || age == data.maxAge{
                
                for age in data.signed.values{
                    self.check(age: age, data: data)
                }
            }
            
            post[Status.key ] = data.status.rawValue
            post[ParticipateableKeys.num.rawValue] = data.numOfParticipants
            post[ParticipateableKeys.signed.rawValue] = data.signed
            post[AgedKeys.age_min.rawValue] = data.minAge
            post[AgedKeys.age_max.rawValue] = data.maxAge
            
            currentData.value = post
            
            taskDone?(nil)
            
            self.removeFromCurrentUserSigned(dType, cu, data, uid, taskDone, indexPath)
            
            return TransactionResult.success(withValue: currentData)
        }
        
    }
    
    fileprivate func removeFromCurrentUserSigned(_ dType: DataType, _ cu: YUser,
                                                 _ data: Unique, _ uid: String,
                                                 _ taskDone: DSTaskListener?,
                                                 _ indexPath: IndexPath?) {
        
        
        //remove from user's list of id's localy
        let arrKey:String
        
        switch dType {
        case .classes:
            arrKey = YUser.Keys.signedC
            cu.signedClassesIDS.removeValue(forKey: data.id)
            
        case .events:
            arrKey = YUser.Keys.signedE
            cu.signedEventsIDS.removeValue(forKey: data.id)
        }
        
        
//        remove on DB
        let userTable = TableNames.users.rawValue
        
        ref.child(userTable).child(uid)
            .child(arrKey).child(data.id).removeValue(){ err,_ in
            if let error = err{
                taskDone?(error)
                return
            }
            
            taskDone?(nil)
            
            var userInfo:[String:Any] = ["type":dType]
            if let i = indexPath{
                userInfo["indexPath"] = i
            }
            
            NotificationManager.shared.removeNotification(objId: data.id)
        
            LocalCalendarManager.shared.removeEvent(objId: data.id)
            
            NotificationCenter.default
                .post(name: ._signedDataRemoved, userInfo: userInfo)
        }        
    }
}
