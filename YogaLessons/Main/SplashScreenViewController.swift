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
        
//        start floating animation
        let animationOptions: UIView.AnimationOptions = [.repeat,.autoreverse,.curveEaseOut]
        UIView.animate(withDuration: 0.7, delay: 0, options: animationOptions,animations: {
                self.logoImg.transform = .init(translationX: 0, y: -20)
        })
        
        NotificationManager.shared.askForPermission { (granted) in
            DispatchQueue.main.async {
                self.startSetup()
            }
        }
        addReachabilityObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeReachabilityObserver()
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
        
        if Auth.auth().currentUser == nil{
            let login = newVC(storyBoardName: "UserLogin", id: "LoginVC")
            present(UINavigationController(rootViewController: login),
                         animated: true)
            return
        }
        
        let ds = DataSource.shared
        
        SVProgressHUD.show(withStatus: loadingLbl.text)
        ds.fetchLoggedUser(forceDownload: true) { (user, err) in
            if let err = err{
                SVProgressHUD.dismiss()
                let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
                
                ErrorAlert.show(message: msg)
                return
            }
            LocationUpdater.shared.getCurrentCountryCode() { code,LocErr in
               
                if let err = LocErr{
                    SVProgressHUD.dismiss()
                    let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
                    
                    ErrorAlert.show(message: msg)
                    return
                }
                MoneyConverter.shared.connect{
                    ds.loadData{ error in
                        SVProgressHUD.dismiss()
                        if let err = error{
                            let msg = (err as? LocalizedError)?.errorDescription ?? err.localizedDescription
                            ErrorAlert.show(message: msg)
                            return
                        }
                        
                        self.moveToMain()
                    }
                }
            }
        }
    }
    
    func moveToMain() {
        performSegue(withIdentifier: "splash", sender: nil)
    }
}

class SplashSegue: UIStoryboardSegue {
    override func perform() {
        guard let logoImg = (source as? SplashScreenViewController)?.logoImg
            else{super.perform()
                return}
        
        // Animate the transition.
        UIView.animate(withDuration: 1, animations: { () -> Void in
            let trans = logoImg.transform
            logoImg.transform =
                trans.scaledBy(x: 70, y: 70).concatenating(trans.translatedBy(x: 0, y: -100))
            logoImg.alpha = 0
            
        }) { didFinish -> Void in
            self.source.present(self.destination,animated: false)
        }
    }
}
