//
//  MemberAndTrainerLoginViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class MemberAndTrainerLoginViewController: UIViewController {

    @IBOutlet weak var gymIDTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var gymIDErrroText: UILabel?
    @IBOutlet weak var emailErrorText: UILabel?
    @IBOutlet weak var passwordErrorText: UILabel?
    @IBOutlet weak var loginBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gymIDTextField?.text = "1221"
        emailTextField?.text = "trainer2@gmail.com"
        passwordTextField?.text = ""
        
        self.assignbackground()
        loginBtn?.isEnabled = false
        loginBtn?.alpha = 0.4
        [gymIDTextField,emailTextField,passwordTextField].forEach{
                   $0?.layer.cornerRadius = 15.0
                   $0?.borderStyle = .none
                   $0?.clipsToBounds = true
                   $0?.addTarget(self, action: #selector(fieldErrorChecker(_:)), for: .editingChanged)
                   $0?.addPaddingToTextField()
               }
        loginBtn?.layer.cornerRadius = 15.0
        loginBtn?.clipsToBounds = true
        
        self.loginBtn?.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
    }
    
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        performSegue(withIdentifier: "forgotPasswordSegue", sender: nil)
    }

    func assignbackground(){
              let background = UIImage(named: "Bg_yel.png")
              var imageView : UIImageView!
              imageView = UIImageView(frame: view.bounds)
              imageView.contentMode =  UIView.ContentMode.scaleToFill
              imageView.clipsToBounds = true
              imageView.image = background
              imageView.center = view.center
              view.addSubview(imageView)
              self.view.sendSubviewToBack(imageView)
          }
    
    @objc func fieldErrorChecker(_ textField:UITextField) {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.gymIDErrroText!, errorMessage: "Gym ID required.")
        case 2:
            ValidationManager.shared.emailValidation(textField: textField, errorLabel: self.emailErrorText!, errorMessage: "Invalid email address.")
        case 3:
            ValidationManager.shared.passwordValidation(textField: textField, errorLabel: self.passwordErrorText!, errorMessage: "Password must be greater than 8 characters.")
        default:
            break
        }
        ValidationManager.shared.loginBtnValidator(loginBtn: self.loginBtn!, textFieldArray: [self.gymIDTextField!], phoneNumberTextField: nil, email: self.emailTextField?.text!, password: self.passwordTextField?.text!)
    }
    
    @objc  func loginAction()  {
        SVProgressHUD.show()
        let email = self.emailTextField?.text!
        let gymID = self.gymIDTextField?.text!
        let password = self.passwordTextField?.text!
        
        DispatchQueue.global(qos: .background).async {
            let flag =  FireStoreManager.shared.isMember(email: email!, gymID: gymID!)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                switch flag {
                case  let .success(sagar):
                    self.memberOrTrainerLoginAction(role: sagar == true ? .Member : .Trainer, email: email!, gymID: gymID!, password: password!)
                case  .failure(_):
                    self.alerMessage(title: "Error", Message: "Username or Password is incorrect.")
                }
            }
        }
    }
    
    func alerMessage(title:String,Message:String) {
        let alertController = UIAlertController(title: title, message: Message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func memberOrTrainerLoginAction(role:Role,email:String,gymID:String,password:String) {
        let colletionString = AppManager.shared.getRole(role: role)
        FireStoreManager.shared.trainerOrMemberLogin(collectionPath: colletionString, gymID: gymID, email: email, password: password, result: {
            (loggedIn,err) in
            
            if err != nil {
                print("Error in loggin")
            }else {
                if loggedIn == true {
                    AppManager.shared.performLogin()
                }else{
                    self.alerMessage(title: "Error", Message: "Username or Password is incorrect.")
                }
            }
        })
    }
 
}

extension MemberAndTrainerLoginViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.fieldErrorChecker(textField)
        ValidationManager.shared.loginBtnValidator(loginBtn: self.loginBtn!, textFieldArray: [self.gymIDTextField!], phoneNumberTextField: nil, email: self.emailTextField?.text!, password: self.passwordTextField?.text!)
    }
}
