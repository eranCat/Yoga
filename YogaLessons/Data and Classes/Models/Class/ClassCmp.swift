//
//  ClassCmp.swift
//  YogaLessons
//
//  Created by Eran karaso on 05/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension Class{
    
    typealias ClassCmp = (Class,Class) -> Bool
    
    static let mostRelevantSorter:ClassCmp = {
        return Class.DateSorter($0,$1) && Class.LocationSorter($0,$1)
    }
    
    static let titleSorter:ClassCmp = {$0.title.lowercased() < $1.title.lowercased()}
    static let levelSorter = { $0.level.rawValue < $1.level.rawValue} as ClassCmp
    static let DateSorter = {$0.startDate > $1.startDate} as ClassCmp
    static let LocationSorter: ClassCmp = {
        
        guard let loc = LocationUpdater.shared.getLastKnowLocation()
            else{return false}
        
        let c1Loc = $0.location
        let c2Loc = $1.location
        
        return c1Loc.distance(from: loc) < c2Loc.distance(from:loc)
    }
    
//    static let statusSorter:ClassCmp = { $0.status == .active}
    
    class func sorter(for st: SortType) -> ClassCmp {
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

extension Class:Equatable{
    static func == (lhs: Class, rhs: Class) -> Bool {
        if lhs === rhs{
            return true
        }
        return lhs.id == rhs.id
    }
}
