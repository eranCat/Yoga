//
//  String+Extensions.swift
//  Lec15Part2
//
//  Created by Eran karaso on 23/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension String{
    
    //usage: btn.text.translated
    var translated: String {
        return NSLocalizedString(self
            , comment:  self)
    }
    
    func print() {
        Swift.print(self)
    }
}
