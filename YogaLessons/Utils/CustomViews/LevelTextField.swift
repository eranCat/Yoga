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
    
    var didSelectHandler:((Level?)->Void)?
    
    var level:Level?
    
    func cTor() {
        
        arrowColor = .white
        
        optionArray = []
        optionIds = []
        
        for level in Level.allCases{
            
            optionArray.append(level.translated.capitalized)
            optionIds?.append(level.rawValue)
        }
        
        self.blurBG()
        
        didSelect { (_, _, id) in
            self.level = Level(rawValue: id)
            self.didSelectHandler?(Level(rawValue: id))
        }
        
        listWillDisappear {
            if let i = self.selectedIndex{
                self.text = self.optionArray[i]
            }
        }
        
        selectedRowColor = UIColor._accent
        
        inputView = .init()
    }
    
    func set(level:Level){
        self.level = level
        text = level.translated.capitalized
        selectedIndex = level.rawValue
    }
    
    
    @objc func openList() {
        showList()
    }
}

class UserLevelField: DropDown {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cTor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cTor()
    }
    
    var didSelectHandler:((Level?)->Void)?
    
    var level:Level?
    private let LVL_OFFSET = 1
    
    func cTor() {
        arrowColor = .white
        
        optionArray = []
        optionIds = []
        
        for level in Level.allCases[LVL_OFFSET...]{
            
            optionArray.append(level.translated.capitalized)
            optionIds?.append(level.rawValue)
        }
        
        
        self.blurBG()
        
        didSelect { (_, _, id) in
            self.level = Level(rawValue: id)
            self.didSelectHandler?(Level(rawValue: id))
        }
        
        listWillDisappear {
            if let i = self.selectedIndex{
                self.text = self.optionArray[i]
            }
        }
        
        selectedRowColor = ._accent
        
        inputView = .init()
    }
    
    func set(level:Level){
        self.level = level
        text = level.translated.capitalized
        selectedIndex = level.rawValue - LVL_OFFSET
    }
    
    
    @objc func openList() {
        showList()
    }
}

