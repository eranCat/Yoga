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
    
    enum NotificationKind {
        case starting
        case canceled
        case restored
    }
    fileprivate func makeNotification(by kind:NotificationKind,id:String,title:String,time:Date) {
        switch kind{
        case .starting:
            makeNotificationForStart(objId: id,title: title,time: time)
            
        case .canceled:
            makeNotificationForCancel(objId: id,title: title,time: time)
            
        case .restored:
            makeNotificationForRestored(objId: id,title: title,time: time)
            
        }
    }
    
    func setNotification(objId:String,title:String,time:Date,kind:NotificationKind) {
        
        askForPermission { (isPermitted) in
            if let hasPermission = isPermitted,hasPermission{
                self.makeNotification(by: kind, id: objId, title: title, time: time)
            }
        }
    }
    
    func showNotificationsSettingAlert(done:((Bool?)->Void)?) {
        
        let settingAction = UIAlertAction(title: "Open settings".translated, style: .default){ _ in
            DispatchQueue.main.async {
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                    else {
                        done?(false)
                        return}
                
                let app = UIApplication.shared
                
                if app.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        app.open(settingsUrl){ (success) in
                            print("Settings opened: \(success)") // Prints true
                            done?(success)
                        }
                    } else {
                        let openedSuccessfully = app.openURL(settingsUrl as URL)
                        done?(openedSuccessfully)
                    }
                }else{
                    done?(false)
                }
            }
        }
        
        let cancelAction =
            UIAlertAction(title: "Cancel".translated,style: .cancel) {_ in done?(false)}
        
        UIAlertController
            .create(title: nil, message: "allowNotifications".translated, preferredStyle: .alert)
            .aAction(settingAction)
            .aAction(cancelAction)
            .show()
    }
    
    fileprivate func makeNotification(startTime time: Date, _ title: String,_ body:String, _ objId: String) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        
        content.body = body
        
        content.sound = .default
        
        
        let dateComps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: false)
        
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let uuidString = UUID().uuidString
        
        createdNotificationsIds.insert(objId)
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current()
            .add(request) { (error) in
                //  check errors
                if let err = error{
                    ErrorAlert.show(message: err.localizedDescription)
                }
        }
    }
    
    private func makeNotificationForStart(objId:String,title:String,time:Date) {
        //                format time from time
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let formattedTime = formatter.string(from: time)
        
        let body = "remindingYou".translated + " \(title)" + "is about to begin at".translated + " \(formattedTime)"
        
        let startTime: Date = time.substruct(unit: .minute, amount: 30) ?? Date()
        
        makeNotification(startTime: startTime ,title,body, objId)
    }
    private func makeNotificationForCancel(objId:String,title:String,time:Date) {
        //                format time from time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let formattedTime = formatter.string(from: time)
        
        let body = "\(title) \("atD".translated) \(formattedTime) \("was canceled".translated)"
        
        let now = Calendar.current.date(byAdding: .second, value: 3, to: .init())!
        
        makeNotification(startTime: now ,title,body, objId)
    }
    private func makeNotificationForRestored(objId:String,title:String,time:Date) {
        //                format time from time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let formattedTime = formatter.string(from: time)
        
        let body = "\(title) \("atD".translated) \(formattedTime) \("has been restored".translated)"
        
        let now = Calendar.current.date(byAdding: .second, value: 3, to: .init())!
        
        makeNotification(startTime: now ,title,body, objId)
    }
    
    func removeNotification(objId:String) {
        guard createdNotificationsIds.contains(objId)
            else {return}
        
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [objId])
    }
   
    fileprivate func askSystemPermission(done:((Bool?)->Void)?) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) { didAllow, error in
            if !didAllow {
                //                        system alert for permission
                notificationCenter.getNotificationSettings { (settings) in
                    switch settings.authorizationStatus{
                        
                    case .authorized:
                        done?(true)
                    case .notDetermined,.denied,.provisional:
                        self.showNotificationsSettingAlert(done:done)
                    @unknown default:
                        print("new unhandled notification status:",settings.authorizationStatus)
                    }
                }
                
            }else{
                done?(didAllow)
            }
        }
    }
    
    func askForPermission(done:((Bool?)->Void)?) {
        
        //                        system alert for permission
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus{

            case .authorized:
                done?(true)
            case .notDetermined,.denied,.provisional:
                let okAction = UIAlertAction(title: "ok".translated, style: .default,handler: { _ in
                    self.askSystemPermission(done: done)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel".translated, style: .cancel,handler: { _ in
                    done?(false)
                })
                
                let msg = "allowNotifications".translated
                DispatchQueue.main.async {
                    UIAlertController
                        .create(title: nil,message: msg,preferredStyle: .alert)
                        .addActions([okAction,cancelAction])
                        .show()
                }

            @unknown default:
                print("new unhandled notification status:",settings.authorizationStatus)
            }
        }
    }
}


//like broadcast manager
extension Notification.Name{
    
    static let _signedTabSelected = Notification.Name("signed tab selected")
    
    static let _dataLoaded = Notification.Name("data loaded")
    
    static let _dataAdded = Notification.Name("data_added")
    static let _signedDataAdded = Notification.Name("signed added")

    static let _dataRemoved = Notification.Name("data removed")
    static let _signedDataRemoved = Notification.Name("signed removed")
    
    static let _dataChanged = Notification.Name("data changed")
    static let _signedDataChanged = Notification.Name("signed.data.changed")
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
    
    static let _settingChanged = Notification.Name("setting.changed")
    static let _reloadedAfterSettingChanged = Notification.Name("reloaded.after.setting.changed")

}

extension NotificationCenter{
    
    func post(name:Notification.Name,userInfo:[AnyHashable:Any]) {
        DispatchQueue.main.async {
            self.post(name: name, object: nil, userInfo: userInfo)
        }
    }
}
