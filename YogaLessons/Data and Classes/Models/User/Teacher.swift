//
//  Teacher.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class Teacher:YUser {
    
    var teachingClassesIDs:[String:Status]//Class id
    
    override init (id:String? = nil,name:String,about:String? = nil,level:Level = .beginner,type:UserType = .student,profileImage img:String? = nil,birthDate:Date,email:String) {
        
        teachingClassesIDs = [:]
        
        super.init(id: id,name: name, about: about, level: level,type: .teacher, profileImage: img,birthDate: birthDate,email:email)
    }
    
    convenience init(user: YUser) {
        self.init(id: user.id,name: user.name, about: user.about, level: user.level, profileImage: user.profileImageUrl,birthDate: user.bDate,email:user.email ?? "")
    }
    
    required init(_ dict: JSON) {
        
        let idsAndRv = dict[Keys.teachingC] as? [String:Int] ?? [:]
        teachingClassesIDs = idsAndRv.mapValues{ Status(rawValue:$0) ?? .open}
        
        super.init(dict)
    }
    
    override func encode() -> JSON {
        var dict = super.encode()
        
        dict[Keys.teachingC] = teachingClassesIDs.mapValues{$0.rawValue}
        
        return dict
    }
    
    override var description: String{
        return "Teacher{\(encode().description)}"//encode already calls super user
    }
    
}
