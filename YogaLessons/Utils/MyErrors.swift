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

extension Date{
    enum Errors:Error {
        case typeNotSupported
    }
}

enum SigningErrors:Error {
    case canNotSignOut
    case noPlaceLeft
    case alreadySignedToClass
    case alreadySignedToEvent
    
    case cantSignToCancled(DataType)
}

extension SigningErrors:LocalizedError{
    var errorDescription: String?{
        let msg = "You're already signed to this "
        switch self {
        case .alreadySignedToClass:
            return NSLocalizedString(msg + "class", comment: "My error alreadySignedToClass")
        case .alreadySignedToEvent:
            return NSLocalizedString(msg + "event", comment: "My error alreadySignedToEvent")
        case .noPlaceLeft:
            return NSLocalizedString("No place left", comment: "My error noPlaceLeft")
        case .canNotSignOut:
            return NSLocalizedString("Can't sign out", comment: "My error canNotSignOut")
        case .cantSignToCancled(let dType):
            
            return NSLocalizedString("Can't sign in becuase the \(dType.singular) was cancled",
                                     comment: "My error cantDeletePeopleAreAlreadySigned")
        }
        
    }
}

enum UserErrors:Error {
    case noUserFound
}

extension UserErrors:LocalizedError{
    var errorDescription: String?{
        switch self {
        case .noUserFound:
            return "User not found!"
        }
    }
}


enum JsonErrors:Error {
    case castFailed
}
extension JsonErrors:LocalizedError{
    var errorDescription: String?{
        switch self {
        case .castFailed:
            return NSLocalizedString("Can't cast data", comment: "Json casting error")
        }
    }
}
