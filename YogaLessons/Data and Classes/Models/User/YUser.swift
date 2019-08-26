//
//  User.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

//import Foundation
import FirebaseDatabase

class YUser: DBCodable,Unique,CustomStringConvertible {
    
    static var currentUser:YUser?
    
    var id:String?
    
    var name: String
    
    var about: String?
    
    var level: Level
    var type: UserType
    
    var profileImageUrl:String?//or string of path on DB
    
    var bDate:Date
    
    var signedClassesIDS,signedEventsIDS:[String:Bool]
    
    var createdEventsIDs:[String:Status]//Event id
    
    var email:String?
    
    init(id:String? = nil,name:String,about:String? = nil,level:Level = .beginner,type:UserType, profileImage img:String? = nil,birthDate:Date,email:String){
        
        self.id = id
        self.name = name
        self.about = about
        self.level = level
        self.type = type
        self.profileImageUrl = img
        self.bDate = birthDate
        
        self.signedEventsIDS = [:]
        self.signedClassesIDS = [:]
        
        self.createdEventsIDs = [:]
        
        self.email = email
    }
    func encode() -> JSON {
        
        var dict:JSON = [:]
        
        dict[Keys.id] = id
        dict[Keys.name] = name
        dict[Keys.about] = about
        dict[Keys.level] = level.rawValue
        dict[Keys.type] = type.rawValue
        dict[Keys.profileImg] = profileImageUrl
        dict[Keys.bDate] = bDate.timeIntervalSince1970
        dict[Keys.signedC] = signedClassesIDS
        dict[Keys.signedE] = signedEventsIDS
        
        dict[Keys.createdEvents] = createdEventsIDs.mapValues{$0.rawValue}
        
        dict[Keys.email] = email
        
        return dict
    }
    
    required init(_ dict: JSON) {
        
        id = dict[Keys.id] as! String?
        name = dict[Keys.name] as! String
        about = dict[Keys.about] as! String?
        
        let lvlRV = dict[Keys.level] as! Int
        level = Level.allCases[lvlRV]
        
        let typeRV = dict[Keys.type] as! Int
        type = UserType(rawValue: typeRV)!
        
        profileImageUrl = dict[Keys.profileImg] as! String?
        
        let time =  dict[Keys.bDate] as! TimeInterval
        bDate = .init(timeIntervalSince1970: time)
        
        
//        let jsonArrays = [
//            dict[Keys.signedC],
//            dict[Keys.signedE],
//            dict[Keys.createdEvents]]
//
//        let resArrays:[[String]] =
//            jsonArrays.map{($0 as! NSArray?)?.stringArray ?? []}

        signedClassesIDS = dict[Keys.signedC] as? [String:Bool] ?? [:]
        
        signedEventsIDS = dict[Keys.signedE] as? [String:Bool] ?? [:]
       
        let idsAndRv = dict[Keys.createdEvents] as? [String:Int] ?? [:]
        createdEventsIDs = idsAndRv.mapValues{ Status(rawValue:$0) ?? .open}
        
        self.email = dict[Keys.email] as? String
    }
    
    
    var description: String{
        return "User{\(encode().description)}"
    }
}
