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
    
    var textFieldArray:[UITextField] = []
    var errorLabelsArray:[UILabel] = []
    var hrLineViewArray:[UIView] = []
    var defaultLabelArray:[UILabel] = []
    var forNonEditLabelArray:[UILabel] = []
    let validator = ValidationManager.shared
    var isEditable:Bool = false
    var isUserProfileUpdated = false
    var actualPasswordLabel:UILabel = UILabel()
    var selectedDate:String = ""
    let imagePicker = UIImagePickerController()
    var datePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldArray = [ self.firstNameTextField,self.lastNameTextField,self.genderTextField,self.passwordTextField,self.emailTextField,self.phoneNumberTextField,self.dobTextField ]
        self.errorLabelsArray = [ self.firstNameErrorLabel,self.lastNameErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.emailErrorLabel,self.phoneNoErrorLabel,self.dobErrorLabel ]
        self.hrLineViewArray = [ self.firstNameHrLineView,self.genderHrLineView,self.emailHrLineView,self.phoneNoHrLineView ]
        self.defaultLabelArray = [ self.firstNameLabel,self.lastNameLabel,self.genderLabel,self.passwordLabel,self.emailLabel,self.phoneNoLabel,self.dobLabel ]
        self.forNonEditLabelArray = [ self.firstNameForNonEditLabel,self.lastNameForNonEditLabel,self.genderForNonEditLabel,self.passwordForNonEditLabel,self.emailForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel  ]
        
        self.setMemberLoginProfileCustomNavigationbar()
        self.setMemberProfileTextFields()
        self.imagePicker.delegate = self
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func openImgPicker() {
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.imagePicker.allowsEditing = true
        self.isUserProfileUpdated = true
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func updateMemberInfo(){
        let memberDetail = self.getMemberDetailData()
        let memberImgData = self.memberProfileImg.image?.pngData()
        SVProgressHUD.show()
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
                    self.showAlert(title: "Error", message: "Error in updating member details.")
                }
            }
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
            "password" : self.passwordTextField.text!,
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
        
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNumberTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
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
                        } catch let error as NSError {
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
        let okAlertAction = UIAlertAction(title: title, style: .default, handler: {
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
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.tag == 7 ? false : true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if  textField.tag == 7  && self.selectedDate != "" {
            textField.text = self.selectedDate
            self.selectedDate = ""
        }
        self.allMemberFieldValidation(textField: textField)
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNumberTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
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
