//
//  ClassTableViewCell.swift
//  YogaLessons
//
//  Created by Eran karaso on 14/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
//import SDWebImage

class ClassCell: UITableViewCell {

    @IBOutlet weak var teacherName: UILabel!
    
    @IBOutlet weak var teacherImg: UIImageView!
    
    @IBOutlet weak var classType: UILabel!
    
    @IBOutlet weak var place: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var level: UILabel!
    
    @IBOutlet weak var cancledImageView: UIImageView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        place.adjustsFontSizeToFitWidth = true
        time.adjustsFontSizeToFitWidth = true
        level.adjustsFontSizeToFitWidth = true
    
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension ClassCell:PopulateDelegate{
    func populate(with:UserConnectionDelegate) {
        
        guard let aClass = with as? Class else {return}
        
        if let teacher = DataSource.shared.getTeacher(by: aClass.uid){
            teacherName.text = teacher.name
            
            StorageManager.shared
                .setImage(withUrl: teacher.profileImageUrl, imgView: teacherImg,placeHolderImg: #imageLiteral(resourceName: "guru"))
        }else{
            print("Couldn't find teacher")
        }
        
        classType.text = aClass.title
        level.text = "\(aClass.level)"
        
        place.text = aClass.locationName
        
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.locale = .preferredLocale
        
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let from = formatter.string(from: aClass.startDate)
        let until = formatter.string(from: aClass.endDate)
        
        
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        let day = formatter.string(from: aClass.startDate)
        
        time.text = "\(from) - \(until), \(day)"
        
        
        cancledImageView.isHidden = aClass.status != .cancled//hidden if not cancled
    }
    
}
