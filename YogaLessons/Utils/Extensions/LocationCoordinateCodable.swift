//
//  LocationCoordinateCodable.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D:DBCodable{
    func encode() -> JSON {
        var dict:[String:CLLocationDegrees] = [:]
        
        dict["lat"] = latitude
        dict["lon"] = longitude
        
        return dict
    }
    
    init(_ dict: JSON) {
        self.init()
        latitude = dict["lat"] as! CLLocationDegrees
        longitude = dict["lon"] as! CLLocationDegrees
    }
}
