//
//  LoginViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController,TextFieldReturn {
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var mainStack: UIStackView!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var signupBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        UINavigationBar.appearance().tintColor = ._btnTint
        
        email.becomeFirstResponder()
        
        initTextFields(email,password)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.titleLbl.alpha = 0
        
        for (i,v) in mainStack.arrangedSubviews.enumerated(){
            v.transform = .init(translationX: (i%2 == 0 ? 1 : -1)*view.bounds.width, y: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        typealias UV = UIView
        
        UV.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.titleLbl.alpha = 1
        })
        
        
        UV.animateToIdentity(views: mainStack.arrangedSubviews,duration: 1)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === password{
            login()
        }
        
        return nextTxtField(textField)
    }
    
    @IBAction func LoginTapped(_ sender: UIButton) {
        login()
    }
    
    
    func checkFields() -> (String,String)? {
        guard let email = self.email.text,!email.isEmpty
            else{
                self.email.setError(message: "fillEmail".translated)
                return nil
        }
        guard let pass = self.password.text,!pass.isEmpty
            else{
                self.password.setError(message: "fillPass".translated)
                return nil
        }
        
        return (email,pass)
    }
    
    func login() {
        guard let (email,pass) = checkFields() else{return}
        
        loginBtn.isEnabled = false
        SVProgressHUD.show()
        
        Auth.auth()
            .signIn(withEmail: email, password: pass) { (res, err) in
                
                if let error = err{
                    ErrorAlert.show(message: error.localizedDescription)
                    SVProgressHUD.dismiss()
                }else{
                    let ds = DataSource.shared
                    
                    ds.fetchLoggedUser(forceDownload: true){ user,err in
                        guard user != nil else{
                            SVProgressHUD.dismiss()
                            if let err = err{
                                ErrorAlert.show(message: err.localizedDescription)
                            }
                            return
                        }
                        
                        //reload all date by new logged user
                        ds.loadData(){ err in
                            SVProgressHUD.dismiss()
                            
                            if let err = err{
                                ErrorAlert.show(message: err.localizedDescription)
                                return
                            }
                            self.show(self.newVC(id: "mainNav"), sender: nil)
                        }
                    }
                }
                self.loginBtn.isEnabled = true
                
        }
    }
    
    fileprivate func showProggressView() {
        let progress = UIProgressView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        
        view.addSubview(progress)
        
        progress.center = view.center
        view.layoutIfNeeded()
    }
}
