//
//  ReachabilityObserverDelegate.swift
//  YogaLessons
//
//  Created by Eran karaso on 10/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation
import Reachability
import SVProgressHUD

//Reachability
//declare this property where it won't go out of scope relative to your listener
fileprivate var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func reachabilityChanged(_ isReachable: Bool)
}

protocol ReachabilityObserverDelegate: class, ReachabilityActionDelegate {
    func addReachabilityObserver()
    func removeReachabilityObserver()
}

// Declaring default implementation of adding/removing observer
extension ReachabilityObserverDelegate {
    
    /** Subscribe on reachability changing */
    func addReachabilityObserver() {
        reachability = Reachability()
        
        reachability.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(true)
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /** Unsubscribe */
    func removeReachabilityObserver() {
        reachability.stopNotifier()
        reachability = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func reachabilityChanged(_ isReachable: Bool) {
        if !isReachable{
            showConnectionAlert()
        }else{
            NotificationCenter.default.post(.init(name: ._connectionMade))
        }
    }
    
    func showConnectionAlert() {
        SVProgressHUD.dismiss()
        let alert = UIAlertController.create(title: "noInternet".translated,message: "checkNet".translated,preferredStyle: .alert)
        .aAction(.init(title: "internetSetting".translated, style: .default) { _ in
            self.openInternetSettings()
        })
            
        alert.show()
        
        
        NotificationCenter.default.addObserver(forName: ._connectionMade, object: nil, queue: .main) { (notif) in
            
            alert.dismiss(animated: true)
        }
    }
    
    func openInternetSettings() {
        
        let shared = UIApplication.shared
        
        let url = URL(string: UIApplication.openSettingsURLString)!
        
        if #available(iOS 10.0, *) {
            shared.open(url)
        } else {
            shared.openURL(url)
        }
    }
}
