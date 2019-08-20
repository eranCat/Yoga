//
//  Located.swift
//  YogaLessons
//
//  Created by Eran karaso on 20/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import CoreLocation

protocol Located {
    var locationCoordinate: CLLocationCoordinate2D { get set }
    var locationName:String { get set }
    
    var location:CLLocation {get}
}

extension Located{
    var location:CLLocation{
        return .init(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
    }
}
