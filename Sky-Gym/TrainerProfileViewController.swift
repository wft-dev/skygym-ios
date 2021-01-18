//
//  TrainerProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/12/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class TrainerProfileViewController: BaseViewController {
    
    @IBOutlet weak var trainerProfileCustomNavigationView: CustomNavigationBar!
    @IBOutlet weak var trainerFirstNameTextField: UITextField!
    @IBOutlet weak var trainerLastNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var trainerFirstNameNonEditLabel: UILabel!
    @IBOutlet weak var trainerLastNameNonEditLabel: UILabel!
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
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNoErrorLabel: UILabel!
    @IBOutlet weak var dobErrorLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var passwordForNonEditLabel: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    @IBOutlet weak var dobForNonEditLabel: UILabel!
    @IBOutlet weak var trainerProfileImg: UIImageView!
    
    var editMode:Bool = false
    var textFieldArray:[UITextField] = []
    var nonEditLabelArray:[UILabel] = []
    var defaultLabelArray:[UILabel] = []
    var forNonEditLabelArray:[UILabel] = []
    var errorLabelsArray:[UILabel] = []
    let imagePicker = UIImagePickerController()
    var isUserProfileUpdated:Bool = false
    let validator = ValidationManager.shared
    var datePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    var selectedDate:String = ""
    var actuallPassword:String = ""
    var trainerEmail:String = ""
    var isAlreadyExistsEmail:Bool = false
    let genderPickerView = UIPickerView()
    let genderArray = ["Male","Female","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground()
        self.genderPickerView.dataSource = self
        self.genderPickerView.delegate = self
        self.trainerProfileCustomNavigationView.navigationTitleLabel.text = "Profile"
        self.trainerProfileCustomNavigationView.searchBtn.isHidden = true
        self.trainerProfileCustomNavigationView.searchBtn.alpha = 0.0
        self.trainerProfileCustomNavigationView.editBtn.isHidden = false
        self.trainerProfileCustomNavigationView.editBtn.alpha = 1.0
        self.trainerProfileCustomNavigationView.editBtn.addTarget(self, action: #selector(makeProfileEditable), for: .touchUpInside)
        self.textFieldArray = [self.trainerFirstNameTextField,self.trainerLastNameTextField,self.genderTextField,self.passwordTextField,self.emailTextField,self.phoneNoTextField,self.dobTextField]
        self.nonEditLabelArray = [self.trainerFirstNameNonEditLabel,self.trainerLastNameNonEditLabel,self.genderNonEditLabel,self.passwordNonEditLabel,self.emailNonEditLabel,self.phoneNoNonEditLabel,self.dobNonEditLabel]
        self.defaultLabelArray = [self.genderLabel,self.passwordLabel,self.emailLabel,self.dobLabel,self.phoneNoLabel]
        self.forNonEditLabelArray = [self.genderForNonEditLabel,self.passwordForNonEditLabel,self.emailForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel]
        self.errorLabelsArray =
            [self.firstNameErrorLabel,self.lastNameErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.emailErrorLabel,self.phoneNoErrorLabel,self.dobErrorLabel]
        
        self.textFieldArray.forEach{
            self.addPaddingToTextField(textField: $0)
            $0.layer.cornerRadius = 7.0
            $0.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0.clipsToBounds = true
            $0.addTarget(self, action: #selector(errorValidator(_:)), for: .editingChanged)
        }
        self.updateBtn.layer.cornerRadius = 15.0
        self.updateBtn.addTarget(self, action: #selector(updateTrainerInfo), for: .touchUpInside)
        self.fetchTrainerProfile(id: AppManager.shared.trainerID)
        
        AppManager.shared.performEditAction(dataFields: self.dataFieldsDir(), edit: false)
        self.hideHrLine(hide: false)
        self.labelColor(color: .lightGray)
        self.hideNonEditLabel(hide: false)
        self.hideDefaultLabel(hide: true)
        self.hideForNonEditLabel(hide: false)
        self.updateBtn.isHidden = true
        self.updateBtn.alpha =  0.0
        self.trainerProfileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openImagePicker)))
        self.imagePicker.delegate = self
        self.trainerProfileImg.makeRounded()
        
        self.datePicker.datePickerMode = .date
        toolBar.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar.sizeToFit()
    }
    
    func addPaddingToTextField(textField:UITextField) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
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

    @objc func openImagePicker() {
        self.isUserProfileUpdated = true
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func updateTrainerInfo(){
        SVProgressHUD.show()
        let trainerInfo = self.getTrainerInfo()
        let trainerImgData = self.trainerProfileImg.image?.pngData()
        self.view.endEditing(true)
        if  self.allFieldsValid() == true {
            FireStoreManager.shared.updateUserCredentials(id: AppManager.shared.trainerID, email: self.emailTextField.text!, password: self.passwordTextField.text!, handler: {
                (err) in
                
                DispatchQueue.global(qos: .background).async {
                    let result = FireStoreManager.shared.updateTrainerDetailBy(id: AppManager.shared.trainerID, trainerInfo: trainerInfo)
                    
                    switch result{
                    case .failure(_) :
                        SVProgressHUD.dismiss()
                        print("Errror")
                        self.showAlert(title: "Error", message: "Error in updating the trainer detail.")
                    case .success(_) :
                        if self.isUserProfileUpdated == true {
                            FireStoreManager.shared.uploadUserImg(imgData: (trainerImgData)!, id: AppManager.shared.trainerID, completion: {
                                (err) in
                                SVProgressHUD.dismiss()
                                if err == nil {
                                    self.showAlert(title: "Success", message: "Trainer detail is updated successfully.")
                                }
                            })
                        } else {
                            SVProgressHUD.dismiss()
                            self.showAlert(title: "Success", message: "Trainer detail is updated successfully.")
                        }
                    }
                }
            })
        }else {
            SVProgressHUD.dismiss()
            for textField in self.textFieldArray {
                self.allTrainerFieldValidation(textField: textField)
            }
            
            self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }
    }
    
    @objc func errorValidator(_ textField:UITextField) {
        if textField.tag == 5 {
            if self.trainerEmail == textField.text! {
                self.updateBtn.isEnabled = true
                self.updateBtn.alpha = 1.0
            }else {
                DispatchQueue.main.async {
                    self.updateBtn.isEnabled = false
                    self.updateBtn.alpha = 0.4
                }
            }
        }
        self.allTrainerFieldValidation(textField: textField)
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
    }
    
    func allTrainerFieldValidation(textField:UITextField) {
        switch textField.tag {
        case 1:
            validator.requiredValidation(textField: textField, errorLabel: self.firstNameErrorLabel, errorMessage: "First name required.")
        case 2 :
            validator.requiredValidation(textField: textField, errorLabel: self.lastNameErrorLabel, errorMessage: "Last name required.")
        case 3 :
            validator.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "Trainer's gender required.")
        case 4 :
            validator.passwordValidation(textField: textField, errorLabel: self.passwordErrorLabel, errorMessage: "Password must be greater than 8 characters.")
        case 5:
            validator.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Invalid Email.")
        case 6 :
            validator.phoneNumberValidation(textField: textField, errorLabel: self.phoneNoErrorLabel, errorMessage: "Phone Number must be 10 digits only.")
        case 7:
            validator.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required.")
        default:
            break
        }
    }
    
    func fetchTrainerProfile(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getTrainerBy(id: id, completion: {
            (trainerData,err) in
            if err == nil {
                
                let trainerDetail = trainerData!["trainerDetail"] as! Dictionary<String,Any>
                self.setTrainerDetail(trainerDetail: AppManager.shared.getTrainerDetailS(trainerDetail: trainerDetail))
                
                FireStoreManager.shared.downloadUserImg(id: AppManager.shared.trainerID, result: {
                    (imgUrl,err) in
                    SVProgressHUD.dismiss()
                    if err == nil {
                        do {
                            let imgData =  try Data(contentsOf: imgUrl!)
                            self.trainerProfileImg.image = UIImage(data: imgData)
                        } catch _ as NSError {
                        }
                    }
                })
            }
        })
    }
    
    @objc func makeProfileEditable(){
        self.editMode = !self.editMode
        AppManager.shared.performEditAction(dataFields: self.dataFieldsDir(), edit: self.editMode)
        self.hideHrLine(hide: self.editMode)
        self.labelColor(color: self.editMode ? .black : .lightGray)
        self.hideNonEditLabel(hide: self.editMode)
        self.hideDefaultLabel(hide: !self.editMode)
        self.hideForNonEditLabel(hide: self.editMode)
        self.hideErrorLabels(hide: !self.editMode)
        self.updateBtn.isHidden = !self.editMode
        self.updateBtn.alpha = self.editMode == false ? 0.0 : 1.0
        self.trainerProfileImg.isUserInteractionEnabled = self.editMode
    }
    
    func setTrainerDetail(trainerDetail:TrainerDataStructure) {
        self.trainerFirstNameNonEditLabel.text = trainerDetail.firstName
        self.trainerLastNameNonEditLabel.text = trainerDetail.lastName
        self.genderNonEditLabel.text = trainerDetail.gender
        self.actuallPassword = ""
        self.actuallPassword = trainerDetail.password
        self.passwordNonEditLabel.text = AppManager.shared.getSecureTextFor(text: trainerDetail.password)
        self.emailNonEditLabel.text = trainerDetail.email
        self.phoneNoNonEditLabel.text = trainerDetail.phoneNo
        self.dobNonEditLabel.text = trainerDetail.dob
        self.trainerEmail = trainerDetail.email
        
        self.trainerFirstNameTextField.text = trainerDetail.firstName
        self.trainerLastNameTextField.text = trainerDetail.lastName
        self.genderTextField.text = trainerDetail.gender
        self.passwordTextField.text = self.actuallPassword
        self.emailTextField.text = trainerDetail.email
        self.phoneNoTextField.text = trainerDetail.phoneNo
        self.dobTextField.text = trainerDetail.dob
    }
    
    func allFieldsValid() -> Bool {
        var flag:Bool = false
        if  self.validator.isAllFieldsRequiredValidated(textFieldArray: self.textFieldArray, phoneNumberTextField: self.phoneNoTextField) == true && self.validator.isEmailValid(email: self.emailTextField.text!) == true  && self.validator.isPasswordValid(password: self.passwordTextField.text!) == true {
            flag = true
        }else {
            flag = false
        }
        
        return flag
    }
    
    func dataFieldsDir() -> [UITextField:UILabel] {
        let dir = [
            self.trainerFirstNameTextField! : self.trainerFirstNameNonEditLabel!,
            self.trainerLastNameTextField! : self.trainerLastNameNonEditLabel!,
            self.genderTextField! : self.genderNonEditLabel!,
            self.passwordTextField! : self.passwordNonEditLabel!,
            self.emailTextField! : self.emailNonEditLabel! ,
            self.dobTextField! : self.dobNonEditLabel!,
            self.phoneNoTextField! : self.phoneNoNonEditLabel!
        ]
        return dir
    }
    
    func hideHrLine(hide:Bool)  {
        [self.firstNameHrLineView,self.genderHrLineView,self.emailHrLineView,self.phoneNoHrLineView].forEach{
            $0?.isHidden = hide
            $0?.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func labelColor(color:UIColor) {
        [self.firstNameLabel,self.lastNameLabel].forEach{
            $0.textColor = color
        }
    }
    
    func hideNonEditLabel(hide:Bool)  {
        self.nonEditLabelArray.forEach{
            $0.isHidden = hide
            $0.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func hideForNonEditLabel(hide:Bool) {
        self.forNonEditLabelArray.forEach{
            $0.isHidden = hide
            $0.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func hideDefaultLabel(hide : Bool)  {
        self.defaultLabelArray.forEach{
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
    
    func getTrainerInfo() -> Dictionary<String,String> {
        let info = [
            "firstName" : self.trainerFirstNameTextField.text!,
            "lastName" : self.trainerLastNameTextField.text!,
            "gender" : self.genderTextField.text!,
            "password" : self.passwordTextField.text!,
            "email" : self.emailTextField.text!,
            "phoneNo" : self.phoneNoTextField.text!,
            "dob" : self.dobTextField.text!
         ]
        return info
    }
    
    func showAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            self.fetchTrainerProfile(id: AppManager.shared.trainerID)
        })
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension TrainerProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.editedImage] as? UIImage {
            self.trainerProfileImg.image = img
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isUserProfileUpdated = false
        dismiss(animated: true, completion: nil)
    }
}

extension TrainerProfileViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 7 {
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
        }
        
        if textField.tag == 5 {
            if self.trainerEmail == textField.text! {
                self.updateBtn.isEnabled = true
                self.updateBtn.alpha = 1.0
            }else {
                DispatchQueue.main.async {
                    self.updateBtn.isEnabled = false
                    self.updateBtn.alpha = 0.4
                }
            }
        }
        
        if textField.tag == 3 {
            textField.inputView = self.genderPickerView
        }
        
        self.allTrainerFieldValidation(textField: textField)
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 7 {
            return false
        }else {
          return  true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if  textField.tag == 7  && self.selectedDate != "" {
            textField.text = self.selectedDate
            self.selectedDate = ""
        }
        
        if textField.tag == 5 {
            let email = textField.text!
            if self.trainerEmail != email {
                DispatchQueue.global(qos: .background).async {
                    let result = FireStoreManager.shared.isUserExists(email: email)
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(flag):
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
            }
        }
        
        self.allTrainerFieldValidation(textField: textField)
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
    }
    
}


extension TrainerProfileViewController : UIPickerViewDataSource {
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

extension TrainerProfileViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField.text = self.genderArray[row]
        
        DispatchQueue.main.async {
            self.allTrainerFieldValidation(textField: self.genderTextField)
            self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }
        
    }
}
