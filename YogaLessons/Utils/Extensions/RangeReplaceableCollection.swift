//
//  File.swift
//  YogaLessons
//
//  Created by Eran karaso on 18/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection {
    @discardableResult
    mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate)
            else { return nil }
        
        return remove(at: index)
    }
}
