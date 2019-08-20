//
//  ErrorAlert.swift
//  YogaLessons
//
//  Created by Eran karaso on 04/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class ErrorAlert {
    
    class func show(title:String? = nil,message:String) {
        guard Thread.current.isMainThread else{
            DispatchQueue.main.async {
                show(title: title, message: message)
            }
            return
        }
        let alert = UIAlertController(title: title ?? "Problem found", message: message, preferredStyle: .alert)
        
        alert.addAction(.init(title: "ok", style: .default, handler: nil))
        
        UIApplication.shared.presentedVC?.present(alert, animated: true)
    }
}
