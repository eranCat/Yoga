//
//  LocationManager.swift
//  Lec18SplitVC
//
//  Created by Eran karaso on 03/07/2019.
//  Copyright © 2019 hackeru. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class LocationUpdater:NSObject {
    static let shared = LocationUpdater()
    
    private lazy var locationManager = CLLocationManager()
    
    var currentCountryCode:String?
    
    override private init() {
        super.init()
                
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestAlwaysAuthorization()
    }
    
    func getLastKnowLocation() -> CLLocation? {
        return locationManager.location
    }
    
    func startLocationUpdates() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        locationManager.distanceFilter = 1000//kCLDistanceFilterNone// in meters
        
        locationManager.startUpdatingLocation()
        
        locationManager.requestLocation()
    }
    
    class func hasPermission() -> Bool{
        
        let status = CLLocationManager.authorizationStatus()
        
        return status == .authorizedAlways || status == .authorizedAlways
    }
    
    class func locationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func showSetting() {
        let openSetting = UIAlertAction(title: "Open settings".translated, style: .default, handler: { (action) in
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else{return}
            
            UIApplication.shared.open(url, options: [:])
        })
        
        UIAlertController.create(title: "allowLocation".translated,
                                             message: nil,
                                             preferredStyle: .alert)
            .aAction(openSetting)
            .aAction(.init(title: "Cancel".translated, style: .cancel))
        .show()
    }
    
    func openDirections(coordinate:CLLocationCoordinate2D,name:String?) {
        var source:MKMapItem?
        if let myLocation = getLastKnowLocation()?.coordinate{
            source = MKMapItem(placemark: MKPlacemark(coordinate: myLocation))
            source!.name = "My location".translated
        }
        
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        destination.name = name
        
        var installedNavigationApps = [UIAlertAction]()
        
        let mapsAction = UIAlertAction(title: "Open with apple maps".translated, style: .default){ action in
            
            var items:[MKMapItem] = [destination]
            
            if let src = source{
                items.insert(src, at: 0)
            }
            
            MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
        
        installedNavigationApps += [mapsAction]

        if let wazeURL = URL(string: "https://waze.com/ul"),
            UIApplication.shared.canOpenURL(wazeURL){
        
            let wazeAction = UIAlertAction(title: "Open with waze".translated, style: .default){ action in
                
                guard let url = URL(string:"https://www.waze.com/ul?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes&zoom=17")
                    else{return}
                
                UIApplication.shared.open(url, options: [:])
            }
            
            wazeAction.setValue(#imageLiteral(resourceName: "waze"), forKey: "image")
            
            installedNavigationApps += [wazeAction]
        }
    
        
        UIAlertController.create(title: nil, message: nil, preferredStyle: .alert)
            .addActions(installedNavigationApps)
            .aAction(.init(title: "Cancel".translated, style: .cancel, handler: nil))
            .show()
    }
    
    func getPlace(for location: CLLocation,
                  completion: @escaping (CLPlacemark?,Error?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            if error != nil {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil,error)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil,error)
                return
            }
            
            completion(placemark,error)
        }
    }
    
    
    func getCurrentCountryCode(done:@escaping (String?,Error?)->Void) {
        if let lastLocation = getLastKnowLocation(){
            getPlace(for: lastLocation) { mark,err in
                let code = mark?.isoCountryCode
                done(code,err)
                self.currentCountryCode = code
            }
        }else{
            done(nil,nil)
        }
    }
}

extension LocationUpdater:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status{
        case .notDetermined://"we didn't request location permission yet"
            break
        case .denied://"no  location permission"
            showSetting()
        case .authorizedAlways,.authorizedWhenInUse://"we got location permission"
            startLocationUpdates()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        NotificationCenter.default.post(name: ._locationChanged,
                                        object: self,userInfo: ["location":locations[0]])
    }
}


class PlaceAnnotation:NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    
    init(title:String?,subtitle:String?,coordinate:CLLocationCoordinate2D) {
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
