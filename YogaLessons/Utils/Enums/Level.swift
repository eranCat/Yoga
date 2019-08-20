//
//  Level.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

enum Level:Int,CaseIterable{
    
    case anyone //= "Anyone"
    case beginner// = "Beginner"
    case intermediate// = "Intermediate"
    case advanced// = "Advanced"
    
    static let key = "level"
}
