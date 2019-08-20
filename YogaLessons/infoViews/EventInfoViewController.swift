//
//  EventInfoViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 24/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD

class EventInfoViewController: UITableViewController {

    
    @IBOutlet weak var eventImgView: UIImageView!//v
    
    @IBOutlet weak var titleView: UILabel!//v
    
    @IBOutlet weak var costCell: UITableViewCell!//v
    
    @IBOutlet weak var costLbl: UILabel!//v
    
    @IBOutlet weak var locationLbl: UILabel!
    
    
    @IBOutlet weak var dateStack: UIStackView!
    
    @IBOutlet weak var dateLbl: UILabel!//v
   
    @IBOutlet weak var peopleStack: UIStackView!
    
    @IBOutlet weak var amountOfPplGoing: UILabel!//√x
    
    @IBOutlet weak var maxPplAmount: UILabel!//v
    
    
    @IBOutlet weak var opProfileImgView: CircledView!
    @IBOutlet weak var opNameLbl: UILabel!
    
    
    @IBOutlet weak var levelLbl: UILabel!
    
    @IBOutlet weak var equipmentTv: UITextView!
    
    
    @IBOutlet weak var extraNotesTv: UITextView!
    var hasXtraNotes = false
    
    
    var eventModel :Event!
    var postingUser:YUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let e = eventModel else{return}
        
        let user = YUser.currentUser!
        //the user didnt sign up for the class
        setSignBtn(isSigned: user.signedEventsIDS[eventModel.id!] != nil)
        
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        equipmentTv.roundCorners()
        extraNotesTv.roundCorners()
        eventImgView.roundCorners()

        if let stack = view.subviews.first as? UIStackView{
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        
        fillViews(with: e)
    }
    
    func setSignBtn(isSigned:Bool) {
        if !isSigned{
            navigationItem.rightBarButtonItem = .init(title: "Sign in", style: .plain, target: self, action: #selector(signinToEvent))
        }else{
            navigationItem.rightBarButtonItem = .init(title: "I'm out", style: .plain, target: self, action: #selector(signOutOfEvent))
        }
    }
    

    private func fillViews(with event:Event) {
        
        if event.imageUrl != nil{
            StorageManager.shared
            .setImage(of: event, imgView: eventImgView)
        }else{
            eventImgView.isHidden = true
        }
        
        if event.cost.amount > 0{
            costLbl.text = event.cost.description
        }else{
            costLbl.text = "It's Free"
        }
        
        titleView.text = event.title
        
        locationLbl.text = event.locationName
        
        
        //MARK: Dates
        let (start,end) = getFormatted(d1: event.startDate, d2: event.endDate)
        let isOnlyDateEqual = event.startDate.equalTo(date: event.endDate)
        
        if !isOnlyDateEqual{
            dateLbl.text = start + " - " + end
        }else{
            dateLbl.text = start
        }
        
        //        MARK: participants
        if event.numOfParticipants > 0{
            amountOfPplGoing.text = event.numOfParticipants.formattedAmount
        }else{
            //maybe hide or say no one's coming
        }
        
        if event.maxParticipants != -1{
            maxPplAmount.text = "out of \(event.maxParticipants)"
        }
        else{
            maxPplAmount.isHidden = true
        }
        
        
        //get teacher obj from event
        postingUser = DataSource.shared.getUser(by: event.uid)
        //set name of teacher
        opNameLbl.text = postingUser?.name
        //set image on opProfileImgView
        if let profileUrl = postingUser?.profileImageUrl{
        StorageManager.shared
            .setImage(withUrl: profileUrl, imgView: opProfileImgView)
        }
        
        
        //level
        levelLbl.text = "\(event.level)"
        
        //equipment
        equipmentTv.text = event.equipment
        
        //xtra, hide stack if there's non
        if let xtra = event.xtraNotes{
            extraNotesTv.text = xtra
            hasXtraNotes = true
        }else{
            hasXtraNotes = false
        }
    }
    
    func getFormatted(d1:Date,d2:Date) -> (String,String) {
        
        //MARK: date formatting
        let formatter = DateFormatter()
        
        formatter.dateStyle = .long
        formatter.doesRelativeDateFormatting = true
        
        formatter.locale = .preferredLocale
        
        let from = formatter.string(from: d1)
        let until = formatter.string(from: d2)
        
        return (from,until)
    }
    
    
    @objc func signinToEvent() {
        guard let event = eventModel else {
            print("Event is nil")
            return
        }
        
        SVProgressHUD.show()
        DataSource.shared.add(event: event, .signed){ (err) in
            
            SVProgressHUD.dismiss()
            if let error = err{
                
                if let signErr = error as? SigningErrors{
                    
                    let title:String?
                    
                    switch signErr{
                        
                    case .noPlaceLeft:
                        title = "Oh no, you're too late"
                    case .alreadySignedToClass, .alreadySignedToEvent:
                        title = "Sign in twice, not very nice"
//                    case .cantSignToCancled(.events):
//                        title = nil
                    default:
                        title = nil
                    }
                    ErrorAlert.show(title: title, message: error.localizedDescription)
                }
                else{
                    ErrorAlert.show(message: error.localizedDescription)
                }
                return
            }
            self.setSignBtn(isSigned: true)
        }
    }
    
    @objc func signOutOfEvent() {
        
        let onSignout:(UIAlertAction)->Void = { _ in
            
            SVProgressHUD.show()
            DataSource.shared
                .unsignFrom(.events, data: self.eventModel) { (err) in
                    
                    SVProgressHUD.dismiss()
                    if let error = err{
                        ErrorAlert.show(message: error.localizedDescription)
                        return
                    }
                    self.setSignBtn(isSigned: false)
            }
        }
        
        let alert = UIAlertController.init(title: "Sign out alert", message: "sure you want to sign out of this class?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "Yes", style: .default,handler: onSignout) )
        
        alert.addAction(.init(title: "No", style: .cancel))
        
        present(alert,animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 8:
            if !hasXtraNotes{
                return 0.0
            }
            fallthrough
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 8:
            if !hasXtraNotes{
                return 0.0
            }
            fallthrough
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section,indexPath.row ){
        case (1,0):
            LocationUpdater.shared
                .openDirections(coordinate: eventModel.locationCoordinate,
                                name: eventModel.locationName)
        default:
            break
        }
    }
}
