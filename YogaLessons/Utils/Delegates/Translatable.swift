//
//  Translatable.swift
//  YogaLessons
//
//  Created by Eran karaso on 24/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

protocol Translateable {
    var translated:String { get}
}

extension Translateable{
    var translated:String{
        return "\(self)".translated
    }
}
