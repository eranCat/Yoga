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
    
    @IBOutlet weak var loadingLbl: PaddingLabel!
    
    @IBOutlet weak var logoImg: UIImageView!
    
    override func viewDidLoad() {
        navigationController?.isToolbarHidden = true
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat,.autoreverse,.curveEaseOut], animations: {
            
            self.logoImg.transform = .init(translationX: 0, y: -20)
        })
        
        NotificationManager.shared.askForPermission { (granted) in
            DispatchQueue.main.async {
                self.startSetup()
            }
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
        
        let ds = DataSource.shared
        
        ds.loadUsers { usersErr in//closure 1 - loding users finished
            
                if let err = usersErr{
                    SVProgressHUD.dismiss()
                    ErrorAlert.show(message: err.localizedDescription)
                    return
                }
                
                if ds.setLoggedUser() {
                    
                    LocationUpdater.shared.getCurrentCountryCode() { (code) in
                    
                        MoneyConverter.shared.connect{
                            ds.loadData{ error in
                                if let error = error{
                                    SVProgressHUD.dismiss()
                                    ErrorAlert.show(message: error.localizedDescription)
                                    return
                                }
                            
                                
                                SVProgressHUD.dismiss()
                                
                                self.show(self.newVC(id: "mainNav"), sender: nil)
                            }
                        }
                    }
                }else{
                    SVProgressHUD.dismiss()
                    
                    let login = self.newVC(storyBoardName: "UserLogin", id: "LoginVC")
                    self.present(UINavigationController(rootViewController: login),
                                 animated: true)
                }
            }
    }
}
