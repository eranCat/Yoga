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
    
    var isTeacher = false
    var isDataEmpty = true
    
    let sectionsHeaders = [SourceType.signed.translated.capitalized,
                           "My uploads".translated.capitalized]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        updateTitle()
        
        updateEmptyLabel()
        
        isTeacher = (YUser.currentUser?.type == .teacher)
        
        subscribeObservers()
        
        //        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    func updateTitle() {
        let title = "\(SourceType.signed.translated)-\(currentDataType.translated)"
        navigationItem.title = title.capitalized
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerCells() {
        for type in DataType.allCases{
            let id = CellIds.id(for: type)
            tableView.register(UINib(nibName: id, bundle: nil), forCellReuseIdentifier: id)
        }
    }
    
    
    func subscribeObservers() {
        
        let observers:[Notification.Name:Selector] =
            [._sortTapped:#selector(onSortTapped(_:)),
             ._signedDataAdded:#selector(signedDataAdded(_:)),
             ._dataAdded:#selector(dataAdded(_:)),
             ._dataChanged:#selector(onDataChanged(_:)),
             ._signedDataRemoved:#selector(signedDataRemoved(_:)),
             ._signedDataChanged:#selector(onDataChanged(_:)),
             ._dataCancled:#selector(onDataChanged(_:)),
             ._settingChanged : #selector(settingChanged(_:)),
             ._reloadedAfterSettingChanged : #selector(reloadedAfterSettingChanged(_:))
        ]
        
        let centerDef = NotificationCenter.default
        
        observers.forEach{
            centerDef.addObserver(self, selector: $1, name: $0, object: nil)
        }
    }
    @objc func settingChanged(_ notification:NSNotification){
        SVProgressHUD.show()
    }
    @objc func reloadedAfterSettingChanged(_ notification:NSNotification){
        SVProgressHUD.dismiss()
        tableView.reloadData()
    }
    
    @objc func signedDataAdded(_ notif: Notification) {
        
        let signedCount = tableView.numberOfRows(inSection: 0)
        let dsSignedCount: Int = dataSource.count(sourceType: .signed, dType: currentDataType)
        guard let type = notif.userInfo?["type"] as? DataType,
            type == currentDataType,
            signedCount < dsSignedCount
            else{return}
        
        let ip: IndexPath = .init(row: 0, section: 0)
        
        tableView.insertRows(at: [ip], with: .automatic)
        //        tableView.reloadRows(at: [ip], with: .none)
        //        tableView.scrollToRow(at: ip, at: .top, animated: true)
    }
    @objc func dataAdded(_ notif: Notification) {
        
        guard let type = notif.userInfo?["type"] as? DataType,
            type == currentDataType
            else{return}
        
        let tableCount = tableView.numberOfRows(inSection: 0)
        let dsCount: Int = dataSource.count(sourceType: .signed, dType: currentDataType)
        
        
        guard let creatorID = dataSource
            .get(sourceType: .signed,dType: currentDataType,at: .init(row: 0, section: 0))?.uid,
            creatorID == YUser.currentUser?.id,
            tableCount < dsCount
            else{return}
        
        let ip: IndexPath = .init(row: 0, section: 1)
        
        tableView.insertRows(at: [ip], with: .automatic)
        tableView.reloadRows(at: [ip], with: .none)
        tableView.scrollToRow(at: ip, at: .top, animated: true)
    }
    
    @objc func signedDataRemoved(_ notif: Notification) {
        
        guard let type = notif.userInfo?["type"] as? DataType,
            type == currentDataType
            else{return}
        
        tableView.reloadData()
    }
    
    @objc func onDataChanged(_ notification:NSNotification) {
        
        guard let ui = notification.userInfo,
            let type = ui["type"] as? DataType,type == currentDataType,
            let _ = ui["status"] as? Status//,status == .cancled
            
            else{return}
        
        tableView.reloadData()
    }
    
    
    @objc func onSortTapped(_ notification:NSNotification) {
        // viewController is visible
        //        guard viewIfLoaded?.window != nil
        //            else{return}
        
        guard let (dType,sType) = notification.userInfo?["dataTuple"] as? (DataType,SortType)
            else{return}
        
        currentDataType = dType
        sortType = sType
        
        dataSource.sortUserUploads(by: sType, dataType: dType)
        
        dataSource.sort(by: sType,sourceType: .signed,dataType: dType)
        
        adjustEmpty(isDataEmpty)
        updateEmptyLabel()
        
        updateTitle()
        
        tableView.reloadData()
    }
    
    func updateEmptyLabel() {
        
        let msg = "No signed ".translated + currentDataType.translated
        
        setupEmptyBG(withMessage: msg)
    }
    
    
    @objc func refreshData() {
        // Fetch Data
        
        //        dataSource.loadUserCreatedData()
        
        dataSource.loadSigned(currentDataType)
        
        tableView.reloadSections([0], with: .automatic)
        
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isTeacher {
            return sectionsHeaders.count
        }
        //not teacher here
        switch currentDataType {
        case .classes:
            return 1
        case .events:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let header = view as? UITableViewHeaderFooterView
            else { return }
        
        if let lbl = header.textLabel{
            lbl.font = UIFont.boldSystemFont(ofSize: 24)
            lbl.frame = header.frame
            lbl.textAlignment = .center
            lbl.textColor = .white
        }
        
        header.tintColor = ._headerTint
        
        if tableView.numberOfSections == 1 {//no need for header if there's only one section
            header.isHidden = true
        }else{
            header.isHidden = isDataEmpty
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.numberOfSections == 1 {//no need for header if there's only one section
            return 0
        }else{
            return isDataEmpty ? 0 : 60
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isDataEmpty || tableView.numberOfSections == 1{
            return nil
        }
        
        return sectionsHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let signedCount = dataSource.count(sourceType: .signed, dType: currentDataType)
        let uploadsCount = dataSource.getUser_sUploads(dType: currentDataType).count
        
        if tableView.numberOfSections == 2{
            isDataEmpty = (signedCount == 0 && uploadsCount == 0)
        }else{
            isDataEmpty = signedCount == 0
        }
        adjustEmpty(isDataEmpty)
        
        return [signedCount,uploadsCount][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellName = CellIds.id(for: currentDataType)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName,for: indexPath)
        
        let data:DynamicUserCreateable?
        
        switch indexPath.section{
        case 1:
            data = dataSource.getUser_sUploads(dType: currentDataType)[indexPath.row]
            cell.backgroundColor = ._userUploads
            cell.selectionStyle = .none
        case 0:fallthrough
        default:
            data = dataSource.get(sourceType: .signed, dType: currentDataType, at: indexPath)
            cell.backgroundColor = ._signedCell
        }
        
        
        if let populateAble = cell as? PopulateDelegate,
            let data = data{
            populateAble.populate(with: data)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        switch indexPath.section {
        case 1:
            
            let update = UIContextualAction(style: .normal, title: "Update".translated) { (_, _, _) in
                let sender = self.dataSource
                    .getUser_sUploads(dType: self.currentDataType)[indexPath.row]
                self.performSegue(withIdentifier: SeguesIDs.edit.rawValue, sender: sender)
                tableView.isEditing = false
            }
            update.image = #imageLiteral(resourceName: "edit")
            update.backgroundColor = ._ok
            
            let data = dataSource.getUser_sUploads(dType: currentDataType)[indexPath.row] as? Statused
            if data?.status == .cancled{
                let title = "Restore".translated+" "+currentDataType.singular
                let restore = UIContextualAction(style: .normal, title: title) { (_, _, completed) in
                    self.toggleCancel(indexPath: indexPath)
                }
                
                restore.backgroundColor = ._accent
                
                return UISwipeActionsConfiguration(actions: [update,restore])
                
            }else{
                let title = "Cancel".translated+" "+currentDataType.singular
                let cancel = UIContextualAction(style: .destructive, title: title) { (_, _, _) in
                    self.cancelPost(indexPath: indexPath)
                }
                cancel.image = #imageLiteral(resourceName: "closeX")
                cancel.backgroundColor = ._danger
                return UISwipeActionsConfiguration(actions: [update,cancel])
            }
            
        case 0:fallthrough//signed
        default:
            let title = "Unsign from ".translated + currentDataType.singular
            let unsign = UIContextualAction(style: .destructive,title: title){ (_,_,_) in
                self.unsign(indexPath: indexPath)
            }
            unsign.backgroundColor = ._danger
            return UISwipeActionsConfiguration(actions: [unsign])
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        switch indexPath.section {
        case 1:
            
            let data = dataSource.getUser_sUploads(dType: currentDataType)[indexPath.row] as? Statused
            if data?.status == .cancled{
                let title = "Restore".translated+" "+currentDataType.singular
                let restore =
                    UITableViewRowAction(style: .default,title: title)
                    {self.toggleCancel(indexPath: $1)}
                restore.backgroundColor = ._accent
                
                return [restore]
                
            }else{
                let title = "Cancel".translated+" "+currentDataType.singular
                let cancel =
                    UITableViewRowAction(style: .destructive,title: title)
                    {self.cancelPost(indexPath: $1)}
                cancel.backgroundColor = ._danger
                return [cancel]
            }
            
        case 0:fallthrough//signed
        default:
            let title = "Unsign from ".translated + currentDataType.singular
            let unsign = UITableViewRowAction(style: .destructive,title: title)
            {self.unsign(indexPath: $1)}
            unsign.backgroundColor = ._danger
            return [unsign]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender:DynamicUserCreateable?
        let segueId:String
        
        switch indexPath.section{
        case 1:
            sender = dataSource.getUser_sUploads(dType: currentDataType)[indexPath.row]
            segueId = SeguesIDs.edit.rawValue
            performSegue(withIdentifier: segueId, sender: sender)
        case 0:fallthrough
        default:
            sender = dataSource.get(sourceType: .signed, dType: currentDataType, at: indexPath)
            segueId = SeguesIDs.dict[currentDataType]!.rawValue
            performSegue(withIdentifier: segueId, sender: sender)
        }
        
    }
    
    
    func unsign(indexPath:IndexPath) {
        //            MARK:check where to remove from
        
        UnsignAlert.show(dType: currentDataType) { _ in
            SVProgressHUD.show()
            
            self.dataSource.unsignFrom(self.currentDataType, at: indexPath){err in
                SVProgressHUD.dismiss()
                
                if let err = err {
                    ErrorAlert.show(message: err.localizedDescription)
                }else{
                    DispatchQueue.main.async{
                        //                        MARK: fix this crash
                        //                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func toggleCancel(indexPath:IndexPath) {
        SVProgressHUD.show()
        //            MARK:check where to remove from
        self.dataSource.toggleCancel(self.currentDataType, at: indexPath.row){ error in
            SVProgressHUD.dismiss()
            if let err = error {
                ErrorAlert.show(message: err.localizedDescription)
                return
            }
            self.tableView.reloadRows(at: [indexPath], with: .middle)
        }
    }
    
    func cancelPost(indexPath:IndexPath) {
        
        let msg = "confirmCancel".translated + currentDataType.singular + " ?"
        
        let alert = UIAlertController.create(title: nil, message: msg,preferredStyle: .alert)
            
            .aAction(UIAlertAction(title: "yes".translated, style: .default) { (_) in
                
                self.toggleCancel(indexPath: indexPath)
            })
            
            .aAction(.init(title: "No".translated, style: .cancel, handler: nil))
        
        present(alert, animated: true)
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
