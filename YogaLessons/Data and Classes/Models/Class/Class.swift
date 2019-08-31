//
//  Class.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import CoreLocation

class Class:DynamicUserCreateable,Participateable,Scheduled,Titled,Statused,Located,Aged{

    var id:String? //may set after init
    
    var title:String
    var cost:Money
    
    var locationCoordinate: CLLocationCoordinate2D
    var locationName:String
    
    var postedDate: Date
    var startDate,endDate:Date
    
    var level:Level = .anyone
    
    var equipment:String
    
    var xtraNotes:String?
    
    var numOfParticipants:UInt
    var maxParticipants:Int
    
    var uid:String//the creators id
    
    var status:Status
    
    var minAge,maxAge:Int
    
    var signed:[String:Bool]//user id
    init(type:String,cost:Double,location:CLLocationCoordinate2D,locationName:String,date:(start:Date,end:Date),level:Level,equipment:String,xtraNotes:String? = nil,maxParticipants:Int,teacher:Teacher) {
        
        self.id = nil
        self.title = type
        self.cost = Money(amount: cost)
        
        self.locationCoordinate = location
        self.locationName = locationName
        
        self.postedDate = .init()
        self.startDate = date.start
        self.endDate = date.end
        
        self.level = level
        self.equipment = equipment
        self.xtraNotes = xtraNotes
        self.numOfParticipants = 0
        self.maxParticipants = maxParticipants
        
//        self.userDict = [:]
//        self.userID = teacher.id!
//        self.teacherName = teacher.name
        self.uid = teacher.id!
        
        self.status = .open
        
        minAge = .max//if age < min
        maxAge = -1//if age > max
        
        signed = [:]
    }
    
    func encode() -> JSON {
        var dict:JSON = [:]
        
        dict[Keys.id] = id
        dict[Keys.type] = title
        dict[Keys.cost] = cost.encode()
        
        dict[Keys.location] = locationCoordinate.encode()//dictionary
        dict[Keys.place] = locationName
        
        
        dict[Keys.postedDate] = postedDate.timeIntervalSince1970
        dict[Keys.startDate] = startDate.timeIntervalSince1970
        dict[Keys.endDate] = endDate.timeIntervalSince1970
        
        dict[Keys.level] = level.rawValue
        dict[Keys.equip] = equipment
        dict[Keys.xtraNotes] = xtraNotes
        dict[ParticipateableKeys.num.rawValue] = numOfParticipants
        dict[ParticipateableKeys.max.rawValue] = maxParticipants
        
        dict[Keys.teacher] = uid
        
        dict[Status.key] = status.rawValue
        
        dict[AgedKeys.age_min.rawValue] = minAge
        dict[AgedKeys.age_max.rawValue] = maxAge
        
        dict[ParticipateableKeys.signed.rawValue] = signed

        return dict
    }
    
    required init(_ dict: JSON) {
        id =   dict[Keys.id] as! String?
        title = dict[Keys.type] as! String
        cost = .init(dict[Keys.cost] as! JSON)
    
        locationCoordinate = .init(dict[Keys.location] as! JSON)
        locationName = dict[Keys.place] as! String
        
        
        let today = Date().timeIntervalSince1970
        postedDate = Date(timeIntervalSince1970: dict[Keys.startDate] as? TimeInterval ?? today)
        startDate = Date(timeIntervalSince1970: dict[Keys.startDate] as! TimeInterval)
        endDate = Date(timeIntervalSince1970: dict[Keys.endDate] as! TimeInterval)

        level = Level.allCases[dict[Keys.level] as! Int]
        
        equipment = dict[Keys.equip] as! String
        
        xtraNotes = dict[Keys.xtraNotes] as! String?
        
        numOfParticipants = dict[ParticipateableKeys.num.rawValue] as! UInt
        maxParticipants = dict[ParticipateableKeys.max.rawValue] as! Int
        
//        userDict = dict[Keys.teacher] as! [String : String]
        uid = dict[Keys.teacher] as! String
        
        let statusRv = dict[Status.key] as? Int ?? 0
        status = Status.allCases[statusRv]
        
        minAge = dict[AgedKeys.age_min.rawValue] as? Int ?? .max
        maxAge = dict[AgedKeys.age_max.rawValue] as? Int ?? -1
        
        signed = dict[ParticipateableKeys.signed.rawValue] as? [String:Bool] ?? [:]
    }
    
}

extension Class:CustomStringConvertible{
    var description: String{
        let encoded = encode().description.replacingOccurrences(of: ",", with: "\n")
        return "Class{\(encoded)}"
    }
}

extension Class{
    func update(from dict:JSON) {
        
        guard self.id == dict[Keys.id] as! String?
            else{return}
        
        title = dict[Keys.type] as! String
        cost = .init(dict[Keys.cost] as! JSON)
        
        locationCoordinate = .init(dict[Keys.location] as! JSON)
        locationName = dict[Keys.place] as! String
        
        startDate = Date(timeIntervalSince1970: dict[Keys.startDate] as! TimeInterval)
        endDate = Date(timeIntervalSince1970: dict[Keys.endDate] as! TimeInterval)
        
        level = Level.allCases[dict[Keys.level] as! Int]
        
        equipment = dict[Keys.equip] as! String
        
        xtraNotes = dict[Keys.xtraNotes] as! String?
        
        numOfParticipants = dict[ParticipateableKeys.num.rawValue] as! UInt
        maxParticipants = dict[ParticipateableKeys.max.rawValue] as! Int
        
        let statusRv = dict[Status.key] as? Int ?? 0
        status = Status.allCases[statusRv]
        
        minAge = dict[AgedKeys.age_min.rawValue] as? Int ?? .max
        maxAge = dict[AgedKeys.age_max.rawValue] as? Int ?? -1
        
        signed = dict[ParticipateableKeys.signed.rawValue] as? [String:Bool] ?? [:]
    }
}

extension Class{
    struct Keys {
        static let id = ClassKeys.id.rawValue
        static let type = ClassKeys.type.rawValue
        static let cost = ClassKeys.cost.rawValue
        static let location = ClassKeys.location.rawValue
        static let place = ClassKeys.place.rawValue
        static let postedDate = ClassKeys.postedDate.rawValue
        static let startDate = ClassKeys.startDate.rawValue
        static let endDate = ClassKeys.endDate.rawValue
        static let level = ClassKeys.level.rawValue
        static let equip = ClassKeys.equip.rawValue
        static let xtraNotes = ClassKeys.xtraNotes.rawValue
        static let teacher = ClassKeys.uid.rawValue
    }
    
    enum ClassKeys:String {
        case id = "id"
        case type = "type"
        case cost = "cost"
        case location = "location"
        case place = "place"
        case postedDate = "postedDate"
        case startDate = "startDate"
        case endDate = "endDate"
        case level = "level"
        case equip = "equip"
        case xtraNotes = "xtraNotes"
        case uid = "uid"
    }
}
