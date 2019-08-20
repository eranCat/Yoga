//
//  Scheduled.swift
//  YogaLessons
//
//  Created by Eran karaso on 05/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import Foundation

protocol Scheduled {
    var postedDate:Date {get set}
    var startDate:Date {get set}
    var endDate:Date {get set}
}
