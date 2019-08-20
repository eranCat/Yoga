//
//  Status.swift
//  YogaLessons
//
//  Created by Eran karaso on 08/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

enum Status:Int,CaseIterable {
    
    case open
    case full
    case cancled
    
    static let key = "status"
}

protocol Statused {
    var status:Status { get set }
}
