//
//  Level.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

enum Level:Int,CaseIterable,Translateable{
    
    case anyone
    case beginner
    case intermediate
    case advanced
    
    static let key = "level"
}
