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

    
    override func viewDidLoad() {
        navigationController?.isToolbarHidden = true
        
        guard Reachability(queueQoS: .utility, targetQueue: .global())?.connection != .none
            else{return}
        
        continueSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addReachabilityObserver()
    }
    
    deinit {
        removeReachabilityObserver()
    }
    
    fileprivate func continueSetup() {
        SVProgressHUD.show()
        
        ds.loadUsers { usersErr in//closure 1 - loding users finished
            
            if let err = usersErr{
                SVProgressHUD.dismiss()
                ErrorAlert.show(message: err.localizedDescription)
                return
            }
            
            if self.ds.setLoggedUser() { //we have a logged user and also got it from the DB
                
                self.ds.loadData{ error in //colsure 2 - load all data done
                    if let error = error{
                        SVProgressHUD.dismiss()
                        ErrorAlert.show(message: error.localizedDescription)
                        return
                    }
                    
                    MoneyConverter.shared.connect
                        {self.openMain()}//closue 3 - finished connecting to money api
                }
                
            }else{
                self.openLogin()
            }
        }
    }
    

    fileprivate func openLogin() {
        self.performSegue(withIdentifier: "showLogin", sender: nil)
        SVProgressHUD.dismiss()
    }
    
    
    func openMain() {
        SVProgressHUD.dismiss()
        show(newVC(id: "mainNav"), sender: nil)
    }
}
