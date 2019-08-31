//
//  Paticipateable.swift
//  YogaLessons
//
//  Created by Eran karaso on 01/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

protocol Participateable {
    var signed:[String:Bool] {get set}
    var numOfParticipants:UInt{get set}
    var maxParticipants:Int{get set}
    
}

enum ParticipateableKeys:String {
    case num = "numOfParticipants"
    case max = "maxParticipants"
    case signed = "signedUID"
}
