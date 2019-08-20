//
//  ClassCmp.swift
//  YogaLessons
//
//  Created by Eran karaso on 05/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension Class{
    
    typealias classCmp = (Class,Class) -> Bool
    
    static let mostRelevantSorter:classCmp = {
        return Class.DateSorter($0,$1) && Class.LocationSorter($0,$1)
    }
    
    static let titleSorter:classCmp = {$0.title.lowercased() < $1.title.lowercased()}
    static let levelSorter = { $0.level.rawValue < $1.level.rawValue} as classCmp
    static let DateSorter = {$0.startDate > $1.startDate} as classCmp
    static let LocationSorter: classCmp = {
        
        guard let loc = LocationUpdater.shared.getLastKnowLocation()
            else{return false}
        
        let c1Loc = $0.location
        let c2Loc = $1.location
        
        return c1Loc.distance(from: loc) < c2Loc.distance(from:loc)
    }
    
    class func sorter(for st: SortType) -> classCmp {
        switch st {
            
        case .best:
            return mostRelevantSorter
        case .name:
            return titleSorter
        case .level:
            return levelSorter
        case .date:
            return DateSorter
        case .near:
            return LocationSorter
            
        }
    }
}

extension Class:Filterable{
    func isSuitable(key: SearchKeyType, query q: String) -> Bool {
        
        let filteredString:String
        
        switch key {
            
        case .title:
            filteredString = title.lowercased()
        case .location:
            filteredString = locationName.lowercased()
        case .teacher:
            let ds = DataSource.shared
            let user = ds.teachersList[uid] ?? ds.usersList[uid]
            filteredString = user?.name ?? ""
        }
        
        return filteredString.contains(q.lowercased())
    }
}
