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
        
        let msg = "confirmUnsign".translated + dType.singular + " ?"
        
        UIAlertController.create(title: nil, message: msg, preferredStyle: .alert)
            .aAction(.init(title: "Yes".translated, style: .default,handler: handler))
            .aAction(.init(title: "No".translated, style: .cancel))
            .show()
    }
}

