//
//  DateTextFieldd.swift
//  YogaLessons
//
//  Created by Eran karaso on 08/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class ToolbarTextField : BlurredTextField{
    
    override func setup(){
        super.setup()
        
        let screenWidth = UIScreen.main.bounds.width
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        
        let button : UIBarButtonItem
        if returnKeyType == .next{
            button = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(buttonAction))
        } else {
            button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(buttonAction))
        }
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [spaceButton,button]
        self.inputAccessoryView = toolbar
        
    }
    
    @objc func buttonAction(){
        //act like return key press
        self.sendActions(for: .editingDidEndOnExit)
        endEditing(true)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(paste(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
