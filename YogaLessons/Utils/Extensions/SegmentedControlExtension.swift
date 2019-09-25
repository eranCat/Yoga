//
//  SegmentedControllerExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 23/09/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UISegmentedControl{
      
    var selectedTintColor: UIColor? {
        get {
            if #available(iOS 13.0, *){
                return self.selectedSegmentTintColor
            }
            return nil
        }
        set {
            if #available(iOS 13.0, *){
                self.selectedSegmentTintColor = newValue
            }
        }
    }
    
    var normalTextColor: UIColor? {
        get {
            if #available(iOS 13.0, *){
                return getTextColor(for: .normal)
            }
            return nil
        }
        set {
            if #available(iOS 13.0, *),let color = newValue{
                setText(color: color, for: .normal)
            }
        }
    }
    
    var selectedTextColor: UIColor? {
        get {
            if #available(iOS 13.0, *){
                return getTextColor(for: .selected)
            }
            return nil
        }
        set {
            if #available(iOS 13.0, *),let color = newValue{
                setText(color: color, for: .selected)
            }
        }
    }
    
    var focusedTextColor: UIColor? {
        get {
            if #available(iOS 13.0, *){
                return getTextColor(for: .focused)
            }
            return nil
        }
        set {
            if #available(iOS 13.0, *),let color = newValue{
                setText(color: color, for: .focused)
            }
        }
    }
    
    func setText(color:UIColor ,for state:UIControl.State ){
        setTitleTextAttributes([.foregroundColor : color], for: state)
    }
    
    func getTextColor(for state:UIControl.State) -> UIColor{
        titleTextAttributes(for: state)?[.foregroundColor] as? UIColor ?? .lightGray
    }
}
