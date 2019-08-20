//
//  ActivityIndicatorViewExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 09/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView{
    class func show(uiView: UIView) -> UIActivityIndicatorView {
        
        let squareView = UIView()
        squareView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        squareView.center = uiView.center
        squareView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        squareView.clipsToBounds = true
        squareView.layer.cornerRadius = 10

        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        actInd.style = .whiteLarge
        actInd.center = CGPoint(x: squareView.frame.size.width / 2,
                                y: squareView.frame.size.height / 2);
        actInd.hidesWhenStopped = true
        squareView.addSubview(actInd)
        uiView.addSubview(squareView)
        actInd.startAnimating()

        return actInd
    }
    
    func hide() {
        stopAnimating()
        superview?.removeFromSuperview()
    }
}
