//
//  LevelTextField.swift
//  YogaLessons
//
//  Created by Eran karaso on 08/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import iOSDropDown

class LevelTextField: DropDown {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cTor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cTor()
    }
    
    internal let levels = Level.allCases.map{ "\($0)".capitalized}
    
    
    var didSelectHandler:((Level)->Void)?
    
    var level:Level?
    
    func cTor() {
                
        optionArray = levels
        
        optionIds = Level.allCases.map{ $0.rawValue} //[0..<Level.allcases.count]
        
        self.blurBG()
        
        didSelect { (_, i, _) in
            self.level = Level.allCases[i]
            self.didSelectHandler?(Level.allCases[i])
        }
        
        listWillDisappear {
            if let i = self.selectedIndex{
                self.text = self.optionArray[i]
            }
        }
        
        selectedRowColor = #colorLiteral(red: 0.7782526016, green: 0.93667835, blue: 1, alpha: 1)
        
        inputView = .init()
        
//        addTarget(self, action: #selector(openList), for: .touchDown)
    }
    
    func set(level:Level){
        self.level = level
        text = "\(level)".capitalized
        selectedIndex = level.rawValue
    }
    
    
    @objc func openList() {
        showList()
    }
}


class UserLevelField: LevelTextField {
    
    private let offset = 1
    
    override func cTor() {
        super.cTor()
        optionArray = [String](levels[offset...])
        
        didSelect { (_, i, _) in
            self.level = Level.allCases[i + self.offset]
            self.didSelectHandler?(Level.allCases[i + self.offset])
        }
        
        listWillDisappear {
            guard let i = self.selectedIndex else{return}
            
            self.text = self.optionArray[i]
        }
    }
}
