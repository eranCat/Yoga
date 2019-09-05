//
//  DateExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 25/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension Date {
    func substruct(unit: Calendar.Component,amount: Int) -> Date? {
        let result =  Calendar.current.date(byAdding: unit, value: -(amount), to: self)
        return result
    }
    
    //compare timeless date
    func equalTo(date:Date) -> Bool {
        let cal = Calendar.current
        
        let comps1 = cal.dateComponents([.day,.month,.year], from: self)
        let comps2 = cal.dateComponents([.day,.month,.year], from: date)

        
        return
            comps1.day == comps2.day &&
            comps1.month == comps2.month &&
            comps1.year == comps2.year
    }
    
    var age:Int{
        let now = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: self, to: now)
        let age = ageComponents.year!
        
        return age
    }
    
    var dateComps:DateComponents{
        return Calendar.current.dateComponents([.year,.month,.day], from: self)
    }
}
