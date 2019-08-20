//
//  ViewControllerExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

//@objc
extension UIViewController{
    static func newVC(storyBoardName storyName:String = "Main" ,id:String) -> UIViewController {
        
        return UIStoryboard(name: storyName, bundle: nil).instantiateViewController(withIdentifier: id)
    }
    
    func newVC(storyBoardName storyName:String = "Main" ,id:String) -> UIViewController {
        return UIViewController.newVC(storyBoardName: storyName, id: id)
    }
    
    //MARK: hide keyboard on tap
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
