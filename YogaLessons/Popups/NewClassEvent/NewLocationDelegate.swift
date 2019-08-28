//
//  File.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import LocationPickerViewController

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
        lblLocation.text = item.name
        selectedPlaceName = item.name
        if item.coordinate != nil{
            let (lat,lon) = item.coordinate!
            selectedCoordinate = .init(latitude: lat, longitude: lon)
        }
    }
    
    
    func setLocationPicker() -> LocationPicker {
        
        let  locPicker = LocationPicker()
        
        locPicker.setColors(themeColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), primaryTextColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), secondaryTextColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
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
