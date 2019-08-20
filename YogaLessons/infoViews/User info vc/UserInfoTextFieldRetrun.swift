//
//  UserInfoTextFieldRetrun.swift
//  YogaLessons
//
//  Created by Eran karaso on 26/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UserInfoViewController:TextFieldReturn{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return nextTxtField(textField)
    }
}

