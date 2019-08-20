//
//  LocaleExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 31/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension Locale {
    static var preferredLocale: Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}
