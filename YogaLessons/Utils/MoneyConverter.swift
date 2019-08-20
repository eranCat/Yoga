//
//  MoneyConverter.swift
//  YogaLessons
//
//  Created by Eran karaso on 08/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

class MoneyConverter {
    static let shared = MoneyConverter()
    static let ApiKey = "ceb2a9d4119b6738d3fa4b8340d94adb"
    static let BaseApi = "http://apilayer.net/api"

    var localeCurrencyMultiplier:Double//1 dollar * x
    
    init() {
        localeCurrencyMultiplier = 1
    }
    
//    call in splash screen
    func connect(completed:@escaping (()->Void)) {
        convert(locale: Locale.current.currencyCode ?? "ILS") { (amount) in
            completed()
            self.localeCurrencyMultiplier = amount
        }
    }
    
    private func convert( locale currencyCodeDest:String,done:@escaping ((Double)->Void)) {
        
        let convertorUrl =
        "\(MoneyConverter.BaseApi)/live?access_key=\(MoneyConverter.ApiKey)&currencies=\(currencyCodeDest)&format=1"
        
        guard let url = URL(string: convertorUrl)
            else{
                done(1)
                return
        }
        
//        print(url.absoluteURL)
        URLSession.shared.dataTask(with: url){ data, response, error in
            
            if let error = error{
                print(error.localizedDescription)
                done(1)
                return
            }
            
            guard let data = data,
                let clRes = try? JSONDecoder().decode(CurrencyLayerResponse.self,from: data)
                else{
                    done(1)
                    return
            }
            
            
            guard clRes.success,
                let result = clRes.quotes["USD"+currencyCodeDest]
            else{
                done(1)
                return
            }
            
            done(result)
            
            }.resume()
    }
    
    
    func convertFromLocaleToDefault(amount:Double) -> Double {
        return amount / localeCurrencyMultiplier
    }

    func convertFromDefaultToLocale(amount:Double) -> Double {
        return amount * localeCurrencyMultiplier
    }
}


struct CurrencyLayerResponse: Codable {
    let success:Bool
    let quotes:[String:Double]
}
