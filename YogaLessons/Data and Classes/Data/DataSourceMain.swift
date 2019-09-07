//
//  DataSource.swift
//  YogaLessons
//
//  Created by Eran karaso on 22/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseDatabase
import UserNotifications
import CoreLocation

class DataSource {
    static let shared = DataSource()
    
    //        MARK:if you don't want location sort, put false
    var isFilteringLocation = true
    //        MARK:if you don't want today sort, put false
    var isFilteringToday = true
    //        MARK:if you don't want monthly sort, put false
    var isFilteringMonth = true

    let ref:DatabaseReference
    
    enum TableNames:String {
        case users  = "users"
        case clases = "classes"
        case events = "events"
        
        static func name(for dType:DataType)->String{
            switch dType {
            case .classes:
                return clases.rawValue
            case .events:
                return  events.rawValue
            }
        }
    }
    
    let MaxPerBatch:UInt = 30
    let MaxRangeKm:CLLocationDistance = 100
    
    var usersList:[String:YUser]//Dictionary<id:User>
    var teachersList:[String:Teacher]//Dictionary<id:Teacher>
    
    typealias DynArr = [DynamicUserCreateable]//inner arrays
    typealias DataTypeDict = [DataType:DynArr]//seconed level
    typealias SrcDict = [SourceType:DataTypeDict]//root
    
    var mainDict:SrcDict
    
    var all_classes,signed_classes:[Class]
    var all_events,signed_events:[Event]
    
    var teacherCreatedClasses:[Class]
    var userCreatedEvents:[Event]
    
    //    MARK: change observers refs
    var classChangedHandle,eventChangedHandle:DatabaseHandle?
    var newClassHandle,newEventHandle:DatabaseHandle?
    
    private init() {
        
        all_classes = []
        all_events = []
        
        signed_classes = []
        signed_events = []
        
        mainDict = [:]
        mainDict[.all] = [.classes:[],.events:[]]
        mainDict[.signed] = [.classes:[],.events:[]]
        
        usersList = [:]
        teachersList = [:]
        
        teacherCreatedClasses = []
        userCreatedEvents = []
        
        ref = Database.database().reference()
        
        observeClassChanged()
        observeEventChanged()
        
        //        MARK: remove from comment
        //        observeClassAdded()
        //        observeEventAdded()
        
        //        MARK: settings
        listenToSettingsChanged()
    }
    
