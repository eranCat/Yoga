//
//  File.swift
//  YogaLessons
//
//  Created by Eran karaso on 06/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation
import EventKit

class LocalCalendarManager {
    static let shared = LocalCalendarManager()
    
    static let createdEventsIds = "createdEventsIds"
    
    var createdEventsIds:[String:String]
    
    
    init() {
        
        let defaults = UserDefaults.standard
        
        let key = LocalCalendarManager.createdEventsIds

        createdEventsIds = defaults.dictionary(forKey: key) as? [String:String] ?? [:]
        
    }
    
    deinit {
        let defaults = UserDefaults.standard
        
        let key = LocalCalendarManager.createdEventsIds
        
        defaults.set(createdEventsIds, forKey: key)
    }
    
    
    func insertEvent(store: EKEventStore,id:String,title:String,placeName:String,location:CLLocation,startDate:Date,endDate:Date) {
        
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars {
            
            if calendar.title == "ioscreator" {
                
                let event = EKEvent(eventStore: store)
                
                createdEventsIds[id] = event.eventIdentifier
                
                event.calendar = calendar
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                
                let structuredLocation = EKStructuredLocation(title: placeName)
                structuredLocation.geoLocation = location
                event.structuredLocation = structuredLocation
                
                do {
                    try store.save(event, span: .thisEvent)
                }
                catch {
                    print("Error saving event in calendar")
                }
            }
        }
    }
    func setEvent(objId:String,objId id:String,title:String,placeName:String,location:CLLocation,startDate:Date,endDate:Date) {
        
        let eventStore = EKEventStore()
        
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore, id: id, title: title, placeName: placeName, location: location, startDate: startDate,endDate: endDate)
            
        case .denied:
            print("Access denied")
        case .notDetermined:
            
            eventStore.requestAccess(to: .event, completion:
                {[weak self] (granted: Bool, error: Error?) in
                    if granted {
                        self!.insertEvent(store: eventStore, id: id, title: title, placeName: placeName, location: location, startDate: startDate,endDate: endDate)
                    } else {
                        print("Access denied")
                    }
            })
        default:
            print("Case default")
        }
    }
    
    func removeEvent(objId:String) {
        let store = EKEventStore();
        store.requestAccess(to: .event) { (granted, error) in
            
            guard granted,
                let eventId = self.createdEventsIds[objId]
            else{return}
            
            if let eventToRemove = store.event(withIdentifier: eventId){
            
                do{
                   try store.remove(eventToRemove, span: .thisEvent,commit: true)
                }
                catch{
                    print(error)
                }
            }
        }
    }
}
