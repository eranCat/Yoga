//
//  Updateable.swift
//  YogaLessons
//
//  Created by Eran karaso on 07/09/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

protocol Updateable{
    
    func update(withNew new:DynamicUserCreateable)
    func update(from dict:JSON)
}
