//
//  ClassInfoViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 24/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD

class ClassInfoViewController: UITableViewController {
    
    var classModel:Class!
    var teacher:Teacher!
    
    @IBOutlet weak var lblTeachersName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tvAbout: UITextView!
    
    @IBOutlet weak var lblClassTitle: UILabel!
    
    @IBOutlet weak var lblCost: UILabel!
    
    @IBOutlet weak var lblPlace: UILabel!
    
    @IBOutlet weak var lblDateTime: UILabel!
    
    @IBOutlet weak var lblCurrentPplAmount: UILabel!
    
    @IBOutlet weak var lblMaxPplCount: UILabel!
    
    @IBOutlet weak var lblAges: UILabel!
    
    @IBOutlet weak var equipment: UITextView!
    
    @IBOutlet weak var extraNotes: UITextView!
    var hasExtraNotes:Bool = false
    var hasAges:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTeachersName.roundCorners()
        tvAbout.roundCorners()
        extraNotes.roundCorners()
        equipment.roundCorners()
        
        
        if classModel == nil{
            navigationController?.popViewController(animated: true)
            return
        }
        
        teacher = DataSource.shared.getTeacher(by: classModel.uid)
        
        setMenuItems()
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
        guard let type = notif.userInfo?["type"] as? DataType,type == .classes,
            let id = notif.userInfo?["id"] as? String,id == classModel.id
            else{return}
        
        fillViews()
        tableView.reloadData()
    }
    private func setMenuItems() {
        
        let shareBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(openShareMenu))
        
        navigationItem.rightBarButtonItems = [.init(title: nil, style: .plain, target: self, action: nil),shareBtn]
    }
    
    @objc func openShareMenu() {
        ShatringManager.share(data:classModel)
    }
    
    fileprivate func setSigninBtn( isSigned:Bool) {
        
        guard let signBtn = navigationItem.rightBarButtonItems?[0]
            else{return}
        
        if !isSigned{
            if classModel.status == .open{
                
                signBtn.title = "I'm in".translated
                signBtn.action = #selector(signinToClass)
                signBtn.isEnabled = true
            }else{
                signBtn.isEnabled = false
            }
        }
        else{
            signBtn.title = "I'm out".translated
            signBtn.action = #selector(signOutClass)
            signBtn.isEnabled = true
        }
    }
    
    
    private func fillViews() {
        
        let user = YUser.currentUser!
        //the user didnt sign up for the class
        setSigninBtn(isSigned: user.signedClassesIDS[classModel.id!] != nil)
        
        lblTeachersName.text = teacher.name
        
        if let imgUrl = teacher.profileImageUrl{
            StorageManager.shared
                .setImage(withUrl: imgUrl, imgView: profileImageView)
        }
        
        if let about = teacher.about,!about.isEmpty{
            tvAbout.text = about
            tvAbout.isHidden = false
        }else{
            tvAbout.isHidden = true
            (tvAbout.superview as! UIStackView).alignment = .center
        }
        
        lblClassTitle.text = classModel.title
        navigationItem.title = classModel.title
        
        if classModel.maxParticipants > 0{
            lblMaxPplCount.text = String(classModel.maxParticipants)
        }else{
            lblMaxPplCount.text = "noMax".translated
        }
        
        lblCurrentPplAmount.text = "\(classModel.numOfParticipants)"
        
        if classModel.cost.amount > 0{
            lblCost.text = classModel.cost.description
        }else{
            //Free!
            lblCost.text = "free".translated
        }
        
        lblPlace.text = classModel.locationName
        
        
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.locale = .preferredLocale
        
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let from = formatter.string(from: classModel.startDate)
        let until = formatter.string(from: classModel.endDate)
        
        
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        let day = formatter.string(from: classModel.startDate)
        
        
        lblDateTime.text = "\(day)\t,\(from)-\(until)"
        
        
        equipment.text = classModel.equipment
        
        if let xtranotes = classModel.xtraNotes,!xtranotes.isEmpty{
            extraNotes.text = xtranotes
            hasExtraNotes = true
        }else{
            hasExtraNotes = false
        }
        
        let minAge = classModel.minAge
        let maxAge = classModel.maxAge
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "placeCell"{
            directionsTapped()
        }
    }
    
    func directionsTapped() {
        
        LocationUpdater.shared
            .openDirections(coordinate: classModel.locationCoordinate,
                            name: classModel.locationName)
    }
    
    @objc func signinToClass() {
        
        SVProgressHUD.show()
        DataSource.shared
            .signTo(.classes,dataObj: classModel) { (err) in
                SVProgressHUD.dismiss()
                if let error = err{
                    
                    if let signErr = error as? SigningErrors{
                        
                        let title:String?
                        
                        switch signErr{
                            
                        case .noPlaceLeft:
                            title = "too late".translated
                        case .alreadySignedToClass, .alreadySignedToEvent:
                            title = "signTwice".translated
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
                self.navigationController?.popViewController(animated: true)
                self.setSigninBtn(isSigned: true)
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 6)], with: .middle)
        }
    }
    
    
    @objc func signOutClass(){
        UnsignAlert.show(dType: .classes) { _ in
            
            SVProgressHUD.show()
            DataSource.shared
                .unsignFrom(.classes, data: self.classModel) { (err) in
                    
                    SVProgressHUD.dismiss()
                    if let error = err{
                        ErrorAlert.show(message: error.localizedDescription)
                        return
                    }
                    self.setSigninBtn(isSigned: false)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        let autoSize = UITableView.automaticDimension
        
        switch indexPath.section {
        case 8:
            return !hasExtraNotes ? 0.0 : autoSize
            
        case 6://ages section
            return hasAges ? autoSize : 0
            
        default:
            return autoSize
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let autoSize = UITableView.automaticDimension
        
        switch section {
        case 8:
            return !hasExtraNotes ? 0 : autoSize
            
        case 6:
            return hasAges ? autoSize : 0
        default:
            return autoSize
        }
    }
}
