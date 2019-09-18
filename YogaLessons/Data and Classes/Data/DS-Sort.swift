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
        
        switch (sourceType,dataType) {
        case (.all,.classes):
            all_classes.sort(by: Class.sorter(for: sortType))
            
        case (.signed,.classes):
            signed_classes.sort(by: Class.sorter(for: sortType))
            
        case (.all,.events):
            all_events.sort(by: Event.sorter(for: sortType))
            
        case (.signed,.events):
            signed_events.sort(by: Event.sorter(for: sortType))
            
        }
        
        updateMainDict(sourceType: .all, dataType: dataType)
    }
    
    func sortUserUploads(by sortType:SortType,dataType dt:DataType ) {
        switch dt {
        case .classes:
            teacherCreatedClasses.sort(by: Class.sorter(for: sortType))
        case .events:
            userCreatedEvents.sort(by: Event.sorter(for: sortType))
        }
        updateMainDict(sourceType: .signed, dataType: dt)
    }
}
