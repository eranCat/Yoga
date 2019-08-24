//
//  MainViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 14/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    @IBOutlet weak var profileBtn: UIBarButtonItem!
    
    lazy var sortBtn: UIBarButtonItem = {
        var btn = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(showSortAlert(_:)))
        
        btn.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        return btn
    }()
    
    lazy var searchBtn: UIBarButtonItem = {
        
        let searchBtn = BlockBarButtonItem(barButtonItemSystem: .search){
            NotificationCenter.default.post(name: ._searchStarted, object: nil)
        }
        
        searchBtn.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        return searchBtn
    }()
    
    lazy var addBtn: UIBarButtonItem = {
        let btn = BlockBarButtonItem(barButtonItemSystem: .add){
            let newNav = self.newVC(storyBoardName: "NewClassEvent", id: "newClassEventNav")
//            self.show(newVc, sender: nil)
            
//            if let nav = newNav as? UINavigationController{
//                if let vc = nav.children[0] as? NewClassEventViewController{
//                    vc.typeSegment.type = self.currentDataType
//                }
//            }
            
            
            self.present(newNav,animated: true)
        }
        
        btn.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        return btn
    }()
    
    lazy var allBar:[UIBarButtonItem] = {
        
        if YUser.currentUser?.type == .teacher{
            return [searchBtn,sortBtn,addBtn]
        }
        
        return [searchBtn,sortBtn]
    }()
    
    lazy var signedBar:[UIBarButtonItem] = {createSignedBarItems()}()
    
    lazy var barItemsForTab:[[UIBarButtonItem]] = {return [allBar,signedBar]}()
    
    var currentDataType:DataType = .classes
    var currentSourceType:SourceType = .all
   
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        delegate = self
        
        subscribeObservers()
        updateTitle()
        navigationItem.setRightBarButtonItems(allBar, animated: true)
    }
    
    func updateTitle() {
        
        let title = "\(currentSourceType)-\(currentDataType)".translated
        
        navigationItem.title = title.capitalized
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let ds = DataSource.shared
        ds.removeAllObserver(dataType: .classes)
        ds.removeAllObserver(dataType: .events)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let ds = DataSource.shared
//        ds.observeClassAdded()
        ds.observeClassChanged()
//        ds.observeEventAdded()
        ds.observeEventChanged()
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        guard identifier == "showUserInfo"
            else {return true}
        
        if YUser.currentUser == nil{
            ErrorAlert.show(title: "Fetching info".translated,
                            message: "Please wait".translated)
            
            guard DataSource.shared.setLoggedUser()
                else{return false}
            
            performSegue(withIdentifier: identifier, sender: YUser.currentUser!)
            
            return true
        }
        
        return true
    }
    
    
    @IBAction func showSortAlert(_ sender: UIBarButtonItem) {
        SortAlert.show()
    }
    
    
    
    func subscribeObservers() {
        
        let names:[Notification.Name] = [._sortTapped,._signedDataAdded]
        
        let selectors = [#selector(onSortTapped(_:)),#selector(onSigned(_:))]
        
        zip(names, selectors).forEach{addObserver($0,$1)}
    }
    
    func addObserver(_ name:Notification.Name,_ selector:Selector) {
        NotificationCenter.default
            .addObserver(self, selector: selector, name: name, object: nil)
    }
    
    @objc func onSortTapped(_ notification:NSNotification) {
        guard let (dType,sType) = notification.userInfo?["dataTuple"] as? (DataType,SortType)
            else{return}
        
        currentDataType = dType
        
        updateTitle()
    }
    
    @objc func onSigned(_ notification:NSNotification){
//        move to signed tab
        
        selectedIndex = 1
        
        currentSourceType = .signed
        updateTitle()
        
//        and sort to type
//        DataSource.shared.sort(by: .best, dataSource: .signed, dataType: currentDataType)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
