//
//  DateTextField.swift
//  FormProject
//
//  Created by hackeru on 29/05/2019.
//  Copyright © 2019 hackeru. All rights reserved.
//

import UIKit

class DateTimeTextField: ToolbarTextField {
    
    private lazy var datePicker = {
        return inputView as! UIDatePicker
    }()
    
    var date : Date?{
        didSet{
            if let d = date{
                let formatter = DateFormatter()
                formatter.dateFormat = .init(format: "EEEE, MMM d, HH:mm", locale: .current, arguments: [])
                text = formatter.string(from: d)
                
                datePicker.date = d
            }
        }
    }
    
    override func setup(){
        super.setup()
        
        addTarget(self, action: #selector(tfTouched), for: .touchUpInside)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = .preferredLocale
        
        let now = Date()
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 12/2, to: now)
        datePicker.minimumDate = now//today
        
        datePicker.tintColor = .white
        datePicker.backgroundColor = .init(patternImage: #imageLiteral(resourceName: "texture"))
        self.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(datePickerAction(_:)), for: .valueChanged)
    }
    
    @objc func datePickerAction(_ sender : UIDatePicker){
        date = sender.date
    }
    
    @objc func tfTouched() {
        if date == nil{
            date = datePicker.minimumDate
        }
    }
    
    override func buttonAction() {
        
        date = datePicker.date
        
        super.buttonAction()
    }
}
