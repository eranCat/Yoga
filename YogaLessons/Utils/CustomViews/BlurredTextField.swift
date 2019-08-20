//
//  BluredTextField.swift
//  YogaLessons
//
//  Created by Eran karaso on 23/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class BlurredTextField: UITextField {
    
    var isBlurred:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        blurBG()
    }
    
    override func blurBG() {
        if !isBlurred{
            super.blurBG()
        }
    }
}

extension UITextField{
    @objc func blurBG() {
        
        backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .light)
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.layer.cornerRadius = 6
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: heightAnchor),
            blurView.widthAnchor.constraint(equalTo: widthAnchor),
            ])
    }
}

extension UITextView{
    func blurBG( cornerRadius: CGFloat = 0 ) {
        backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .light)
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.layer.cornerRadius = cornerRadius > 0 ? cornerRadius : 6
        blurView.clipsToBounds = true
        
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: heightAnchor),
            blurView.widthAnchor.constraint(equalTo: widthAnchor),
            ])
    }
}
