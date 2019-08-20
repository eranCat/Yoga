//
//  BarButtonItem.swift
//  YogaLessons
//
//  Created by Eran karaso on 24/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class BlockBarButtonItem: UIBarButtonItem {
    typealias emptyClosure = () -> Void
    private var actionHandler: emptyClosure?

    convenience init(title: String?, style: UIBarButtonItem.Style, actionHandler: emptyClosure?) {
        self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.actionHandler = actionHandler
    }

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, actionHandler: emptyClosure?) {
        self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.actionHandler = actionHandler
    }

    convenience init(barButtonItemSystem item: UIBarButtonItem.SystemItem,action:emptyClosure?) {
        self.init(barButtonSystemItem: item, target: nil,
                   action: #selector(barButtonItemPressed))
        actionHandler = action
        self.target = self
    }

    @objc func barButtonItemPressed(_ sender: UIBarButtonItem) {
        actionHandler?()
    }
}
