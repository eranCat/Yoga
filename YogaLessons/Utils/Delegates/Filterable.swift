//
//  Filterable.swift
//  YogaLessons
//
//  Created by Eran karaso on 17/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

protocol Filterable {
    func isSuitable(key:SearchKeyType,query q:String)->Bool
}
