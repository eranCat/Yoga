//
//  Class.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import CoreLocation

class Event:DynamicUserCreateable,Participateable,Scheduled,Titled,Statused,Located,Aged{
    
    var id:String //may set after init
    
    var title:String
    var cost:Money
    
    var locationCoordinate: CLLocationCoordinate2D
    var locationName:String
    var countryCode: String
    
    var postedDate: Date
    var startDate,endDate:Date
    
    var level:Level = .anyone
    
    var equipment:String
    
    var xtraNotes:String?
    
    var numOfParticipants:UInt
    var maxParticipants:Int
    
    var imageUrl:String?
    
    var uid: String
    
    var status:Status
    
    var minAge,maxAge:Int
    
    var signed:[String:Bool]
    
    init(title:String,cost:Double,
         locationName:String, location:CLLocationCoordinate2D,countryCode:String,
         date:(start:Date,end:Date),level:Level,imageUrl:String? = nil,
         equipment:String,xtraNotes:String? = nil,maxParticipants:Int,user:YUser) {
        self.id = ""
        
        self.title = title
        self.cost = Money(amount: cost)
        
        self.locationCoordinate = location
        self.locationName = locationName
        self.countryCode = countryCode
        
        self.postedDate = .init()
        self.startDate = date.start
        self.endDate = date.end
        
        self.level = level
        self.equipment = equipment
        self.xtraNotes = xtraNotes
        self.numOfParticipants = 0
        self.maxParticipants = maxParticipants
        
        self.uid = user.id
        
        self.imageUrl = imageUrl
        
        status = .open
        
        minAge = .max//if age < min
        maxAge = -1//if age > max
        
        signed = [:]
    }
    
    func encode() -> JSON{
        var dict:JSON = [:]
        
        dict[Keys.id] = id
        dict[Keys.title] = title
        dict[Keys.cost] = cost.encode()
        
        dict[Keys.location] = locationCoordinate.encode()//dictionary
        dict[Keys.place] = locationName
        dict["countryCode"] = countryCode
        
        dict[Keys.postedDate] = postedDate.timeIntervalSince1970
        dict[Keys.startDate] = startDate.timeIntervalSince1970
        dict[Keys.endDate] = endDate.timeIntervalSince1970
        
        dict[Keys.level] = level.rawValue
        dict[Keys.equip] = equipment
        dict[Keys.xtraNotes] = xtraNotes
        dict[ParticipateableKeys.num.rawValue] = numOfParticipants
        dict[ParticipateableKeys.max.rawValue] = maxParticipants
        
        dict[Keys.user] = uid
        
        dict[Keys.imageUrl] = imageUrl
        
        dict[Status.key] = status.rawValue
        
        dict[AgedKeys.age_min.rawValue] = minAge
        dict[AgedKeys.age_max.rawValue] = maxAge
        
        dict[ParticipateableKeys.signed.rawValue] = signed
        
        return dict
    }
    
    required init(_ dict: JSON) {
        id = dict[Keys.id] as! String
        title = dict[Keys.title] as! String
        cost = .init(dict[Keys.cost] as! JSON)
        
        locationCoordinate = .init(dict[Keys.location] as! JSON)
        locationName = dict[Keys.place] as! String
        countryCode = dict["countryCode"] as? String ?? ""
        
        let today = Date().timeIntervalSince1970
        postedDate = Date(timeIntervalSince1970: dict[Keys.startDate] as? TimeInterval ?? today)
        startDate = Date(timeIntervalSince1970: dict[Keys.startDate] as! TimeInterval)
        endDate = Date(timeIntervalSince1970: dict[Keys.endDate] as! TimeInterval)
        
        level = Level(rawValue: dict[Keys.level] as! Int)!
        
        equipment = dict[Keys.equip] as! String
        
        xtraNotes = dict[Keys.xtraNotes] as! String?
        
        numOfParticipants = dict[ParticipateableKeys.num.rawValue] as! UInt
        maxParticipants =   dict[ParticipateableKeys.max.rawValue] as! Int
        
        uid = dict[Keys.user] as! String
        
        imageUrl = dict[Keys.imageUrl] as? String? ?? nil
        
        let statusRv = dict[Status.key] as? Int ?? 0
        status = Status.allCases[statusRv]
        
        minAge = dict[AgedKeys.age_min.rawValue] as? Int ?? .max
        maxAge = dict[AgedKeys.age_max.rawValue] as? Int ?? -1
        
        signed = dict[ParticipateableKeys.signed.rawValue] as? [String:Bool] ?? [:]
    }
    
}


