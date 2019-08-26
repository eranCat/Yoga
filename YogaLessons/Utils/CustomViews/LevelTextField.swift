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
        
        selectedRowColor = #colorLiteral(red: 0.7782526016, green: 0.93667835, blue: 1, alpha: 1)
        
        inputView = .init()
        
        //        addTarget(self, action: #selector(openList), for: .touchDown)
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
    
    func cTor() {
        
        optionArray = []
        optionIds = []
        
        for level in Level.allCases[1...]{
            
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
        
        selectedRowColor = #colorLiteral(red: 0.7782526016, green: 0.93667835, blue: 1, alpha: 1)
        
        inputView = .init()
        
        //        addTarget(self, action: #selector(openList), for: .touchDown)
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

