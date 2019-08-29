//
//  NewClassEventViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 29/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import iOSDropDown
import LocationPickerViewController

class NewClassEventViewController: UITableViewController,TextFieldReturn {

    @IBOutlet weak var typeSegment: DataTypeSegmentView!
    
    @IBOutlet weak var tfTitle: UITextField!
    
    @IBOutlet weak var eventImgView: UIImageView!
    
    
    lazy var imagePicker: MyImagePicker = {
        return createImagePicker()
    }()
    
    var hasImage = false
    
    @IBOutlet weak var tfCost: CurrencyField!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    lazy var locationPicker = setLocationPicker()
    var selectedCoordinate:CLLocationCoordinate2D?
    var selectedPlaceName:String?
    
    
    @IBOutlet weak var tfstartDate: DateTimeTextField!
    
    @IBOutlet weak var tfEndDate: DateTimeTextField!
    
    @IBOutlet weak var tfLevel: LevelTextField!
    
    @IBOutlet weak var maxPplDropDown: MaxAmountField!
    
    @IBOutlet weak var maxPplStepper: UIStepper!
    var maxPplCount:Int?,noMaxPpl = false
    
    @IBOutlet weak var tvEquipment: BetterTextView!
    
    @IBOutlet weak var tvExtraNotes: BetterTextView!
    
    var focusedField:UIView?
    
    
    
    var model:DynamicUserCreateable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .init(patternImage: #imageLiteral(resourceName: "sea"))
        
//        tfTitle.placeholder = "Yoga kind"
        
        navigationItem.hidesSearchBarWhenScrolling = true
        
        eventImgView.round()
//        eventImgView.frame = .init(origin: eventImgView.frame.origin,
//                                   size: .init(width: eventImgView.frame.width,
//                                               height: UIScreen.main.bounds.height * 0.1))
        
        maxPplStepper.layer.cornerRadius = 5
        maxPplStepper.clipsToBounds = true

        initDropDown()
        
        tvEquipment.delegate2 = self
        tvExtraNotes.delegate2 = self
        
        initTextFields(tfTitle,maxPplDropDown,tfstartDate,tfEndDate,tfCost,tfLevel)
        
//        subscribeToKeyboard()
        
        if !(YUser.currentUser is Teacher || YUser.currentUser?.type == .teacher) {
            typeSegment.type = .events
            typeSegment.selectedSegmentIndex = 1
            changeToEventView()
//            typeSegment.isUserInteractionEnabled = false
            typeSegment.setEnabled(false, forSegmentAt: 0)
        }
        
        guard let model = model
            else {return}
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let aClass = model as? Class{
            fill(classModel: aClass)
        }else if let event = model as? Event{
            fill(event:event)
        }
    }
    