extension Event:CustomStringConvertible{
    
    var description: String{
        let encoded = encode().description.replacingOccurrences(of: ",", with: "\n")
        return "Event{\(encoded)}"
    }
}

extension Event:Updateable{
    func update(from dict:JSON) {
        guard id == dict[Keys.id] as! String?
            else{return}
        
        title = dict[Keys.title] as! String
        cost = .init(dict[Keys.cost] as! JSON)
        
        locationCoordinate = .init(dict[Keys.location] as! JSON)
        locationName = dict[Keys.place] as! String
        countryCode = dict["countryCode"] as? String ?? ""
        
        startDate = Date(timeIntervalSince1970: dict[Keys.startDate] as! TimeInterval)
        endDate = Date(timeIntervalSince1970: dict[Keys.endDate] as! TimeInterval)
        
        level = Level(rawValue: dict[Keys.level] as! Int)!
        
        equipment = dict[Keys.equip] as! String
        
        xtraNotes = dict[Keys.xtraNotes] as! String?
        
        numOfParticipants = dict[ParticipateableKeys.num.rawValue] as! UInt
        maxParticipants =   dict[ParticipateableKeys.max.rawValue] as! Int
        
        imageUrl = dict[Keys.imageUrl] as? String? ?? nil
        
        let statusRv = dict[Status.key] as? Int ?? 0
        status = Status.allCases[statusRv]
        
        minAge = dict[AgedKeys.age_min.rawValue] as? Int ?? .max
        maxAge = dict[AgedKeys.age_max.rawValue] as? Int ?? -1
        
        signed = dict[ParticipateableKeys.signed.rawValue] as? [String:Bool] ?? [:]
    }
    func update(withNew new: DynamicUserCreateable) {
        guard id == new.id,
        let new = new as? Event
            else{return}
        
        title = new.title
        cost = new.cost
        locationCoordinate = new.locationCoordinate
        locationName = new.locationName
        countryCode = new.countryCode
        postedDate = new.postedDate
        startDate = new.startDate
        endDate = new.endDate
        level = new.level
        equipment = new.equipment
        xtraNotes = new.xtraNotes
        numOfParticipants = new.numOfParticipants
        maxParticipants = new.maxParticipants
        imageUrl = new.imageUrl
        status = new.status
        minAge = new.minAge
        maxAge = new.maxAge
    }
}

extension Event{
    
    enum EventKeys:String {
        case id = "id"
        case title = "title"
        case cost = "cost"
        case location = "location"
        case place = "place"
        case postedDate = "postedDate"
        case startDate = "startDate"
        case endDate = "endDate"
        case level = "level"
        case equip = "equip"
        case xtraNotes = "xtraNotes"
        case user = "uid"
        case imageUrl = "imageUrl"
    }
    struct Keys {
        static let id = EventKeys.id.rawValue
        static let title = EventKeys.title.rawValue
        static let cost = EventKeys.cost.rawValue
        static let location = EventKeys.location.rawValue
        static let place = EventKeys.place.rawValue
        static let postedDate = EventKeys.postedDate.rawValue
        static let startDate = EventKeys.startDate.rawValue
        static let endDate = EventKeys.endDate.rawValue
        static let level = EventKeys.level.rawValue
        static let equip = EventKeys.equip.rawValue
        static let xtraNotes = EventKeys.xtraNotes.rawValue
        static let user = EventKeys.user.rawValue
        static let imageUrl = EventKeys.imageUrl.rawValue
    }
}
