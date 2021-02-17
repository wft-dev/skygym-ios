//
//  MemberLoginProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 05/01/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    
    @IBOutlet weak var firstNameForNonEditLabel: UILabel!
    @IBOutlet weak var lastNameForNonEditLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var passwordForNonEditLabel: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    @IBOutlet weak var dobForNonEditLabel: UILabel!
    
    private lazy var imagePicker:UIImagePickerController = {
        return UIImagePickerController()
    }()
    
    private lazy var datePicker:UIDatePicker = {
        return UIDatePicker()
    }()
    
    private lazy var genderPickerView:UIPickerView = {
        return UIPickerView()
    }()
    
    var textFieldArray:[UITextField] = []
    var errorLabelsArray:[UILabel] = []
    var hrLineViewArray:[UIView] = []
    var defaultLabelArray:[UILabel] = []
    var forNonEditLabelArray:[UILabel] = []
    var isEditable:Bool = false
    var isUserProfileUpdated = false
    var actualPasswordLabel:UILabel = UILabel()
    var selectedDate:String = ""
    var toolBar:UIToolbar? = nil
    var isAlreadyExistsEmail:Bool = false
    var memberLoginProfileEmail:String = ""
    var memberPassword:String = ""
    let genderArray = ["Male","Female","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        
        self.textFieldArray = [ self.firstNameTextField,self.lastNameTextField,self.genderTextField,self.passwordTextField,self.emailTextField,self.phoneNumberTextField,self.dobTextField ]
        self.errorLabelsArray = [ self.firstNameErrorLabel,self.lastNameErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.emailErrorLabel,self.phoneNoErrorLabel,self.dobErrorLabel ]
        self.hrLineViewArray = [ self.firstNameHrLineView,self.genderHrLineView,self.emailHrLineView,self.phoneNoHrLineView ]
        self.defaultLabelArray = [ self.firstNameLabel,self.lastNameLabel,self.genderLabel,self.passwordLabel,self.emailLabel,self.phoneNoLabel,self.dobLabel ]
        self.forNonEditLabelArray = [ self.firstNameForNonEditLabel,self.lastNameForNonEditLabel,self.genderForNonEditLabel,self.passwordForNonEditLabel,self.emailForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel  ]
        
        self.setMemberLoginProfileCustomNavigationbar()
        self.setMemberProfileTextFields()
        self.imagePicker.delegate = self
        self.genderPickerView.dataSource = self
        self.genderPickerView.delegate = self
        
        AppManager.shared.performEditAction(dataFields: self.getDataDir(), edit: false)
        self.setMemberHrLineView(hide: false)
        self.hideErrorLabels(hide: true)
        self.hideLabelsArray(labelArray: self.defaultLabelArray, hide: true)
        self.hideLabelsArray(labelArray: self.forNonEditLabelArray, hide: false)
        self.updateBtn.isHidden = true
        self.updateBtn.alpha = 0.0
        self.updateBtn.addTarget(self, action: #selector(updateMemberInfo), for: .touchUpInside)
        self.memberProfileImg.isUserInteractionEnabled = false
        self.memberProfileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openImgPicker)))
        self.fetchMemberDetailBy(id: AppManager.shared.memberID)
    }

    
    @objc func openImgPicker() {
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.imagePicker.allowsEditing = true
        self.isUserProfileUpdated = true
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func isAllFieldsValid() -> Bool {
        if  ValidationManager.shared.isAllFieldsRequiredValidated(textFieldArray: self.textFieldArray, phoneNumberTextField: self.phoneNumberTextField) == true && ValidationManager.shared.isEmailValid(email: self.emailTextField.text!) == true && ValidationManager.shared.isPasswordValid(password: self.passwordTextField.text!) == true {
            return true
        } else {
            return false
        }
    }
    
    @objc func updateMemberInfo(){
        let memberDetail = self.getMemberDetailData()
        let memberImgData = self.memberProfileImg.image?.pngData()
        SVProgressHUD.show()
        
        if isAllFieldsValid() == true && self.isAlreadyExistsEmail == false {
            
            FireStoreManager.shared.updateUserCredentials(id: AppManager.shared.memberID, email: self.emailTextField.text!, password: self.memberPassword, handler: {
                (err ) in
                
                if err == nil {
                    DispatchQueue.global(qos: .background).async {
                        let result = FireStoreManager.shared.updateMemberProfileDetail(id: AppManager.shared.memberID, memberDetail: memberDetail)
                        
                        switch result {
                        case .failure(_):
                            self.showAlert(title: "Error", message: "Error in updating member details.")
                        case let .success(flag) :
                            if flag == true {
                                FireStoreManager.shared.uploadUserImg(imgData: (memberImgData)!, id: AppManager.shared.memberID, completion: {
                                    (err) in
                                    SVProgressHUD.dismiss()
                                    if err == nil {
                                        self.showAlert(title: "Success", message: "Member detail is updated successfully.")
                                    }
                                })
                            }else {
                                SVProgressHUD.dismiss()
                                self.showAlert(title: "Error", message: "Error in updating member details.")
                            }
                        }
                    }
                }
            })
        } else {
            SVProgressHUD.dismiss()
            self.emailTextField.layer.borderColor = UIColor.red.cgColor
            self.emailTextField.layer.borderWidth = 1.0
            self.emailErrorLabel.text = "Email already exists."
            self.updateBtn.isEnabled = false
            self.updateBtn.alpha = 0.4
        }
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
        self.hideErrorLabels(hide: !self.isEditable)
        self.hideLabelsArray(labelArray: self.defaultLabelArray, hide: !self.isEditable)
        self.hideLabelsArray(labelArray: self.forNonEditLabelArray, hide: self.isEditable)
        self.updateBtn.isHidden = !self.isEditable
        self.updateBtn.alpha = self.isEditable == true ?  1.0 : 0.0
        self.memberProfileImg.isUserInteractionEnabled = self.isEditable
        self.passwordNonEditLabel.isHidden = self.isEditable
    }
    
    func getDataDir() -> [UITextField:UILabel] {
        let dir = [
            self.firstNameTextField! : self.firstNameNonEditLabel!,
            self.lastNameTextField! : self.lastNameNonEditLabel!,
            self.genderTextField! : self.genderNonEditLabel!,
            self.phoneNumberTextField! : self.phoneNoNonEditLabel!,
            self.emailTextField! : self.emailNonEditLabel!,
            self.passwordTextField! : self.actualPasswordLabel,
            self.dobTextField! : self.dobNonEditLabel!
        ]
        return dir
    }
    
    func getMemberDetailData() -> Dictionary<String,String> {
        let dir = [
            "firstName" : self.firstNameTextField.text!,
            "lastName" : self.lastNameTextField.text!,
            "gender" : self.genderTextField.text!,
            "password" : AppManager.shared.encryption(plainText: self.passwordTextField.text!),
            "email"  : self.emailTextField.text!,
            "phoneNo" : self.phoneNumberTextField.text!,
            "dob" : self.dobTextField.text!
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
    
    func hideLabelsArray(labelArray:[UILabel],hide:Bool) {
        labelArray.forEach{
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
        
        self.datePicker.datePickerMode = .date
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd-MMM-YYYY"
        selectedDate = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
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
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.firstNameErrorLabel, errorMessage: "First Name required.")
            break
        case 2:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.lastNameErrorLabel, errorMessage: "Last Name required.")
            break
        case 3:
       ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "gender required.")
            break
        case 4:
            ValidationManager.shared.passwordValidation(textField: textField, errorLabel: self.passwordErrorLabel, errorMessage: "Password must be greater than 8 characters.")
            break
        case 5:
          ValidationManager.shared.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Invalid Email")
            break
        case 6:
           ValidationManager.shared.phoneNumberValidation(textField: textField, errorLabel: self.phoneNoErrorLabel, errorMessage: "Phone number must be 10 digits only.")
        case 7 :
           ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required.")
        default:
            break
        }
        
        ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNumberTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
    }

    
    func fetchMemberDetailBy(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (memberData, err) in
            
            if err != nil {
                SVProgressHUD.dismiss()
                self.showAlert(title: "Error", message: "Member details are not fetched, please try again.")
            } else {
                let memberDetailData = memberData?["memberDetail"] as! Dictionary<String,String>
                let memberDetail = AppManager.shared.getMemberDetailStr(memberDetail: memberDetailData)
                self.setMemberDetail(memberDetail: memberDetail)
                
                FireStoreManager.shared.downloadUserImg(id: AppManager.shared.memberID, result: {
                    (imgUrl,err) in
                    if err == nil {
                        do {
                            let imgData = try Data(contentsOf: imgUrl!)
                            let img =  UIImage(data:imgData )
                            self.memberProfileImg.image = img
                            self.memberProfileImg.makeRounded()
                            SVProgressHUD.dismiss()
                        } catch _ {
                            }
                    } else {
                        SVProgressHUD.dismiss()
                    }
                })
             }
        })
    }
    
    func showAlert(title:String,message:String) {
        let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
        _ in
            if title == "Success" {
                self.fetchMemberDetailBy(id: AppManager.shared.memberID)
            }
        })
        
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setMemberDetail(memberDetail:MemberDetailStructure) {
        self.firstNameNonEditLabel.text = memberDetail.firstName
        self.lastNameNonEditLabel.text = memberDetail.lastName
        self.genderNonEditLabel.text = memberDetail.gender
        self.actualPasswordLabel.text = memberDetail.password
        self.passwordNonEditLabel.text = AppManager.shared.getSecureTextFor(text: memberDetail.password)
        self.emailNonEditLabel.text = memberDetail.email
        self.phoneNoNonEditLabel.text = memberDetail.phoneNo
        self.dobNonEditLabel.text = memberDetail.dob
        self.memberLoginProfileEmail = memberDetail.email
        self.memberPassword = memberDetail.password

        self.firstNameTextField.text = memberDetail.firstName
        self.lastNameTextField.text = memberDetail.lastName
        self.genderTextField.text = memberDetail.gender
        self.passwordTextField.text = self.actualPasswordLabel.text
        self.emailTextField.text = memberDetail.email
        self.phoneNumberTextField.text = memberDetail.phoneNo
        self.dobTextField.text = memberDetail.dob
    }
}

