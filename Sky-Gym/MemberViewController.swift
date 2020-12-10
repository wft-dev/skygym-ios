//
//  MemberViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 07/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class MemberViewController: BaseViewController {
    @IBOutlet weak var memberNaviagationBar: CustomNavigationBar!
    @IBOutlet weak var dateOfJoiningTextField: UITextField!
    @IBOutlet weak var memberIDTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var trainerNameTextField: UITextField!
    @IBOutlet weak var uploadIDTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var memberImg: UIImageView!
    @IBOutlet weak var memberIDNonEditLabel: UILabel!
    @IBOutlet weak var memberID: UILabel!
    @IBOutlet weak var dateOfJoining: UILabel!
    @IBOutlet weak var memberIDHrLineView: UIView!
    @IBOutlet weak var dateOfJoiningNonEditLabel: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var genderNonEditLabel: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var passwordNonEditLabel: UILabel!
    @IBOutlet weak var genderHrLineView: UIView!
    @IBOutlet weak var trainerName: UILabel!
    @IBOutlet weak var trainerNameNonEditLabel: UILabel!
    @IBOutlet weak var trainerNameHrView: UIView!
    @IBOutlet weak var uploadID: UILabel!
    @IBOutlet weak var uploadIDNonEditLabel: UILabel!
    @IBOutlet weak var uploadIDHrView: UIView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailNonEditLabel: UILabel!
    @IBOutlet weak var emailHrLineView: UIView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressNonEditLabel: UILabel!
    @IBOutlet weak var addressHrLineView: UIView!
    @IBOutlet weak var phoneNoNonEditScreenLabel: UILabel!
    @IBOutlet weak var phoneNo: UILabel!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var dobNonEditScreenLabel: UILabel!
    @IBOutlet weak var phoneNoHrLineView: UIView!
    @IBOutlet weak var generalToggleBtn: UIButton!
    @IBOutlet weak var personalToggleBtn: UIButton!
    @IBOutlet weak var memberFullNameLabel: UILabel!
    @IBOutlet weak var memberIDForNonEditLabel: UILabel!
    @IBOutlet weak var dateOfJoiningForNonEditLabel: UILabel!
    @IBOutlet weak var trainerNameForNonEditLabel: UILabel!
    @IBOutlet weak var uploadForNonEditLabel: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var addressForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    @IBOutlet weak var dobForNonEditLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var passwordForNonEditLabel: UILabel!
    @IBOutlet weak var trainerTypeLabel: UILabel!
    @IBOutlet weak var memberViewScrollView: UIScrollView!

    @IBOutlet weak var memberIDErrorLabel: UILabel!
    @IBOutlet weak var dateOfJoiningErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var trainerNameErrorLabel: UILabel!
    @IBOutlet weak var uploadIDErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberErrorLabel: UILabel!
    @IBOutlet weak var dobErrorLabel: UILabel!

    var isEdit:Bool = false
    var firstName:String = ""
    var lastName:String = ""
    var imgPicker:UIImagePickerController = UIImagePickerController()
    var datePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    var imgURL:URL? = nil
    var isUploadIdSelected:Bool = false
    var isUserProfileSelected:Bool = false
    var img:UIImage? = nil
    var forNonEditLabelArray:[UILabel] = []
    var defaultLabelArray:[UILabel] = []
    var errorLabelArray:[UILabel] = []
    var textFieldArray:[UITextField] = []
    let validation = ValidationManager.shared
    var selectedDate:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.forNonEditLabelArray = [self.memberIDForNonEditLabel,self.dateOfJoiningForNonEditLabel,self.genderForNonEditLabel,self.passwordForNonEditLabel,self.trainerNameForNonEditLabel,self.uploadForNonEditLabel,self.emailForNonEditLabel,self.addressForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel]
        self.defaultLabelArray = [self.memberID,self.dateOfJoining,self.gender,self.password,self.trainerName,self.uploadID,self.email,self.address,self.phoneNo,self.dob]
        self.errorLabelArray = [self.memberIDErrorLabel,self.dateOfJoiningErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.addressErrorLabel,self.trainerNameErrorLabel,self.uploadIDErrorLabel,self.emailErrorLabel,self.phoneNumberErrorLabel,self.dobErrorLabel]
        self.textFieldArray = [self.memberIDTextField,self.dateOfJoiningTextField,self.genderTextField,self.trainerNameTextField,self.uploadIDTextField,self.phoneNoTextField,self.dobTextField]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memberImg.image = self.img
        self.memberImg.makeRounded()
        self.memberImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUserProfilePicker)))
        self.fetchMemberProfileDetails(id: AppManager.shared.memberID)
        self.imgPicker.delegate = self
        self.updateBtn.isEnabled = false
        self.updateBtn.alpha = 0.6
        self.setMemberProfileCompleteView()
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        SVProgressHUD.show()
        
        FireStoreManager.shared.updateMemberDetails(id: AppManager.shared.memberID,memberDetail: self.getMemberProfileDetails(), handler: {
            (err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.showMemberProfileAlert(title: "Error", message: "Member detail is not updated.")
            } else {
                if self.isUploadIdSelected == true {
                    FireStoreManager.shared.uploadImg(url: self.imgURL!, membeID: AppManager.shared.memberID, imageName: self.uploadIDTextField.text!, completion: {
                        (err) in
                        if err != nil {
                            self.showMemberProfileAlert(title: "Error", message: "Member detail is not updated.")
                        } else {
                            self.showMemberProfileAlert(title: "Success", message: "Member detail is updated successfully.")
                        }
                    })
                    self.isUserProfileSelected = false
                }
                    
                else if self.isUserProfileSelected == true {
                    FireStoreManager.shared.uploadUserImg(imgData: (self.memberImg.image?.pngData())!, id: AppManager.shared.memberID, completion: {
                        err in
                        if err == nil {
                            self.showMemberProfileAlert(title: "Success", message: "Member detail is updated successfully.")
                        }
                    })
                    self.isUserProfileSelected = false
                }
                else {
                    self.showMemberProfileAlert(title: "Success", message: "Member detail is updated successfully.")
                }
            }
        })
    }
    
    @IBAction func generalToggleBtnAction(_ sender: Any) {
        if self.generalToggleBtn.currentImage == UIImage(named: "non_selecte") {
            self.generalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
    }
    
    @IBAction func personalToggleBtnAction(_ sender: Any) {
        if self.personalToggleBtn.currentImage == UIImage(named: "non_selecte") {
            self.personalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.generalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
    }
}

extension MemberViewController{
    
    

    
    func allMemberProfileFieldsRequiredValidation(textField:UITextField)  {
        switch textField.tag {
        case 1:
            validation.requiredValidation(textField: textField, errorLabel: self.memberIDErrorLabel, errorMessage: "Member ID required.")
        case 2:
            validation.requiredValidation(textField: textField, errorLabel: self.dateOfJoiningErrorLabel, errorMessage: "Date of join required.")
        case 3:
            validation.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "Member's gender required." )
        case 4:
            validation.passwordValidation(textField: textField, errorLabel:self.passwordErrorLabel, errorMessage: "Password must be greater than 8 character.")
        case 5:
            validation.requiredValidation(textField: textField, errorLabel: self.trainerNameErrorLabel, errorMessage: "Trainer's name required.")
        case 6:
            validation.requiredValidation(textField: textField, errorLabel: self.uploadIDErrorLabel, errorMessage: "Upload ID required." )
        case 7:
            validation.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Invalid email address.")
        case 8:
            validation.phoneNumberValidation(textField: textField, errorLabel:self.phoneNumberErrorLabel, errorMessage: "Phone number must be 10 digits only.")
        case 9:
                validation.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required." )
        default:
            break
        }
    }
    
    func setMemberProfileCompleteView()  {
        self.memberNavigationBar()
        setTextFields()
        self.updateBtn.layer.cornerRadius = 15.0
        self.updateBtn.isHidden = true
        AppManager.shared.performEditAction(dataFields: self.getMemberProfileFieldsAndLabelDic(), edit:  false)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: self.errorLabelArray, flag: true)
        self.setHrLineView(isHidden: false, alpha: 1.0)
        self.addressNonEditLabel.isHidden = false
        self.addressNonEditLabel.alpha = 1.0
        self.addressTextView.isHidden  = true
        self.addressTextView.alpha = 0.0
        self.setToggleBtns(isEnabled: false, alpha: 0.9)
        self.addUploadTextFieldRightView()
        self.memberImg.isUserInteractionEnabled = false
        
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
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        self.selectedDate = dateFormatter.string(from:datePicker.date )
        self.view.endEditing(true)
      }
    
    func memberNavigationBar()  {
        memberNaviagationBar.menuBtn.isHidden = true
        memberNaviagationBar.leftArrowBtn.isHidden = false
        memberNaviagationBar.leftArrowBtn.alpha = 1.0
        memberNaviagationBar.searchBtn.isHidden = true
        memberNaviagationBar.navigationTitleLabel.text = "Member"
        self.setBackAction(toView: self.memberNaviagationBar)
        memberNaviagationBar?.editBtn.isHidden = false
        memberNaviagationBar?.editBtn.alpha = 1.0
        memberNaviagationBar?.editBtn.addTarget(self, action: #selector(makeEditable), for: .touchUpInside)
    }
    
    func setTextFields()  {
        [self.memberIDTextField,self.dateOfJoiningTextField,self.genderTextField,self.passwordTextField,self.trainerNameTextField,self.emailTextField,self.uploadIDTextField,self.phoneNoTextField,self.dobTextField].forEach{
            $0?.addPaddingToTextField(height: 10, Width: 10)
                           $0?.layer.cornerRadius = 7.0
                           $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
                           $0?.clipsToBounds = true
            $0?.addTarget(self, action: #selector(fieldsValidatorAction(_:)), for: .editingChanged)
        }
        self.addressTextView.layer.cornerRadius = 7.0
    }
    
    
    @objc func fieldsValidatorAction(_ textField:UITextField) {
        self.allMemberProfileFieldsRequiredValidation(textField: textField)
//        validation.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField)
        
    }
    
    @objc func makeEditable() {
       if self.isEdit == true {
        self.memberImg.isUserInteractionEnabled = false
        AppManager.shared.performEditAction(dataFields:self.getMemberProfileFieldsAndLabelDic(), edit:  false)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: self.errorLabelArray, flag: true)
        self.addressNonEditLabel.isHidden = false
        self.addressTextView.isHidden  = true
        self.addressTextView.alpha = 0.0
        self.isEdit = false
        self.setHrLineView(isHidden: false, alpha: 1.0)
        self.setToggleBtns(isEnabled: false, alpha: 0.9)
        self.updateBtn.isHidden = true
       } else{
        self.memberImg.isUserInteractionEnabled = true
        AppManager.shared.performEditAction(dataFields:self.getMemberProfileFieldsAndLabelDic(), edit:  true)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: errorLabelArray, flag: false)
        self.setToggleBtns(isEnabled: true, alpha: 1.0)
        self.memberIDTextField.isEnabled = true
        self.memberIDTextField.layer.opacity = 0.4
        self.isEdit = true
        self.addressNonEditLabel.isHidden = true
        self.addressTextView.isHidden  = false
        self.addressTextView.alpha = 1.0
        self.setHrLineView(isHidden: true, alpha: 0.0)
        self.memberIDTextField.isEnabled = false
        self.updateBtn.isHidden = false
        self.updateBtn.alpha = 1.0
        }
       }

       func setHrLineView(isHidden:Bool,alpha:CGFloat) {
        [self.genderHrLineView,self.addressHrLineView,self.memberIDHrLineView,self.trainerNameHrView,self.phoneNoHrLineView,self.uploadIDHrView,self.emailHrLineView].forEach{
               $0?.isHidden = isHidden
               $0?.alpha = alpha
           }
       }

       func getMemberProfileFieldsAndLabelDic() -> [UITextField:UILabel] {
        let dir = [
            self.memberIDTextField! : self.memberIDNonEditLabel!,
            self.dateOfJoiningTextField! : self.dateOfJoiningNonEditLabel!,
            self.genderTextField! : self.genderNonEditLabel!,
            self.passwordTextField! : self.passwordNonEditLabel!,
            self.trainerNameTextField! : self.trainerNameNonEditLabel!,
            self.uploadIDTextField! : self.uploadIDNonEditLabel!,
            self.emailTextField! : self.emailNonEditLabel!,
            self.phoneNoTextField! : self.phoneNoNonEditScreenLabel!,
            self.dobTextField! : self.dobNonEditScreenLabel!
        ]
           return dir
       }
       
    func setToggleBtns(isEnabled:Bool,alpha:CGFloat) {
        [self.generalToggleBtn,self.personalToggleBtn].forEach{
            $0?.isEnabled = isEnabled
            $0?.alpha = alpha
        }
    }
    
    func fetchMemberProfileDetails(id:String)  {
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (data,err) in
            if err != nil {
                self.viewDidLoad()
            } else {
                let memberDetail = data?["memberDetail"] as! NSDictionary
                self.fillMemberProfileDetail(memberDetail: AppManager.shared.getMemberDetailStr(memberDetail: memberDetail ))
             }
        })
    }
    
    func fillMemberProfileDetail(memberDetail:MemberDetailStructure) {
        self.firstName = memberDetail.firstName
        self.lastName = memberDetail.lastName
        self.memberFullNameLabel.text = "\(self.firstName) \(self.lastName)"
        self.memberIDNonEditLabel.text = memberDetail.memberID
        self.dateOfJoiningNonEditLabel.text = memberDetail.dateOfJoining
        self.genderNonEditLabel.text = memberDetail.gender
        self.passwordNonEditLabel.text = memberDetail.password
        self.trainerNameNonEditLabel.text = memberDetail.trainerName
        self.emailNonEditLabel.text = memberDetail.email
        self.uploadIDNonEditLabel.text = memberDetail.uploadIDName
        self.addressNonEditLabel.text = memberDetail.address
        self.phoneNoNonEditScreenLabel.text = memberDetail.phoneNo
        self.dobNonEditScreenLabel.text = memberDetail.dob
        self.setMemberProfileTrainerType(type: memberDetail.type)

        self.memberIDTextField.text! = memberDetail.memberID
        self.dateOfJoiningTextField.text! = memberDetail.dateOfJoining
        self.genderTextField.text! = memberDetail.gender
        self.passwordTextField.text! = memberDetail.password
        self.trainerNameTextField.text! = memberDetail.trainerName
        self.emailTextField.text! = memberDetail.email
        self.addressTextView.text! = memberDetail.address
        self.phoneNoTextField.text! = memberDetail.phoneNo
        self.dobTextField.text! = memberDetail.dob
     }
    
    func setMemberProfileTrainerType(type:String) {
        if type == "General"{
            self.generalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
       
        } else {
            self.generalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.personalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        }
     }
    
    func selectedMemberType() -> String {
           var type :String = ""
           if self.generalToggleBtn.currentImage == UIImage(named: "selelecte"){
               type = "General"
           } else {
               type = "Personal"
           }
           return type
       }
    
    func getMemberProfileDetails() -> [String:String] {
         let memberDetail:[String:String] = [
            "firstName":self.firstName,
            "lastName": self.lastName,
             "memberID":self.memberIDTextField.text!,
             "dateOfJoining":self.dateOfJoiningTextField.text!,
             "gender":self.genderTextField.text!,
             "password":self.passwordTextField.text!,
             "type":self.selectedMemberType(),
             "trainerName":self.trainerNameTextField.text!,
             "uploadIDName":self.uploadIDTextField.text!,
             "email":self.emailTextField.text!,
             "address":self.addressTextView.text!,
             "phoneNo" : self.phoneNoTextField.text!,
             "dob":self.dobTextField.text!,
         ]
         return memberDetail
     }
    
    func showMemberProfileAlert(title:String,message:String)  {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
               (action) in
            if title == "Success" {
                self.viewWillAppear(true)
            }
           })
           alert.addAction(okAlertAction)
           present(alert, animated: true, completion: nil)
       }
    
    func addUploadTextFieldRightView() {
        let imgView = UIImageView(image: UIImage(named: "cam.png"))
        imgView.contentMode = UIView.ContentMode.center
        var v:UIView? = nil
        
        imgView.frame = CGRect(x: 0.0, y: 0.0, width:20, height: 20)
        v = UIView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width + 10 , height: imgView.frame.height))
        v!.addSubview(imgView)
        v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMemberProfileImgPicker)))

        self.uploadIDTextField.rightView = v
        self.uploadIDTextField.rightViewMode = .always
    }
    
    @objc func openMemberProfileImgPicker(){
        self.imgPicker.allowsEditing = true
        self.imgPicker.modalPresentationStyle = .fullScreen
        self.imgPicker.sourceType = .photoLibrary
        present(self.imgPicker, animated: true, completion: nil)
    }
    
    @objc func openUserProfilePicker(){
           self.isUserProfileSelected = true
           self.imgPicker.allowsEditing = true
           self.imgPicker.modalPresentationStyle = .overCurrentContext
           self.imgPicker.sourceType = .photoLibrary
           present(self.imgPicker, animated: true, completion: nil)
       }
}

