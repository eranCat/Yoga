//
//  NewTextViewDelegate.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension NewClassEventViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        focusedField = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        focusedField = nil
    }
}
