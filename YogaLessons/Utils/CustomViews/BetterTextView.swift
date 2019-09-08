//
//  TextViewExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 20/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

@IBDesignable
class BetterTextView :UITextView,UITextViewDelegate{
    
    var placeHolderString:String?
    
    var delegate2:UITextViewDelegate?
    
    @IBInspectable var defaultTextColor:UIColor = .black
    
    override func awakeFromNib() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
        
        delegate = self
        
        blurBG(cornerRadius: layer.cornerRadius)
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
        layer.masksToBounds = true
        
        if text != placeHolderString{
            textColor = defaultTextColor
        }
    }
    
    
    override var text: String!
        {
        didSet(new){ //set from code
            if !new.isEmpty && new != placeHolderString{
                textColor = defaultTextColor
            }
        }
    }
    
    @IBInspectable
    var PlaceHolder: String? {
        get {
            return placeHolderString
        }
        set {
            text = newValue?.translated
            placeHolderString = newValue?.translated
            textColor = ._placeholderTxt
        }
    }
    
    var isEmpty:Bool{
        return text == PlaceHolder
    }
    
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textColor == UIColor._placeholderTxt {
            if text == placeHolderString{
                text = ""
            }
            textColor = defaultTextColor
        }
        
        delegate2?.textViewDidBeginEditing?(textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if text.isEmpty {
            text = placeHolderString
            textColor = UIColor._placeholderTxt
        }
        
        delegate2?.textViewDidEndEditing?(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"{
            resignFirstResponder()
            return false
        }
        
        return true
    }
    
    fileprivate func shakeEffect(baseColor: UIColor,revert: Bool, shakes: Float) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        
        animation.fromValue = baseColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.5
        if revert { animation.autoreverses = true } else { animation.autoreverses = false }
        self.layer.add(animation, forKey: "")
        
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        
        if revert { shake.autoreverses = true  } else { shake.autoreverses = false }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
    
    func setError(message:String) {
        
        ErrorAlert.show(title: nil,message: message){ _ in
            self.shakeEffect(baseColor: .black, revert: false, shakes: 2)
            self.becomeFirstResponder()
        }
    }
}
