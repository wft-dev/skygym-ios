//
//  MemberViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 07/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD


class ListOfTrainerTableCell: UITableViewCell {
    @IBOutlet weak var trainerName: UILabel!
}

class MemberViewController: BaseViewController {
    
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
    @IBOutlet weak var generalTypeLabel: UILabel!
    @IBOutlet weak var personalTypeLabel: UILabel!
    @IBOutlet weak var listOfTrainerView: UIView!
    @IBOutlet weak var listOfTrainerTable: UITableView!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var trainerListShowBtn: UIButton!
    
    private lazy var imgPicker:UIImagePickerController = {
        return UIImagePickerController()
    }()

    private lazy var genderPickerView:UIPickerView = {
        return UIPickerView()
    }()
    
    private lazy var validator:ValidationManager = {
      return  ValidationManager.shared
    }()
    
    var isEdit:Bool = false
    var firstName:String = ""
    var lastName:String = ""
    var datePicker = UIDatePicker()
    var toolBar:UIToolbar? = nil
    var imgURL:URL? = nil
    var isUploadIdSelected:Bool = false
    var isUserProfileSelected:Bool = false
    var img:UIImage? = nil
    var forNonEditLabelArray:[UILabel] = []
    var defaultLabelArray:[UILabel] = []
    var errorLabelArray:[UILabel] = []
    var textFieldArray:[UITextField] = []
    var selectedDate:String = ""
    var actualPassword :String = ""
    var isImagePickerSelected:Bool = false
    var trainerType:String = ""
    var trainerID:String = ""
    var listOfTrainers:[TrainerDataStructure] = []
    var isAlreadyExistsEmail:Bool = false
    var memberEmail:String = ""
    let genderArray = ["Male","Female","Other"]

    override func viewDidLoad() {
        self.setMemberProfileCompleteView()
        setMemberViewNavigationView()
    }

    func isFieldsDataValid() -> Bool {
        return self.validator.isMemberProfileValidated(textFieldArray: self.textFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!) == true  && isAlreadyExistsEmail == false
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        SVProgressHUD.show()
        let encryptedPassword = AppManager.shared.encryption(plainText: self.passwordTextField.text!)
        if self.isFieldsDataValid() == true {
            FireStoreManager.shared.updateUserCredentials(id: AppManager.shared.memberID, email: self.emailTextField.text!, password: encryptedPassword, handler: {
                (err) in
                
                FireStoreManager.shared.updateMemberDetails(id: AppManager.shared.memberID,memberDetail: self.getMemberProfileDetails(), handler: {
                    (err) in
                    if err != nil {
                        self.showMemberProfileAlert(title: "Error", message: "Member detail is not updated.")
                    } else {
                        if self.isUploadIdSelected == true {
                            FireStoreManager.shared.uploadImg(url: self.imgURL!, membeID: AppManager.shared.memberID, imageName: self.uploadIDTextField.text!, completion: {
                                (err) in
                                SVProgressHUD.dismiss()
                                if err != nil {
                                    self.showMemberProfileAlert(title: "Error", message: "Member detail is not updated.")
                                } else {
                                    self.showMemberProfileAlert(title: "Success", message: "Member detail is updated successfully.")
                                }
                            })
                            self.isUserProfileSelected = false
                        }
                         if self.memberImg.tag == 1111 {
                            FireStoreManager.shared.uploadUserImg(imgData: (self.memberImg.image?.pngData())!, id: AppManager.shared.memberID, completion: {
                                err in
                                SVProgressHUD.dismiss()
                                if err == nil {
                                    self.showMemberProfileAlert(title: "Success", message: "Member detail is updated successfully.")
                                }
                            })
                            self.isUserProfileSelected = false
                        }
                        else {
                            SVProgressHUD.dismiss()
                            self.showMemberProfileAlert(title: "Success", message: "Member detail is updated successfully.")
                        }
                    }
                })
            })
        }else {
            SVProgressHUD.dismiss()
            for textField in self.textFieldArray {
                self.allMemberProfileFieldsRequiredValidation(textField: textField)
            }
            DispatchQueue.main.async {
                self.updateBtn.isEnabled = false
                self.updateBtn.alpha = 0.4
            }
        }
    }
    
