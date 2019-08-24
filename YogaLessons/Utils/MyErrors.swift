//
//  MyErrors.swift
//  YogaLessons
//
//  Created by Eran karaso on 26/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

enum LevelErrors:Error {
    case typeNotSupported
}

enum UserTypeErrors:Error {
    case typeNotSupported
}

enum MoneyErrors:Error {
    case typeNotSupported
}
enum LocationCoordinateErrors:Error {
    case typeNotSupported
}

enum UserErrors:Error {
    case noUserFound
}
extension Date{
    enum Errors:Error {
        case typeNotSupported
    }
}

enum JsonErrors:Error {
    case castFailed
}
enum SigningErrors:Error {
    case canNotSignOut
    case noPlaceLeft
    case alreadySignedToClass
    case alreadySignedToEvent
    
    case cantSignToCancled(DataType)
}

extension SigningErrors:LocalizedError,Translateable{
    var errorDescription: String?{
        switch self {
        case .alreadySignedToClass:
            return NSLocalizedString( "alreadySigned".translated + DataType.classes.singular, comment: "My error alreadySignedToClass")
            
        case .alreadySignedToEvent:
            return NSLocalizedString( "alreadySigned".translated + DataType.events.singular, comment: "My error alreadySignedToEvent")
            
        case .noPlaceLeft:
            return NSLocalizedString("No place left".translated,
                                     comment: "My error noPlaceLeft")
            
        case .canNotSignOut:
            return NSLocalizedString("Can't sign out".translated,
                                     comment: "My error canNotSignOut")
        
        case .cantSignToCancled(let dType):
            return NSLocalizedString("signToCancled".translated + dType.singular,
                                     comment: "My error cantDeletePeopleAreAlreadySigned")
        }
        
    }
}


extension UserErrors:LocalizedError,Translateable{
    var errorDescription: String?{
        switch self {
        case .noUserFound:
            return "noUserFound".translated
        }
    }
}


extension JsonErrors:LocalizedError,Translateable{
    var errorDescription: String?{
        switch self {
        case .castFailed:
            return NSLocalizedString("castFailed".translated, comment: "Json casting error")
        }
    }
}
