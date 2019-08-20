//
//  AppExtension.swift
//  Lec16
//
//  Created by Eran karaso on 26/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UIApplication{
    var presentedVC: UIViewController?{
        //application singleton.app windows
//        var root = UIApplication.shared.keyWindow?.rootViewController
//
//        while let pvc = root?.presentingViewController {
//            root = pvc
//        }
        
        var vc: UIViewController? = keyWindow?.rootViewController ?? windows[0].rootViewController
        
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        
        return vc
    }
}
