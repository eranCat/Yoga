//
//  DS-Classes.swift
//  YogaLessons
//
//  Created by Eran karaso on 01/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth

extension DataSource{

    func add(class aClass: DynamicUserCreateable,_ sourceType:SourceType = .all,taskDone: DSTaskListener?) {
       
        switch sourceType {
        case .all:
            addToAll(.classes, dataObj:aClass, taskDone: taskDone)
        case .signed:
            signTo(.classes, dataObj: aClass,taskDone: taskDone)
        }
    }
}
