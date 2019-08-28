//
//  Aged.swift
//  YogaLessons
//
//  Created by Eran karaso on 26/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

protocol Aged:class {
    var minAge:Int {get set}
    var maxAge:Int {get set}
}


enum AgedKeys:String {
    case age_max = "age_max"
    case age_min = "age_min"
}

