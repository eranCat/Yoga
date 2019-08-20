//
//  CellsIds.swift
//  YogaLessons
//
//  Created by Eran karaso on 29/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

enum CellIds:String {
    case _class = "ClassCell"
    case _event = "EventCell"
    
    static func id(for type:DataType) -> String {
        switch type {
        
        case .classes:
            return CellIds._class.rawValue
        case .events:
            return CellIds._event.rawValue
        }
    }
}
