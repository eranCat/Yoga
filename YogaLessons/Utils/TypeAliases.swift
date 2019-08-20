//
//  TypeAliases.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import CoreLocation

typealias TableControllerDDS = UITableViewDelegate & UITableViewDataSource

typealias JSON = Dictionary<String,Any>

typealias PageViewDDS = UIPageViewControllerDelegate & UIPageViewControllerDataSource

typealias PickerDDS = UIPickerViewDelegate & UIPickerViewDataSource


//image picking
typealias ImgPickerD = UIImagePickerControllerDelegate
typealias NavConrollerD = UINavigationControllerDelegate


typealias DSListener = ()->Void
typealias DSTaskListener = (Error?)->Void
typealias DynamicUserCreateable = DBCodable & Unique & UserConnectionDelegate
