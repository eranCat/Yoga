//
//  DateTextField.swift
//  FormProject
//
//  Created by hackeru on 29/05/2019.
//  Copyright © 2019 hackeru. All rights reserved.
//

import UIKit

class DateTextField: ToolbarTextField {
    
    private lazy var datePicker : UIDatePicker = {
        return inputView as! UIDatePicker
    }()

    var date : Date?{
        didSet{
            if let d = date{
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.locale = .preferredLocale
                
                text = formatter.string(from: d)
                
                formatter.doesRelativeDateFormatting = true
                
                datePicker.date = d
            }
        }
    }
    
    let age = (max : 80 , min : 14)
    
    override func setup(){
        super.setup()
        
        addTarget(self, action: #selector(tfTouched), for: .touchUpInside)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = .preferredLocale
        
        
        datePicker.maximumDate = Date().substruct(unit: .year, amount: age.min)
        datePicker.minimumDate = Date().substruct(unit: .year, amount: age.max)
        
        datePicker.tintColor = .white
        datePicker.backgroundColor = .init(patternImage: #imageLiteral(resourceName: "texture"))
        self.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(datePickerAction(_:)), for: .valueChanged)
    }
    
    @objc func datePickerAction(_ sender : UIDatePicker){
        date = sender.date
    }
    
    @objc
    func tfTouched() {
        if date == nil{
            date = datePicker.minimumDate
        }
    }
    
    override func buttonAction() {
        
        date = datePicker.date
        
        super.buttonAction()
    }
}
