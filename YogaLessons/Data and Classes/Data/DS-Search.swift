//
//  DS-Filter.swift
//  YogaLessons
//
//  Created by Eran karaso on 01/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension DataSource{
    
    func filter(sourceType:SourceType = .all,dataType:DataType, by key:SearchKeyType,query:String) -> [DynamicUserCreateable] {
        
        let filterable = getList(sourceType: sourceType, dType: dataType) as! [Filterable]
        
        let filtered = filterable.filter {$0.isSuitable(key: key, query: query)}
        
        return filtered as! [DynamicUserCreateable]
    }
}