extension MemberViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if self.isUserProfileSelected == true{
            if let selectedImg:UIImage = info[.editedImage] as? UIImage {
                self.memberImg.image = selectedImg
                dismiss(animated: true, completion: nil)
            }
        } else {
            if let selectedImgURL:URL = info[ .imageURL ] as? URL {
                self.imgURL = selectedImgURL
                let imgaeName = selectedImgURL.lastPathComponent
                self.uploadIDTextField.text = imgaeName
                self.isUploadIdSelected = true
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isUploadIdSelected = false
        dismiss(animated: true, completion: nil)
    }
}

extension MemberViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 || textField.tag == 9 {
            return false
        } else{
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 || textField.tag == 9 {
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.selectedDate.count > 1 {
            switch textField.tag {
            case 2:
                self.dateOfJoiningTextField.text = self.selectedDate
            case 9:
                self.dobTextField.text = self.selectedDate
            default:
                break
            }
        }

        self.allMemberProfileFieldsRequiredValidation(textField: textField)
        validation.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField,email:self.emailTextField.text!,password:self.passwordTextField.text!)
    }
}

extension MemberViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.validation.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
        validation.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: self.phoneNoTextField,email:self.emailTextField.text!,password:self.passwordTextField.text!)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.validation.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
    }
}
