//
//  UserKeys.swift
//  YogaLessons
//
//  Created by Eran karaso on 27/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension YUser{
    struct Keys {
        static let id = UserKeys.id.rawValue
        static let name = UserKeys.name.rawValue
        static let about = UserKeys.about.rawValue
        static let level = UserKeys.level.rawValue
        static let type = UserKeys.type.rawValue
        static let profileImg = UserKeys.profileImg.rawValue
        static let bDate = UserKeys.bDate.rawValue
        static let signedC = UserKeys.signedC.rawValue
        static let signedE = UserKeys.signedE.rawValue
        static let createdEvents = UserKeys.createdEvents.rawValue
        static let email = UserKeys.email.rawValue
        
    }
    
    static let Model:[String:String] = [
        Keys.profileImg : "profileImageUrl",
        Keys.signedC : "signedClassesIDS",
        Keys.signedE: "signedEventsIDS",
        Keys.createdEvents : "createEventsIds",
    ]
    
    enum UserKeys:String {
        case id = "id"
        case name = "name"
        case about = "about"
        case level = "level"
        case type = "type"
        case profileImg = "profileImage"
        case bDate = "bDate"
        case signedC = "signedClasses"
        case signedE = "signedEvents"
        case createdEvents = "createdEventsIds"
        case email = "email"
    }
    
    func setValue(_ value: Any?, forKey key: UserKeys) -> Any?{//returns a simple saveable obj for firebase
        
        switch key {
        case .id:
            self.id = value as! String
            return id
        case .name:
            self.name = value as! String
            return name
        case .about:
            self.about = value as? String? ?? nil
            return about
        case .profileImg:
            self.profileImageUrl = value as? String? ?? nil
            return profileImageUrl
        case .level:
            if let level = value as? Level{
                self.level = level
            }else if let rv = value as? Int {
                self.level = Level.allCases[rv]
            }
            
            return level.rawValue
        case .type:
            if let type = value as? UserType{
                self.type = type
            }else if let rv = value as? Int {
                self.type = UserType.allCases[rv]
            }
            
            return type.rawValue
        case .bDate:
            if let timeInterval = value as? TimeInterval{
                self.bDate = Date(timeIntervalSince1970: timeInterval)
            }else if let date = value as? Date{
                self.bDate = date
            }
            return bDate.timeIntervalSince1970
        case .signedC:
            self.signedClassesIDS = value as? [String:Bool] ?? [:]
            return signedClassesIDS
        case .signedE:
            self.signedEventsIDS = value as? [String:Bool] ?? [:]
            return signedEventsIDS
            
        case .createdEvents:
            self.createdEventsIDs = value as? [String:Status] ?? [:]
            return createdEventsIDs.mapValues{$0.rawValue}
        case .email:
            self.email = value as? String
            return email
        }
    }
}

extension Teacher{
    struct Keys {
        static let teachingC = TeacherKeys.teachingC.rawValue
    }
    
    enum TeacherKeys:String {
        case teachingC = "teachingClassesIDs"
    }
   
    func setValue(_ value: Any?, forKey key: TeacherKeys) -> Any? {
        
        switch key {
        case .teachingC:
            teachingClassesIDs = value as? [String:Status] ?? [:]
            return teachingClassesIDs.mapValues{$0.rawValue}
        }
    }
}
