//
//  TextFieldExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 29/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UITextField{
 
    fileprivate func shakeEffect(baseColor: UIColor,revert: Bool, shakes: Float) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        
        animation.fromValue = baseColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.5
        if revert { animation.autoreverses = true }
        else { animation.autoreverses = false }
        
        layer.add(animation, forKey: "")
        
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        
        if revert { shake.autoreverses = true  } else { shake.autoreverses = false }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        layer.add(shake, forKey: "position")
    }
    
    func setError(message:String) {
        
        let alert = UIAlertController(title: "Incorrect value", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok", style: .default)
        { action in
            
            self.shakeEffect(baseColor: .black, revert: false, shakes: 2)
            self.becomeFirstResponder()
        }
        
        alert.addAction(ok)
        
        UIApplication.shared.presentedVC?.present(alert, animated: true)
    }
}
