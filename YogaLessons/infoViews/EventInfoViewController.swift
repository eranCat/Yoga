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
    
    @IBOutlet weak var costCell: UITableViewCell!//v
    
    @IBOutlet weak var costLbl: UILabel!//v
    
    @IBOutlet weak var locationLbl: UILabel!
    
    
    @IBOutlet weak var dateStack: UIStackView!
    
    @IBOutlet weak var dateLbl: UILabel!//v
   
    @IBOutlet weak var amountOfPplGoing: UILabel!//√x
    
    @IBOutlet weak var pplAreGoingLbl: UILabel!
    var pplAreGoingDefaultText:String?
    
    @IBOutlet weak var maxPplAmount: UILabel!//v
    
    
    @IBOutlet weak var opProfileImgView: CircledView!
    @IBOutlet weak var opNameLbl: UILabel!
    
    
    @IBOutlet weak var levelLbl: UILabel!
    
    @IBOutlet weak var equipmentTv: UITextView!
    
    @IBOutlet weak var lblAges: UILabel!
    
    @IBOutlet weak var extraNotesTv: UITextView!
    var hasXtraNotes = false
    var hasAges = false
    
    var eventModel :Event!
    var postingUser:YUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard eventModel != nil else{
            navigationController?.popViewController(animated: true)
            return
        }
        
        equipmentTv.roundCorners()
        extraNotesTv.roundCorners()
        eventImgView.roundCorners()
        opNameLbl.roundCorners()
        
        if let stack = view.subviews.first as? UIStackView{
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }        

        let user = YUser.currentUser!
        //the user didnt sign up for the class
        setMenuItems()
        setSignBtn(isSigned: user.signedEventsIDS[eventModel.id!] != nil)
        fillViews()
        
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged(_:)), name: ._dataChanged, object: nil)
    }
    
    @objc func dataChanged(_ notif:NSNotification){
        guard let type = notif.userInfo?["type"] as? DataType,type == .events,
            let id = notif.userInfo?["id"] as? String,id == eventModel.id
            else{return}
        
        fillViews()
        tableView.reloadData()
    }
    
    private func setMenuItems() {
        
        let signBtn = UIBarButtonItem(title: nil, style: .plain, target: self, action: nil)
        let shareBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .plain, target: self,
                                       action: #selector(openShareMenu))
        
        navigationItem.rightBarButtonItems = [signBtn,shareBtn]
    }
    @objc func openShareMenu() {
        SharingManager.share(data:self.eventModel)
    }
    
    func setSignBtn(isSigned:Bool) {
        
        guard let signBtn = navigationItem.rightBarButtonItems?[0]
            else{return}
        
        if !isSigned{
            if eventModel.status == .open{
                
                signBtn.title = "I'm in".translated
                signBtn.action = #selector(signinToEvent)
                signBtn.isEnabled = true
            }else{
                signBtn.isEnabled = false
            }
        }
        else{
            signBtn.title = "I'm out".translated
            signBtn.action = #selector(signOutOfEvent)
            signBtn.isEnabled = true
        }
    }
    

    private func fillViews() {
        
        if eventModel.imageUrl != nil{
            StorageManager.shared
            .setImage(of: eventModel, imgView: eventImgView)
        }else{
            eventImgView.isHidden = true
        }
        
        if eventModel.cost.amount > 0{
            costLbl.text = eventModel.cost.description
        }else{
            costLbl.text = "free".translated
        }
        
        navigationItem.title = eventModel.title
        
        locationLbl.text = eventModel.locationName
        
        
        //MARK: Dates
        let (start,end) = getFormatted(d1: eventModel.startDate, d2: eventModel.endDate)
        let isOnlyDateEqual = eventModel.startDate.equalTo(date: eventModel.endDate)
        
        if !isOnlyDateEqual{
            dateLbl.text = start + " - " + end
        }else{
            dateLbl.text = start
        }
        
        //        MARK: participants
        
        if eventModel.numOfParticipants > 0{
            [amountOfPplGoing,pplAreGoingLbl,maxPplAmount].forEach{$0.isHidden = false}
            pplAreGoingLbl.text = pplAreGoingDefaultText ?? pplAreGoingLbl.text
            amountOfPplGoing.text = eventModel.numOfParticipants.formattedAmount
        }else{
            //maybe hide or say no one's coming
            pplAreGoingDefaultText = pplAreGoingLbl.text
            pplAreGoingLbl.text = "be the first one to sign in 🥳".translated
            [amountOfPplGoing,maxPplAmount].forEach{$0.isHidden = true}
        }
        
        if eventModel.maxParticipants != -1{
            maxPplAmount.text = "out of ".translated + "\(eventModel.maxParticipants)"
//            maxPplAmount.isHidden = false
        }else{
            maxPplAmount.isHidden = true
        }
        
        //get teacher obj from event
        postingUser = DataSource.shared.getUser(by: eventModel.uid)
        //set name of teacher
        opNameLbl.text = postingUser?.name
        //set image on opProfileImgView
        if let profileUrl = postingUser?.profileImageUrl{
        StorageManager.shared
            .setImage(withUrl: profileUrl, imgView: opProfileImgView)
        }
        
        
        //level
        levelLbl.text = eventModel.level.translated
        
        //equipment
        equipmentTv.text = eventModel.equipment
        
        //xtra, hide stack if there's non
        if let xtra = eventModel.xtraNotes,!xtra.isEmpty{
            extraNotesTv.text = xtra
            hasXtraNotes = true
        }else{
            hasXtraNotes = false
        }
        
        if let ageStack = lblAges.superview as? UIStackView{
            if let ageTxtLbl = ageStack.arrangedSubviews[safe: 0] as? UILabel{
                ageTxtLbl.text = "ages".translated
            }
        }
        
        let minAge = eventModel.minAge
        let maxAge = eventModel.maxAge
        self.hasAges = minAge < .max && maxAge > -1
        if hasAges{
            if minAge == maxAge{
                lblAges.text = "\(minAge)"
            }else{
                lblAges.text = "\(minAge) - \(maxAge)"
            }
        }
        else{
            lblAges.text = ""
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
       
        SVProgressHUD.show()
        DataSource.shared.signTo(.events, dataObj: eventModel){ (err) in
            
            SVProgressHUD.dismiss()
            if let error = err{
                
                if let signErr = error as? SigningErrors{
                    
                    let title:String?
                    
                    switch signErr{
                        
                    case .noPlaceLeft:
                        title = "too late".translated
                    case .alreadySignedToClass, .alreadySignedToEvent:
                        title = "signTwice".translated
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
        
        UnsignAlert.show(dType: .events) { _ in
            
            SVProgressHUD.show()
            DataSource.shared
                .unsignFrom(.events, data: self.eventModel) { (err) in
                    
                    SVProgressHUD.dismiss()
                    if let error = err{
                        ErrorAlert.show(message: error.localizedDescription)
                        return
                    }
                    self.setSignBtn(isSigned: false)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let autoSize = UITableView.automaticDimension
        
        switch (indexPath.section,indexPath.row) {
        case (8,_):
            return !hasXtraNotes ? 0.0 : autoSize
            
        case (4,1)://participants section -> ages row
            return hasAges ? autoSize : 0
        case (0,0):
            return eventImgView.isHidden ? 0.0 : autoSize
        default:
            return autoSize
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let autoSize = UITableView.automaticDimension
        
        switch section {
        case 8:
            return !hasXtraNotes ? 0.0 : autoSize
            
        default:
            return autoSize
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
