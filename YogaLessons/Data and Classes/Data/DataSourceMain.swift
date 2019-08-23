//
//  DataSource.swift
//  YogaLessons
//
//  Created by Eran karaso on 22/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseDatabase
import UserNotifications
import GeoFire

class DataSource {
    static let shared = DataSource()
    
    let ref:DatabaseReference
    let geoFire:GeoFire
    
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
    
    let MaxPerBatch = 30 as UInt
    let MaxRangeKm = 100 as CLLocationDistance
    
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
        geoFire = GeoFire(firebaseRef: ref)
        
        observeClassChanged()
        observeEventChanged()
        
//        MARK: remove from comment
//        observeClassAdded()
//        observeEventAdded()
    }
    
    deinit {
        removeAllObserver(dataType: .classes)
        removeAllObserver(dataType: .events)
    }
    
    
    //MARK: -------loaders------
    func loadData(loaded:DSListener?) {
        
        loadAll(.classes){
            
//            self.loadAllBatch(.events,loadFromBegining: true){ hasDataEnded in
            self.loadAll(.events){
                loaded?()
            }
        }
    }
    
    fileprivate func executeAllLoadQuery(_ queriedRef: DatabaseQuery, _ loaded: ((Bool) -> Void)?, _ dType: DataType, _ user: YUser, _ signedIds: [String:Bool],_ lastPost:(DynamicUserCreateable & Scheduled)?) {
        
        queriedRef.queryLimited(toLast: MaxPerBatch)
            .observeSingleEvent(of: .value){ (snapshot, string) in
                
                guard let values = snapshot.children.allObjects as? [DataSnapshot]
                    else{
                        loaded?(true)
                        return}
                let currentLocation = LocationUpdater.shared.getLastKnowLocation()
                
                for child in values{
                    guard child.key != lastPost?.id//!allIds.contains(child.key)
                        else{continue}
                    
                    guard let json = child.value as? JSON
                        else{break}
                    
                    switch dType{
                    case .classes:
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
                        if signedIds[aClass.id!] != nil{
                            if aClass.status != .cancled{
                                self.signed_classes.insert(aClass, at: 0)
                            }else{
                                self.signed_classes.append(aClass)
                            }
                        }
                    case .events:
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
                        if signedIds[event.id!] != nil{
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
    func loadAll(_ dType:DataType,loaded:DSListener?) {
        
        let tableKey = TableNames.name(for: dType)//classes/events
        
        //        MARK: Important! don't user 2 orderd or limited queries
        let queriedRef = ref.child(tableKey).queryLimited(toLast: MaxPerBatch)
        
        
        queriedRef.observeSingleEvent(of: .value)
        { (snapshot, string) in
            
            guard let values = snapshot.children.allObjects as? [DataSnapshot]
                else{
                    loaded?()
                    return
            }
            
            let user = YUser.currentUser!

            let lastLocation = LocationUpdater.shared.getLastKnowLocation()
            
            switch dType{
                
            case .classes:
                
                self.all_classes.removeAll()
                self.signed_classes.removeAll()
                self.teacherCreatedClasses.removeAll()
                
                for child in values{
                    guard let json = child.value as? JSON
                        else{continue}
                    
                    let aClass = Class(json)
                    
                    guard self.isInRange(currentLocation: lastLocation, location: aClass.location)
                        else{continue}
                    
//                    for class is cancled
                    if aClass.status != .cancled{
                        self.all_classes.insert(aClass, at: 0)//push to top
                    }else{
                        self.all_classes.append(aClass)//add to bottom
                    }
                    
                    //                        uploads
                    if user.type == .teacher && aClass.uid == user.id{
                        
                        self.teacherCreatedClasses.append(aClass)
                    }
                    //                        signed
                    if let _ = user.signedClassesIDS[aClass.id!]{
                        if aClass.status != .cancled{
                            self.signed_classes.insert(aClass, at: 0)
                        }else{
                            self.signed_classes.append(aClass)
                        }
                    }
                }
            case .events:
                
                self.all_events.removeAll()
                self.signed_events.removeAll()
                self.userCreatedEvents.removeAll()
                
                for child in values{
                    guard let json = child.value as? JSON
                        else{continue}
                    
                    let event = Event(json)
                    
                    guard self.isInRange(currentLocation: lastLocation, location: event.location)
                        else{continue}
                    
                    
                    if event.status != .cancled{
                        self.all_events.insert(event, at: 0)//push to top
                    }else{
                        self.all_events.append(event)//add to bottom
                    }
                    //                        uploads
                    if event.uid == user.id{
                        self.userCreatedEvents.append(event)
                    }
                    //                        signed
                    if let _ = user.signedEventsIDS[event.id!]{
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

            loaded?()
        }
    }
    
    func isInRange(currentLocation:CLLocation?,location:CLLocation) -> Bool {
//        add return true if you don't want location sort
//        return true
        if let loc = currentLocation{
            let distance = location.distance(from: loc)
            let meters = MaxRangeKm * 1000 /*km*/
            if distance < meters{
                return true
            }
            return false
        }
        
        return true
    }
    
    
    
    func loadUserCreatedData() {
        guard let user = YUser.currentUser
            else {return}
        
        userCreatedEvents = all_events.filter { $0.uid == user.id }
        
        if user.type == .teacher && user is Teacher{//just for clarity both checks
            
            teacherCreatedClasses = all_classes.filter { $0.uid == user.id }
        }
    }
    
    //    MARK: add
    
    func addToAll(_ dType:DataType, dataObj:DynamicUserCreateable,taskDone:DSTaskListener?) {
        
        let dataRef = ref.child(TableNames.name(for: dType)).childByAutoId()
        
        guard let user = YUser.currentUser,
            let uid = user.id,
            let keyID = dataRef.key
            else{return}
        
        
        var dataObj = dataObj
        
        dataObj.id = keyID
        
        dataObj.uid = uid
        
//        add to all classes/events json
        dataRef.setValue(dataObj.encode())
        
        let arrKey:String
        let ids:[String]
        //can be teaching + type.lowercased + IDS
        switch dType {
        case .classes:
            
            guard let teacher = user as? Teacher else{return}
            
            arrKey = Teacher.Keys.teachingC
            teacher.teachingClassesIDs[keyID] = .open
            ids = .init(teacher.teachingClassesIDs.keys)
            
            if self.newClassHandle != nil{
                break
            }
            self.all_classes.insert(dataObj as! Class,at: 0)
            
        case .events:
            
            arrKey = YUser.Keys.createdEvents
            user.createdEventsIDs[keyID] = .open
            ids = .init(user.createdEventsIDs.keys)

            if self.newEventHandle != nil{
                break
            }
            self.all_events.insert(dataObj as! Event, at: 0)
        }
        self.updateMainDict(sourceType: .all, dataType: dType)
        
        NotificationCenter.default.post(name: ._dataAdded,userInfo: ["type":dType,"indexPath":IndexPath(row: 0, section: 0)])
        
        ref.child(TableNames.users.rawValue)//users table
            .child(uid)//of user by id
            .child(arrKey).setValue(ids){ err,childRef in
                
                if let error = err{
                    ErrorAlert.show(message: error.localizedDescription)
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
        
        
        let alert  = UIAlertController(title: "Choose a reminder", message: "remind you before it starts", preferredStyle: .actionSheet)
        
        let notificationAction = UIAlertAction(title: "Notify me", style: .default) { _ in
            NotificationManager.shared.setNotification(objId: dataObj.id!, title: title, time: startDate)
        }
        
        let calendar = UIAlertAction(title: "Add to calendar", style: .default) { _ in
            LocalCalendarManager.shared.setEvent( objId: dataObj.id!, title: title, placeName: placeName, location: location, startDate: startDate, endDate: endDate)
        }
        
        alert.addAction(notificationAction)
        alert.addAction(calendar)
        
        alert.addAction(UIAlertAction(title: "Don't remind me", style: .cancel, handler: nil))
        
        UIApplication.shared.presentedVC?.present(alert, animated: true)
    }
    
    func updateNumOfParticipants(data:(Unique & Participateable),dType:DataType,completionBlock:@escaping DSTaskListener) {
        let key:String
        switch dType {
        case .classes:
            key = Class.Keys.numParticipants
        case .events:
            key = Event.Keys.numParticipants
        }
        
        ref.child(TableNames.name(for: dType))
            .child(data.id!).updateChildValues([key : data.numOfParticipants ]){err,snap in
                completionBlock(err)
        }
    }
    
    
    func setCancled(_ dType:DataType ,at index:Int,taskDone:DSTaskListener?) {
        
        typealias StatusedData = DynamicUserCreateable & Statused
        
        var dataObj = getList(sourceType: .all, dType: dType)[index] as! StatusedData
        
        guard let teacher = YUser.currentUser as? Teacher,
            let uid = teacher.id,
            let objID = dataObj.id
            else{return}
        
        dataObj.status = .cancled
        
        let dataRef = ref.child(TableNames.name(for: dType)).child(objID).child(Status.key)
        
        //MARK: from the classes/Events main json
        dataRef.setValue(Status.cancled.rawValue){ err,childRef in
            if let error = err{
                ErrorAlert.show(message: error.localizedDescription)
                taskDone?(error)
                return
            }
            self.removeFromCreatorsList(uid, dataObj.id!, dType, taskDone: taskDone)
        }
    }
    
    fileprivate func removeFromCreatorsList(_ uid:String,_ objId:String,_ dType:DataType,taskDone:DSTaskListener?) {
        //MARK:   remove from db teacher's teahcing list
        
        let teacherRef = self.ref.child(TableNames.users.rawValue).child(uid)
        
        let arrKey:String
        
        switch dType {
        case .classes:
            arrKey = Teacher.Keys.teachingC
            
        case .events:
            arrKey = YUser.Keys.createdEvents
        }
        
        let arrayRef = teacherRef.child(arrKey).child(objId)
        
        arrayRef.setValue(false) { (err, _) in
            if let error = err{
                taskDone?(error)
                return
            }
            
            taskDone?(nil)
            NotificationCenter.default.post(name: ._dataCancled,userInfo: ["type":dType])
        }
    }
    
    
    func get(sourceType:SourceType,dType:DataType,at indexPath:IndexPath) -> DynamicUserCreateable? {
        
        let arr = getList(sourceType: sourceType, dType: dType)
        
        guard indexPath.row < arr.count
            else{return nil}
        
        return arr[indexPath.row]
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
}
