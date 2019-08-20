//
//  TypeTextField.swift
//  YogaLessons
//
//  Created by Eran karaso on 08/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//
import iOSDropDown

class TypeTextField: DropDown{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cTor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cTor()
    }
    
    private let types = UserType.allCases.map{ "\($0)".capitalized}
    
    var didSelectHandler:((UserType)->Void)?
    
    var type:UserType?
    
    func cTor() {
        self.blurBG()
        
        optionArray = types
        
        didSelect { (_, i, _) in
            self.type = UserType.allCases[i]
            self.didSelectHandler?(UserType.allCases[i])
        }
        
        listWillDisappear {
            if let i = self.selectedIndex{
                self.text = self.types[i].capitalized
            }
        }
        
        selectedRowColor = #colorLiteral(red: 0.7782526016, green: 0.93667835, blue: 1, alpha: 1)
        
        inputView = .init()
        
        addTarget(self, action: #selector(openList), for: .touchDown)
    }
    
    func set(type :UserType){
        self.type = type
        text = "\(type)".capitalized
        selectedIndex = type.rawValue
    }
    
    @objc func openList() {
        showList()
    }
}
