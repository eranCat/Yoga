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
    var currentType:DataType?
    
    @IBOutlet weak var tfTitle: UITextField!
    
    @IBOutlet weak var eventImgView: UIImageView!
    
    lazy var imagePicker = createImagePicker()
    
    var selectedImage:UIImage? = nil
    
    @IBOutlet weak var tfCost: CurrencyField!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    lazy var locationPicker = setLocationPicker()
    var selectedCoordinate:CLLocationCoordinate2D?
    var selectedPlaceName:String?
    var selectedCountryCode:String?
    
    
    @IBOutlet weak var tfstartDate: DateTimeTextField!
    
    @IBOutlet weak var tfEndDate: DateTimeTextField!
    @IBOutlet weak var repeatingWeeksLbl: UILabel!
    @IBOutlet weak var repeatingWeeksCountLbl: UILabel!
    @IBOutlet weak var repeatingWeekStepper: UIStepper!
    var repatingWeeksCount = 0
    
    @IBOutlet weak var tfLevel: LevelTextField!
    
    @IBOutlet weak var maxPplDropDown: MaxAmountField!
    
    @IBOutlet weak var maxPplStepper: UIStepper!
    var maxPplCount:Int?,noMaxPpl = false
    
    @IBOutlet weak var tvEquipment: BetterTextView!
    
    @IBOutlet weak var tvExtraNotes: BetterTextView!
    
    @IBOutlet weak var trashBarBtn: UIBarButtonItem!
    var focusedField:UIView?
    
    var model:DynamicUserCreateable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *){
            
            typeSegment.selectedTintColor = ._btnTint
            typeSegment.selectedTextColor = .white
            typeSegment.normalTextColor = .darkGray
            typeSegment.focusedTextColor = .black
            
            for stepper in [repeatingWeekStepper!,maxPplStepper!]{
                stepper.setDecrementImage(stepper.decrementImage(for: .normal), for: .normal)
                stepper.setIncrementImage(stepper.incrementImage(for: .normal), for: .normal)
            }
        }
        
        tableView.backgroundColor = .init(patternImage: #imageLiteral(resourceName: "sea"))
        
        navigationItem.hidesSearchBarWhenScrolling = true
        
        eventImgView.round()
        
        for stepper in [maxPplStepper,repeatingWeekStepper]{
            stepper?.layer.cornerRadius = 5
            stepper?.clipsToBounds = true
        }
        
        initDropDown()
        
        tvEquipment.delegate2 = self
        tvExtraNotes.delegate2 = self
        
        initTextFields(tfTitle,maxPplDropDown,tfstartDate,tfEndDate,tfCost,tfLevel)
        
        if !(YUser.currentUser is Teacher) {
            typeSegment.type = .events
            currentType = .events
            typeSegment.selectedSegmentIndex = 1
            changeToEventView()
            
            typeSegment.setEnabled(false, forSegmentAt: 0)
        }
        
        currentType = typeSegment.type
        
        if model != nil {
            
            navigationItem.titleView = nil
            
            
            let updateBtn = UIBarButtonItem(title: "Update".translated, style: .plain,
                                            target: self, action: #selector(update))
            
            updateBtn.tintColor = ._btnTint
            
            navigationItem.rightBarButtonItem = updateBtn
            
            switch model {
            case let aClass as Class:
                currentType = .classes
                typeSegment?.type = currentType!
                changeToClassView()
                fill(aClass)
            case let event as Event:
                currentType = .events
                typeSegment?.type = currentType!
                changeToEventView()
                fill(event)
            default:
                break
            }
        }
        
        self.tfstartDate.date = .init()
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
        
        tfstartDate.placeholder = "startT".translated.capitalized
        tfEndDate.placeholder = "endT".translated.capitalized
        
        navigationItem.title = "new-\(currentType!)".translated
        
//        tableView.reloadRows(at: [.init(row: 0, section: 8)], with: .automatic)
        tableView.reloadData()
    }
    
    
    
    fileprivate func changeToEventView() {
        
        tfstartDate.placeholder = "startD".translated.capitalized
        tfEndDate.placeholder = "endD".translated.capitalized
        
        navigationItem.title = "new-\(currentType!)".translated
        
        tableView.reloadRows(at: [.init(row: 0, section: 8)], with: .automatic)
        tableView.reloadData()
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        currentType = typeSegment.type
        
        switch typeSegment.type {
        case .classes:
            changeToClassView()
        case .events:
            changeToEventView()
        }
    }
    
    func validateAndCreateData() -> UserConnectionDelegate? {
        
        guard let user = YUser.currentUser else{return nil}
        
        if currentType == .classes{
            guard user is Teacher
                else{
                    ErrorAlert.show(message: "Only teachers can create clasess!".translated)
                    return nil
            }
        }
        
        
        guard let title = tfTitle.text,!title.isEmpty
            else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                tfTitle.setError(message: "fill".translated + tfTitle.placeholder!)
                return nil
        }
        
        let cost = tfCost.doubleValue
        if let model = model as? Priced,cost > model.cost.amount{
            tableView.scrollToRow(at: .init(row: 0, section: 3), at: .top, animated: true)
            tfCost.setError(message: "Price can only be lowered".translated)
            return nil
        }
        
        guard let locationCoordinate = self.selectedCoordinate,
            let locName = self.selectedPlaceName,
            let code = self.selectedCountryCode
            else {
                let selectMsg = "select".translated + "location".translated
                ErrorAlert.show(message: selectMsg)
                tableView.selectRow(at: IndexPath(row: 0, section: 2), animated: true, scrollPosition: .top)
                return nil
        }
        
        guard let startDate = tfstartDate.date else{
            let msg = "fill".translated + tfstartDate.placeholder!
            self.tfstartDate.setError(message: msg)
            return nil
        }
        guard let endDate = tfEndDate.date else{
            let msg = "fill".translated + tfEndDate.placeholder!
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
        
        
        switch currentType! {
        case .classes:
            
            return Class( type: title, cost: cost,
                          location: locationCoordinate, locationName: locName,countryCode: code,
                          date: date, level: level, equipment: equip,
                          xtraNotes: xtra, maxParticipants: maxPpl, teacher: user as! Teacher)
        case .events:
            
            return Event(title: title, cost: cost,
                         locationName: locName, location: locationCoordinate,countryCode: code,
                         date: date, level: level, equipment: equip, xtraNotes: xtra, maxParticipants: maxPpl, user: user)
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        let ds = DataSource.shared
        
        let saveTaskListener:DSTaskListener = { err in
            SVProgressHUD.dismiss()
            if let error = err{
                let description = (error as? LocalizedError)?.errorDescription ??
                    error.localizedDescription
                ErrorAlert.show(message: description)
                return
            }
        }
        
        switch validateAndCreateData() {
            
        case let aClass as Class:
            if repatingWeeksCount > 0{
                ds.addToAll(.classes, originDataObj: aClass,
                            weekCount: repatingWeeksCount + 1){ err,_ in
                                saveTaskListener(err)
                }
            }else{
                ds.addToAll(.classes, dataObj: aClass, taskDone: saveTaskListener)
            }
        case let event as Event:
            
            if repatingWeeksCount > 0{
                ds.addToAll(.events, originDataObj: event,
                            weekCount: repatingWeeksCount + 1){ err,event in
                                saveTaskListener(err)
                                if err == nil,let img = self.selectedImage{
                                    //                    call image save for finished image
                                    if let event = event as? Event{
                                        StorageManager.shared.save(image: img, for: event)
                                    }
                                }
                }
                
            }else{
                ds.addToAll(.events, dataObj: event){ err in
                    saveTaskListener(err)
                    if err == nil,let img = self.selectedImage{
                        //                    call image save for finished image
                        StorageManager.shared.save(image: img, for: event)
                    }
                }
            }
            
        default:
            return
        }
        
        SVProgressHUD.show()
        dismiss(animated: true)
        //only show after synchronic code finished
        //and dismissed when done saving
    }
    
    @objc func update() {
        
        let updatedTaskListener:DSTaskListener = { err in
            SVProgressHUD.dismiss()
            
            switch err {
            case .some(let DTErr as DataTypeError):
                ErrorAlert.show(message: DTErr.errorDescription!)
                return
            case .some(let err):
                ErrorAlert.show(message: err.localizedDescription)
                return
            default:
                break
            }
            self.dismiss(animated: true)
        }

        let ds = DataSource.shared
        
        switch validateAndCreateData() {
            
        case let aClass as Class:
            guard let localClass = model as? Class else{return}
            aClass.id = localClass.id
            
            ds.update(dType: .classes, localModel: localClass, withNew: aClass, taskDone: updatedTaskListener)
            
        case let event as Event:
            guard let localEvent = model as? Event else{return}
            event.id = localEvent.id
            
            ds.update(dType: .events, localModel: localEvent, withNew: event){ err in
                //                    done saving event to DB
                updatedTaskListener(err)
                
                let storageMngr = StorageManager.shared
                
                //                    call image save for finished image
                if let img = self.selectedImage{
                    storageMngr.save(image: img, for: self.model as! Event){ err in
                        if let error = err {
                            // Handle any errors
                            ErrorAlert.show(message: error.localizedDescription)
                            return
                        }
                        
                        NotificationCenter.default.post(name: ._dataChanged,
                                                        userInfo: ["type":DataType.events])
                    }
                }
                else{
                    //                    call image save for finished image
                    storageMngr.removeImage(forEvent: self.model as! Event)
                    NotificationCenter.default.post(name: ._dataChanged,                                   userInfo: ["type":DataType.events])
                }
            }
        default:
            return
        }
        
        SVProgressHUD.show()
    }
    
    @IBAction func discard(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
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
    
    @IBAction func repeatingWeeksStepperChanged(_ sender: UIStepper) {
        repatingWeeksCount = Int(sender.value)
        repeatingWeeksCountLbl.text = "\(repatingWeeksCount)"
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
        let hasImg = selectedImage != nil || (model as? Event)?.imageUrl != nil
        imagePicker.show(hasImage: hasImg,size: .regular)
    }
    
    
    fileprivate func loadImageFromUrl(_ url: URL) {
        
        let imageView = self.eventImgView! // just for better looking code
        
        DispatchQueue.main.async {
            imageView.sd_setImage(with: url) { (sd_img, err, _, _) in
                if let error = err{
                    ErrorAlert.show(message: error.localizedDescription)
                    return
                }
                
                if let img = sd_img{
                    self.selectedImage = img
                }
            }
        }
    }
    
    fileprivate func createImagePicker() -> MyImagePicker {
        let picker =
            MyImagePicker(allowsEditing: false){ image,url,removeChosen in
                
                let hasImage = image != nil || url != nil
                if removeChosen || !hasImage{
                    
                    self.eventImgView.image = #imageLiteral(resourceName: "image-holder")
                    self.eventImgView.contentMode = .scaleAspectFit
                    self.selectedImage = nil
                }else {
                    if let img = image{
                        self.selectedImage = img
                        DispatchQueue.main.async {
                            self.eventImgView.image = img
                        }
                    }else if let url = url{
                        self.loadImageFromUrl(url)
                    }
                }
        }
        
        return picker
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 8://image section
            if currentType == .classes{
                return 0
            }
            fallthrough
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.section,indexPath.row ){
        case (8,_)://image section
            if currentType == .classes{
                return 0
            }
        case (2,1)://week count
            if currentType == .events || model != nil{
                return 0
            }
        default:
            return UITableView.automaticDimension
        }
        
        return UITableView.automaticDimension
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
    
    func fill(_ aClass:Class) {
        
        navigationItem.title = DataType.classes.singular
        
        tfTitle.text = aClass.title
        
        lblLocation.text = aClass.locationName
        selectedPlaceName = aClass.locationName
        selectedCoordinate = aClass.locationCoordinate
        selectedCountryCode = aClass.countryCode
        
        tfstartDate.date = aClass.startDate
        tfEndDate.date = aClass.endDate
        
        tfLevel.set(level:  aClass.level)
        
        tfCost.money = aClass.cost//first time just for init
        tfCost.money = aClass.cost
        
        if aClass.maxParticipants != -1{
            maxPplDropDown.text = "\(aClass.maxParticipants)"
            maxPplDropDown.selectedIndex = 0
        }else{
            maxPplDropDown.selectedIndex = 1
        }
        
        maxPplCount = aClass.maxParticipants
        
        tvEquipment.text = aClass.equipment
        tvExtraNotes.text = aClass.xtraNotes
    }
    
    func fill(_ event :Event) {
        
        if event.imageUrl != nil{
            StorageManager.shared.setImage(of: event, imgView: eventImgView)
            eventImgView.contentMode = .scaleAspectFill
        }
        
        navigationItem.title = DataType.events.singular
        
        tfTitle.text = event.title
        
        lblLocation.text = event.locationName
        selectedPlaceName = event.locationName
        selectedCoordinate = event.locationCoordinate
        selectedCountryCode = event.countryCode
        
        tfstartDate.date = event.startDate
        tfEndDate.date = event.endDate
        
        tfLevel.set(level: event.level)
        
        tfCost.money = event.cost
        tfCost.money = event.cost
        
        if event.maxParticipants != -1{
            maxPplDropDown.text = "\(event.maxParticipants)"
            maxPplDropDown.selectedIndex = 0
        }else{
            maxPplDropDown.selectedIndex = 1
        }
        maxPplCount = event.maxParticipants
        
        tvEquipment.text = event.equipment
        tvExtraNotes.text = event.xtraNotes
    }
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        view.endEditing(true)
    }
}