    func setMemberViewNavigationView() {
        let title = NSAttributedString(string:"Member", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        self.navigationItem.titleView = titleLabel
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(memberViewBackBtnAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let leftSpaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [leftSpaceBtn,backButton])
        stackView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        let backBtn = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backBtn
        
        if AppManager.shared.loggedInRole != LoggedInRole.Member{
            let editButton = UIButton()
            editButton.setImage(UIImage(named: "edit"), for: .normal)
            editButton.addTarget(self, action: #selector(makeEditable), for: .touchUpInside)
            editButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            editButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
            editButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
            let rightStackView = UIStackView(arrangedSubviews: [editButton,spaceBtn])
            rightStackView.widthAnchor.constraint(equalToConstant: 28).isActive = true
            let rightEditBtn = UIBarButtonItem(customView: rightStackView)
            navigationItem.rightBarButtonItem = rightEditBtn
        }   
    }
    
    @objc  func memberViewBackBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func generalToggleBtnAction(_ sender: Any) {
        if self.generalToggleBtn.currentImage == UIImage(named: "non_selecte") {
            self.generalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
        self.trainerNameTextField.text = ""
         self.allMemberProfileFieldsRequiredValidation(textField: self.trainerNameTextField)
        self.fetchListOfTrainer(category: .general)
    }
    
    @IBAction func personalToggleBtnAction(_ sender: Any) {
        if self.personalToggleBtn.currentImage == UIImage(named: "non_selecte") {
            self.personalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.generalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
        self.trainerNameTextField.text = ""
         self.allMemberProfileFieldsRequiredValidation(textField: self.trainerNameTextField)
        self.fetchListOfTrainer(category: .personal)
    }
    
    
    @IBAction func trainerNameListBtnAction(_ sender: Any) {
       self.listOfTrainerView.isHidden = !self.listOfTrainerView.isHidden
        self.listOfTrainerView.alpha = self.listOfTrainerView.isHidden == true ? 0.0 : 1.0
    }

    func fetchListOfTrainer(category:TrainerType) {
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getTrainerByCategory(category: category)
            
            DispatchQueue.main.async {
                switch result {
                    
                case let .success(trainerArray):
                    self.listOfTrainers = trainerArray
                    self.listOfTrainerTable.reloadData()
                case .failure(_):
                    break
                }
            }
        }
    }

    func allMemberProfileFieldsRequiredValidation(textField:UITextField)  {
        switch textField.tag {
        case 1:
            self.validator.requiredValidation(textField: textField, errorLabel: self.memberIDErrorLabel, errorMessage: "Member ID required.")
        case 2:
            self.validator.requiredValidation(textField: textField, errorLabel: self.dateOfJoiningErrorLabel, errorMessage: "Date of join required.")
        case 3:
            self.validator.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "Member's gender required." )
        case 4:
            self.validator.passwordValidation(textField: textField, errorLabel:self.passwordErrorLabel, errorMessage: "Password must be greater than 8 character.")
        case 5:
            self.validator.requiredValidation(textField: textField, errorLabel: self.trainerNameErrorLabel, errorMessage: "Trainer's name required.")
        case 6:
            self.validator.requiredValidation(textField: textField, errorLabel: self.uploadIDErrorLabel, errorMessage: "Upload ID required." )
        case 7:
            self.validator.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Invalid email address.")
        case 8:
            self.validator.phoneNumberValidation(textField: textField, errorLabel:self.phoneNumberErrorLabel, errorMessage: "Phone number must be 10 digits only.")
        case 9:
                self.validator.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required." )
        default:
            break
        }
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField,email:self.emailTextField.text!,password:self.passwordTextField.text!)
    }
    
    func setMemberProfileCompleteView()  {
        SVProgressHUD.show()
        self.toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        setTextFields()
        self.updateBtn.layer.cornerRadius = 15.0
        self.updateBtn.isHidden = !self.isImagePickerSelected
        
        self.memberImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUserProfilePicker)))
        self.imgPicker.delegate = self
        self.listOfTrainerTable.isScrollEnabled = false
        
        self.forNonEditLabelArray = [self.memberIDForNonEditLabel,self.dateOfJoiningForNonEditLabel,self.genderForNonEditLabel,self.passwordForNonEditLabel,self.trainerNameForNonEditLabel,self.uploadForNonEditLabel,self.emailForNonEditLabel,self.addressForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel]
        self.defaultLabelArray = [self.memberID,self.dateOfJoining,self.gender,self.password,self.trainerName,self.uploadID,self.email,self.address,self.phoneNo,self.dob]
        self.errorLabelArray = [self.memberIDErrorLabel,self.dateOfJoiningErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.addressErrorLabel,self.trainerNameErrorLabel,self.uploadIDErrorLabel,self.emailErrorLabel,self.phoneNumberErrorLabel,self.dobErrorLabel]
        self.textFieldArray = [self.memberIDTextField,self.dateOfJoiningTextField,self.genderTextField,self.trainerNameTextField,self.uploadIDTextField,self.phoneNoTextField,self.dobTextField]
        self.personalTypeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trainerTypeAction(_:))))
        self.generalTypeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trainerTypeAction(_:))))
        
        AppManager.shared.performEditAction(dataFields: self.getMemberProfileFieldsAndLabelDic(), edit: self.isImagePickerSelected )
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: self.errorLabelArray, flag: !self.isImagePickerSelected)
        AppManager.shared.hidePasswordTextField(hide: !self.isImagePickerSelected, passwordTextField: self.passwordTextField, passwordLabel: self.passwordNonEditLabel)
        self.trainerListShowBtn.isEnabled = false
        
        self.setHrLineView(isHidden: self.isImagePickerSelected, alpha: 1.0)
        self.addressNonEditLabel.isHidden = self.isImagePickerSelected
        self.addressNonEditLabel.alpha =  self.isImagePickerSelected == false ? 1.0 : 0.0
        self.addressTextView.isHidden  = !self.isImagePickerSelected
        self.addressTextView.alpha = self.isImagePickerSelected == false ? 0.0 : 1.0
        self.trainerTypeLabel.textColor =  self.isImagePickerSelected == false ? .lightGray : .black
        self.setToggleBtns(isEnabled: self.isImagePickerSelected, alpha: self.isImagePickerSelected == false ?  0.9 : 1.0)
        self.addUploadTextFieldRightView()
        self.memberImg.isUserInteractionEnabled = self.isImagePickerSelected

        self.datePicker.datePickerMode = .date
        toolBar!.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar!.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar!.sizeToFit()
        self.addClickToDismissTrainerList()
        
        self.listOfTrainerView.layer.cornerRadius = 12.0
        self.listOfTrainerView.layer.borderWidth = 1.0
        self.listOfTrainerView.layer.borderColor = UIColor.black.cgColor
        self.listOfTrainerTable.layer.cornerRadius = 12.0
        self.listOfTrainerTable.layer.borderWidth = 1.0
        self.listOfTrainerTable.layer.borderColor = UIColor.black.cgColor
        self.listOfTrainerView.isHidden = true
        self.listOfTrainerView.alpha = 0.0
        
        self.trainerNameTextField.isUserInteractionEnabled = false
        self.trainerNameTextField.isEnabled = false
        self.fetchMemberProfileDetails(id: AppManager.shared.memberID)
        
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
        
        self.memberImg.image = self.img
        self.memberImg.makeRounded()
        self.memberImg.tag = 00
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
    
    private func addClickToDismissTrainerList() {

           let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedView(_:)))
           tapRecognizer.cancelsTouchesInView = false
           self.view.isUserInteractionEnabled = true
           tapRecognizer.delegate = self
           self.view.addGestureRecognizer(tapRecognizer)
       }

       @objc
    private func dismissPresentedView(_ sender: Any?) {
        self.listOfTrainerView.isHidden = true
        self.listOfTrainerView.alpha = 0.0
        self.view.endEditing(true)
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
    }
    
    @objc func makeEditable() {
       if self.isEdit == true {
        self.memberImg.isUserInteractionEnabled = false
        AppManager.shared.performEditAction(dataFields:self.getMemberProfileFieldsAndLabelDic(), edit:  false)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: self.errorLabelArray, flag: true)
        AppManager.shared.hidePasswordTextField(hide: true, passwordTextField: self.passwordTextField, passwordLabel: self.passwordNonEditLabel)
        self.addressNonEditLabel.isHidden = false
        self.addressNonEditLabel.alpha = 1.0
        self.addressTextView.isHidden  = true
        self.addressTextView.alpha = 0.0
        self.trainerTypeLabel.textColor = .lightGray
        self.isEdit = false
        self.setHrLineView(isHidden: false, alpha: 1.0)
        self.setToggleBtns(isEnabled: false, alpha: 0.9)
        self.generalTypeLabel.isUserInteractionEnabled = false
        self.personalTypeLabel.isUserInteractionEnabled = false
        self.updateBtn.isHidden = true
        self.setMemberProfileTrainerType(type: self.trainerType)
        self.trainerListShowBtn.isEnabled = false
       } else{
        self.memberImg.isUserInteractionEnabled = true
        AppManager.shared.performEditAction(dataFields:self.getMemberProfileFieldsAndLabelDic(), edit:  true)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: errorLabelArray, flag: false)
        AppManager.shared.hidePasswordTextField(hide: false, passwordTextField: self.passwordTextField, passwordLabel: self.passwordNonEditLabel)
        self.setToggleBtns(isEnabled: true, alpha: 1.0)
        DispatchQueue.main.async {
            self.generalTypeLabel.isUserInteractionEnabled = true
            self.personalTypeLabel.isUserInteractionEnabled = true
        }
        self.memberIDTextField.layer.opacity = 0.4
        self.trainerTypeLabel.textColor = .black
        self.isEdit = true
        self.addressNonEditLabel.isHidden = true
        self.addressNonEditLabel.alpha = 0.0
        self.addressTextView.isHidden  = false
        self.addressTextView.alpha = 1.0
        self.setHrLineView(isHidden: true, alpha: 0.0)
        self.memberIDTextField.isEnabled = false
        self.updateBtn.isHidden = false
        self.updateBtn.alpha = 1.0
        self.updateBtn.isEnabled = true
        self.trainerListShowBtn.isEnabled = true
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
            SVProgressHUD.dismiss()
            if err != nil {
                self.showMemberProfileAlert(title: "Retry", message: "Error in getting member's details, please try again.")
            } else {
                let memberDetail = data?["memberDetail"] as! Dictionary<String,String>
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
        self.actualPassword = ""
        self.actualPassword = memberDetail.password
        self.passwordNonEditLabel.text = AppManager.shared.getSecureTextFor(text: memberDetail.password)
        self.emailNonEditLabel.text = memberDetail.email
        self.uploadIDNonEditLabel.text = memberDetail.uploadIDName
        self.addressNonEditLabel.text = memberDetail.address
        self.phoneNoNonEditScreenLabel.text = memberDetail.phoneNo
        self.dobNonEditScreenLabel.text = memberDetail.dob
        self.memberEmail = memberDetail.email
        self.trainerID = memberDetail.trainerID
        if memberDetail.trainerID != "" {
            self.fetchTrainer(trainerID: memberDetail.trainerID)
        }else {
            self.trainerNameNonEditLabel.text = ""
            self.trainerNameTextField.text! = ""
            self.trainerType = ""
            self.setMemberProfileTrainerTypeNone()
        }

        self.memberIDTextField.text! = memberDetail.memberID
        self.dateOfJoiningTextField.text! = memberDetail.dateOfJoining
        self.genderTextField.text! = memberDetail.gender
        self.passwordTextField.text! = self.actualPassword
        self.emailTextField.text! = memberDetail.email
        self.addressTextView.text! = memberDetail.address
        self.phoneNoTextField.text! = memberDetail.phoneNo
        self.dobTextField.text! = memberDetail.dob
        
        if self.emailTextField.text == memberDetail.email {
            self.isAlreadyExistsEmail = false
        }else {
            self.isAlreadyExistsEmail = true
        }
     }
    
    func fetchTrainer(trainerID:String)  {
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getTrainerDetailBy(id: trainerID)
            
            DispatchQueue.main.async {
                switch result {
                    
                case let .success(trainerDetail):
                    self.trainerNameNonEditLabel.text = "\(trainerDetail!.firstName) \(trainerDetail!.lastName)"
                    self.trainerNameTextField.text! = "\(trainerDetail!.firstName) \(trainerDetail!.lastName)"
                    self.trainerType = trainerDetail!.type
                    self.setMemberProfileTrainerType(type: self.trainerType)
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func setMemberProfileTrainerTypeNone() {
        self.generalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        self.personalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
    }
    
    @objc func trainerTypeAction(_ gesture:UITapGestureRecognizer){
        let selectedLabel = gesture.view as! UILabel
        self.trainerNameTextField.text = ""
        DispatchQueue.main.async {
            self.setMemberProfileTrainerType(type: selectedLabel.text!)
        }
    }
    
    func setMemberProfileTrainerType(type:String) {
        let trainerName = self.trainerNameTextField.text
        if trainerName != "" {
            self.trainerNameErrorLabel.text = ""
            self.trainerNameTextField.borderStyle = .none
            self.trainerNameTextField.layer.borderColor = UIColor.clear.cgColor
            self.trainerNameTextField.layer.borderWidth = 0.0
            } else {
            self.trainerNameErrorLabel.text = "Trainer's name required."
            self.trainerNameTextField.layer.borderColor = UIColor.red.cgColor
            self.trainerNameTextField.layer.borderWidth = 1.0
            }
        
        if type == "General"{
            self.generalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.fetchListOfTrainer(category: .general)
        } else {
            self.generalToggleBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.personalToggleBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.fetchListOfTrainer(category: .personal)
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
             "password":AppManager.shared.encryption(plainText: self.passwordTextField.text!),
             "type":self.selectedMemberType(),
             "trainerName":self.trainerNameTextField.text!,
             "uploadIDName":self.uploadIDTextField.text!,
             "email":self.emailTextField.text!,
             "address":self.addressTextView.text!,
             "phoneNo" : self.phoneNoTextField.text!,
             "dob":self.dobTextField.text!,
             "trainerID":self.trainerID
         ]

         return memberDetail
     }
    
    func showMemberProfileAlert(title:String,message:String)  {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
               (action) in
            if title == "Success" || title == "Retry" {
                self.fetchMemberProfileDetails(id: AppManager.shared.memberID )
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
        self.isUserProfileSelected = false
        self.imgPicker.allowsEditing = true
        self.imgPicker.modalPresentationStyle = .fullScreen
        self.imgPicker.sourceType = .photoLibrary
        present(self.imgPicker, animated: true, completion: nil)
    }
    
    @objc func openUserProfilePicker(){
           self.isUserProfileSelected = true
           self.imgPicker.allowsEditing = true
           self.imgPicker.modalPresentationStyle = .fullScreen
           self.imgPicker.sourceType = .photoLibrary
           present(self.imgPicker, animated: true, completion: nil)
       }
}

extension MemberViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.isImagePickerSelected = true
        
        if self.isUserProfileSelected == true{
            if let selectedImg:UIImage = info[.editedImage] as? UIImage {
                self.memberImg.image = selectedImg
                self.memberImg.tag = 1111
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
        self.isImagePickerSelected = true
        dismiss(animated: true, completion: nil)
    }
}

extension MemberViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 || textField.tag == 9 || textField.tag == 6 || textField.tag == 3  {
            return false
        } else{
            return true
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.listOfTrainerView.isHidden == false && textField.tag != 5 {
            self.listOfTrainerView.isHidden = true
            self.listOfTrainerView.alpha = 0.0
        }
        
        if textField.tag == 2 || textField.tag == 9 {
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
        }
        
        if textField.tag == 3 {
            var row:Int = 0
            switch textField.text {
            case "Male":
                row = 0
            case "Female":
                row = 1
            case "Others":
                row = 2
            default:
                row = 0
            }
            self.genderPickerView.selectRow(row, inComponent: 0, animated: true)
            textField.inputView = self.genderPickerView
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
        
        if textField.tag == 7 {
            let email = textField.text!
            if self.memberEmail != email {
                DispatchQueue.global(qos: .default).async {
                    let result = FireStoreManager.shared.isUserExists(email: email)
                    DispatchQueue.main.async {
                        switch result {
                        case let  .success(flag):
                            if flag == false {
                                self.isAlreadyExistsEmail = false
                                self.updateBtn.isEnabled = true
                                self.updateBtn.alpha = 1.0
                                self.emailErrorLabel.text = ""
                                textField.layer.borderColor = .none
                                textField.layer.borderWidth = 0.0
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

        self.allMemberProfileFieldsRequiredValidation(textField: textField)
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField,email:self.emailTextField.text!,password:self.passwordTextField.text!)
        
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

extension MemberViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.validator.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
        self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: self.phoneNoTextField,email:self.emailTextField.text!,password:self.passwordTextField.text!)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.validator.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
       self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: self.phoneNoTextField,email:self.emailTextField.text!,password:self.passwordTextField.text!)
        
        DispatchQueue.main.async {
            if self.isAlreadyExistsEmail == true {
                self.emailTextField.layer.borderColor = UIColor.red.cgColor
                self.emailTextField.layer.borderWidth = 1.0
                self.emailErrorLabel.text = "Email already exists."
                self.updateBtn.isEnabled = false
                self.updateBtn.alpha = 0.4
            }else {
                self.emailTextField.layer.borderColor = .none
                self.emailTextField.layer.borderWidth = 0.0
                self.emailErrorLabel.text = ""
                self.updateBtn.isEnabled = true
                self.updateBtn.alpha = 1.0
            }
        }
    }
}


extension MemberViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfTrainers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listOfTrainerCell", for: indexPath) as! ListOfTrainerTableCell
        let singleTrainer = self.listOfTrainers[indexPath.row]
        cell.trainerName.text = "\(singleTrainer.firstName) \(singleTrainer.lastName)"
        
        return cell
    }
}

extension MemberViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleTrainer = self.listOfTrainers[indexPath.row]
        self.trainerID = singleTrainer.trainerID
        self.trainerNameTextField.text = "\(singleTrainer.firstName) \(singleTrainer.lastName)"
        self.listOfTrainerView.isHidden = true
        DispatchQueue.main.async {
            self.allMemberProfileFieldsRequiredValidation(textField: self.trainerNameTextField)
            self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }
    }
}

extension MemberViewController:UIPickerViewDataSource{
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

extension MemberViewController:UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField.text = self.genderArray[row]
        DispatchQueue.main.async {
            self.allMemberProfileFieldsRequiredValidation(textField: self.trainerNameTextField)
            self.validator.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }
    }
    
}

extension MemberViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         self.view.endEditing(true)
        if touch.view?.isDescendant(of: self.listOfTrainerView) == true ||
            touch.view?.tag == 110 {
            return false
        }else {
            return true
        }
        
    }
}
