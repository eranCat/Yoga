//
//  UserInfoTextViewDelegate.swift
//  YogaLessons
//
//  Created by Eran karaso on 26/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UserInfoViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        let about = !aboutTV.isEmpty ? (aboutTV.text ?? "") : ""
        
        guard about != currentUser.about else{return}
        
        dataSource.updateCurrentUserValue(forKey: .about, about)
    }
}

