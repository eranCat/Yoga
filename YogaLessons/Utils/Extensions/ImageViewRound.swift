//
//  ImageViewRound.swift
//  YogaLessons
//
//  Created by Eran karaso on 22/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UIImageView{
    func round(by radius:CGFloat = 10) {
        layer.cornerRadius = radius
        clipsToBounds = radius > 0
    }
}
