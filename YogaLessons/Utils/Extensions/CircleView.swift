//
//  CircleView.swift
//  YogaLessons
//
//  Created by Eran karaso on 16/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class CircledView: UIImageView {
    private func makeCircled() {
        let maxSize = max(frame.height,frame .width)
        
        layer.cornerRadius = maxSize / 2
        
        layer.borderWidth = 1
        layer.borderColor = UIColor._border.cgColor
        
        clipsToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        makeCircled()
    }
}

extension UIView{
    func roundCorners(radius:CGFloat = 10) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
