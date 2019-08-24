//
//  NotificationManager.swift
//  YogaLessons
//
//  Created by Eran karaso on 05/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    static let createdNotificationsIds = "createdNotificationsIds"
    var createdNotificationsIds:Set<String>//id of notification
    
    init() {
        
        let defaults = UserDefaults.standard
        
        let key = NotificationManager.createdNotificationsIds
        
        createdNotificationsIds = defaults.object(forKey: key) as? Set<String> ?? []
    }
    
    deinit {
        let defaults = UserDefaults.standard
        
        let key = NotificationManager.createdNotificationsIds
        
        defaults.set(createdNotificationsIds, forKey: key)
    }
    
    func setNotification(objId:String,title:String,time:Date) {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
                
                
                notificationCenter.getNotificationSettings { (settings) in
                    switch settings.authorizationStatus{
                        
                    case .authorized:
                        self.makeNotification( objId: objId, title,time)
                    case .notDetermined,.denied,.provisional:
                        break@unknown default:
                        fatalError()
                        
                    }
                }
            }
            
            self.makeNotification( objId: objId, title, time)
        }
    }
    
    func makeNotification(objId:String,_ title:String,_ time:Date) {
        let content = UNMutableNotificationContent()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let formattedTime = formatter.string(from: time)
        
        content.title = title
        
        content.body =
        "remindingYou".translated + " \(title)" + "is about to begin at".translated + " \(formattedTime)"
        //                formatt time from time
        content.sound = .default
        
        let dateComps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: time.substruct(unit: .hour, amount: 1)!)//notifies 1 hour before
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: false)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let uuidString = UUID().uuidString
        
        createdNotificationsIds.insert(objId)
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current()
            .add(request) { (error) in
            //  check errors
        }
    }
    
    func removeNotification(objId:String) {
        guard createdNotificationsIds.contains(objId)
            else {return}
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [objId])
    }
   
}


//like broadcast manager
extension Notification.Name{
    
    static let _signedTabSelected = Notification.Name("signed tab selected")
    
    static let _dataLoaded = Notification.Name("data loaded")
    
//    static let _dataSorted = Notification.Name("data sorted")
    
    static let _dataAdded = Notification.Name("data_added")
    static let _signedDataAdded = Notification.Name("signed added")

    static let _dataRemoved = Notification.Name("data removed")
    static let _signedDataRemoved = Notification.Name("signed removed")
    
    static let _dataChanged = Notification.Name("data changed")
    static let _dataCancled = Notification.Name("cancled")
    
    
    static let _sortTapped = Notification.Name("sort Tapped")
    
    static let _searchStarted = Notification.Name("search Tapped")
    static let _searchQueryTyped = Notification.Name("search query")
    static let _searchCanceled = Notification.Name("search cancled")
    
    static let _locationChanged = Notification.Name("Location changed")
    
    static let _currentUserDidSet = Notification.Name("current user did set")
    
    //keyboard notifications
    static let keyboardWillShow = UIResponder.keyboardWillShowNotification
    static let keyboardWillHide = UIResponder.keyboardWillHideNotification
    
    static let _connectionMade = Notification.Name("Internet connection made")
}

extension NotificationCenter{
    
    func post(name:Notification.Name,userInfo:[AnyHashable:Any]) {
        DispatchQueue.main.async {
            self.post(name: name, object: nil, userInfo: userInfo)
        }
    }
}
