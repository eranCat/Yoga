//
//  File.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import LocationPickerViewController
import CoreLocation

extension NewClassEventViewController:LocationPickerDelegate{
    
    func locationDidSelect(locationItem: LocationItem) {
        
    }
    
    func locationDidPick(locationItem: LocationItem) {
        updateLocationFeilds(locationItem)
    }
    
    func locationDidDeny(locationPicker: LocationPicker) {
        LocationUpdater.shared.showSetting()
    }
    
    func updateLocationFeilds(_ item: LocationItem) {
        guard let (lat,lon) = item.coordinate,
            let code = item.addressDictionary?["CountryCode"] as? String
            else{
                ErrorAlert.show(message: LocationErrors.locationAmbiguous.errorDescription!)
                return
        }
        let place:String
        if let address = item.addressDictionary?["Street"] as? String,
            let city = item.addressDictionary?["City"] as? String{
            
            place = "\(city) \(address)"
        }else{
            place = item.name
        }
        
        
        updateLocationCompnents(name: place,coordinate: .init(latitude: lat, longitude: lon),
                                countryCode: code)
    }
    
    func updateLocationCompnents(name:String,coordinate:CLLocationCoordinate2D,countryCode:String)  {
        
        lblLocation.text = name
        selectedPlaceName = name
        
        selectedCoordinate = coordinate
        
        selectedCountryCode = countryCode
    }
    
    
    func setLocationPicker() -> LocationPicker {
        
        let  locPicker = LocationPicker()
        
        locPicker.setColors(themeColor: ._primary,
                            primaryTextColor: ._btnTint,
                            secondaryTextColor: ._accent)
        locPicker.currentLocationText = "Current Location".translated
        locPicker.searchBarPlaceholder = "Search for location".translated
        locPicker.locationDeniedAlertTitle = "Location access denied".translated
        locPicker.locationDeniedAlertMessage = "allowLocation".translated
        locPicker.locationDeniedGrantText = "Grant".translated
        locPicker.locationDeniedCancelText = "Cancel".translated
        
        locPicker.searchResultLocationIcon = #imageLiteral(resourceName: "locationPlace")
        
        locPicker.navigationController?.isNavigationBarHidden = false
        locPicker.addBarButtons()
        
        //        locationPicker.searchDistance = 10_000//in meters
        locPicker.longitudinalDistance = 600
        locPicker.delegate = self
        
        return locPicker
    }
}
