//
//  DataType.swift
//  YogaLessons
//
//  Created by Eran karaso on 02/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

enum DataType:Int,CaseIterable {
    case classes,events
    
    var singular:String{
        switch self {
        
        case .classes:
            return "class"
        case .events:
            return "event"
        }
    }
}
