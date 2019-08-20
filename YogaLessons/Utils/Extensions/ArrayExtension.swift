//
//  ArrayExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 29/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension NSArray{
    var stringArray:[String]{
        return self.filter{ $0 is String} as! [String]
    }
//    var stringArray:[Element]{
//        return self.filter{ $0 is String} as! [Element]
//    }
    
}
