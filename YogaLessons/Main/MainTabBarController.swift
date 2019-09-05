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
        
        return btn
    }()
    
    lazy var searchBtn: UIBarButtonItem = {
        
        let searchBtn = BlockBarButtonItem(barButtonItemSystem: .search){
            NotificationCenter.default.post(name: ._searchStarted, object: nil)
        }
        
        return searchBtn
    }()
    
    lazy var addBtn: UIBarButtonItem = {
        let btn = BlockBarButtonItem(barButtonItemSystem: .add){
            
            let newNav = self.newVC(storyBoardName: "NewClassEvent", id: "NewClassEvent")
            
            self.present(UINavigationController(rootViewController: newNav),animated: true)
        }
        
        return btn
    }()
    
    lazy var allBar:[UIBarButtonItem] = {
        
        return [searchBtn,sortBtn,addBtn]
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
        configureNavBarLayout()
    }
    
    fileprivate func configureNavBarLayout() {
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = ._btnTint
        let backImg = #imageLiteral(resourceName: "backArrow").sd_resizedImage(with: .init(width: 26, height: 26),
                                                                               scaleMode: .aspectFit)
        appearance.backIndicatorImage = backImg
        appearance.backIndicatorTransitionMaskImage = backImg
    }
    
    func updateTitle() {
        
        let title = "\(currentSourceType)-\(currentDataType)".translated
        
        navigationItem.title = title.capitalized
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        let ds = DataSource.shared
//        ds.removeAllObserver(dataType: .classes)
//        ds.removeAllObserver(dataType: .events)
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        let ds = DataSource.shared
////        ds.observeClassAdded()
//        ds.observeClassChanged()
////        ds.observeEventAdded()
//        ds.observeEventChanged()
//
//    }
    
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
        
        let observers :[Notification.Name : Selector] =
            [._sortTapped:#selector(onSortTapped(_:)),
             ._signedDataAdded:#selector(onSigned(_:))]
        
        let def = NotificationCenter.default
        observers.forEach{
            def.addObserver(self, selector: $1, name: $0, object: nil)
        }
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
