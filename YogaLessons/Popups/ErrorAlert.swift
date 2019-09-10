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
        let alert = UIAlertController.create(title: title ?? "Problem found".translated, message: message, preferredStyle: .alert)
        
        alert.bgColor = ._errAlertBg
        
        alert.aAction(.init(title: "ok".translated, style: .default, handler: nil)).show()
    }
//    for Set Error of textField
    class func show(title: String?, message: String?,
         onDismissed:@escaping (UIAlertAction)->Void) {
        let alert = UIAlertController.create(title: title, message: message, preferredStyle: .alert)
        
        alert.bgColor = ._errAlertBg
        
        let okAction = UIAlertAction(title: "ok".translated, style: .default, handler: onDismissed)
        alert.aAction(okAction).show()
    }
}
