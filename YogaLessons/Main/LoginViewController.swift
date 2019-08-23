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
    
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        email.becomeFirstResponder()
        
        initTextFields(email,password)
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
                self.email.setError(message: "Please fill in your email.")
                return nil
        }
        guard let pass = self.password.text,!pass.isEmpty
            else{
                self.password.setError(message: "Please fill in your password.")
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
                }else{
                    DataSource.shared.setLoggedUser()
                    self.show(self.newVC(id: "mainNav"), sender: nil)
                }
                self.loginBtn.isEnabled = true
                
                SVProgressHUD.dismiss()
        }
    }

    
    fileprivate func showProggressView() {
        let progress = UIProgressView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        
        view.addSubview(progress)
        
        progress.center = view.center
        view.layoutIfNeeded()
    }
}
