//
//  CollectionExtension.swift
//  YogaLessons
//
//  Created by Eran karaso on 23/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
