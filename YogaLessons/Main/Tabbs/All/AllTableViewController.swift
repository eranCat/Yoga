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
    lazy var searchController:UISearchController = { return createSearchController()}()
    
    lazy var filtered:[DataType:[DynamicUserCreateable]] = { [.classes:[],.events:[]]}()
    //    var filteredClasses:[Class] = []
    //    var filteredEvents:[Event] = []
    
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
        
        navigationItem.title = currentDataType.translated.capitalized
        
        updateEmptyBG()
        
        tableView.separatorInset.left = 120
        
        createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func createObservers() {
        
        let names:[Notification.Name] = [._sortTapped,
                                         ._searchStarted,
                                         ._dataAdded,._dataRemoved,._dataChanged]
        
        let selectors = [
            #selector(onSortTapped(_:)),
            #selector(initSearch),
            #selector(dataAdded(_:)),
            #selector(dataRemoved(_:)),
            #selector(dataChanged(_:))
        ]
        
        let centerDef = NotificationCenter.default
        
        for (name,selector) in zip(names,selectors){
            centerDef.addObserver(self, selector: selector, name: name, object: nil)
        }
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
        
        if let indexPath = notification.userInfo?["indexPath"] as? IndexPath{
            //            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            //            tableView.endUpdates()
        }else{
            tableView.reloadData()
        }
    }
    
    @objc func onSortTapped(_ notification:NSNotification) {
        
        // viewController is visible
        guard viewIfLoaded?.window != nil
            else{return}
        
        guard let (dType,sType) = notification.userInfo?["dataTuple"] as? (DataType,SortType)
            else{return}
        
        currentDataType = dType
        sortType = sType
        
        updateEmptyBG()
        
        dataSource.sort(by: sType,sourceType: .all,dataType: dType)
        
        reload()
    }
    
    func updateEmptyBG() {
        let text:String
        
        if Locale.preferredLanguages[0].starts(with: "he"){//hebrew
            text = "עדיין \(currentDataType.translated) אין"
        }else{
            text = "No \(currentDataType.translated) yet"
        }
        setupEmptyBG(withMessage: text)
    }
    
    func reload() {
        //        tableView.reloadSections(IndexSet(integer: 0), with: .left)
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let data = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)!
        guard let statused = data as? Statused,
            statused.status == .open
            else{return []}
        
        let objId = data.id!
        let signed:[String:Bool]
        
        let user = YUser.currentUser!
        switch currentDataType {
        case .classes:
            signed = user.signedClassesIDS
        case .events:
            signed = user.signedEventsIDS
        }
        
        let signAction:UITableViewRowAction
        //the user didnt sign up for the class
        if let isSigned = signed[objId] {
            signAction = .init(style: .default, title: "I'm out".translated, handler: { _,_ in
                
                self.signUserOut(indexPath)
            })
            signAction.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }else{
            
            signAction = .init(style: .default, title: "I'm in".translated, handler: {(_,_) in
                
                self.signinUserTo(indexPath)
            })
            signAction.backgroundColor =  #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
        
        return [signAction]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1{//show loading cell on section 1
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell",for: indexPath) as! ProggressCell
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
        
        let sender = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)
        
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
                    
                    ErrorAlert.show(title: title, message: err.localizedDescription)
                    
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
        //if currentnum == max else
        dataSource.signTo(currentDataType, dataObj: data, taskDone: onAdd)
    }
    
    func signUserOut(_ indexPath:IndexPath){
        
        guard let obj = dataSource.get(sourceType: .all, dType: currentDataType, at: indexPath)
            else{return}
        
        var sureQ: String = "Are you sure you want to sign out of this".translated
        sureQ += "\(currentDataType.singular)?"
        
        let alert = UIAlertController.init(title: "Sign out alert".translated, message: sureQ , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "Yes".translated, style: .default) { _ in
            
            SVProgressHUD.show()
            DataSource.shared
                .unsignFrom(self.currentDataType, data: obj) { (err) in
                    
                    if let error = err{
                        ErrorAlert.show(message: error.localizedDescription)
                    }
                    SVProgressHUD.dismiss()
            }
        })
        
        alert.addAction(.init(title: "No".translated, style: .cancel))
        
        present(alert,animated: true)
    }
    
    
    // MARK: - Navigation
    private enum SeguesIDs:String {
        case classInfo = "showClassInfo"
        case eventInfo = "showEventInfo"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier ,
            let segueId = SeguesIDs(rawValue: id)
            else{return}
        
        switch segueId {
        case .classInfo:
            guard let destVC = segue.destination as? ClassInfoViewController,
                let c = sender as? Class
                else{return}
            
            destVC.classModel = c
            
        case .eventInfo:
            guard let destVC = segue.destination as? EventInfoViewController,
                let e = sender as? Event
                else{return}
            
            destVC.eventModel = e
        }
    }
    
}
