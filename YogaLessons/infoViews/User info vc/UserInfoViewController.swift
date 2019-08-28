//
//  UserInfoViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 20/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class UserInfoViewController: UIViewController {
    
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var levelTF: UserLevelField!
    
    @IBOutlet weak var birthDateTF: DateTextField!
    
    @IBOutlet weak var aboutTV: BetterTextView!
    
    
    lazy var hasProfilePic:Bool = {
        return self.currentUser.profileImageUrl != nil
    }()
    
    var currentUser:YUser!
    
    let dataSource = DataSource.shared
    lazy var imagePicker = MyImagePicker(completion: onImagePicked(image:url:removePicked:))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.contents = #imageLiteral(resourceName: "flower").cgImage
//        view.backgroundColor = .init(patternImage: UIImage(named: "infoBG")!)
        
        for v in view.subviews{
            if let scrollView = v as? UIScrollView{
                scrollView.keyboardDismissMode = .onDrag
                break
            }
        }
        
        navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.2615792751, green: 0.2857673466, blue: 0.6650569439, alpha: 1)
        
        aboutTV.delegate2 = self
        
        levelTF.didSelectHandler = {self.levelChanged($0)}
        
        initTextFields(nameTF,birthDateTF)
        
        if let user = YUser.currentUser {
            currentUser = user
            fillFieldsFromUser()
        }
    }
    
    
    
    private func fillFieldsFromUser() {
        
        StorageManager.shared.setProfileImage( imgView: profileImgView)
        
        navigationItem.title = currentUser.name
        
        nameTF.text = currentUser.name
        
        levelTF.set(level: currentUser.level)
        
        birthDateTF.date = currentUser.bDate
        
        aboutTV.text = currentUser.about
    }
    
    @IBAction func signoutTapped(_ sender: UIBarButtonItem) {
        
        let confirmAlert = UIAlertController(title: "Sign out warning".translated,
                                             message: "confirmLogout".translated,
                                             preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes, bye.".translated,
                                             style: .default) { alert in
            
            //show alert - are you sure?!
            do{
                try Auth.auth().signOut()
                let loginVC = self.newVC(storyBoardName: "UserLogin", id: "LoginVC")
                self.present(UINavigationController(rootViewController: loginVC), animated: true)
                self.navigationController?.popViewController(animated: false)
            }catch{
                print(error)
            }
        })
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel".translated, style: .cancel))
        
        present(confirmAlert, animated: true)
    }
    
    @IBAction func camTap(_ sender: UITapGestureRecognizer) {
        
        self.imagePicker.show(hasImage: hasProfilePic)
    }
    
    
    @IBAction func nameChanged(_ sender: UITextField) {
        //sender
        guard let name = nameTF.text,!name.isEmpty else {
            self.nameTF.setError(message: "fill".translated + "yname".translated)
            return
        }
        guard name != currentUser.name else{return}
        
        navigationItem.title = name
        
        dataSource.updateCurrentUserValue(forKey: .name, name)
    }
    
    func levelChanged(_ level:Level?) {
        guard let level = level else {
            self.levelTF.setError(message: "fill".translated + "level".translated)
            return
        }
        guard level != currentUser.level else{return}
        
        dataSource.updateCurrentUserValue(forKey: .level, level.rawValue)
    }
    
    @IBAction func birthDateChanged(_ sender: DateTextField) {
        
        guard let bDate = birthDateTF.date else {
            birthDateTF.setError(message: "fill".translated + "birth date".translated)
            return
        }
        
        guard bDate != currentUser.bDate else{return}
        
        dataSource.updateCurrentUserValue(forKey: .bDate, bDate)
    }
    
    @IBAction func resetPasswordWithEmail(_ sender: UIButton) {
        
        sender.isEnabled = false
        SVProgressHUD.show()
        UsersManager.shared.sendResetPassword(){ error in
            
            SVProgressHUD.dismiss()
            sender.isEnabled = true
            
            let alert = UIAlertController(title: "Password reset".translated,
                                          message: "emailSent".translated,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ok".translated, style: .default))
            
            let checkEmail = UIAlertAction(title: "Check email".translated, style: .default) { _ in
                
                let userEmail = Auth.auth().currentUser?.email
                
                guard let appURL = URL(string: "mailto:" + (userEmail ?? "BLAH@BLAH.COM"))
                    else{return}
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appURL as URL)
                }
                else {
                    UIApplication.shared.openURL(appURL as URL)
                }
            }
            //MARK: check if he's signed
            alert.addAction(checkEmail)
            
            
            self.present(alert, animated: true)
        }
    }
    
    func onImagePicked(image:UIImage?,url:URL?,removePicked:Bool) {
        if removePicked{
            self.profileImgView.image = #imageLiteral(resourceName: "camera")
            self.hasProfilePic = false
            StorageManager.shared.removeCurrentUserProfileImage(){
                print("image removed")
            }
            return
        }
        self.hasProfilePic = image != nil || url != nil
        if let img = image {
            StorageManager.shared.saveCurrentUser( profileImage: img)
            DispatchQueue.main.async{
                self.profileImgView.image = img
            }
            
        }else if let url = url{
            
            SVProgressHUD.show()
            
            StorageManager.shared.setImage(withUrl: url, imgView: self.profileImgView,placeHolderImg:UIImage(named:"camera")){ sd_img,err,_ in
                
                SVProgressHUD.dismiss()
                
                if err == nil{
                    StorageManager.shared.saveCurrentUser( profileImage: sd_img)
                }
            }
        }
    }
}
