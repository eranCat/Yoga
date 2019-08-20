//
//  Money.swift
//  YogaLessons
//
//  Created by Eran karaso on 23/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

class Money:DBCodable,CustomStringConvertible{
    
    var amount:Double//locale
    let converter = MoneyConverter.shared
    
    init(amount: Double) {
        self.amount = amount
    }
    
    func encode() -> JSON {
        return [Keys.amount:converter.convertFromLocaleToDefault(amount: amount)]
    }
    
    required init(_ dict: JSON) {
        let amount = dict[Keys.amount] as! Double
        self.amount = converter.convertFromDefaultToLocale(amount: amount)
    }
    
    var description: String{
        let x = NSNumber(value: amount)
        return Formatter.currency.string(from: x) ?? String(amount)
    }
    
    private struct Keys{
        static let amount = "amount"
    }
}

extension Money:Equatable,Comparable{
    static func < (lhs: Money, rhs: Money) -> Bool {
        return lhs.amount < rhs.amount
    }
    
    static func == (lhs: Money, rhs: Money) -> Bool {
        return lhs.amount == rhs.amount
    }
    
    static func == (lhs:Money,rhs:Double)->Bool{
        return lhs.amount == rhs
    }
}