    func initDropDown() {
        
        maxPplDropDown.didSelect { (selectedTxt, index, id) in
             self.noMaxPpl = index == 1
             self.maxPplCount = index == 0 ? 0 : nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return nextTxtField(textField)
    }
    
    fileprivate func changeToClassView() {
//        tfTitle.placeholder = "Yoga kind"
//        tfstartDate.placeholder = "Start time"
//        tfEndDate.placeholder = "End time"
//        eventImgView.isHidden = true
         navigationItem.title = "new-\(typeSegment.type)".translated
    }
    
    
    
    fileprivate func changeToEventView() {
//        tfTitle.placeholder = "Event name"
//        tfstartDate.placeholder = "Start date"
//        tfEndDate.placeholder = "End date"
//        eventImgView.isHidden = false
         navigationItem.title = "new-\(typeSegment.type)".translated
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        switch typeSegment.type {
        case .classes:
            changeToClassView()
        case .events:
            changeToEventView()
        }
        
//        tableView.reloadSections([8], with: .automatic)
        tableView.reloadRows(at: [.init(row: 0, section: 8)], with: .automatic)
        tableView.reloadData()
    }
    
    func validateAndCreateData() -> UserConnectionDelegate? {
        
        guard let user = YUser.currentUser else{return nil}
        
        if typeSegment.type == .classes{
            guard let teacher = user as? Teacher
                else{
                    ErrorAlert.show(message: "Only teachers can create clasess!".translated)
                    return nil
            }
        }
        
        let typeTxt = typeSegment.type.singular

        guard let title = tfTitle.text,!title.isEmpty
            else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                tfTitle.setError(message: "fill".translated + tfTitle.placeholder!)
                return nil
        }
        
        let cost = tfCost.doubleValue
        
        guard let locationCoordinate = self.selectedCoordinate,
            let locName = self.selectedPlaceName
        else {
            let selectMsg = "select".translated + "location".translated
            ErrorAlert.show(message: selectMsg)
            tableView.selectRow(at: IndexPath(row: 0, section: 2), animated: true, scrollPosition: .top)
            return nil
        }
        
        let dateTxt = typeSegment.type == .classes ? "T" : "D"
        
        guard let startDate = tfstartDate.date else{
            let msg = "fill".translated + "start\(dateTxt)".translated
            self.tfstartDate.setError(message: msg)
            return nil
        }
        guard let endDate = tfEndDate.date else{
            let msg = "fill".translated + "end\(dateTxt)".translated
            self.tfEndDate.setError(message: msg)
            return nil
        }
        
        guard startDate < endDate else {
            ErrorAlert.show(title: "Dates problem".translated,
                            message: "startD>endD".translated)
            return nil
        }
        
        let date = (startDate,endDate)

        guard let level = tfLevel.level else {
            self.tfLevel.setError(message: "fill".translated + "level of".translated)
            return nil
        }

        
        let maxPplMessage = "fill".translated +  "maxPpl".translated
        guard let maxPplSelectedIndex = maxPplDropDown.selectedIndex
            else{
                self.maxPplDropDown.setError(message: maxPplMessage)
                return nil
                }
        
        guard (maxPplSelectedIndex == 0 &&  maxPplCount != nil && maxPplCount! > 0)
            || maxPplSelectedIndex != 0
            else{
                self.maxPplDropDown.setError(message: maxPplMessage)
                return nil
            }
        
        let maxPpl = maxPplCount ?? -1
       
        
        guard !tvEquipment.isEmpty,let equip = tvEquipment.text
                 else {
            self.tvEquipment.setError(message: "fill".translated + "equipment".translated)
            return nil
        }
        
        let xtra = !tvExtraNotes.isEmpty ? tvExtraNotes.text : ""
        
        
        switch typeSegment.type {
        case .classes:
            
            return Class( type: title, cost: cost, location: locationCoordinate, locationName: locName, date: date, level: level, equipment: equip, xtraNotes: xtra, maxParticipants: maxPpl, teacher: user as! Teacher)
        case .events:
            
            return Event(title: title, cost: cost, locationName: locName, location: locationCoordinate, date: date, level: level, equipment: equip, xtraNotes: xtra, maxParticipants: maxPpl, user: user)
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        let dType = DataType.allCases[ typeSegment.selectedSegmentIndex]
        
        let ds = DataSource.shared
        
        
        let saveTaskListener:DSTaskListener = { err in
            SVProgressHUD.dismiss()
            if let error = err{
                ErrorAlert.show(message: error.localizedDescription)
                return
            }
        }
        
        switch dType {
            
        case .classes:
            guard let c = validateAndCreateData() as? Class else{return}
        
            ds.addToAll(.classes, dataObj: c, taskDone: saveTaskListener)
            
        case .events:
            guard let e = validateAndCreateData() as? Event else{return}
            
            if hasImage{
                ds.addToAll(.events, dataObj: e) { err in
//                    done saving event to DB
                    saveTaskListener(err)
                    guard err == nil,let img = self.eventImgView.image
                        else{return}
//                    call image save for finished image
                    StorageManager.shared.save(image: img, for: e)
                }
            }
            else{
                ds.addToAll(.events, dataObj: e, taskDone: saveTaskListener)
            }
        }
        
        SVProgressHUD.show()
        self.dismiss(animated: true)
        //            self.navigationController?.popViewController(animated: true)
        //only show after synchronic code finished
        //and dismissed when done saving
    }
    
    @IBAction func discard(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
//        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tfDidBeginEditing(_ sender: UITextField) {
        focusedField = sender
    }
    
    @IBAction func tfDidEndEditing(_ sender: UITextField) {
        focusedField = nil
    }
    
    
    @IBAction func stepperValueChange(_ sender: UIStepper) {
        if  maxPplDropDown.selectedIndex == nil || maxPplDropDown.selectedIndex != 0{
            maxPplDropDown.selectedIndex = 0
            sender.value = 0
        }
        
        maxPplCount = Int(sender.value)
        maxPplDropDown.text = "\(maxPplCount!)"
        
        if sender.value == sender.maximumValue{
            maxPplDropDown.showList()
            maxPplDropDown.selectedIndex = 1
        }
    }
    
    
    @IBAction func maxPplEndEdit(_ sender: UITextField) {
        guard let text = sender.text,
            !text.isEmpty,//not empty
            var value = Int(text),value > 0//and no negative
            else {return}
        
        let stepperMax = Int(maxPplStepper.maximumValue)
        let stepperMin = Int(maxPplStepper.minimumValue)
        value = value.clamp(lower: stepperMin,stepperMax)
        
        sender.text = "\(value)"
        
        maxPplCount = value
        maxPplDropDown.selectedIndex = 0
        maxPplStepper.value = Double(value)
    }
    
    
    @IBAction func imageTap(_ sender: UITapGestureRecognizer) {
        imagePicker.show(hasImage: hasImage,size: .regular)
    }
    
    
    fileprivate func createImagePicker() -> MyImagePicker {
        let picker =
            MyImagePicker(allowsEditing: false){ image,url,removeChosen in
                
                self.hasImage = image != nil || url != nil
                if removeChosen || !self.hasImage{
                    self.eventImgView.image = #imageLiteral(resourceName: "image")
                    self.eventImgView.contentMode = .scaleAspectFit
                }else {
                    if let img = image{
                        DispatchQueue.main.async {
                            self.eventImgView.image = img
                        }
                    }else if let url = url{
                        DispatchQueue.main.async {
                            self.eventImgView.sd_setImage(with: url, completed: nil)
                        }
                    }
                    self.eventImgView.contentMode = .scaleAspectFill
                }
            }
        
        return picker
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 8://image section
            if typeSegment.type == .classes{
                return 0
            }
            fallthrough
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch indexPath.section {
        case 8://image section
            if typeSegment.type == .classes{
                return 0
            }
            fallthrough
        default:
            return UITableView.automaticDimension
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "locationCell"{
            
            let navC = UINavigationController(rootViewController: self.locationPicker)
            
            present(navC,animated: true)
        }
    }

    //MARK: fill data for edit
    
    func fill(classModel:Class) {
        
        navigationItem.title = DataType.classes.singular
        
        tfTitle.text = classModel.title
        
        lblLocation.text = classModel.locationName
        
        tfstartDate.date = classModel.startDate
        tfEndDate.date = classModel.endDate
        
        tfLevel.level = classModel.level
        
        tfCost.money = classModel.cost
        
        if classModel.maxParticipants != -1{
            maxPplDropDown.text = "\(classModel.maxParticipants)"
        }else{
            maxPplDropDown.selectedIndex = 1
        }
        
        tvEquipment.text = classModel.equipment
        tvExtraNotes.text = classModel.xtraNotes
    }
    
    func fill(event :Event) {
        
        StorageManager.shared.setImage(of: event, imgView: eventImgView)
        
        navigationItem.title = DataType.classes.singular
        
        tfTitle.text = event.title
        
        lblLocation.text = event.locationName
        
        tfstartDate.date = event.startDate
        tfEndDate.date = event.endDate
        
        tfLevel.level = event.level
        
        tfCost.money = event.cost
        
        if event.maxParticipants != -1{
            maxPplDropDown.text = "\(event.maxParticipants)"
        }else{
            maxPplDropDown.selectedIndex = 1
        }
        
        tvEquipment.text = event.equipment
        tvExtraNotes.text = event.xtraNotes
    }
    

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        view.endEditing(true)
    }
}
