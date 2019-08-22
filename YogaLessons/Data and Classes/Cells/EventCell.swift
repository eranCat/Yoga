//
//  ClassTableViewCell.swift
//  YogaLessons
//
//  Created by Eran karaso on 14/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet weak var eventName: UILabel!//filled
    
    @IBOutlet weak var place: UILabel!//filled
    
    @IBOutlet weak var time: UILabel!//filled

    @IBOutlet weak var imageDateContentView: UIView!
    
    @IBOutlet weak var eventImgView: UIImageView!
    
    @IBOutlet weak var cancledImageView: UIImageView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        eventImgView.layer.cornerRadius = 6
        eventImgView.clipsToBounds = true
        
        eventName.adjustsFontSizeToFitWidth = true
        place.adjustsFontSizeToFitWidth = true
        time.adjustsFontSizeToFitWidth = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension EventCell:PopulateDelegate{
    func populate(with:UserConnectionDelegate) {
        
        guard let event = with as? Event
            else {return}
        
        eventName.text = event.title
        place.text = event.locationName
        
        //MARK: date formatting
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        
        formatter.locale = .preferredLocale
        
        let from = formatter.string(from: event.startDate)
        let until = formatter.string(from: event.endDate)
        
        let isOnlyDateEqual = event.startDate.equalTo(date: event.endDate)
        
        if !isOnlyDateEqual{
            time.text = "\(from) - \(until)"
        }else{
            time.text = from
        }
        if event.imageUrl != nil{
        StorageManager.shared
            .setImage(of: event, imgView: eventImgView)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.eventImgView.isHidden = (event.imageUrl == nil) //true when no image,false for image
        }
        
        cancledImageView.isHidden = event.status != .cancled
        cancledImageView.layer.zPosition = 10
    }
}
