//
//  DS-Events.swift
//  YogaLessons
//
//  Created by Eran karaso on 01/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseDatabase

extension DataSource{

    func add(event:DynamicUserCreateable,_ sourceType:SourceType = .all,taskDone:DSTaskListener?) {
        
        switch sourceType {
        case .all:
            addToAll(.events, dataObj: event, taskDone: taskDone)
            
        case .signed:
            signTo(.events, dataObj: event, taskDone: taskDone)
        }
    }
    
//    
//    func update(event:Event,_ sourceType:SourceType = .all,taskDone: DSTaskListener?) {
//
//    }
}
