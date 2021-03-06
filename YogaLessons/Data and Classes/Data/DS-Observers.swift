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
                
                if self.mainDict[.all]![.classes]!.first(where: {$0.id == newChild.key}) == nil{
                    
                    guard let json = newChild.value as? JSON
                        else{return}
                    
                    let aClass = Class(json)
                    
                    guard !self.mainDict[.all]![.classes]!.contains(where: {$0.id == aClass.id})
                        else{return}

                    self.mainDict[.all]![.classes]!.insert(aClass, at: 0)
                    
                    let userInfo:JSON =
                        ["type" : DataType.classes,
                        "indexPath":IndexPath(row: 0, section: 0)]
                
                    NotificationCenter.default.post(name: ._dataAdded,userInfo: userInfo)
                }
        }
    }
    
    func observeEventAdded()  {
        let tableKey = TableNames.name(for: .events)//classes/events
        
        newEventHandle = ref.child(tableKey)
            .observe( .childChanged){ (newChild, string) in
                
                if self.mainDict[.all]![.events]!.first(where: {$0.id == newChild.key}) == nil{
                    
                    guard let json = newChild.value as? JSON
                        else{return}
                
                    let event: Event = Event(json)
                    guard !self.mainDict[.all]![.events]!.contains(where: {$0.id == event.id})
                        else{return}

                    self.mainDict[.all]![.events]!.insert( event , at: 0)
                    
                    let userInfo = ["type" : DataType.events,
                                    "indexPath":IndexPath(row: 0, section: 0)] as [String : Any]
                    NotificationCenter.default.post(name: ._dataAdded,userInfo: userInfo)
                }
        }
    }
    
    func observeClassChanged() {
        let tableKey = TableNames.name(for: .classes)//classes/events
        
        classChangedHandle = ref.child(tableKey)
            .observe( .childChanged){ (snapshot, string) in
                
                guard let json = snapshot.value as? JSON,
                        let classID = json[Class.Keys.id] as? String,
                        let aClass = self.mainDict[.all]![.classes]!.first(where: {$0.id == classID}) as? Class
                    else{return}
                
                let statusBefore = aClass.status
                aClass.update(from: json)
                
                var userInfo: JSON = ["type" : DataType.classes]
                userInfo["status"] = aClass.status
                userInfo["id"] = classID
                
                NotificationCenter.default.post(name: ._dataChanged, userInfo: userInfo)
                
                if self.mainDict[.signed]![.classes]!.contains(where:{ $0.id  == aClass.id}){
                    self.notifyForStatusIfNeeded(data: aClass, statusBefore: statusBefore)
                    NotificationCenter.default.post(name: ._signedDataChanged, userInfo: userInfo)
                }
        }
    }
    func observeEventChanged() {
        let tableKey = TableNames.name(for: .events)//classes/events
        
        eventChangedHandle = ref.child(tableKey)
            .observe( .childChanged){ (snapshot, string) in
                
                guard let json = snapshot.value as? JSON,
                        let eventID = json[Event.Keys.id] as? String,
                        let event = self.mainDict[.all]![.events]!.first(where: {$0.id == eventID}) as? Event
                    else{return}
                
                let statusBefore = event.status
                event.update(from: json)
                
                var userInfo: [String : Any] = ["type" : DataType.events]
                userInfo["status"] = event.status
                userInfo["id"] = eventID
                
                NotificationCenter.default.post(name: ._dataChanged, userInfo: userInfo)
                if self.mainDict[.signed]![.events]!.contains(where: {$0.id == event.id}){
                    self.notifyForStatusIfNeeded(data: event, statusBefore: statusBefore)
                    NotificationCenter.default.post(name: ._signedDataChanged, userInfo: userInfo)
                }
        }
    }
    
    fileprivate func removeClassObservers(_ tableKey: String) {
        
        if let handle = classChangedHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
            classChangedHandle = nil
        }
        
        if let handle = newClassHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
            newClassHandle = nil
        }
    }
    
    fileprivate func removeEventObserver(_ tableKey: String) {
        
        if let handle = eventChangedHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
            eventChangedHandle = nil
        }
        
        if let handle = newEventHandle{
            ref.child(tableKey).removeObserver(withHandle: handle)
            newEventHandle = nil
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
    
    func notifyForStatusIfNeeded(data:DynamicUserCreateable,statusBefore:Status) {
        
        guard
            //if it's a class that the user has signed to
            (data is Class && mainDict[.signed]![.classes]!.contains(where: {$0.id == data.id}))
            ||//or
            //if it's an event that the user has signed to
                (data is Event && mainDict[.signed]![.events]!.contains( where: {$0.id == data.id}))
            
            else {return}
        
        let id = data.id
        
        let currentStatus = (data as! Statused).status
        let title = (data as! Titled).title
        let startTime = (data as! Scheduled).startDate
        
        let hadBeenCanceled = statusBefore != .cancled && currentStatus == .cancled
        
        let hadBeenRestored = statusBefore == .cancled && currentStatus != .cancled
        
        let notifManger = NotificationManager.shared
        
        if hadBeenCanceled{
            //1.remove notification and event from calendar
            notifManger.removeNotification(objId: id)
            LocalCalendarManager.shared.removeEvent(objId: id)
            
            //2.notify that it was cancled immidietly
            notifManger.setNotification(objId: id, title: title, time: startTime,kind: .canceled)
            
        }else if hadBeenRestored{
            //1.notify the this has been restored
            notifManger.setNotification(objId: id, title: title, time: startTime,kind: .restored)
            
            //2.make somehow show reminder alert  when tapped on notification
        }
    }
    
    
    func listenToSettingsChanged() {
        registerSettingsBundle()
        NotificationCenter.default
            .addObserver(self, selector: #selector(defaultsChanged),
                         name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    @objc func defaultsChanged(){
        
        let standard = UserDefaults.standard
        isFilteringToday = standard.bool(forKey: "today_preference")
        isFilteringMonth = standard.bool(forKey: "month_preference")
        isFilteringLocation = standard.bool(forKey: "location_preference")
        
        if isFilteringLocation{
            LocationUpdater.shared.getCurrentCountryCode { code,locationErr in
                if let err = locationErr{
                    let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
                    print(msg)
                    return
                }
                
                let def = NotificationCenter.default
                
                def.post(name: ._settingChanged, object: nil)
                self.loadData { (err) in
                    def.post(name: ._reloadedAfterSettingChanged, object: nil)
                }
            }
        }
        else{
            let def = NotificationCenter.default
            
            def.post(name: ._settingChanged, object: nil)
            self.loadData { (err) in
                def.post(name: ._reloadedAfterSettingChanged, object: nil)
            }
        }
    }
}
