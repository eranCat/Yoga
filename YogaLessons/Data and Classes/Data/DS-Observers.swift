//
//  DS-Observers.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

extension DataSource{
    
    func observeClassAdded() {
        let tableKey = TableNames.name(for: .classes)//classes/events
        
        newClassHandle = ref.child(tableKey)
            .observe( .childAdded){ (newChild, string) in
                
                if self.all_classes.first(where: {$0.id == newChild.key}) == nil{
                    
                    guard let json = newChild.value as? JSON
                        else{return}
                
                    self.all_classes.append(Class(json))
                    
                    self.updateMainDict(sourceType: .all, dataType: .classes)
                }

                
                NotificationCenter.default.post(name: ._dataAdded,
                                                userInfo: ["type" : DataType.classes])
        }
    }
    
    func observeEventAdded()  {
        let tableKey = TableNames.name(for: .events)//classes/events
        
        newEventHandle = ref.child(tableKey)
            .observe( .childChanged){ (newChild, string) in
                
                if self.all_events.first(where: {$0.id == newChild.key}) == nil{
                    
                    guard let json = newChild.value as? JSON
                        else{return}
                
                    self.all_events.append( Event(json))
                    
                    self.updateMainDict(sourceType: .all, dataType: .events)
                }
                
                NotificationCenter.default.post(name: ._dataAdded,
                                                userInfo: ["type" : DataType.events])
        }
    }
    
    func observeClassChanged() {
        let tableKey = TableNames.name(for: .classes)//classes/events
        
        classChangedHandle = ref.child(tableKey)
            .observe( .childChanged){ (snapshot, string) in
                
                guard let json = snapshot.value as? JSON
                    else{return}
                
                let user = YUser.currentUser!
                
                let aClass = Class(json)
                
                let predicate:((Class)->Bool) = {$0.id == aClass.id}
                
                //                    all
                if let i = self.all_classes.firstIndex(where: predicate){
                    self.all_classes[i] = aClass
                }
                
                //                        uploads
                if user.type == .teacher && aClass.uid == user.id{
                    if let i = self.teacherCreatedClasses.firstIndex(where: predicate){
                        self.teacherCreatedClasses[i] = aClass
                    }
                }
                
                //                        signed
                if user.signedClassesIDS[aClass.id!] != nil{
                    if let i = self.signed_classes.firstIndex(where: predicate){
                        self.signed_classes[i] = aClass
                    }
                }
                
                
                self.updateMainDict(sourceType: .all, dataType: .classes)
                
                
                
                var userInfo: [String : Any] = ["type" : DataType.classes]
                userInfo["status"] = aClass.status
                
                NotificationCenter.default.post(name: ._dataChanged, userInfo: userInfo)
        }
    }
    func observeEventChanged() {
        let tableKey = TableNames.name(for: .events)//classes/events
        
        eventChangedHandle = ref.child(tableKey)
            .observe( .childChanged){ (snapshot, string) in
                
                guard let json = snapshot.value as? JSON
                    else{return}
                
                
                let user = YUser.currentUser!
                
                let event = Event(json)
                
                let predicate:((Event)->Bool) = {$0.id == event.id}
                
                //                    all
                if let i = self.all_events.firstIndex(where: predicate){
                    
                    self.all_events[i] = event
                }
                
                //                        uploads
                if event.uid == user.id{
                    self.userCreatedEvents.append(event)
                }
                
                //                        signed
                if user.signedEventsIDS[event.id!] != nil,
                    let i = self.signed_events.firstIndex(where: predicate){
                    
                    self.signed_events[i] = event
                }
                    
                
                self.updateMainDict(sourceType: .all, dataType: .events)
                
                var userInfo: [String : Any] = ["type" : DataType.events]
                userInfo["status"] = event.status
                
                NotificationCenter.default.post(name: ._dataChanged, userInfo: userInfo)
        }
    }
    
    fileprivate func removeClassObservers(_ tableKey: String) {
        
        if let handle = classChangedHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
        }
        
        if let handle = newClassHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
        }
    }
    
    fileprivate func removeEventObserver(_ tableKey: String) {
        
        if let handle = eventChangedHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
        }
        
        if let handle = newEventHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
        }
    }
    
    func removeAllObserver(dataType dType:DataType) {

        let tableKey = TableNames.name(for: dType)//classes/events

        switch dType {
        case .classes:
            removeClassObservers(tableKey)

        case .events:
            removeEventObserver(tableKey)
        }
    }
}
