//
//  SignupViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 15/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignupViewController: UIViewController,TextFieldReturn {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var tf_name: UITextField!
    
    @IBOutlet weak var tf_email: UITextField!
    
    @IBOutlet weak var tf_pass: UITextField!
    
    @IBOutlet weak var tf_type: UserTypeTextField!
    
    @IBOutlet weak var tf_level: UserLevelField!
    
    @IBOutlet weak var tf_bDate: DateTextField!
    
    @IBOutlet weak var tv_about: BetterTextView!
    
    let typePicker = UIPickerView()
    let levelPicker = UIPickerView()
    
    lazy var imagePicker = {
        return MyImagePicker(){ image,url,removePicked in
            
            if removePicked{
                self.profileImage.image = #imageLiteral(resourceName: "camera")
                self.selectedPicture = nil
                return
            }
            
            
            if let img = image {
                DispatchQueue.main.async {
                    self.profileImage.image = img
                }
                self.selectedPicture = img
                
            }else if let url = url{
                DispatchQueue.main.async {
                    self.profileImage.sd_setImage(with: url) { (img, err, _, _) in
                        self.selectedPicture = img
                    }
                }
            }
        }
    }()
    var selectedPicture:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        tf_name.becomeFirstResponder()
        initTextFields(tf_name,tf_email,tf_pass)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return nextTxtField(textField)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        guard let (name,email,pass,type,level,bDate) = checkFields()
            else{return}
        
        SVProgressHUD.show()
        
        let about = !self.tv_about.isEmpty ? self.tv_about.text : nil
        
        let user = YUser(name: name,about: about, level: level, type: type, birthDate: bDate,email:email)
        
        
        //add user to authenticated users
        UsersManager.shared.createUser(withEmail: email, password: pass, user: user,
                                       profileImage: selectedPicture){[weak self](res, error) in
            
            if let error = error{
                SVProgressHUD.dismiss()
                ErrorAlert.show(message: error.localizedDescription)
                return
            }
            
            SVProgressHUD.dismiss()
            
            guard let self = self else{return}
            
//            self.dismiss(animated: true)
            
            self.show(self.newVC( id: "mainNav"), sender: nil)
        }
    }
    
    func checkFields() -> (String,String,String,UserType,Level,Date)? {
        guard let name = tf_name.text,!name.isEmpty else {
            self.tf_name.setError(message: "fill".translated + "yname".translated)
            return nil
        }
        
        guard let email = tf_email.text,!email.isEmpty else {
            self.tf_email.setError(message: "fillEmail".translated)
            return nil
        }
        
        guard let pass = tf_pass.text,!pass.isEmpty else {
            self.tf_pass.setError(message: "fillPass".translated)
            return nil
        }
        
        guard let bDate = tf_bDate.date
            else {
                tf_bDate.setError(message: "fill".translated +  "birth date".translated)
                return nil
        }
        
        guard !(tf_type.text?.isEmpty ?? false),
                let type = tf_type.type
            else {
                tf_type.setError(message: "fill".translated + "userType".translated)
                return nil
        }
        
        guard let level = tf_level.level
            else {
                tf_level.setError(message: "fill".translated + "level of".translated)
                return nil
        }
        
        
        return (name,email,pass,type,level,bDate)
    }
    
    @IBAction func camTap(_ sender: UITapGestureRecognizer) {
        
        self.imagePicker.show(hasImage: selectedPicture != nil)
    }
}
