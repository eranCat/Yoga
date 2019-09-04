//
//  SplashScreenViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 10/07/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import SVProgressHUD
import Reachability

class SplashScreenViewController: UIViewController,ReachabilityObserverDelegate {
    
    lazy var ds = {return DataSource.shared}()

    @IBOutlet weak var loadingLbl: PaddingLabel!
    
    @IBOutlet weak var logoImg: UIImageView!
    
    override func viewDidLoad() {
        navigationController?.isToolbarHidden = true
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat,.autoreverse,.curveEaseIn], animations: {
            
            self.logoImg.transform = .init(translationX: 0, y: -20)
        })
        
        NotificationManager.shared.askForPermission { (isPermitted) in
            self.startSetup()
        }
        addReachabilityObserver()
    }
    deinit {
        removeReachabilityObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        logoImg.layer.removeAllAnimations()
    }
    
    func startSetup() {
        let reachability = Reachability(queueQoS: .utility, targetQueue: .global())
        guard reachability?.connection != .none
            else{
                showConnectionAlert()
                return
            }
        
        SVProgressHUD.show()
        ds.loadUsers { usersErr in//closure 1 - loding users finished
            
            if let err = usersErr{
                SVProgressHUD.dismiss()
                ErrorAlert.show(message: err.localizedDescription)
                return
            }
            
            if self.ds.setLoggedUser() { //#2 we have a logged user and also got it from the DB
                
                LocationUpdater.shared.getCurrentCountryCode() { (code) in
                    
                    self.ds.loadData{ error in //colsure 3 - load all data done
                        if let error = error{
                            SVProgressHUD.dismiss()
                            ErrorAlert.show(message: error.localizedDescription)
                            return
                        }
                        
                        MoneyConverter.shared.connect{//closue 4 - finished connecting to money api
                            
                            SVProgressHUD.dismiss()
                            
                            self.show(self.newVC(id: "mainNav"), sender: nil)
                        }
                    }
                }
                
            }else{
                SVProgressHUD.dismiss()
                
                let login = self.newVC(storyBoardName: "UserLogin", id: "LoginVC")
                self.present(UINavigationController(rootViewController: login), animated: true)
            }
        }
    }
    
}
