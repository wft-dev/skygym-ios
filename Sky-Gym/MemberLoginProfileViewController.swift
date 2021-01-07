//
//  MemberLoginProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 05/01/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class MemberLoginProfileViewController: UIViewController {
    
    @IBOutlet weak var memberLoginProfileCustomNavigationbarView: CustomNavigationBar!
    
    @IBOutlet weak var memberProfileImg: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNoErrorLabel: UILabel!
    @IBOutlet weak var dobErrorLabel: UILabel!
    
    @IBOutlet weak var updateBtn: UIButton!
    
    @IBOutlet weak var firstNameNonEditLabel: UILabel!
    @IBOutlet weak var lastNameNonEditLabel: UILabel!
    @IBOutlet weak var firstNameHrLineView: UIView!
    @IBOutlet weak var genderNonEditLabel: UILabel!
    @IBOutlet weak var passwordNonEditLabel: UILabel!
    @IBOutlet weak var genderHrLineView: UIView!
    @IBOutlet weak var emailNonEditLabel: UILabel!
    @IBOutlet weak var emailHrLineView: UIView!
    @IBOutlet weak var phoneNoNonEditLabel: UILabel!
    @IBOutlet weak var dobNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoHrLineView: UIView!
    
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    
    var textFieldArray:[UITextField] = []
    var errorLabelsArray:[UILabel] = []
    var hrLineViewArray:[UIView] = []
    var defaultLabelArray:[UILabel] = []
    let validator = ValidationManager.shared
    var isEditable:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldArray = [ self.firstNameTextField,self.lastNameTextField,self.genderTextField,self.passwordTextField,self.emailTextField,self.phoneNumberTextField,self.dobTextField ]
        self.errorLabelsArray = [ self.firstNameErrorLabel,self.lastNameErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.emailErrorLabel,self.phoneNoErrorLabel,self.dobErrorLabel ]
        self.hrLineViewArray = [ self.firstNameHrLineView,self.genderHrLineView,self.emailHrLineView,self.phoneNoHrLineView ]
        self.defaultLabelArray = [ self.firstNameLabel,self.lastNameLabel,self.genderLabel,self.passwordLabel,self.emailLabel,self.phoneNoLabel,self.dobLabel ]
        
        self.setMemberLoginProfileCustomNavigationbar()
        self.setMemberProfileTextFields()
        
        AppManager.shared.performEditAction(dataFields: self.getDataDir(), edit: false)
        self.setMemberHrLineView(hide: false)
        self.hideErrorLabels(hide: true)
        self.labelColor(color: .lightGray)
        self.updateBtn.isHidden = true
        self.updateBtn.alpha = 0.0
        
        
        
    }
    
    func setMemberLoginProfileCustomNavigationbar() {
        self.memberLoginProfileCustomNavigationbarView.navigationTitleLabel.text = "Profile"
        self.memberLoginProfileCustomNavigationbarView.searchBtn.isHidden = true
        self.memberLoginProfileCustomNavigationbarView.searchBtn.alpha = 0.0
        self.memberLoginProfileCustomNavigationbarView.editBtn.isHidden = false
        self.memberLoginProfileCustomNavigationbarView.editBtn.alpha = 1.0
        self.memberLoginProfileCustomNavigationbarView.editBtn.addTarget(self, action: #selector(makeProfileEditable), for: .touchUpInside)
    }
    
    @objc func makeProfileEditable(){
        self.isEditable = !self.isEditable
        AppManager.shared.performEditAction(dataFields: self.getDataDir(), edit: self.isEditable)
        self.setMemberHrLineView(hide: self.isEditable)
        self.hideErrorLabels(hide: self.isEditable)
        self.labelColor(color: self.isEditable ? .black : .lightGray)
        self.updateBtn.isHidden = !self.isEditable
        self.updateBtn.alpha = self.isEditable == true ?  1.0 : 0.0   
    }
    
    func getDataDir() -> [UITextField:UILabel] {
        let dir = [
            self.firstNameTextField! : self.firstNameNonEditLabel!,
            self.lastNameTextField! : self.lastNameNonEditLabel!,
            self.genderTextField! : self.genderNonEditLabel!,
            self.phoneNumberTextField! : self.phoneNoNonEditLabel!,
            self.emailTextField! : self.emailNonEditLabel!,
            self.passwordTextField! : self.passwordNonEditLabel!,
            self.dobTextField! : self.dobNonEditLabel!
        ]
        return dir
    }
    func setMemberHrLineView(hide:Bool) {
        self.hrLineViewArray.forEach{
            $0.isHidden = hide
            $0.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func hideErrorLabels(hide:Bool)  {
        self.errorLabelsArray.forEach{
            $0.isHidden = hide
            $0.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func labelColor(color:UIColor) {
        self.defaultLabelArray.forEach{
            $0.textColor = color
        }
    }
    
    func setMemberProfileTextFields() {
        self.textFieldArray.forEach{
            self.addPaddingToTextField(textField: $0)
            $0.layer.cornerRadius = 7.0
            $0.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0.clipsToBounds = true
            $0.addTarget(self, action: #selector(errorValidator(_:)), for: .editingChanged)
        }
        self.updateBtn.layer.cornerRadius = 15.0
        self.updateBtn.layer.borderColor = UIColor.black.cgColor
        self.updateBtn.layer.borderWidth = 0.7
        self.updateBtn.clipsToBounds = true
    }
    
    func addPaddingToTextField(textField:UITextField) {
           let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
           textField.leftView = paddingView
           textField.leftViewMode = .always
           textField.backgroundColor = UIColor.white
           textField.textColor = UIColor.black
       }
    
    @objc func errorValidator(_ textField:UITextField) {
        self.allMemberFieldValidation(textField: textField)
    }
    
    func allMemberFieldValidation(textField:UITextField) {
        switch textField.tag {
        case 1:
            self.validator.requiredValidation(textField: textField, errorLabel: self.firstNameErrorLabel, errorMessage: "First Name required.")
            break
        case 2:
            self.validator.requiredValidation(textField: textField, errorLabel: self.lastNameErrorLabel, errorMessage: "Last Name required.")
            break
        case 3:
            self.validator.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "gender required.")
            break
        case 4:
            self.validator.passwordValidation(textField: textField, errorLabel: self.passwordErrorLabel, errorMessage: "Password must be greater than 8 characters.")
            break
        case 5:
            self.validator.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Invalid Email")
            break
        case 6:
            self.validator.phoneNumberValidation(textField: textField, errorLabel: self.phoneNoErrorLabel, errorMessage: "Phone number must be 10 digits only.")
        case 7 :
            self.validator.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required.")
        default:
            break
        }
    }

}
