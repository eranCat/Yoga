//
//  UnsignAlert.swift
//  YogaLessons
//
//  Created by Eran karaso on 24/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class UnsignAlert {
    class func show(dType:DataType,handler:@escaping (UIAlertAction)->Void) {
        
        let msg = "confirmUnsign".translated + " " + dType.singular + " ?"
        
        let alert = UIAlertController.init(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "Yes".translated, style: .default,handler: handler) )
        
        alert.addAction(.init(title: "No".translated, style: .cancel))
        
        UIApplication.shared.presentedVC?.present(alert,animated: true)
    }
}

