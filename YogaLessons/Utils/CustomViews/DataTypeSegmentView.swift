//
//  TypeSegmentView.swift
//  YogaLessons
//
//  Created by Eran karaso on 09/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class DataTypeSegmentView: UISegmentedControl {

    var type:DataType = .classes
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        removeAllSegments()
        
        let font = UIFont(name: "Kailasa", size: 20) ?? UIFont.systemFont(ofSize: 20)
        setTitleTextAttributes([NSAttributedString.Key.font: font],
                                for: .normal)
        
        tintColor = #colorLiteral(red: 0.2615792751, green: 0.2857673466, blue: 0.6650569439, alpha: 1)
        
        for (i,dt) in DataType.allCases.enumerated(){
            insertSegment(withTitle: dt.singular.capitalized, at: i, animated: false)
        }
        
        selectedSegmentIndex = 0
        type = DataType.allCases[0]
        
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc func valueChanged() {
         type =  DataType.allCases[selectedSegmentIndex]
    }
}
