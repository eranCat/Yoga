//
//  ClassesTableViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 21/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignedTableViewController: UITableViewController,DynamicTableDelegate {
    
    //MARK: DynamycTableDelegate
    var currentDataType  = DataType.classes
    
    var sortType = SortType.best
    
    let dataSource =  DataSource.shared
    
    var isTeacher = false,isEmpty = true
    let sectionsHeaders = ["My uploads","Signed"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        navigationItem.title = "Signed \(currentDataType)".capitalized
        
        setupEmptyBG(withMessage: "No signed \(currentDataType)")
        
        isTeacher = (YUser.currentUser?.type == .teacher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeObservers()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerCells() {
        for type in DataType.allCases{
            let id = CellIds.id(for: type)
            tableView.register(UINib(nibName: id, bundle: nil), forCellReuseIdentifier: id)
        }
    }
    
    @objc func signedDataAdded(_ notif: Notification) {
        
        guard let type = notif.userInfo?["type"] as? DataType,
            type == currentDataType
            else{return}
        
        tableView.insertRows(at: [.init(row: 0, section: 0)], with: .automatic)
    }
    
    func subscribeObservers() {
        
        let names:[Notification.Name] = [._sortTapped,._signedDataAdded,._dataCancled]
        
        let selectors:[Selector] = [#selector(onSortTapped(_:)),
                                     #selector(signedDataAdded(_:)),
                                     #selector(onDataChanged(_:)),
                                    ]
        
        
        let centerDef = NotificationCenter.default
        for (name,selector) in zip(names, selectors){
            centerDef.addObserver(self,selector: selector,name: name,object: nil)
        }
    }
    @objc func onDataChanged(_ notification:NSNotification) {
        
        guard
            let ui = notification.userInfo,
            
            let type = ui["type"] as? DataType,type == currentDataType,
            
            let status = ui["status"] as? Status,status == .cancled
            
            else{return}
        
        tableView.reloadData()
    }
    
    
    @objc func onSortTapped(_ notification:NSNotification) {
        // viewController is visible
        guard viewIfLoaded?.window != nil
            else{return}
        
        guard let (dType,sType) = notification.userInfo?["dataTuple"] as? (DataType,SortType)
            else{return}
        
        currentDataType = dType
        sortType        = sType
        
        dataSource.sortUserUploads(by: sType, dataType: dType)
        
        dataSource.sort(by: sType,sourceType: .signed,dataType: dType)
        
        refreshData()
        
        updateEmptyLabel()
    }
    
    func updateEmptyLabel() {
        guard let emptyView = tableView.backgroundView as? EmptyView
            else{return}
        
        emptyView.messageLbl.text = "No signed \(currentDataType)"
    }
    
    
    @objc func refreshData() {
        // Fetch Data
        
        dataSource.loadUserCreatedData()
        
        dataSource.loadSigned(currentDataType)
        
        
        tableView.reloadSections([0,1], with: .automatic)
        
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if !isTeacher && currentDataType == .classes{
            return 1
        }
        return sectionsHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isEmpty
            else{return nil}
        
        return sectionsHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let signedCount = dataSource.getList(sourceType: .signed, dType: currentDataType).count
        let count = dataSource.user_sUploads(dType: currentDataType).count
        isEmpty = (signedCount == 0 && count == 0)
        
        switch section {
        case 0://user uploads
            adjustEmpty(isEmpty)
            return count
        case 1:fallthrough//signed
        default:
            adjustEmpty(isEmpty)
            return signedCount
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellName = CellIds.id(for: currentDataType)
        
//        let cell = Bundle.main.loadNibNamed(cellName, owner: self, options: nil)?.first as! UITableViewCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName,for: indexPath)
        
        let data:DynamicUserCreateable?
        
        switch indexPath.section{
        case 0:
            data = dataSource.user_sUploads(dType: currentDataType)[indexPath.row]
            cell.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            cell.selectionStyle = .none
        case 1:fallthrough
        default:
            data = dataSource.get(sourceType: .signed, dType: currentDataType, at: indexPath)
            cell.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        
        
        if let populateAble = cell as? PopulateDelegate,
            let data = data{
            populateAble.populate(with: data)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        switch indexPath.section {
        case 0:
            let cancel = UITableViewRowAction(style: .destructive,
                                              title: "Cancel "+currentDataType.singular)
                                                {self.cancelPost(indexPath: $1)}
            
            return [cancel]

        case 1:fallthrough//signed
        default:
            let unsign = UITableViewRowAction(style: .destructive,
                                              title: "Unsign from  "+currentDataType.singular)
                                                {self.unsign(indexPath: $1)}
            return [unsign]
        }
    }
    func unsign(indexPath:IndexPath) {
        //            MARK:check where to remove from
        SVProgressHUD.show()
        
        self.dataSource.unsignFrom(self.currentDataType, at: indexPath){err in
            SVProgressHUD.dismiss()
            if let err = err {
                ErrorAlert.show(message: err.localizedDescription)
            }
            self.tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
    
    func cancelPost(indexPath:IndexPath) {
        SVProgressHUD.show()
        //            MARK:check where to remove from
        self.dataSource.setCancled(self.currentDataType, at: indexPath.row){ error in
            SVProgressHUD.dismiss()
            if let err = error {
                ErrorAlert.show(message: err.localizedDescription)
            }
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        dataSource.swapSigned(currentDataType, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender:DynamicUserCreateable?
        let segueId:String
        
        switch indexPath.section{
        case 0:
            sender = dataSource.user_sUploads(dType: currentDataType)[indexPath.row]
            segueId = SeguesIDs.edit.rawValue
        case 1:fallthrough
        default:
            sender = dataSource.get(sourceType: .signed, dType: currentDataType, at: indexPath)
            segueId = SeguesIDs.dict[currentDataType]!.rawValue
            performSegue(withIdentifier: segueId, sender: sender)
        }
        
    }
    
    // MARK: - Navigation
    
    private enum SeguesIDs:String {
        case classInfo = "showClassInfo"
        case eventInfo = "showEventInfo"
        case edit = "openEdit"
        
        static let dict:[DataType:SeguesIDs] = [.classes:.classInfo,.events:.eventInfo]
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier ,
            let segueId = SeguesIDs(rawValue: id)
            else{return}
        
        switch segueId {
        case .classInfo:
            if let destVC = segue.destination as? ClassInfoViewController,
                let c = sender as? Class{
                
                destVC.classModel = c
            }
        case .eventInfo:
            if let destVC = segue.destination as? EventInfoViewController,
                let e = sender as? Event{
                
                destVC.eventModel = e
            }
        case .edit:
            guard let destNav = segue.destination as? UINavigationController,
            let destVC = destNav.children[0] as? NewClassEventViewController,
                let data = sender as? DynamicUserCreateable
                else{return}
                
            destVC.model = data
        }
    }
}
