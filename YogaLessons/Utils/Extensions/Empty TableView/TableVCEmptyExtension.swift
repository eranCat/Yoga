//
//  File.swift
//  YogaLessons
//
//  Created by Eran karaso on 07/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

extension UITableViewController{
    
    func adjustEmpty(_ isEmpty:Bool) {
        tableView.separatorStyle = isEmpty ? .none : .singleLine
        tableView.backgroundView?.isHidden = !isEmpty
    }
    
    func setupEmptyBG(withMessage msg:String? = nil) {
        let emptyView = Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)?.first as? EmptyView
        guard emptyView != nil else{return}
        
        tableView.backgroundView = emptyView
        if msg != nil{
            emptyView!.messageLbl.text = msg
        }
    }
}
