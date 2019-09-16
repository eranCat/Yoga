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
import FirebaseAuth

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
        
        
        if Auth.auth().currentUser == nil{
            let login = newVC(storyBoardName: "UserLogin", id: "LoginVC")
            present(UINavigationController(rootViewController: login),
                         animated: true)
            return
        }
        
        let ds = DataSource.shared
        
        ds.fetchLoggedUser(forceDownload: true) { (user, err) in
            if let err = err{
                SVProgressHUD.dismiss()
                let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
                
                ErrorAlert.show(message: msg)
                return
            }
            LocationUpdater.shared.getCurrentCountryCode() { (code) in
                MoneyConverter.shared.connect{
                    ds.loadData{ error in
                        SVProgressHUD.dismiss()
                        if let err = error{
                            let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
                            ErrorAlert.show(message: msg)
                            return
                        }
                        
                        self.show(self.newVC(id: "mainNav"), sender: nil)
                    }
                }
            }
        }
    }
    
    /*let ds = DataSource.shared
     ds.loadUsers { usersErr in//closure 1 - loding users finished
     
     if let err = usersErr{
     SVProgressHUD.dismiss()
     let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
     ErrorAlert.show(message: msg)
     return
     }
     
     if ds.setLoggedUser() {
     
     LocationUpdater.shared.getCurrentCountryCode() { _ in
     
     MoneyConverter.shared.connect{
     ds.loadData{ error in
     
     SVProgressHUD.dismiss()
     if let err = error{
     let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
     ErrorAlert.show(message: msg)
     return
     }
     
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
     }*/
}
