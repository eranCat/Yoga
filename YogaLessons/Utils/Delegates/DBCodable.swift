//
//  FirebaseDecodable.swift
//  YogaLessons
//
//  Created by Eran karaso on 07/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

protocol DBCodable {
    func encode()->JSON
    init?(_ dict:JSON)
}

protocol Unique {
    var id:String? {get set}
}
