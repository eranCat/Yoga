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
        
        startSetup()
        addReachabilityObserver()
    }
    deinit {
        removeReachabilityObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat,.autoreverse,.curveEaseIn], animations: {
            
            self.logoImg.transform = .init(translationX: 0, y: -50)
        })
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
        
        continueSetup()
    }
    
    fileprivate func continueSetup() {
        
        SVProgressHUD.showProgress(0)
        ds.loadUsers { usersErr in//closure 1 - loding users finished
            
            if let err = usersErr{
                SVProgressHUD.dismiss()
                ErrorAlert.show(message: err.localizedDescription)
                return
            }
            
            if self.ds.setLoggedUser() { //we have a logged user and also got it from the DB
                
                SVProgressHUD.showProgress(0.3)

                self.ds.loadData{ error in //colsure 2 - load all data done
                    if let error = error{
                        SVProgressHUD.dismiss()
                        ErrorAlert.show(message: error.localizedDescription)
                        return
                    }
                    
                    SVProgressHUD.showProgress(0.5)
                    
                    
                    MoneyConverter.shared.connect{
                        SVProgressHUD.showProgress(1)
                        self.openMain()
                    }//closue 3 - finished connecting to money api
                }
                
            }else{
                SVProgressHUD.dismiss()
                self.openLogin()
            }
        }
    }
    

    fileprivate func openLogin() {
        let login = newVC(storyBoardName: "UserLogin", id: "LoginVC")
        present(UINavigationController(rootViewController: login), animated: true)
    }
    
    
    func openMain() {
        SVProgressHUD.dismiss()
        show(newVC(id: "mainNav"), sender: nil)
    }
}
