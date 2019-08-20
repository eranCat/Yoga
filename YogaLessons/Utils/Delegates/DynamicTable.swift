//
//  DynTable.swift
//  YogaLessons
//
//  Created by Eran karaso on 02/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

protocol DynamicTableDelegate {
    
    var currentDataType:DataType {get set}
    var sortType:SortType {get set}
}
