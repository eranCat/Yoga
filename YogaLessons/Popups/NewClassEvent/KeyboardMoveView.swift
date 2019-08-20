//
//  22.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension NewClassEventViewController{
    
//    func subscribeToKeyboard() {
//
//        let notifications:[Notification.Name] = [.keyboardWillShow,.keyboardWillHide]
//
//        for notification in notifications {
//
//            NotificationCenter.default
//                .addObserver(self, selector:#selector(keyBoardWillChange(_:)),
//                             name: notification, object: nil)
//        }
//    }
//
//    @objc
//    func keyBoardWillChange(_ notification:Notification) {
//        //        print("keyboard will show",notification.name.rawValue)
//
//        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//            else{return}
//
//
//        let keyboardY = self.view.frame.height - keyboardRect.height
//
//        let keyobardPadding:CGFloat = 60
//
//        switch notification.name {
//        case .keyboardWillShow:
//
//
//            guard let editingTFY = self.focusedField?.frame.origin.y,
//                self.view.frame.origin.y >= 0, //to  check if not already changed
//                editingTFY > keyboardY - keyobardPadding
//                else{return}
//
//
//            self.view.frame.origin.y = (editingTFY - (keyboardY - keyobardPadding))
//
//            UIView.animate(withDuration: 0.25, delay: 0,
//                           options: .curveEaseInOut,
//                           animations: {self.view.layoutIfNeeded()},
//                           completion: nil)
//
//
//
//        case .keyboardWillHide:
//
//            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
//
//                self.view.frame.origin.y = 0
//            })
//
//        default:
//            break
//        }
//    }
    
}
