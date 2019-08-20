//
//  ImageViewRounded.swift
//  Lec8HW
//
//  Created by Eran karaso on 27/05/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UIButton{
    @IBInspectable
    var rounded: CGFloat {
        get{return layer.cornerRadius}
        set
        {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
    }
    
}
