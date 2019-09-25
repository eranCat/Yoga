//
//  DS-sort.swift
//  YogaLessons
//
//  Created by Eran karaso on 01/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import FirebaseDatabase

extension DataSource{
    func sort(by sortType:SortType,
              sourceType:SourceType = .all,
              dataType:DataType = .classes) {
        
        var sorted:[DynamicUserCreateable]? = mainDict[sourceType]![dataType]
        
        switch dataType {
        case .classes:
            let sorter = Class.sorter(for: sortType)
            sorted = (sorted as? [Class])?.sorted(by: sorter)
                
        case .events:
            let sorter = Event.sorter(for: sortType)
            sorted = (sorted as? [Event])?.sorted(by: sorter)
        }
        
        if let sorted = sorted {
            mainDict[sourceType]![dataType]! = sorted
        }
    }
    
    func sortUserUploads(by sortType:SortType,dataType dt:DataType ) {
        switch dt {
        case .classes:
            teacherCreatedClasses.sort(by: Class.sorter(for: sortType))
        case .events:
            userCreatedEvents.sort(by: Event.sorter(for: sortType))
        }
    }
}
