//
//  SearchBarExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 09/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UISearchBar{
    var scopeBarTextColorNormal:UIColor{
        set(color){
            setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.foregroundColor : color], for: .normal)
        }
        
        get{
            let attrabutes = scopeBarButtonTitleTextAttributes(for: .normal)
            
            return attrabutes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? UIColor()
        }
    }
    var scopeBarTextColorSelected:UIColor{
        set(color){
            setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.foregroundColor : color], for: .selected)
        }
        
        get{
            let attrabutes = scopeBarButtonTitleTextAttributes(for: .selected)
            
            return attrabutes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? UIColor()
        }
    }
    
    
    var textField:UITextField?{
        return findTextField(view: self)
    }
    
    private func findTextField(view:UIView) -> UITextField? {
        for v in view.subviews{
            if let tf = v as? UITextField{
                return tf
            }
            else if let tf = findTextField(view: v){
                return tf
            }
        }
        
        return nil
    }
}