    deinit {
        removeAllObserver(dataType: .classes)
        removeAllObserver(dataType: .events)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: -------loaders------
    func loadData(loaded:DSTaskListener?) {
        
        self.loadAll(.classes){ error in
            if error != nil{
                loaded?(error)
                return
            }
            self.loadAll(.events){ error in
                loaded?(error)
            }
        }
        
    }
    
    func loadAllBatch(_ dType:DataType,loadFromBegining:Bool,loadedHandler:((Bool)->Void)?) {
        
        let user = YUser.currentUser!
        
        let tableKey = TableNames.name(for: dType)//classes/events
        
        let allRef = ref.child(tableKey)
        
        //        MARK: Important! don't user 2 orderd or limited queries
        var queriedRef = allRef.queryOrdered(byChild: Class.Keys.postedDate)
        //(byChild: Class.Keys.startDate)
        
        
        var signedIds:[String:Bool]//for faster search
        
        var lastPost:(DynamicUserCreateable & Scheduled)?
        
        
        switch dType{
            
        case .classes:
            
            if loadFromBegining{
                all_classes.removeAll(keepingCapacity: true)
                teacherCreatedClasses.removeAll(keepingCapacity: true)
                signed_classes.removeAll(keepingCapacity: true)
            }
            
            signedIds = user.signedClassesIDS
            lastPost = all_classes.last
        case .events:
            
            if loadFromBegining{
                all_events.removeAll(keepingCapacity: true)
                userCreatedEvents.removeAll(keepingCapacity: true)
                signed_events.removeAll(keepingCapacity: true)
            }
            
            signedIds = user.signedEventsIDS
            lastPost = all_events.last
        }
        
        
        
        if !loadFromBegining, let last = lastPost  {
            
            let lastTimestamp = last.postedDate.timeIntervalSince1970
            queriedRef = queriedRef.queryEnding(atValue: lastTimestamp)
        }
        
        executeAllLoadQuery(queriedRef, loadedHandler, dType, user, signedIds,lastPost)
    }
    
    fileprivate func executeAllLoadQuery(_ queriedRef: DatabaseQuery, _ loaded: ((Bool) -> Void)?, _ dType: DataType, _ user: YUser, _ signedIds: [String:Bool],_ lastPost:(DynamicUserCreateable & Scheduled)?) {
        
        queriedRef.queryLimited(toLast: MaxPerBatch)
            .observeSingleEvent(of: .value){ (snapshot, string) in
                
                guard let values = snapshot.children.allObjects as? [DataSnapshot]
                    else{
                        loaded?(true)
                        return}
                let currentLocation = LocationUpdater.shared.getLastKnowLocation()
                
                
                switch dType{
                case .classes:
                    for child in values{
                        guard child.key != lastPost?.id//!allIds.contains(child.key)
                            else{continue}
                        
                        guard let json = child.value as? JSON
                            else{break}
                        let aClass = Class(json)
                        
                        guard self.isInRange(currentLocation: currentLocation, location: aClass.location)
                            else{continue}
                        
                        //  all
                        if aClass.status != .cancled{
                            self.all_classes.insert(aClass, at: 0)
                        }else{
                            self.all_classes.append(aClass)
                        }
                        //uploads
                        if user.type == .teacher && aClass.uid == user.id{
                            self.teacherCreatedClasses.append(aClass)
                        }
                        
                        //signed
                        if signedIds[aClass.id] != nil{
                            if aClass.status != .cancled{
                                self.signed_classes.insert(aClass, at: 0)
                            }else{
                                self.signed_classes.append(aClass)
                            }
                        }
                    }
                case .events:
                    for child in values{
                        guard child.key != lastPost?.id//!allIds.contains(child.key)
                            else{continue}
                        
                        guard let json = child.value as? JSON
                            else{break}
                        let event = Event(json)
                        
                        guard self.isInRange(currentLocation: currentLocation, location: event.location)
                            else{continue}
                        
                        //all
                        if event.status != .cancled{
                            self.all_events.insert(event, at: 0)
                        }else{
                            self.all_events.append(event)
                        }
                        
                        //uploads
                        if event.uid == user.id{
                            self.userCreatedEvents.append(event)
                        }
                        
                        //signed
                        if signedIds[event.id] != nil{
                            if event.status != .cancled{
                                self.signed_events.insert(event, at: 0)
                            }else{
                                self.signed_events.append(event)
                            }
                        }
                    }
                }
                
                self.updateMainDict(sourceType: .all, dataType: dType)
                self.updateMainDict(sourceType: .signed, dataType: dType)
                
                
                loaded?(values.isEmpty)
        }
    }
    
    fileprivate func convertValuesToClasses(_ values: [DataSnapshot], _ user: YUser) {
        
        let today = Date()
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: .init())!
        
        all_classes.removeAll()
        signed_classes.removeAll()
        teacherCreatedClasses.removeAll()
        
        for child in values{
            guard let json = child.value as? JSON
                else{continue}
            
            let aClass = Class(json)
            
            if aClass.endDate >= today || !isFilteringToday{
                
                
                let isUserSigned = user.signedClassesIDS.keys.contains(aClass.id)
                
                if aClass.status != .cancled{
                    
                    self.all_classes.insert(aClass, at: 0)//push to top
                    
                    if isUserSigned{
                        self.signed_classes.insert(aClass, at: 0)
                    }
                    
                }else{
                    
                    self.all_classes.append(aClass)//add to bottom
                    
                    if isUserSigned{
                        self.signed_classes.append(aClass)
                    }
                }
                
            }
            //                        uploads
            if aClass.postedDate >= nextMonth || !isFilteringMonth{
                if let teacher = user as? Teacher,
                    teacher.teachingClassesIDs[aClass.id] != nil{
                    
                    self.teacherCreatedClasses.insert(aClass,at: 0)
                }
            }
        }
    }
    
    fileprivate func convertValuesToEvents(_ values: [DataSnapshot], _ user: YUser) {
        
        let today = Date()
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: .init())!
        
        all_events.removeAll()
        signed_events.removeAll()
        userCreatedEvents.removeAll()
        
