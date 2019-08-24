//
//  Class.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import CoreLocation

class Class:DynamicUserCreateable,Participateable,Scheduled,Titled,Statused,Located{

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
    
    var minAge,maxAge:Int?
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
        
        minAge = nil//if age < min
        maxAge = -1//if age > max
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
        dict[Keys.numParticipants] = numOfParticipants
        dict[Keys.maxParticipants] = maxParticipants
        
        dict[Keys.teacher] = uid
        
        dict[Status.key] = status.rawValue
        
        dict[Keys.age_min] = minAge
        dict[Keys.age_max] = maxAge

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
        
        numOfParticipants = dict[Keys.numParticipants] as! UInt
        maxParticipants = dict[Keys.maxParticipants] as! Int
        
//        userDict = dict[Keys.teacher] as! [String : String]
        uid = dict[Keys.teacher] as! String
        
        let statusRv = dict[Status.key] as? Int ?? 0
        status = Status.allCases[statusRv]
        
        minAge = dict[Keys.age_min] as? Int
        maxAge = dict[Keys.age_max] as? Int
    }
    
}

extension Class:CustomStringConvertible{
    var description: String{
        let encoded = encode().description.replacingOccurrences(of: ",", with: "\n")
        return "Class{\(encoded)}"
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
        static let numParticipants = ClassKeys.numParticipants.rawValue
        static let maxParticipants = ClassKeys.maxParticipants.rawValue
        static let teacher = ClassKeys.uid.rawValue
        static let age_max = ClassKeys.age_max.rawValue
        static let age_min = ClassKeys.age_min.rawValue
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
        case numParticipants = "numOfParticipants"
        case maxParticipants = "maxParticipants"
        case uid = "uid"
        case age_max = "age_max"
        case age_min = "age_min"
    }
}
