//
//  ClassesTableViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import SVProgressHUD

class AllTableViewController: UITableViewController,DynamicTableDelegate {
    //MARK:    DynamycTableDelegate
    
    var currentDataType: DataType = .classes
    
    var sortType: SortType = .best
    
    let dataSource =  DataSource.shared
    
    var isFetchingMore = false
    var hasEndReached = false
    var leadingScreenForBatching:CGFloat = 3.0
    
    var isSearching = false
    var searchType:SearchKeyType?
    
    // Search controller
    lazy var searchController = createSearchController()
    
    lazy var filtered:[DataType:[DynamicUserCreateable]] = { [.classes:[],.events:[]]}()
    
    fileprivate func registerCells() {
        //        MARK: load cells
        let classCellId = CellIds.id(for: .classes)
        let classNib = UINib(nibName: classCellId, bundle: nil)
        tableView.register(classNib, forCellReuseIdentifier: classCellId)
        
        let eventCellId = CellIds.id(for: .events)
        let eventNib = UINib(nibName: eventCellId, bundle: nil)
        tableView.register(eventNib, forCellReuseIdentifier: eventCellId)
        
        tableView.register(ProggressCell.self, forCellReuseIdentifier: "loadingCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl = nil//cancel pull to refresh
        
        navigationItem.title = currentDataType.translated.capitalized
        
        updateEmptyBG()
        
        tableView.separatorInset.left = 120
        
        createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func createObservers() {
        
        let observersDiect:[Notification.Name:Selector] = [
            ._sortTapped : #selector(onSortTapped(_:)),
            ._searchStarted : #selector(initSearch),
            ._dataAdded : #selector(dataAdded(_:)),
            ._dataRemoved : #selector(dataRemoved(_:)),
            ._dataChanged : #selector(dataChanged(_:)),
            ._signedTabSelected : #selector(signedTabSelected(_:)),
            ._settingChanged : #selector(settingChanged(_:)),
            ._reloadedAfterSettingChanged : #selector(reloadedAfterSettingChanged(_:))
        ]
        
        let centerDef = NotificationCenter.default
        
        for (name,selector) in observersDiect{
            centerDef.addObserver(self, selector: selector, name: name, object: nil)
        }
    }
    
    @objc func settingChanged(_ notification:NSNotification){
        SVProgressHUD.show()
    }
    @objc func reloadedAfterSettingChanged(_ notification:NSNotification){
        SVProgressHUD.dismiss()
        tableView.reloadData()
    }

    @objc func signedTabSelected(_ notification:NSNotification){
        searchController.dismiss(animated: true)
    }
    
    @objc func dataChanged(_ notification:NSNotification) {
        guard let type = notification.userInfo?["type"] as? DataType,
            type == currentDataType
            else{return}
        
        tableView.reloadData()
    }
    
    
    @objc func dataRemoved(_ notification:NSNotification) {
        guard let type = notification.userInfo?["type"] as? DataType,
            type == currentDataType
            else {return}
        
        if let indexPath = notification.userInfo?["indexPath"] as? IndexPath{
            //            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .top)
            //            tableView.endUpdates()
        }else{
            tableView.reloadData()
        }
    }
    
    @objc func dataAdded(_ notification:NSNotification) {
        guard let type = notification.userInfo?["type"] as? DataType,
            type == currentDataType
            else {return}
        
        if let indexPaths = notification.userInfo?["indexPaths"] as? [IndexPath]{
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        }else{
            tableView.reloadData()
        }
    }
    
    @objc func onSortTapped(_ notification:NSNotification) {
        
        // viewController is visible
//        guard viewIfLoaded?.window != nil
//            else{return}
        
        guard let (dType,sType) = notification.userInfo?["dataTuple"] as? (DataType,SortType)
            else{return}
        
        currentDataType = dType
        sortType = sType
        
        updateEmptyBG()
        
        dataSource.sort(by: sType,sourceType: .all,dataType: dType)
        
        tableView.reloadData()
    }
    
    func updateEmptyBG() {
        let text = "\("non".translated) \(currentDataType.translated) \("yet".translated)"
        
        setupEmptyBG(withMessage: text)
    }
    
    func reload() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    @objc func refreshData() {
        
        dataSource.loadAll(currentDataType) { err in
            if let error = err{
                ErrorAlert.show(message: error.localizedDescription)
                return
            }
            self.reload()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//MARK: 2 for loading cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            let count:Int
            
            if isSearching {
                count = filtered[currentDataType]!.count
            }else{
                count = dataSource.count(sourceType: .all,dType: currentDataType)
            }
            
            adjustEmpty(count == 0 )
            
            return count
            
        case 1:
            return isFetchingMore ? 1 : 0
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let data = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)!
        
        let objId = data.id
        let signed:[String:Bool]
        
        
        let shareAction = UIContextualAction(style: .normal, title: "Share".translated) { (_, actionView, complete) in
            
            SharingManager.share(data: data)
        }
        shareAction.image = #imageLiteral(resourceName: "share")
        shareAction.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        let user = YUser.currentUser!
        switch currentDataType {
        case .classes:
            signed = user.signedClassesIDS
        case .events:
            signed = user.signedEventsIDS
        }
        
        let signAction:UIContextualAction
        //the user didnt sign up for the class
        if signed[objId] != nil {
            signAction = .init(style: .normal, title:  "I'm out".translated) { (_, _, _) in
                
                self.signUserOut(indexPath)
            }
            
            signAction.backgroundColor = ._danger
            
            return .init(actions: [signAction,shareAction])
        }else{
            
            signAction = .init(style: .normal, title: "I'm in".translated){(_,_,_) in
                
                self.signinUserTo(indexPath)
            }
            signAction.backgroundColor =  ._accent
            
            let actions = (data as! Statused).status == .open ?  [signAction,shareAction] : []
            return .init(actions: actions)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{//show loading cell on section 1
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell",
                                                     for: indexPath) as! ProggressCell
            cell.spinner.startAnimating()
            return cell
        }
        
        let data:UserConnectionDelegate?
        
        
        if isSearching{
            data = filtered[currentDataType]![safe: indexPath.row]
        }
        else{
            data = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)
        }
        
        let cellId = CellIds.id(for: currentDataType)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId,for: indexPath)
        
        
        if let populateable = cell as? PopulateDelegate,let data = data{
            populateable.populate(with: data)
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender:DynamicUserCreateable?
        
        if !isSearching{
            sender = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)
        }else{
            sender = filtered[currentDataType]![safe: indexPath.row]
        }
        
        let ids:[DataType:SeguesIDs] = [.classes:.classInfo,.events:.eventInfo]
        
        performSegue(withIdentifier: ids[currentDataType]!.rawValue,sender: sender)
    }
    
