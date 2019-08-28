//
//  UIViewExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 28/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UIView{
    
//    call on viewWillAppear
    class func reposition(views:[UIView],transform:CGAffineTransform) {
        views.forEach{$0.transform = transform}
    }
    
//    call on viewDidApear
    class func animateToIdentity(views:[UIView],
                                 duration:TimeInterval = 1.0,
                                 delay:TimeInterval = 0,
                                 completion:((Bool)->Void)? = nil) {
        
        let relDuration = duration / Double(views.count)
        
        UIView.animateKeyframes(withDuration: duration, delay: delay,
                                options: [.calculationModeLinear], animations: {
                                    
                                    
                                    for (i,v) in views.enumerated(){
                                        
                                        let relStartTime = (Double(i) * relDuration) / duration
                                        
                                        UIView.addKeyframe(withRelativeStartTime: relStartTime,
                                                           relativeDuration: relDuration,
                                                           animations: {
                                                            v.transform = .identity
                                        })
                                    }
                                    
                                    
                                    
        }, completion: completion)
    }
}
