//
//  MainConnectionDelegate.swift
//  YogaLessons
//
//  Created by Eran karaso on 10/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import Reachability

extension MainTabBarController:ReachabilityObserverDelegate{
    
    override func viewWillAppear(_ animated: Bool) {
        addReachabilityObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeReachabilityObserver()
    }
}
