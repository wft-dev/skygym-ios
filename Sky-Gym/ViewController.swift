//
//  ViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 23/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registrationBtn: UIButton?
    @IBOutlet weak var memberLoginBtn: UIButton?
    @IBOutlet weak var emailErrorLabel: UILabel?
    @IBOutlet weak var passwordErrorLabel: UILabel?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground()
        self.setLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.emailTextField?.text = ""
        self.passwordTextField?.text = ""
    }
    
    
    @objc func errorChecker(_ textfield:UITextField)  {
        switch textfield.tag {
        case 1:
            if textfield.text!.count < 1 {
                self.emailErrorLabel?.text = "Empty Field"
            }
            else {
                if AppManager.shared.isEmailValid(email: (self.emailTextField?.text)!) {
                    self.emailErrorLabel?.text = ""
                }
                else {
                    self.emailErrorLabel?.text = "Incorrect Email Address"
                }
            }
        case 2:
            if textfield.text!.count < 1 {
                self.passwordErrorLabel?.text = "Empty Field"
            }
            else {
                if AppManager.shared.isPasswordValid(text: (self.passwordTextField?.text)!) {
                    self.passwordErrorLabel?.text = ""
                }
                else {
                    self.passwordErrorLabel?.text = "Password should be greater than 8 characters."
                }
            }
        default:
            break
        }
  
        if AppManager.shared.isPasswordValid(text: (self.passwordTextField?.text)!) && AppManager.shared.isEmailValid(email: (self.emailTextField?.text)!){
               self.loginBtn.isEnabled = true
               self.loginBtn.alpha = 1.0
           }
           else {
               self.loginBtn.isEnabled = false
               self.loginBtn.alpha = 0.5
           }
       }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        FireStoreManager.shared.isAdminLogin(email: (self.emailTextField?.text)!, password: (self.passwordTextField?.text)!, result: {
            (loggedIn,err) in
            
            if err != nil {
                self.showLoginAlert(title: "Error", message: "Error in finding admin, due to network connectivity.")
            } else {
                if loggedIn == true{
                    AppManager.shared.performLogin()
                }else {
                    self.showLoginAlert(title: "Error", message: "Username or Password is incorrect.")
                }
            }
            
        })
    }
    
    @IBAction func registrationBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "registrationSegue", sender: nil)
    }
    
    @IBAction func memberLoginBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "memberLoginSegue", sender: nil)
    }
}

extension UITextField {
    func addPaddingToTextField() {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.leftView = paddingView;
        self.leftViewMode = .always;
        self.rightView = paddingView;
        self.rightViewMode = .always;
        self.backgroundColor = UIColor.white
        self.textColor = UIColor.black
    }
    func addPaddingToTextField(height:CGFloat,Width:CGFloat) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: Width, height: height))
        self.leftView = paddingView;
        self.leftViewMode = .always;
        self.rightView = paddingView;
        self.rightViewMode = .always;
        self.backgroundColor = UIColor.white
        self.textColor = UIColor.black
    }
}

extension UITextView{
    func addPaddingToTextField() {
       // let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.contentInset = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
    }
    func addPaddingToTextView(top:CGFloat,right:CGFloat,bottom:CGFloat,left:CGFloat) {
          // let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
           self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
       }
}

extension ViewController {
       
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
    
       func setUnderLineText(text:String) {
           let underlineAttribute: [NSAttributedString.Key: Any] = [
               .underlineStyle: 1.0]
           
           let underlineAttributedString = NSMutableAttributedString(string: text, attributes: underlineAttribute)
           
        self.registrationBtn?.setAttributedTitle(underlineAttributedString, for: .normal)
       }
    
    func setLoginView() {
        [emailTextField,passwordTextField].forEach{
            $0?.layer.cornerRadius = 15.0
            $0?.borderStyle = .none
            $0?.clipsToBounds = true
            $0?.addPaddingToTextField()
            $0?.addTarget(self, action: #selector(errorChecker(_:)), for: .editingChanged)
        }
        
        loginBtn?.layer.cornerRadius = 15.0
        loginBtn?.clipsToBounds = true
        memberLoginBtn?.layer.cornerRadius = 8.0
        memberLoginBtn?.clipsToBounds = true
        setUnderLineText(text: "Registration")
    }
    
    func showLoginAlert(title:String,message:String) {
         let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
         let okAlertAction = UIAlertAction(title: "Ok", style: .default, handler:nil)
          alertController.addAction(okAlertAction)
         present(alertController, animated: true, completion: nil)
     }

}
