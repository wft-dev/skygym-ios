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
    
    private lazy  var datePicker:UIDatePicker = {
        return UIDatePicker()
    }()
    
    private lazy var genderPickerView:UIPickerView = {
        return UIPickerView()
    }()
    
    var gymName:String = ""
    var gymID:String = ""
    var gymAddress:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var id:String = ""
    var appDelegate :AppDelegate? = nil
    var selectedDate:Date? = nil
    var toolBar:UIToolbar? = nil
    var isAlreadyExistsEmail:Bool = false
    var textFieldArray:[UITextField] = []
    let genderArray = ["Male","Female","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
        self.textFieldArray = [self.genderTextField!,self.emailTextField!,self.mobileNumberTextField!,self.passwordTextField!,self.dobTextField!]
        self.setDatePicker()
        self.setTextFields()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate = UIApplication.shared.delegate as? AppDelegate
    }
    
    @objc func errorChecker(_ textfield:UITextField)  {
           self.allFieldValidation(textField: textfield)
       }
    
    func allDataValid() -> Bool {
        
        if ValidationManager.shared.isAllFieldsRequiredValidated(textFieldArray: self.textFieldArray, phoneNumberTextField: self.mobileNumberTextField) == true && ValidationManager.shared.isEmailValid(email: (self.emailTextField?.text)!) == true && ValidationManager.shared.isPasswordValid(password: (self.passwordTextField?.text)!) == true {
           
            if self.isAlreadyExistsEmail == true {
                self.emailTextField?.layer.borderColor = UIColor.red.cgColor
                self.emailTextField?.layer.borderWidth = 1.0
                self.emailErrorText?.text = "Email already exists."
                return false
            }else{
                self.emailTextField?.layer.borderColor = UIColor.clear.cgColor
                self.emailTextField?.layer.borderWidth = 0.0
                self.emailTextField?.borderStyle = .none
                self.emailErrorText?.text = ""
                return true
            }
            
        }else {
            return false
        }
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        SVProgressHUD.show()
        DispatchQueue.main.async {
            for textField in self.textFieldArray {
                self.allFieldValidation(textField: textField)
            }
        }

        if allDataValid() == true && self.isAlreadyExistsEmail == false {
            FireStoreManager.shared.register(id: UUID().uuidString, gymID: AppManager.shared.gymID, adminDetail:self.getAdminData() as! [String:String], result: {
                err in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.showAlert(title: "Error", message: "Error in registering admin,please try again.")
                }else{
                    self.showAlert(title: "Success", message: "Admin is registered successfully.")
                }
            })
        }else {
                SVProgressHUD.dismiss()
            if self.isAlreadyExistsEmail == true {
                self.emailTextField?.layer.borderColor = UIColor.red.cgColor
                self.emailTextField?.layer.borderWidth = 1.0
                self.emailErrorText!.text = "Email already exists."
            }
                self.doneBtn!.isEnabled = false
                self.doneBtn!.alpha = 0.4
        }
    }
    
    func allFieldValidation(textField:UITextField) {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.genderErrorText!, errorMessage: "Gender required.")
        case 2:
            ValidationManager.shared.emailValidation(textField: textField, errorLabel: self.emailErrorText!, errorMessage: "Invalid Email.")
        case 3:
            ValidationManager.shared.phoneNumberValidation(textField: textField, errorLabel: self.mobileNumberErrorText!, errorMessage: "Phone no must be 10 digit only.")
        case 4:
            ValidationManager.shared.passwordValidation(textField: textField, errorLabel: self.passwordErrorText!, errorMessage: "Password must be greater than 8 Characters.")
        case 5 :
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.dobErrortext!, errorMessage: "D.O.B. reauired.")
        default:
            break
        }
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
    
    func setDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.date = Date()
        toolBar?.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar?.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar?.sizeToFit()
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
        doneBtn?.isEnabled = false
        doneBtn?.alpha = 0.4
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
            "password":AppManager.shared.encryption(plainText: (self.passwordTextField?.text)!) 
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.allFieldValidation(textField: textField)
        
        if textField.tag == 5 && self.selectedDate != nil {
            textField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
            DispatchQueue.main.async {
                self.allFieldValidation(textField: textField)
            }
        }
        
        if textField.tag == 2 {
            let email = textField.text!
            DispatchQueue.global(qos: .background).async {
                let result = FireStoreManager.shared.isUserExists(email: email)
                
                DispatchQueue.main.async {
                    switch result {
                    case let .success(flag):
                        if flag == false {
                            textField.borderStyle = .none
                            self.isAlreadyExistsEmail = false
                            self.doneBtn!.isEnabled = true
                            self.doneBtn!.alpha = 1.0
                        }else {
                            textField.layer.borderColor = UIColor.red.cgColor
                            textField.layer.borderWidth = 1.0
                            self.emailErrorText!.text = "Email already exists."
                            self.isAlreadyExistsEmail = true
                            self.doneBtn!.isEnabled = false
                            self.doneBtn!.alpha = 0.4
                        }

                    case .failure(_):
                        break
                    }
                }
                
            }
        }
        
        if textField.tag == 1 && textField.text == "" {
            textField.text = self.genderArray.first
            DispatchQueue.main.async {
                self.allFieldValidation(textField: self.genderTextField!)
            }
        }
        
        ValidationManager.shared.updateBtnValidator(updateBtn: self.doneBtn!, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.mobileNumberTextField, email: self.emailTextField?.text, password: self.passwordTextField?.text)
        
        DispatchQueue.main.async {
            if self.isAlreadyExistsEmail == true {
                self.emailTextField?.layer.borderColor = UIColor.red.cgColor
                self.emailTextField?.layer.borderWidth = 1.0
                self.emailErrorText!.text = "Email already exists."
                self.doneBtn!.isEnabled = false
                self.doneBtn!.alpha = 0.4
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 5 || textField.tag == 1 {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 1:
            textField.inputView = self.genderPickerView
        case 5:
            textField.inputAccessoryView = self.toolBar
            textField.inputView = datePicker
        default:
            break
        }
        
    }
}

extension AdminRegistrationSecondViewController:UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genderArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderArray[row]
    }
    
}

extension AdminRegistrationSecondViewController:UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField?.text = self.genderArray[row]
        DispatchQueue.main.async {
            self.allFieldValidation(textField: self.genderTextField!)
        }
    }
    
}
