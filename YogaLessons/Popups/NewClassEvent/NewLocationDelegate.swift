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
        updateLocationFeilds( locationItem)
        popLocationPicker()
    }
    
    func locationDidPick(locationItem: LocationItem) {
        updateLocationFeilds(locationItem)
        popLocationPicker()
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
    
    func popLocationPicker() {
        
        if navigationController?.viewControllers.last! is LocationPicker {
            navigationController?.popViewController(animated: true)
        }
    }
}
