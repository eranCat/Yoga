//
//  SearchSections.swift
//  YogaLessons
//
//  Created by Eran karaso on 02/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

enum SearchKeyType:Int,CaseIterable,Hashable {
    case title,location,teacher
    
    var translated:String{
        return "\(self)".translated
    }
}
