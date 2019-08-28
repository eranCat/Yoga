//
//  NumberTextField.swift
//  YogaLessons
//
//  Created by Eran karaso on 16/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import iOSDropDown

class MaxAmountField: DropDown {
    
    var number : Int?{
        guard let t = text,
        let num = Int(t), num >= 0
        else {return nil}
        
        return num
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        optionArray = ["Choose a number".translated,"No maximum".translated]
        selectedRowColor = #colorLiteral(red: 0.7782526016, green: 0.93667835, blue: 1, alpha: 1)
        blurBG()
    }
    
//    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
//
//        let validCharacters = CharacterSet(charactersIn: "0123456789")
//        return text.rangeOfCharacter(from: validCharacters) != nil //if contains this numbers
//    }
//
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(paste(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
