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
    
    @IBOutlet weak var openSettingBtn: UIButton!
    
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
        
        aboutTV.delegate2 = self
        
        levelTF.didSelectHandler = {self.levelChanged($0)}
        
        initTextFields(nameTF,birthDateTF)
        
        if let user = YUser.currentUser {
            currentUser = user
            fillFieldsFromUser()
        }
        
        if Locale.preferredLanguages.first?.starts(with: "he") ?? false{
            openSettingBtn.imageEdgeInsets =  .init(top: 0, left: 0, bottom: 0, right: -20)
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
        
        let confirmAlert = UIAlertController.create(title: "Sign out warning".translated,
                                             message: "confirmLogout".translated,
                                             preferredStyle: .alert)
        
            .aAction(.init(title: "Yes, bye.".translated,
                                             style: .default) { alert in
            
            //show alert - are you sure?!
            do{
                try Auth.auth().signOut()
                let loginVC = self.newVC(storyBoardName: "UserLogin", id: "LoginVC")
                let navC = UINavigationController(rootViewController: loginVC)
                navC.modalPresentationStyle = .fullScreen
                self.present(navC, animated: true)
                self.navigationController?.popViewController(animated: false)
            }catch{
                print(error)
            }
        })
            .aAction(UIAlertAction(title: "Cancel".translated, style: .cancel))
        
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
    @IBAction func openSettings(_ sender: UIButton) {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
        UIApplication.shared.canOpenURL(settingsUrl)
            else {return}
        
        UIApplication.shared.open(settingsUrl) { (success) in
            print("Settings opened: \(success)") // Prints true
        }
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
            
            UIAlertController.create(title: "Password reset".translated,
                                                 message: "emailSent".translated,
                                                 preferredStyle: .alert)
            
            .aAction(UIAlertAction(title: "ok".translated, style: .default))
            //MARK: check if he's signed
            .aAction(checkEmail)
            .show()
        }
    }
    
    func onImagePicked(image:UIImage?,url:URL?,removePicked:Bool) {
        let storage = StorageManager.shared
        
        if removePicked{
            profileImgView.image = #imageLiteral(resourceName: "camera")
            hasProfilePic = false
            storage.removeCurrentUserProfileImage(){
                if let err = $0 {
                    let msg = err.localizedDescription
                    switch err{
                    case let locErr as LocalizedError:
                        ErrorAlert.show(message: locErr.errorDescription ?? msg)
                    default :
                        ErrorAlert.show(message: msg)
                    }
                    return
                }
            }
            return
        }
        
        hasProfilePic = image != nil || url != nil
        if let img = image {
            storage.saveCurrentUser( profileImage: img)
            DispatchQueue.main.async{
                self.profileImgView.image = img
            }
            
        }else if let url = url{
            
            SVProgressHUD.show()
            
            storage.setImage(withUrl: url,imgView: profileImgView,
                           placeHolderImg:#imageLiteral(resourceName: "camera")){ err,image in
                
                SVProgressHUD.dismiss()
                
                if let err = err {
                    let msg = err.localizedDescription
                    switch err{
                    case let locErr as LocalizedError:
                        ErrorAlert.show(message: locErr.errorDescription ?? msg)
                    default :
                        ErrorAlert.show(message: msg)
                    }
                    return
                }
    
                storage.saveCurrentUser( profileImage: image)
            }
        }
    }
}
