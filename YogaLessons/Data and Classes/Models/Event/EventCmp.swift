//
//  EventCmp.swift
//  YogaLessons
//
//  Created by Eran karaso on 05/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension Event{
    
    typealias eventCmp = (Event,Event) -> Bool
    
    static let mostRelevantSorter:eventCmp =
    { Event.DateSorter($0,$1) && Event.LocationSorter($0,$1)}
    
    static let titleSorter:eventCmp  = { $0.title.lowercased() < $1.title.lowercased()}
    static let levelSorter: eventCmp = { $0.level.rawValue < $1.level.rawValue}
    static let DateSorter: eventCmp = { $0.startDate > $1.startDate}
    static let LocationSorter: eventCmp = {
        
        guard let loc = LocationUpdater.shared.getLastKnowLocation()
            else{return false}
        
        let e1Loc = $0.location
        let e2Loc = $1.location
        
        return e1Loc.distance(from: loc) < e2Loc.distance(from:loc)
    }
    
    class func sorter(for st: SortType) -> eventCmp {
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

extension Event:Filterable{
    
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

extension Event:Equatable{
    static func == (lhs: Event, rhs: Event) -> Bool {
        if lhs === rhs{
            return true
        }
        return lhs.id == rhs.id
    }
}
