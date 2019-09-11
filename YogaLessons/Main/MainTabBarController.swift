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
    
    var currentDataType:DataType = .classes{
        didSet{
            updateTitle()
        }
    }
    var currentSourceType:SourceType = .all{
        didSet{
            updateTitle()
        }
    }
   
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        delegate = self
        
//        set title view for better style
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        // this next line picks up the UINavBar tint color instead of fixing it to a particular one as in Gavin's solution
        titleLabel.textColor = UINavigationBar.appearance().tintColor
        titleLabel.font = UIFont(name: "Euphomia UAS", size: 16.0)?.bold
        navigationItem.titleView = titleLabel
        
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
        
        let title = "\(currentSourceType)-\(currentDataType)".translated.capitalized
        
        if let lbl = navigationItem.titleView as? UILabel{
            lbl.text = title
        }
        else{
            navigationItem.title = title
        }
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
        
        let observers :[Notification.Name : Selector] =
            [._sortTapped:#selector(onSortTapped(_:)),
             ._signedDataAdded:#selector(onSigned(_:))]
        
        let def = NotificationCenter.default
        observers.forEach{
            def.addObserver(self, selector: $1, name: $0, object: nil)
        }
    }
    
    @objc func onSortTapped(_ notification:NSNotification) {
        guard let (dType,_) = notification.userInfo?["dataTuple"] as? (DataType,SortType)
            else{return}
        
        currentDataType = dType
        
        updateTitle()
    }
    
    @objc func onSigned(_ notification:NSNotification){
//        move to signed tab
        
        selectedIndex = 1
        
        currentSourceType = .signed
        
        changeBarButtons(bySelectedIndex: selectedIndex)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    var bold:UIFont {
        return withTraits(traits: .traitBold)
    }
}