    func signinUserTo(_ indexPath: IndexPath) {
        let onAdd = { error in
            SVProgressHUD.dismiss()
            
            if let err = error {
                if let signErr = err as? SigningErrors{
                    
                    let title:String?
                    
                    switch signErr{
                        
                    case .noPlaceLeft:
                        title = "too late".translated//Oh no ,you're too late
                    case .alreadySignedToClass, .alreadySignedToEvent:
                        title = "signTwice".translated //Sign in twice, not very nice."
                    default:
                        title = nil
                    }
                    
                    ErrorAlert.show(title: title, message: signErr.errorDescription ?? err.localizedDescription)
                    
                }else{
                    ErrorAlert.show(message: err.localizedDescription)
                }
                return
            }
        } as DSTaskListener
        
        SVProgressHUD.show()
        let data:DynamicUserCreateable
        if !isSearching{
            
            guard let d = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)
                else{
                    SVProgressHUD.dismiss()
                    return
            }
            
            data = d
        }else{
            
            data = filtered[currentDataType]![indexPath.row]
        }
        dataSource.signTo(currentDataType, dataObj: data, taskDone: onAdd)
    }
    
    func signUserOut(_ indexPath:IndexPath){
        
        guard let obj = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)
            else{return}
        
        UnsignAlert.show(dType: currentDataType) { _ in
            
            SVProgressHUD.show()
            DataSource.shared
                .unsignFrom(self.currentDataType, data: obj) { (err) in
                    
                    if let error = err{
                        ErrorAlert.show(message: error.localizedDescription)
                    }
                    SVProgressHUD.dismiss()
            }
        }
    }
    
    
    // MARK: - Navigation
    private enum SeguesIDs:String {
        case classInfo = "showClassInfo"
        case eventInfo = "showEventInfo"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let _ = segue.identifier,
            let sender = sender
            else{return}
        
        switch sender {
        case let aClass as Class:
            if let destVC = segue.destination as? ClassInfoViewController{
                destVC.classModel = aClass
            }
            
        case let event as Event:
            if let destVC = segue.destination as? EventInfoViewController{
                destVC.eventModel = event
            }
            
        default:
            return
        }
    }
    
}
