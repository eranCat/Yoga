//
//  LoginReturnExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 10/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit


protocol TextFieldReturn:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    
    //MARK: call this method in viewdidload
    func initTextFields(_ textFields:UITextField...)
}

extension TextFieldReturn{
    
    //call this inside of textFieldShouldReturn
    func nextTxtField(_ textField:UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func initTextFields(_ textFields:UITextField...){

        for (i,tf) in textFields.enumerated() {
            tf.delegate = self
            tf.tag = i
        }
    }
}