        for child in values{
            guard let json = child.value as? JSON
                else{continue}
            
            let event = Event(json)
            
            if event.endDate >= today || !isFilteringToday{
                
                let isUserSigned = user.signedEventsIDS.keys.contains(event.id)
                
                if event.status != .cancled{
                    
                    all_events.insert(event, at: 0)//push to top
                    if isUserSigned{
                        signed_events.insert(event, at: 0)
                    }
                    
                }else{
                    
                    all_events.append(event)//add to bottom
                    if isUserSigned{
                        signed_events.append(event)
                    }
                }
            }
//                        uploads
            if event.postedDate >= nextMonth || !isFilteringMonth{
                if let status = user.createdEventsIDs[event.id] {
                    userCreatedEvents.insert(event,at: 0)
                }
            }
        }
    }
    
    func loadAll(_ dType:DataType,loaded:DSTaskListener?) {
        
        let tableKey = TableNames.name(for: dType)//classes/events
        //        MARK: Important! don't user 2 orderd or limited queries
        let tableRef = ref.child(tableKey)
        var queriedRef:DatabaseQuery? = nil

        if isFilteringLocation ,
            let code = LocationUpdater.shared.currentCountryCode{
            queriedRef = tableRef.queryOrdered(byChild: "countryCode")
                                .queryEqual(toValue: code)
        }
    
        
        let postedDateKey =  dType == .classes ? Class.Keys.postedDate : Event.Keys.postedDate
        
        (queriedRef ?? tableRef.queryOrdered(byChild: postedDateKey))
            .queryLimited(toLast: MaxPerBatch)
            .observeSingleEvent(of: .value)
        { (snapshot, string) in
            
            guard let values = snapshot.children.allObjects as? [DataSnapshot]
                else{
                    loaded?(JsonErrors.castFailed)
                    return
            }
            
            guard let user = YUser.currentUser
                else{
                    loaded?(UserErrors.noUserFound)
                    return
            }
            
            switch dType{
                
            case .classes:
                self.convertValuesToClasses(values, user)
                
            case .events:
                self.convertValuesToEvents(values, user)
            }
            
            self.updateMainDict(sourceType: .all, dataType: dType)
            self.updateMainDict(sourceType: .signed, dataType: dType)
            
            loaded?(nil)
        }
        
    }
    
    func isInRange(currentLocation:CLLocation?,location:CLLocation) -> Bool {
        
        guard isFilteringLocation
            else{return true}
        
        guard let loc = currentLocation
            else{return false}
        
        let distance = location.distance(from: loc)
        let meters = MaxRangeKm * 1000 /*km*/
        
        return distance < meters
    }
    
    
    
    func loadUserCreatedData() {
        guard let user = YUser.currentUser
            else {return}
        
        if let teacher = user as? Teacher{//just for clarity both checks
            
            teacherCreatedClasses.removeAll()
            
            for id in teacher.teachingClassesIDs.keys{
                if let aClass = all_classes.first(where: {$0.id == id}){
                    teacherCreatedClasses.insert(aClass,at: 0)
                }
            }
        }

        
        userCreatedEvents.removeAll()
        
        for id in user.createdEventsIDs.keys{
            if let event = all_events.first(where: {$0.id == id}){
                userCreatedEvents.insert(event,at: 0)
            }
        }
    }
    
    //    MARK: add
    
    func addToAll(_ dType:DataType, dataObj:DynamicUserCreateable,taskDone:DSTaskListener?) {
        
        let dataRef:DatabaseReference = ref.child(TableNames.name(for: dType)).childByAutoId()
        
        guard let user = YUser.currentUser,
            let keyID = dataRef.key
            else{
                taskDone?(UserErrors.noUserFound)
                return
            }
        
        let uid = user.id
        
        var dataObj = dataObj
        
        dataObj.id = keyID
        
        dataObj.uid = uid
        
        //        add to all classes/events json
        dataRef.setValue(dataObj.encode())
        
        let arrKey:String
        let ids:[String:Int]
        //can be teaching + type.lowercased + IDS
        switch dType {
        case .classes:
            
            guard let teacher = user as? Teacher else{
                taskDone?(nil)
                return
            }
            
            arrKey = Teacher.Keys.teachingC
            teacher.teachingClassesIDs[keyID] = .open
            ids = teacher.teachingClassesIDs.compactMapValues{$0.rawValue}
            
            if newClassHandle == nil{
                all_classes.insert(dataObj as! Class,at: 0)
            }
            
        case .events:
            
            arrKey = YUser.Keys.createdEvents
            user.createdEventsIDs[keyID] = .open
            ids = user.createdEventsIDs.compactMapValues{$0.rawValue}
            
            if newEventHandle == nil{
                all_events.insert(dataObj as! Event, at: 0)
            }
        }
        updateMainDict(sourceType: .all, dataType: dType)
        
        NotificationCenter.default.post(name: ._dataAdded,userInfo: ["type":dType,"indexPath":IndexPath(row: 0, section: 0)])
        
        ref.child(TableNames.users.rawValue)//users table
            .child(uid)//of user by id
            .child(arrKey).setValue(ids){ err,childRef in
                
                if let error = err{
                    taskDone?(error)
                    return
                }
                taskDone?(nil)
        }
    }
    
    func showReminderAlert(dataObj:DynamicUserCreateable) {
        
        let title = (dataObj as! Titled).title
        
        //        protocol sheduald
        let schedualedObj = dataObj as! Scheduled
        let startDate = schedualedObj.startDate
        let endDate = schedualedObj.endDate
        
        //        protocol located
        let located = dataObj as! Located
        let location = located.location
        let placeName = located.locationName
        
        
        let notificationAction = UIAlertAction(title: "Notify me".translated, style: .default) { _ in
            NotificationManager.shared.setNotification(objId: dataObj.id, title: title, time: startDate, kind: .starting)
        }
        
        let calendar = UIAlertAction(title: "Add to calendar".translated,
                                     style: .default) { _ in
                                        LocalCalendarManager.shared.setEvent( objId: dataObj.id, title: title, placeName: placeName, location: location, startDate: startDate, endDate: endDate)
        }
        UIAlertController.create(title: "Choose a reminder".translated,
                                              message: "remindBeforeStart".translated,
                                              preferredStyle: .alert)
        .aAction(notificationAction)
        .aAction(calendar)
        .aAction(.init(title: "Don't remind me".translated,style: .cancel,handler: nil))
            .show()
    }
    
    func toggleCancel(_ dType:DataType ,at index:Int,taskDone:DSTaskListener?) {
        
        typealias StatusedData = DynamicUserCreateable & Statused & Participateable
        
        var dataObj = getUser_sUploads(dType: dType)[index] as! StatusedData
        
        let objID = dataObj.id
        
        
        //        Toggle
        if dataObj.status == .cancled{
            let currentNum = dataObj.numOfParticipants
            let max = dataObj.maxParticipants
            
            dataObj.status = currentNum < max ? .open : .full
        }else{
            dataObj.status = .cancled
        }
        
        //MARK: from the classes/Events main json
        ref.child(TableNames.name(for: dType))
            .child(objID)
            .child(Status.key)
            .setValue(dataObj.status.rawValue){ err,childRef in
                if let error = err{
                    ErrorAlert.show(message: error.localizedDescription)
                    taskDone?(error)
                    return
                }
                //            self.removeFromCreatorsList(uid, dataObj.id!, dType, taskDone: taskDone)
                taskDone?(nil)
                NotificationCenter.default.post(name: ._dataCancled,userInfo: ["type":dType])
        }
    }
    
    //    fileprivate func removeFromCreatorsList(_ uid:String,_ objId:String,_ dType:DataType,taskDone:DSTaskListener?) {
    //        //MARK:   remove from db teacher's teahcing list
    //        guard let teacher = YUser.currentUser as? Teacher,
    //        let uid = teacher.id
    //        else{return}
    //
    //        let teacherRef = self.ref.child(TableNames.users.rawValue).child(uid)
    //
    //        let arrKey:String
    //
    //        switch dType {
    //        case .classes:
    //            arrKey = Teacher.Keys.teachingC
    //
    //        case .events:
    //            arrKey = YUser.Keys.createdEvents
    //        }
    //
    //        let arrayRef = teacherRef.child(arrKey).child(objId)
    //
    //        arrayRef.setValue(false) { (err, _) in
    //            if let error = err{
    //                taskDone?(error)
    //                return
    //            }
    //
    //            taskDone?(nil)
    //            NotificationCenter.default.post(name: ._dataCancled,userInfo: ["type":dType])
    //        }
    //    }
    
    
    func get(sourceType:SourceType,dType:DataType,at indexPath:IndexPath) -> DynamicUserCreateable? {
        
        return getList(sourceType: sourceType, dType: dType)[safe: indexPath.row]
    }
    
    func getList(sourceType:SourceType,dType:DataType) -> [DynamicUserCreateable] {
        
        return mainDict[sourceType]?[dType] ?? []
    }
    
    func count(sourceType:SourceType = .all,dType:DataType) -> Int {
        return getList(sourceType: sourceType, dType: dType).count
    }
    
    func getUser_sUploads(dType:DataType) -> [DynamicUserCreateable] {
        switch dType {
        case .classes:return teacherCreatedClasses
        case .events:return userCreatedEvents
        }
    }
    
    func updateMainDict(sourceType:SourceType,dataType:DataType) {
        
        switch sourceType {
            
        case .all:
            mainDict[.all]![dataType] = dataType == .classes ? all_classes : all_events
        case .signed:
            mainDict[.signed]![dataType] = dataType == .classes ? signed_classes : signed_events
        }
        
    }
    
    
    func update<T:Updateable & DynamicUserCreateable>(localModel:T,withNew new:T,taskDone:DSTaskListener?) {
//        updates on data change from dict
        localModel.update(withNew: new)
        
        
        //        add to all classes/events json
        let dataRef:DatabaseReference
        switch new {
        case let aClass as Class:
            dataRef = ref.child(TableNames.clases.rawValue)

            
        case let event as Event:
            dataRef = ref.child(TableNames.events.rawValue)
            
        default:
//            show some error
            taskDone?(DataTypeError.incompatibleType)
            return
        }
        
        
        dataRef.child(new.id)
            .updateChildValues( new.encode()) { (err, _) in
                taskDone?(err)
            }
    }
}
