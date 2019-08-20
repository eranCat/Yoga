//
//  Signupscroll.swift
//  YogaLessons
//
//  Created by Eran karaso on 04/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

//for textfield scroll
extension SignupViewController:UITextFieldDelegate,UITextViewDelegate{
    
    func delegateTextFields(root rootView:UIView) {
        for v in rootView.subviews {
            if let textField = v as? UITextField{
                textField.delegate = self
            }else if let tv = v as? UITextView {
                if let bTv = tv as? BetterTextView{
                    bTv.delegate2 = self
                }else{
                    tv.delegate = self
                }
            }
            else{
                delegateTextFields(root: v)
            }
        }
    }
    
    fileprivate func scrollToView(_ v: UIView) {
        //        let y = v.center.y
        //        UIView.animate(withDuration: 0.3,delay:0, options: .curveEaseOut,animations: {
        //
        //            self.scrollView.contentOffset = .init(x: 0, y: y)
        //        })
    }
    fileprivate func resetScrolling() {
        //        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollToView(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resetScrolling()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        scrollToView(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        resetScrolling()
    }
}