extension MemberLoginProfileViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 7 {
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.toolBar
            
            if textField.text != "" {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
        }
        
        if textField.tag == 3 {
            textField.inputView = self.genderPickerView
        }
        
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.tag == 7 ? false : true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if  textField.tag == 7  && self.selectedDate != "" {
            textField.text = self.selectedDate
            self.selectedDate = ""
        }
        
        if textField.tag == 5 {
            let email = textField.text!
            if self.memberLoginProfileEmail != email {
                DispatchQueue.global(qos: .default).async {
                    let result = FireStoreManager.shared.isUserExists(email: email)
                    DispatchQueue.main.async {
                        switch result {
                        case let  .success(flag):
                            if flag == false {
                                self.isAlreadyExistsEmail = false
                                self.updateBtn.isEnabled = true
                                self.updateBtn.alpha = 1.0
                            }else {
                                textField.layer.borderColor = UIColor.red.cgColor
                                textField.layer.borderWidth = 1.0
                                self.emailErrorLabel.text = "Email already exists."
                                self.isAlreadyExistsEmail = true
                                self.updateBtn.isEnabled = false
                                self.updateBtn.alpha = 0.4
                            }
                            
                        case .failure(_):
                            break
                        }
                    }

                }
            }else {
                self.isAlreadyExistsEmail = false
            }
        }
        
        self.allMemberFieldValidation(textField: textField)
        ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNumberTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
        
        DispatchQueue.main.async {
            if self.isAlreadyExistsEmail == true {
                self.emailTextField.layer.borderColor = UIColor.red.cgColor
                self.emailTextField.layer.borderWidth = 1.0
                self.emailErrorLabel.text = "Email already exists."
                self.updateBtn.isEnabled = false
                self.updateBtn.alpha = 0.4
            }
        }
    }
}

extension MemberLoginProfileViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[.editedImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        self.memberProfileImg.image = img
        self.memberProfileImg.makeRounded()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isUserProfileUpdated = false
        self.dismiss(animated: true, completion: nil)
    }
}

extension MemberLoginProfileViewController: UIPickerViewDataSource{
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


extension MemberLoginProfileViewController : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField.text = self.genderArray[row]
        DispatchQueue.main.async {
            self.allMemberFieldValidation(textField: self.genderTextField)
            ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNumberTextField, email: self.emailTextField.text!, password: self.passwordTextField.text)
        }
    }
    
}
