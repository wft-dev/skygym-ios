//
//  ForgotPasswordViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 21/01/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class ForgotPasswordViewController: BaseViewController {
    
    @IBOutlet weak var resetPasswordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var verifyEmailBtn: UIButton!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordErrorLabel: UILabel!
    @IBOutlet weak var confirmaPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var resetPassword: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!

    var ID:String = ""
    var email:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        setForgotPasswordView()
        self.newPasswordTextField.isSecureTextEntry = true
        self.confirmPasswordTextField.isSecureTextEntry = true
    }
    
    override func assignbackground(){
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
    
    @IBAction func backBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func verifyEmailBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        SVProgressHUD.show()
        self.email = self.emailTextField.text!
        
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.isUserExistsWithID(email: self.email)
            
            DispatchQueue.main.async {
                switch result {
                    
                case let .success(userInfo):
                    let flag = userInfo?["exists"]  as! Bool
                    if flag == true {
                        self.ID = userInfo?["ID"] as! String
                        self.hideVerifyEmailContent(hide: true)
                        self.hideNewPasswordContent(hide: false)
                        SVProgressHUD.dismiss()
                    }else {
                        SVProgressHUD.dismiss()
                        self.ID = ""
                        self.showAlert(title: "Error", message: "User does not exists with this email address.")
                        self.emailTextField.text = ""
                    }
                    break
                case .failure(_):
                    SVProgressHUD.dismiss()
                    break
                }
            }
        }
    }
    
    @IBAction func resetPasswordBtnAction(_ sender: Any) {
        [emailTextField,newPasswordTextField,confirmPasswordTextField].forEach{
            self.allFieldsValidation(textField: $0)
        }
        if allFieldsValid() == true {
            DispatchQueue.global(qos: .background).async {
                let result = FireStoreManager.shared.isMemberWith(id: self.ID)
                DispatchQueue.main.async {
                    switch result {
                    case let .success(flag):
                        let encryptedPassword = AppManager.shared.encryption(plainText: self.confirmPasswordTextField.text!)
                        self.setPasswordFor(role: flag == true ? .Member : .Trainer, id: self.ID, password:encryptedPassword)
                    case .failure(_):
                        break
                    }
                }
            }
            self.resetPassword.isEnabled = true
            self.resetPassword.alpha = 1.0
        }else {
            self.resetPassword.isEnabled = false
            self.resetPassword.alpha = 0.4
        }
    }
    
    func setPasswordFor(role:Role,id:String,password:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.updateUserCredentials(id: id, email:self.email , password: password, handler: {
            (err) in
            
            if err == nil {
                FireStoreManager.shared.setPasswordFor(role: role, id: id, password: password, handler: {
                    (err) in
                    SVProgressHUD.dismiss()
                    if err != nil {
                        self.showAlert(title: "Error", message: "Password is not reset successfully.")
                    }else {
                       self.showAlert(title: "Success", message: "Password is reset successfully.")
                    }
                })
            }else {
                SVProgressHUD.dismiss()
            }
        })
    }
    
    func allFieldsValid() -> Bool {
        if  ValidationManager.shared.isAllFieldsRequiredValidated(textFieldArray: [newPasswordTextField,confirmPasswordTextField], phoneNumberTextField: nil) == true && ValidationManager.shared.isDuplicate(text1: self.newPasswordTextField.text!, text2: self.confirmPasswordTextField.text!) == true {
            return true
        }else {
            return false
        }
    }

    func hideVerifyEmailContent(hide:Bool) {
        [resetPasswordLabel,emailLabel,emailErrorLabel].forEach{
            $0?.isHidden = hide
            $0?.alpha = hide == false ? 1.0 : 0.0
        }
        self.emailTextField.isHidden = hide
        self.emailTextField.alpha = hide == false ? 1.0 : 0.0
        self.verifyEmailBtn.isHidden = hide
        self.verifyEmailBtn.alpha = hide == false ? 1.0 : 0.0
    }
    
    func showAlert(title:String,message:String) {
        let alertController =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
        _ in
            if title == "Success" {
                self.dismiss(animated: true, completion: nil)
            }
        })
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func hideNewPasswordContent(hide:Bool) {
        [newPasswordLabel,confirmaPasswordLabel,confirmPasswordErrorLabel,newPasswordErrorLabel].forEach{
            $0?.isHidden = hide
            $0?.alpha = hide == false ? 1.0 : 0.0
        }
        self.newPasswordTextField.isHidden = hide
        self.newPasswordTextField.alpha = hide == false ? 1.0 : 0.0
        self.confirmPasswordTextField.isHidden = hide
        self.confirmPasswordTextField.alpha = hide == false ? 1.0 : 0.0
        self.resetPassword.isHidden = hide
        self.resetPassword.alpha = hide == false ? 0.4 : 0.0
    }

    func setForgotPasswordView() {
        [emailTextField,newPasswordTextField,confirmPasswordTextField].forEach{
            $0?.layer.cornerRadius = 15.0
            $0?.borderStyle = .none
            $0?.addPaddingToTextField()
            $0?.backgroundColor = .white
            $0?.addTarget(self, action: #selector(errorChecker(_:)), for: .editingChanged)
        }
        
        [verifyEmailBtn,resetPassword].forEach{
            $0?.layer.cornerRadius = 15.0
            $0?.clipsToBounds = true
            $0?.isEnabled = false
            $0?.alpha = 0.4
        }
    }
    
    @objc func errorChecker(_ textfield:UITextField) {
        allFieldsValidation(textField: textfield)
    }
    
    func allFieldsValidation(textField:UITextField) {
        switch textField.tag {
        case 1:
            ValidationManager.shared.emailValidation(textField: textField, errorLabel: emailErrorLabel, errorMessage: "Invalid Email.")
            break
        case 2:
            ValidationManager.shared.passwordValidation(textField: textField, errorLabel: newPasswordErrorLabel, errorMessage: "Password must be greater than 8 characters.")
            break
        case 3:
            if  ValidationManager.shared.isDuplicate(text1: self.newPasswordTextField.text!, text2: textField.text!) == false {
                confirmPasswordErrorLabel.text = "Password did not matched."
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
                resetPassword.isEnabled = false
                resetPassword.alpha = 0.4
            }else {
                self.confirmPasswordErrorLabel.text = ""
                textField.borderStyle = .none
                textField.layer.borderColor = UIColor.clear.cgColor
                textField.layer.borderWidth = 0.0
                resetPassword.isEnabled = true
                resetPassword.alpha = 1.0
            }
        default:
            break
        }
        
        if textField.tag == 1 {
            if ValidationManager.shared.isEmailValid(email: textField.text!) {
                self.verifyEmailBtn.isEnabled = true
                self.verifyEmailBtn.alpha = 1.0
            }else {
                self.verifyEmailBtn.isEnabled = false
                self.verifyEmailBtn.alpha = 0.4
            }
        }
    }
    
}

extension ForgotPasswordViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.allFieldsValidation(textField: textField)
        ValidationManager.shared.loginBtnValidator(loginBtn: self.resetPassword, textFieldArray: [newPasswordTextField,confirmPasswordTextField], phoneNumberTextField: nil, email: nil, password: self.newPasswordTextField.text!)
    }
}
