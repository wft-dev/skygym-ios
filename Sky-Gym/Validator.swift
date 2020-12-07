//
//  Validator.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 26/11/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import UIKit


class ValidationManager: NSObject {
    static let shared:ValidationManager = ValidationManager()
    private override init() {}
     
    func isTextViewRequiredValid(textView:UITextView) -> Bool {
        return textView.text!.count > 0 ? true : false
    }
    
    func isAllFieldsRequiredValidated(textFieldArray:[UITextField],phoneNumberTextField:UITextField?) -> Bool {
        var flag:Bool = false
        
        if phoneNumberTextField != nil  {
            validatorLoop: for textField in textFieldArray{
                if  textField.text!.count > 0 {
                    flag = phoneNumberTextField?.text?.count  == 10 ? true : false
                }else {
                    flag = false
                    break validatorLoop
                }
            }
        } else {
            validatorLoop: for textField in textFieldArray{
                if  textField.text!.count > 0 {
                    flag = true
                }else {
                    flag = false
                    break validatorLoop
                }
            }
        }
        return flag
    }

    func isEmailValid(email:String) -> Bool {
        return AppManager.shared.isEmailValid(email: email) ? true : false
    }
    func isPasswordValid(password:String) -> Bool {
        return AppManager.shared.isPasswordValid(text: password) ? true : false
    }

    func requiredValidation(textField:UITextField,errorLabel:UILabel,errorMessage:String)  {
        if textField.text!.count > 0 {
            errorLabel.text = ""
            textField.borderStyle = .none
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0.0
        } else {
            errorLabel.text = errorMessage
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1.0
        }
    }
    
    func phoneNumberValidation(textField:UITextField,errorLabel:UILabel,errorMessage:String)  {
        if textField.text!.count == 10 {
            errorLabel.text = ""
            textField.borderStyle = .none
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0.0
        } else {
            errorLabel.text = errorMessage
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1.0
        }
    }
    
    func emailValidation(textField:UITextField,errorLabel:UILabel,errorMessage:String) {
        if textField.text!.count > 0 {
            if AppManager.shared.isEmailValid(email: textField.text!){
                errorLabel.text = ""
                textField.borderStyle = .none
                textField.layer.borderColor = UIColor.clear.cgColor
                textField.layer.borderWidth = 0.0
            } else{
                errorLabel.text = errorMessage
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        } else {
            errorLabel.text = "Email required."
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1.0
        }
    }
    
    func passwordValidation(textField:UITextField,errorLabel:UILabel,errorMessage:String) {
        if textField.text!.count > 0 {
            if AppManager.shared.isPasswordValid(text: textField.text!) {
                errorLabel.text = ""
                textField.borderStyle = .none
                textField.layer.borderColor = UIColor.clear.cgColor
                textField.layer.borderWidth = 0.0
            } else{
                errorLabel.text = errorMessage
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        } else {
            errorLabel.text = "Password required."
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1.0
        }
    }
    
    func requiredValidation(textView:UITextView,errorLabel:UILabel,errorMessage:String)  {
        if textView.text!.count > 1 {
            errorLabel.text = ""
            textView.layer.borderColor = UIColor.clear.cgColor
            textView.layer.borderWidth = 0.0
        } else {
            errorLabel.text = errorMessage
            textView.layer.borderColor = UIColor.red.cgColor
            textView.layer.borderWidth = 1.0
        }
    }
    
    func maxCharacterValidation(textField:UITextField,max:Int) -> Bool {
        return textField.text!.count < max ? true : false
    }
    
    func minCharacterValidation(textField:UITextField,min:Int) -> Bool {
        return textField.text!.count > min ? true : false
    }
    
    func isDuplicate(text1:String,text2:String) -> Bool {
        return text1 == text2 ? true : false
    }
    
    func updateBtnValidator(updateBtn:UIButton,textFieldArray:[UITextField],textView:UITextView,phoneNumberTextField:UITextField?,email:String?,password:String?) {
        var flag:Bool = false
        
        if email != nil && password == nil {
            flag = isAllFieldsRequiredValidated(textFieldArray:textFieldArray, phoneNumberTextField: phoneNumberTextField) && isEmailValid(email: email!) == true ? true : false
        }
            
        else if password != nil && email == nil {
            flag = isAllFieldsRequiredValidated(textFieldArray:textFieldArray, phoneNumberTextField: phoneNumberTextField) && isPasswordValid(password: password!) == true ? true : false
        }
            
        else if email != nil && password != nil {
            flag = isAllFieldsRequiredValidated(textFieldArray: textFieldArray, phoneNumberTextField: phoneNumberTextField) && isEmailValid(email: email!) && isPasswordValid(password: password!) == true ? true : false
        }
            
        else {
            flag = isAllFieldsRequiredValidated(textFieldArray:textFieldArray, phoneNumberTextField: phoneNumberTextField)
        }

        if flag == true  && isTextViewRequiredValid(textView: textView) == true {
            updateBtn.isEnabled = true
            updateBtn.alpha = 1.0
        } else {
            updateBtn.isEnabled = false
            updateBtn.alpha = 0.4
        }
    }

    func isMemberProfileValidated(textFieldArray:[UITextField],textView:UITextView,phoneNumberTextField:UITextField?,email:String?,password:String?) -> Bool {
        var flag:Bool = false
        
        if email != nil && password == nil {
            flag = isAllFieldsRequiredValidated(textFieldArray:textFieldArray, phoneNumberTextField: phoneNumberTextField) && isEmailValid(email: email!) == true ? true : false
        }
            
        else if password != nil && email == nil {
            flag = isAllFieldsRequiredValidated(textFieldArray:textFieldArray, phoneNumberTextField: phoneNumberTextField) && isPasswordValid(password: password!) == true ? true : false
        }
            
        else if email != nil && password != nil {
            flag = isAllFieldsRequiredValidated(textFieldArray: textFieldArray, phoneNumberTextField: phoneNumberTextField) && isEmailValid(email: email!) && isPasswordValid(password: password!) == true ? true : false
        }
            
        else {
            flag = isAllFieldsRequiredValidated(textFieldArray:textFieldArray, phoneNumberTextField: phoneNumberTextField)
        }

        return flag
    }
  
}

