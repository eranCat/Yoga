//
//  CustomAlert.swift
//  YogaLessons
//
//  Created by Eran karaso on 31/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    var preferedFont: UIFont{ return UIFont(name: "Al Nile", size: 18.0)!}
    var titleFont :UIFont { return UIFont(name: "AlNile-Bold", size: 20.0)!}
    

    var bgColor:UIColor?{
        set(color){
            if let c = color{
                let contentView = view.subviews.last?.subviews.last?.subviews.first
                contentView?.backgroundColor = c
                view.tintColor = ._dialogTxtColor
            }
        }
        get{
            return view.subviews.last?.subviews.last?.backgroundColor
        }
    }
    
    var messageTextColor:UIColor?{
        set(color){
            
            if let color = color,
                let message = self.message{
                
                let messageMutableString = NSMutableAttributedString(string: message as String, attributes: [.font: preferedFont])
                
                messageMutableString.addAttribute(.foregroundColor, value: color, range: .init(location:0,length:message.count))
                
                setValue(messageMutableString, forKey: "attributedMessage")
            }
        }
        get{
            return value(forKey: "attributedMessage") as? UIColor
        }
    }
    
    var titleTextColor:UIColor? {
        set(color){
            
            if let color = color,
                let title = self.title{
                
                let titleMutableString = NSMutableAttributedString(string: title as String,
                                                                   attributes: [.font:titleFont])
                
                titleMutableString.addAttribute(NSAttributedString.Key.foregroundColor,
                                value: color, range: NSRange(location:0,length:title.count))
                
                setValue(titleMutableString, forKey: "attributedTitle")
            }
        }
        get{
            return value( forKey: "attributedTitle") as? UIColor
        }
    }

    
    
    class func create(title: String?, message: String?, preferredStyle: UIAlertController.Style)->UIAlertController{
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        alertController.bgColor = ._dialogBGcolor

        // Change Title With Color and Font:
        alertController.titleTextColor = ._dialogTxtColor

        // Change Message With Color and Font
        alertController.messageTextColor = ._dialogTxtColor
        
        alertController.modalPresentationStyle = .fullScreen
        
        return alertController
    }
    
    func show(presentingVC:UIViewController? = nil, completion:(()->Void)? = nil){
        (presentingVC ?? UIApplication.shared.presentedVC)?.present(self, animated: true, completion: completion)
    }
    
    
    func aAction(_ action: UIAlertAction) -> UIAlertController {
        self.addAction(action)
        
        switch action.style {
        case .destructive:
            action.tintColor = ._destructiveTxt
        case .cancel:
            break
        default:
            break
        }
        
        return self
    }
    func addActions(_ actions:[UIAlertAction]) -> UIAlertController {
        actions.forEach{ aAction($0)}
        return self
    }
    
}

extension UIAlertAction{
    var tintColor:UIColor?{
        get{
            return value(forKey: "titleTextColor") as? UIColor
        }
        set(c){
            if let color = c{
                setValue(color, forKey: "titleTextColor")
            }
        }
    }
}
