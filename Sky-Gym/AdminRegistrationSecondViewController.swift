//
//  AdminRegistrationSecondViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class AdminRegistrationSecondViewController: UIViewController {
    
    @IBOutlet weak var genderTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var mobileNumberTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var dobTextField: UITextField?
    @IBOutlet weak var doneBtn: UIButton?
    @IBOutlet weak var genderErrorText: UILabel?
    @IBOutlet weak var emailErrorText: UILabel?
    @IBOutlet weak var mobileNumberErrorText: UILabel?
    @IBOutlet weak var passwordErrorText: UILabel?
    @IBOutlet weak var dobErrortext: UILabel?
    
    var gymName:String = ""
    var gymID:String = ""
    var gymAddress:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var id:String = ""
    var appDelegate :AppDelegate? = nil
    var selectedDate:Date? = nil
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDatePicker()
        self.setTextFields()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate = UIApplication.shared.delegate as? AppDelegate
    }
    
    @objc func errorChecker(_ textfield:UITextField)  {
           self.textFieldValidations(textField: textfield)
       }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        SVProgressHUD.show()
        FireStoreManager.shared.register(id: UUID().uuidString, gymID: AppManager.shared.gymID, adminDetail:self.getAdminData() as! [String:String], result: {
            err in
            SVProgressHUD.dismiss()
            if err != nil {
                self.showAlert(title: "Error", message: "Error in registering admin,please try again.")
            }else{
                self.showAlert(title: "Success", message: "Admin is registered successfully.")
            }
        })
    }
}

extension AdminRegistrationSecondViewController{
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
    func setDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.date = Date()
        toolBar.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar.sizeToFit()
    }
    
       @objc func cancelTextField()  {
           self.view.endEditing(true)
       }
    
    @objc func doneTextField()  {
        self.selectedDate = datePicker.date
        self.view.endEditing(true)
    }
    
    func setTextFields() {
         assignbackground()
               
               [genderTextField,emailTextField,mobileNumberTextField,passwordTextField,dobTextField].forEach{
                $0?.layer.cornerRadius = 15.0
                $0?.borderStyle = .none
                $0?.clipsToBounds = true
                $0?.addPaddingToTextField()
                $0?.addTarget(self, action: #selector(errorChecker(_:)), for: .editingChanged)
                           }
               doneBtn?.layer.cornerRadius = 15.0
               doneBtn?.clipsToBounds = true
    }
    
    func textFieldValidations(textField:UITextField) {
    switch textField.tag {
    case 1:
        if textField.text!.count < 1 {
            self.genderErrorText?.text = "Gender should be there."
        } else {
            self.genderErrorText?.text = ""
        }
        
    case 2:
        if textField.text!.count < 1 {
            self.emailErrorText?.text = "Email Address should be there."
        } else {
              if AppManager.shared.isEmailValid(email: (self.emailTextField?.text)!) {
                                      self.emailErrorText?.text = ""
                                  }
                                  else {
                                    self.emailErrorText?.text = "Incorrect Email Address"
                                  }
        }
        case 3:
        if textField.text!.count < 1 {
            self.mobileNumberErrorText?.text = "Mobile Number should be there."
        } else {
            self.mobileNumberErrorText?.text = ""
        }
    case 4:
        if textField.text!.count < 1 {
            self.passwordErrorText?.text = "Password should be there."
        } else {
            if AppManager.shared.isPasswordValid(text: (self.passwordTextField?.text)!) {
                self.passwordErrorText?.text = ""
            }
            else {
                self.passwordErrorText?.text = "Password should be greater than 8 characters."
            }
        }
    case 5:
        if textField.text!.count < 1 {
            self.dobErrortext?.text = "D.O.B. should be there."
        } else {
            self.dobErrortext?.text = ""
        }
        
    default:
        break
    }
      //  self.isAllTextFieldsValid()
        }
    
    func getAdminData() -> [String:Any] {
        let admin:[String:Any] =  [
            "dob":self.dobTextField?.text ?? "",
            "email":self.emailTextField?.text ?? "",
            "firstName":self.firstName,
            "lastName":self.lastName,
            "gender":self.genderTextField?.text ?? "",
            "gymAddress":self.gymAddress,
            "gymID":self.gymID,
            "gymName":self.gymName,
            "mobileNo":self.mobileNumberTextField?.text! ?? "",
            "password":self.passwordTextField?.text ?? ""
            ]
        
        return admin
    }

    func showAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "Ok", style: .default, handler: {
            _ in
            if alertController.title == "Success"{
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        })
         alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension AdminRegistrationSecondViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.textFieldValidations(textField: textField)
        
        if textField.tag == 5 && self.selectedDate != nil {
            textField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 5 {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 5 {
            textField.inputAccessoryView = self.toolBar
            textField.inputView = datePicker
        }
    }
}
