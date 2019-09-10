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
enum LocationErrors:Error {
    case locationAmbiguous
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
enum DataTypeError:Error{
    case incompatibleType
}

enum StorageErrors:Error{
    case problemWithUrl
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
            return "alreadySigned".translated + DataType.classes.singular
            
        case .alreadySignedToEvent:
            return "alreadySigned".translated + DataType.events.singular
            
        case .noPlaceLeft:
            return "No place left".translated
                                     
            
        case .canNotSignOut:
            return "Can't sign out".translated
                                     
        
        case .cantSignToCancled(let dType):
            return "signToCancled".translated + dType.singular
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
            return "castFailed".translated
        }
    }
}

extension DataTypeError:LocalizedError,Translateable{
    var errorDescription: String?{
        switch self {
        case .incompatibleType:
            return "incompatibleType".translated
        }
    }
}

extension LocationErrors:LocalizedError,Translateable{
    var errorDescription: String?{
        switch self {
        case .locationAmbiguous:
            return "locationAmbiguous".translated
        }
    }
}
