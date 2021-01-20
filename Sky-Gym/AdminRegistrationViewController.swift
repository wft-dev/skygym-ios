//
//  AdminRegistrationViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class AdminRegistrationViewController: UIViewController {
    
    @IBOutlet weak var gymNameTextField: UITextField?
    @IBOutlet weak var gymIDTextField: UITextField?
    @IBOutlet weak var gymAddressTextView: UITextView?
    @IBOutlet weak var firstNameTextField: UITextField?
    @IBOutlet weak var lastNameTextField: UITextField?
    @IBOutlet weak var gymNameErrorText: UILabel?
    @IBOutlet weak var gymIDErrorText: UILabel?
    @IBOutlet weak var firstNameErrorText: UILabel?
    @IBOutlet weak var lastNameErrorText: UILabel?
    @IBOutlet weak var gymAddressErrorText: UILabel!
    @IBOutlet weak var forwardBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTextFields()
    }
    
    @objc func errorChecker(_ textfield:UITextField)  {
        self.textFieldValidations(textField: textfield)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func forwardBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "forwardSegue", sender: nil)
    }
    
}

extension AdminRegistrationViewController{
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
    
   func textFieldValidations(textField:UITextField) {
switch textField.tag {
case 1:
    if textField.text!.count < 1 {
        self.gymNameErrorText?.text = "Gym Name should be there."
    } else {
        self.gymNameErrorText?.text = ""
    }
    
case 2:
    if textField.text!.count < 1 {
        self.gymIDErrorText?.text = "Gym ID should be there."
    } else {
        self.gymIDErrorText?.text = ""
    }
case 4:
    if textField.text!.count < 1 {
        self.firstNameErrorText?.text = "First Name should be there."
    } else {
        self.firstNameErrorText?.text = ""
    }
case 5:
    if textField.text!.count < 1 {
        self.lastNameErrorText?.text = "Last Name should be there."
    } else {
        self.lastNameErrorText?.text = ""
    }
    
default:
    break
}
    self.isAllTextFieldsValid()
    }
    
    func isAllTextFieldsValid()  {
        let gymNameCount = self.gymNameTextField?.text?.count
        let gymIDCount = self.gymIDTextField?.text?.count
        let gymAddressCount = self.gymAddressTextView?.text.count
        let firstNameCount = self.firstNameTextField?.text?.count
        let lastNameCount = self.lastNameTextField?.text?.count
        
        if gymNameCount ?? 0  > 1 && gymIDCount ?? 0 > 1 && gymAddressCount ?? 0  > 1 && firstNameCount  ?? 0 > 1 && lastNameCount ?? 0  > 1 {
            self.forwardBtn?.isEnabled = true
                  self.forwardBtn?.alpha = 1.0
        } else {
                 self.forwardBtn?.isEnabled = false
              self.forwardBtn?.alpha = 0.5
        }
    }
    
    func setTextFields() {
        self.assignbackground()
        [gymNameTextField,gymIDTextField,firstNameTextField,lastNameTextField].forEach{
            $0?.layer.cornerRadius = 15.0
            $0?.borderStyle = .none
            $0?.clipsToBounds = true
            $0?.addTarget(self, action: #selector(errorChecker(_:)), for: .editingChanged)
            $0?.addPaddingToTextField()
        }
        gymAddressTextView?.layer.cornerRadius = 15.0
        gymAddressTextView?.clipsToBounds = true
        gymAddressTextView?.addPaddingToTextField()
        self.forwardBtn?.isEnabled = false
        self.forwardBtn?.alpha = 0.5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "forwardSegue" {
            SVProgressHUD.show()
        //    DispatchQueue.main.async {
                let  secondRegisterationVC = segue.destination as! AdminRegistrationSecondViewController
                secondRegisterationVC.gymName = self.gymNameTextField?.text ?? ""
                secondRegisterationVC.gymID = self.gymIDTextField?.text ?? ""
                secondRegisterationVC.gymAddress = self.gymAddressTextView?.text ?? ""
                secondRegisterationVC.firstName = self.firstNameTextField?.text ?? ""
                secondRegisterationVC.lastName = self.lastNameTextField?.text ?? ""
                secondRegisterationVC.id = UUID().uuidString
                SVProgressHUD.dismiss()
         //   }
        }
    }
}

extension AdminRegistrationViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.textFieldValidations(textField: textField)
    }
}

extension AdminRegistrationViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
    if (self.gymAddressTextView?.text.count)! < 1 {
        self.gymAddressErrorText?.text = "Gym Address should be there."
        
    } else {
        self.gymAddressErrorText?.text = ""
    }
        self.isAllTextFieldsValid()
    }
    
    func textViewDidChange(_ textView: UITextView) {
            if (self.gymAddressTextView?.text.count)! < 1 {
            self.gymAddressErrorText?.text = "Gym Address should be there."
        } else {
            self.gymAddressErrorText?.text = ""
        }
        
        self.isAllTextFieldsValid()

    }
}
