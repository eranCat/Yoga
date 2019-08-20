//
//  ColoredNavBar.swift
//  YogaLessons
//
//  Created by Eran karaso on 19/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

@IBDesignable
extension UIViewController{
    
    @IBInspectable
    var NavigationBarColor: UIColor? {
        set(color){
            navigationController?.navigationBar.barTintColor = color
        }
        get{
            return navigationController?.navigationBar.barTintColor
        }
    }
}
