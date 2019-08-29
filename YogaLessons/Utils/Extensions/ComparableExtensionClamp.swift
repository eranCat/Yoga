//
//  File.swift
//  YogaLessons
//
//  Created by Eran karaso on 28/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

extension Comparable
{
    func clamp<T: Comparable>(lower: T, _ upper: T) -> T {
        return min(max(self as! T, lower), upper)
    }
}
