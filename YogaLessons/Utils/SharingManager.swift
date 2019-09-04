//
//  ShatringManager.swift
//  YogaLessons
//
//  Created by Eran karaso on 03/09/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class SharingManager {
    class func share(data:DynamicUserCreateable) {
        
        let data = data as! (Titled & Located & Scheduled)
        let currentDataType:DataType = data is Event ? .events : .classes
        //        MARK: link to app on Appstore
        //        let appleID = ""
        //        let appStoreLink = "https://itunes.apple.com/app/id\(appleID)"
        
        // text to share
        
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.locale = .preferredLocale
        
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let from = formatter.string(from: data.startDate)
        let until = formatter.string(from: data.endDate)
        
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        let day = formatter.string(from: data.startDate)
        
        // set up activity view controller
        var textToShare = "\("checkOut".translated) \(currentDataType.singular) "
        textToShare += "of".translated + " " + data.title + "\n"
        textToShare += "atD".translated + " \(day)" + "\n"
        textToShare += "between the hours ".translated + "\(from) - \(until) "
        textToShare += "on".translated + data.locationName
        
        let presentedVC: UIViewController? = UIApplication.shared.presentedVC

        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = presentedVC?.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes =
            [ .addToReadingList,.assignToContact,.openInIBooks,.print,.saveToCameraRoll]
        
        // present the view controller
        presentedVC?.present(activityViewController, animated: true)
    }
}
