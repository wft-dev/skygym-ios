//
//  ProfileAdminViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/02/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//
import UIKit
import SVProgressHUD


class ProfileAdminViewController: UIViewController {
    
    @IBOutlet weak var adminProfileNavigationBar: CustomNavigationBar!
    @IBOutlet weak var gymNameTextField: UITextField!
    @IBOutlet weak var gymIDTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var adminScrollView: UIScrollView!
    @IBOutlet weak var adminProfileImg: UIImageView!
    @IBOutlet weak var gymName: UILabel!
    @IBOutlet weak var gymNameNonEditLabel: UILabel!
    @IBOutlet weak var gymNameForNonEditLabel: UILabel!
    @IBOutlet weak var gymID: UILabel!
    @IBOutlet weak var gymIDForNonEditLabel: UILabel!
    @IBOutlet weak var gymIDNonEditLabel: UILabel!
    @IBOutlet weak var gymNameHrLineView: UIView!
    @IBOutlet weak var gymNameErrorLabel: UILabel!
    @IBOutlet weak var gymIDErrorLabel: UILabel!
    @IBOutlet weak var gymAddress: UILabel!
    @IBOutlet weak var gymAddressForNonEditLabel: UILabel!
    @IBOutlet weak var gymAddressNonEditLabel: UILabel!
    @IBOutlet weak var gymAddressHrLineView: UIView!
    @IBOutlet weak var gymAddressErrorLabel: UILabel!
    @IBOutlet weak var openningTimeLabel: UILabel!
    @IBOutlet weak var openningTimeForNonEditLabel: UILabel!
    @IBOutlet weak var openningTimeNonEditLabel: UILabel!
    @IBOutlet weak var openningTimeTextField: UITextField!
    @IBOutlet weak var openningTimeErrorLabel: UILabel!
    @IBOutlet weak var closingTimeLabel: UILabel!
    @IBOutlet weak var closingTimeForNonEditLabel: UILabel!
    @IBOutlet weak var closingTimeNonEditLabel: UILabel!
    @IBOutlet weak var closingTimeTextField: UITextField!
    @IBOutlet weak var closingTimeErrorLabel: UILabel!
    @IBOutlet weak var gymTimeHrLineView: UIView!
    @IBOutlet weak var gymDays: UILabel!
    @IBOutlet weak var gymDaysForNonEditLabel: UILabel!
    @IBOutlet weak var gymDaysNonEditLabel: UILabel!
    @IBOutlet weak var gymDaysTextField: UITextField!
    @IBOutlet weak var gymDaysErrorLabel: UILabel!
    @IBOutlet weak var gymDaysHrLineView: UIView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var firstNameForNonEditLabel: UILabel!
    @IBOutlet weak var firstNameNonEditLabel: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var lastNameForNonEditLabel: UILabel!
    @IBOutlet weak var lastNameNonEditLabel: UILabel!
    @IBOutlet weak var firstNameHrLineView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var genderNonEditLabel: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var passwordForNonEditLabel: UILabel!
    @IBOutlet weak var passworNonEditLabel: UILabel!
    @IBOutlet weak var genderHrLineView: UIView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var emailNonEditLabel: UILabel!
    @IBOutlet weak var emailHrLineView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNo: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoNonEditLabel: UILabel!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var dobForNonEditLabel: UILabel!
    @IBOutlet weak var dobNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoHrLineView: UIView!
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var phoneNoErrorLabel: UILabel!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var dobErrorLabel: UILabel!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var weekDaysListView: UIView!
    @IBOutlet weak var weekDaysListTable: UITableView!
    @IBOutlet weak var weekDaysListBtn: UIButton!
    
    
    private lazy var imagePicker:UIImagePickerController = {
        return UIImagePickerController()
    }()
    
    private lazy var datePicker:UIDatePicker = {
        return UIDatePicker()
    }()
    
    private lazy var timePicker :UIDatePicker = {
        return UIDatePicker()
    }()
    
    private lazy var genderPickerView:UIPickerView = {
        return UIPickerView()
    }()

    var isProfileImgSelected:Bool = false
    var isEdit:Bool = false
    var toolBar:UIToolbar? = nil
    var selectedDate:String = ""
    var selectedTime:String = ""
    var forNonEditLabelArray:[UILabel] = []
    var defaultLabelArray:[UILabel] = []
    var textFieldsArray:[UITextField] = []
    var errorLabelArray:[UILabel] = []
    var actualPassword:UILabel? = nil
    var duplicateError:String = ""
    var weekdayArray:[String] = []
    var imageName = ""
    var selectedWeekdaysArray:[Int] = []
    var isAlreadyExistsEmail:Bool = false
    var adminEmail:String = ""
    var genderArray:[String] = []

    override func viewDidLoad() {
        SVProgressHUD.show()
        self.toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        self.weekdayArray = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        self.genderArray = ["Male","Female","Other"]
        self.actualPassword = UILabel()
        self.addClickToDismissGymWeekDaysList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setAdminProfileView()
        self.fetchAdminDetailBy(id: AppManager.shared.adminID)
        
    }

    @IBAction func updateBtnAction(_ sender: Any) {
        let adminID = AppManager.shared.adminID
        SVProgressHUD.show()
        if ValidationManager.shared.isAllFieldsRequiredValidated(textFieldArray: self.textFieldsArray, phoneNumberTextField: self.phoneNoTextField) == true && ValidationManager.shared.isEmailValid(email: self.emailTextField.text!) == true && ValidationManager.shared.isPasswordValid(password: self.passwordTextField.text!) == true && self.isAlreadyExistsEmail == false {
            if self.isProfileImgSelected == true {
                FireStoreManager.shared.uploadUserImg(imgData: (self.adminProfileImg.image?.pngData())!, id: AppManager.shared.adminID, completion: {
                    err in
                    SVProgressHUD.dismiss()
                    if err != nil {
                      //  self.showAdminProfileAlert(title: "Error", message: "Error in uploading the user profile image, Please try again.")
                    } else {
                        FireStoreManager.shared.updateAdminDetail(id: adminID,adminDetail: self.getAdminDetailForUpdate(), result: {
                            (err) in
                            self.isProfileImgSelected = false
                            AppManager.shared.isInitialUploaded = true
                            if err != nil {
                                self.showAdminProfileAlert(title: "Error", message: "Error in updating admin details, please try again.")
                            } else {
                                self.showAdminProfileAlert(title: "Success", message: "Admin details are updated successfully.")
                            }
                        })
                    }
                })
            }  else {
                FireStoreManager.shared.updateAdminDetail(id: adminID, adminDetail: self.getAdminDetailForUpdate(), result: {
                    (err) in
                    SVProgressHUD.dismiss()
                    if err != nil {
                        self.showAdminProfileAlert(title: "Error", message: "\(err!.localizedDescription)")
                        //Error in updating admin details, please try again.
                    } else {
                        self.showAdminProfileAlert(title: "Success", message: "Admin details are updated successfully.")
                    }
                })
            }
        }else {
            SVProgressHUD.dismiss()
            self.emailTextField.layer.borderColor = UIColor.red.cgColor
            self.emailTextField.layer.borderWidth = 1.0
            self.emailErrorLabel.text = "Email already exists."
            self.updateBtn.isEnabled = false
            self.updateBtn.alpha = 0.4
        }

    }
    
    @IBAction func gymDaysListBtnAction(_ sender: Any) {
        self.weekDaysListView.isHidden = !self.weekDaysListView.isHidden
        self.weekDaysListView.alpha = self.weekDaysListView.isHidden == true ? 0.0 : 1.0

        if self.weekDaysListView.isHidden == true {
            self.setGymDaysFieldData()
        }
    }

    func setAdminProfileView() {
        self.setAdminProfileNavigationBar()
        self.setTextFields()
        self.adminProfileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPicker)))
        self.imagePicker.delegate = self
        self.weekDaysListView.isHidden = true
        self.weekDaysListTable.delegate = self
        self.weekDaysListTable.dataSource = self
        self.imageName  = "unchecked-checkbox"
        self.weekDaysListTable.allowsMultipleSelection = true
        self.weekDaysListTable.isMultipleTouchEnabled = true
        self.genderPickerView.dataSource = self
        self.genderPickerView.delegate = self

        self.forNonEditLabelArray = [self.gymNameForNonEditLabel,self.gymIDForNonEditLabel,self.gymAddressForNonEditLabel,self.firstNameForNonEditLabel,self.lastNameForNonEditLabel,self.emailForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel,self.genderForNonEditLabel,self.passwordForNonEditLabel,self.openningTimeForNonEditLabel,self.closingTimeForNonEditLabel,self.gymDaysForNonEditLabel]

        self.defaultLabelArray = [self.gymName,self.gymID,self.gymAddress,self.firstName,self.lastName,self.email,self.genderLabel,self.password,self.phoneNo,self.dob,self.openningTimeLabel,self.closingTimeLabel,self.gymDays]

        self.textFieldsArray = [self.gymNameTextField,self.gymIDTextField,self.firstNameTextField,self.lastNameTextField,self.genderTextField,self.phoneNoTextField,self.dobTextField,self.openningTimeTextField,self.closingTimeTextField,self.gymDaysTextField]

        self.errorLabelArray = [self.gymNameErrorLabel,self.gymIDErrorLabel,self.gymAddressErrorLabel,self.firstNameErrorLabel,self.lastNameErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.emailErrorLabel,self.phoneNoErrorLabel,self.dobErrorLabel,self.openningTimeErrorLabel,self.closingTimeErrorLabel,self.gymDaysErrorLabel]

        self.adminProfileImg.makeRounded()
        AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: false)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: self.errorLabelArray, flag: true)
        self.setHrLineView(isHidden: false, alpha: 1.0)
        self.weekDaysListBtn.isEnabled = false
        self.addressTextView.isHidden = true
        self.addressTextView.alpha = 0.0
        AppManager.shared.hidePasswordTextField(hide: true,passwordTextField:self.passwordTextField,passwordLabel: self.passworNonEditLabel)
        self.gymAddressNonEditLabel.isHidden = false
        self.gymAddressNonEditLabel.alpha = 1.0
        self.updateBtn.isHidden = true
        self.adminProfileImg.isUserInteractionEnabled = false
        self.gymDaysTextField.isUserInteractionEnabled = false
        self.gymDaysTextField.isEnabled = false
    }

    private func addClickToDismissGymWeekDaysList() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissGymWeekDaysList(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.cancelsTouchesInView = true
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapRecognizer)
    }

    @objc func dismissGymWeekDaysList(_ gesture : UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.weekDaysListView.isHidden = true
        self.weekDaysListView.alpha = 0.0
        self.setGymDaysFieldData()
    }

    func setAdminProfileNavigationBar() {
        self.adminProfileNavigationBar.menuBtn.isHidden = false
        self.adminProfileNavigationBar.searchBtn.isHidden = true
        self.adminProfileNavigationBar.navigationTitleLabel.text = "Profile"
        self.adminProfileNavigationBar.editBtn.isHidden = false
        self.adminProfileNavigationBar.editBtn.alpha = 1.0
        self.adminProfileNavigationBar.editBtn.addTarget(self, action: #selector(editAdmin), for: .touchUpInside)
    }

    func setGymDaysFieldData() {
        let selectedWeekdayArray = AppManager.shared.getSelectedWeekdays(selectedArray: self.selectedWeekdaysArray.sorted(), defaultArray: self.weekdayArray)
        var str:String = ""
        for weekday in  selectedWeekdayArray {
            if selectedWeekdayArray.last != weekday  {
                str += "\(weekday), "
            } else {
                str += weekday
            }
        }
        self.gymDaysTextField.text = str
    }

    @objc func editAdmin() {
        if self.isEdit == true {
            AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  false)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, errorLabels: self.errorLabelArray, flag: true)
            self.isEdit = false
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.addressTextView.isHidden = true
            self.addressTextView.alpha = 0.0
            AppManager.shared.hidePasswordTextField(hide: true,passwordTextField:self.passwordTextField,passwordLabel: self.passworNonEditLabel)
            self.gymAddressNonEditLabel.isHidden = false
            self.gymAddressNonEditLabel.alpha = 1.0
            self.updateBtn.isHidden = true
            self.adminProfileImg.isUserInteractionEnabled = false
            self.weekDaysListBtn.isEnabled = false
        } else{
                AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
                AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray,errorLabels: self.errorLabelArray, flag: false)
                self.isEdit = true
                self.setHrLineView(isHidden: true, alpha: 0.0)
                self.gymIDTextField.layer.opacity = 0.4
                self.addressTextView.isHidden = false
                self.addressTextView.alpha = 1.0
                AppManager.shared.hidePasswordTextField(hide: false,passwordTextField:self.passwordTextField,passwordLabel: self.passworNonEditLabel)
                self.gymAddressNonEditLabel.isHidden = true
                self.updateBtn.isHidden = false
                self.updateBtn.isEnabled = true
                self.gymIDTextField.isEnabled = false
                self.adminProfileImg.isUserInteractionEnabled = true
            self.passwordTextField.text = self.actualPassword?.text
            self.weekDaysListBtn.isEnabled = true
        }
         }

    func getFieldsAndLabelDic() -> [UITextField:UILabel] {
                let dir = [
                    self.gymNameTextField! : self.gymNameNonEditLabel!,
                    self.gymIDTextField! : self.gymIDNonEditLabel!,
                    self.firstNameTextField! : self.firstNameNonEditLabel!,
                    self.lastNameTextField! : self.lastNameNonEditLabel!,
                    self.genderTextField! : self.genderNonEditLabel!,
                    self.emailTextField! : self.emailNonEditLabel!,
                    self.phoneNoTextField! : self.phoneNoNonEditLabel!,
                    self.dobTextField! : self.dobNonEditLabel!,
                    self.openningTimeTextField! : self.openningTimeNonEditLabel!,
                    self.closingTimeTextField! : self.closingTimeNonEditLabel!,
                    self.gymDaysTextField! : self.gymDaysNonEditLabel!
            ]
                return dir
            }
              func setHrLineView(isHidden:Bool,alpha:CGFloat) {
                [self.gymNameHrLineView,self.gymAddressHrLineView,self.firstNameHrLineView,self.phoneNoHrLineView,self.emailHrLineView,self.genderHrLineView,self.gymTimeHrLineView,self.gymDaysHrLineView].forEach{
                      $0?.isHidden = isHidden
                      $0?.alpha = alpha
                  }
              }

    func setTextFields() {
        [self.gymNameTextField,self.gymIDTextField,self.firstNameTextField,self.lastNameTextField,self.genderTextField,self.dobTextField,self.phoneNoTextField,self.passwordTextField,self.emailTextField,self.gymDaysTextField,self.openningTimeTextField,self.closingTimeTextField].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
            //print("text field tag : \()")
            if $0?.tag != 12 {
                $0?.addTarget(self, action: #selector(checkProfileValidation(_:)), for: .editingChanged)
            }
        }
        self.weekDaysListView.layer.cornerRadius = 12.0
        self.weekDaysListView.layer.borderColor = UIColor.gray.cgColor
        self.weekDaysListView.layer.borderWidth = 0.7

        self.updateBtn.layer.cornerRadius = 12.0
        self.updateBtn.layer.borderColor = UIColor.black.cgColor
        self.updateBtn.layer.borderWidth = 0.7
        self.updateBtn.clipsToBounds = true
        self.passwordTextField.isSecureTextEntry = true
        self.addressTextView.addPaddingToTextField()
        self.addressTextView.layer.cornerRadius = 7.0
        self.addressTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.addressTextView.clipsToBounds = true
        self.datePicker.datePickerMode = .date
        self.timePicker.datePickerMode = .time
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
        dateFormatter.dateFormat = "h:mm a"
        self.selectedTime = dateFormatter.string(from: timePicker.date)
        dateFormatter.dateFormat =  "dd-MMM-yyyy"
        selectedDate = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    @objc func checkProfileValidation(_ textField:UITextField) {
        self.allProfileFieldsRequiredValidation(textField: textField)
      //  self.updateProfileBtnEnabler(textFieldArray: self.textFieldsArray)
        ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldsArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField,email: self.emailTextField.text!,password: self.passwordTextField.text!)
    }

    func allProfileFieldsRequiredValidation(textField:UITextField)  {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.gymNameErrorLabel, errorMessage: "Gym name required.")
        case 3:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.firstNameErrorLabel, errorMessage: "First Name required.")
        case 4:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.lastNameErrorLabel, errorMessage: "Last Name required." )
        case 5:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "Gender required.")
        case 6:
            ValidationManager.shared.passwordValidation(textField: textField, errorLabel: self.passwordErrorLabel, errorMessage: "Password must be greater than 8 character.")
        case 7:
           ValidationManager.shared.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Invalid Email.")
        case 8:
           ValidationManager.shared.phoneNumberValidation(textField: textField, errorLabel: self.phoneNoErrorLabel, errorMessage: "Phone number must be 10 digits only.")
        case 9:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required." )
        case 10:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.openningTimeErrorLabel, errorMessage: "Gym open time required.")
        case 11:
           ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.closingTimeErrorLabel, errorMessage: self.duplicateError.count > 1 ? duplicateError : "Gym close time required.")
        case 12:
           ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.gymDaysErrorLabel, errorMessage:  "Gym days required.")
        default:
            break
        }
    }
       func addPaddingToTextField(textField:UITextField) {
                let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                textField.leftView = paddingView
                textField.leftViewMode = .always
                textField.backgroundColor = UIColor.white
                textField.textColor = UIColor.black
            }

    func fetchAdminDetailBy(id:String) {
        FireStoreManager.shared.getAdminDetailBy(id: AppManager.shared.adminID, result: {
            (data,err) in

            if err != nil {
                print("Error in fetching the admin details.")
            }else{
                let adminDetail = data?["adminDetail"] as! Dictionary<String,Any>
                let adminDetails = AppManager.shared.getAdminProfile(adminDetails: adminDetail)
                self.fillAdminDetail(adminDetail: adminDetails)
                FireStoreManager.shared.downloadUserImg(id: AppManager.shared.adminID, result: {
                    (url,err) in
                     SVProgressHUD.dismiss()
                    if err != nil {
                       // self.viewDidLoad()
                    } else{
                        do {
                            let imgData = try Data(contentsOf: url!)
                            self.adminProfileImg.image = UIImage(data: imgData)
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                })
            }
        })
    }

    func fillAdminDetail(adminDetail:AdminProfile) {
        DispatchQueue.main.async {
             self.actualPassword?.text = ValidationManager.shared.decryption(hash: adminDetail.password)
            self.passworNonEditLabel.text = AppManager.shared.getSecureTextFor(text: (self.actualPassword?.text ?? ""))
            self.passwordTextField.text = self.actualPassword?.text
        }
        
        self.gymNameNonEditLabel.text = adminDetail.gymName
        self.gymIDNonEditLabel.text = adminDetail.gymID
        self.gymAddressNonEditLabel.text = adminDetail.gymAddress
        self.firstNameNonEditLabel.text = adminDetail.firstName
        self.lastNameNonEditLabel.text = adminDetail.lastName
        self.genderNonEditLabel.text = adminDetail.gender
        
        self.emailNonEditLabel.text = adminDetail.email
        self.phoneNoNonEditLabel.text = adminDetail.phoneNO
        self.dobNonEditLabel.text = adminDetail.dob
        self.openningTimeNonEditLabel.text = adminDetail.gymOpenningTime
        self.closingTimeNonEditLabel.text = adminDetail.gymClosingTime
        self.gymDaysNonEditLabel.text = adminDetail.gymDays
        self.adminEmail = adminDetail.email

        self.gymNameTextField.text = adminDetail.gymName
        self.gymIDTextField.text = adminDetail.gymID
        self.addressTextView.text = adminDetail.gymAddress
        self.firstNameTextField.text = adminDetail.firstName
        self.lastNameTextField.text = adminDetail.lastName
        self.genderTextField.text = adminDetail.gender
       
        self.emailTextField.text = adminDetail.email
        self.phoneNoTextField.text = adminDetail.phoneNO
        self.dobTextField.text = adminDetail.dob
        self.openningTimeTextField.text = adminDetail.gymOpenningTime
        self.closingTimeTextField.text = adminDetail.gymClosingTime
        self.gymDaysTextField.text = adminDetail.gymDays
        self.selectedWeekdaysArray = adminDetail.gymDyasArrayIndexs
        self.weekDaysListTable.reloadData()
    }

    func getAdminDetailForUpdate() -> Dictionary<String,Any> {
        let admin:Dictionary<String,Any> = [
            "dob":self.dobTextField.text!,
            "email":self.emailTextField.text!,
            "firstName":self.firstNameTextField.text!,
            "lastName":self.lastNameTextField.text!,
            "gender":self.genderTextField.text!,
            "gymAddress":self.addressTextView.text!,
            "gymID":self.gymIDTextField.text!,
            "gymName":self.gymNameTextField.text!,
            "mobileNo":self.phoneNoTextField.text!,
            "password":AppManager.shared.encryption(plainText: self.passwordTextField.text!),
            "gymOpenningTime" : self.openningTimeTextField.text!,
            "gymClosingTime" : self.closingTimeTextField.text!,
            "gymDays":self.gymDaysTextField.text!,
            "gymDaysArrayIndexs":self.selectedWeekdaysArray
        ]
        return admin
    }

    func showAdminProfileAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "Ok", style: .default, handler:{
        _ in
            if title == "Success" {
                self.fetchAdminDetailBy(id: AppManager.shared.adminID)
            }
        })
         alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func showPicker(){
        self.isProfileImgSelected = true
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.modalPresentationStyle = .overCurrentContext
        present(self.imagePicker, animated: true, completion: nil)
    }
}

extension ProfileAdminViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let img:UIImage = info[.editedImage] as? UIImage{
            self.adminProfileImg.image = img
            dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileAdminViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 9 || textField.tag == 10  || textField.tag == 11  || textField.tag == 12 {            return false
        }else{
            return true
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.weekDaysListView.isHidden == false && textField.tag != 12  {
            self.weekDaysListView.isHidden = true
            self.weekDaysListView.alpha = 0.0
        }
        switch textField.tag {
        case 5:
            textField.inputView = self.genderPickerView
            break

        case 9:
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0 {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
            break

        case 10  :
            textField.inputView = self.timePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0 {
                let df = DateFormatter()
                df.dateFormat = "hh:mm a"
                self.timePicker.date = df.date(from: textField.text!)!
            }
            break
        case 11 :
            textField.inputView = self.timePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0 {
                let df = DateFormatter()
                df.dateFormat = "hh:mm a"
                self.timePicker.date = df.date(from: textField.text!)!
            }
            break

        default:
            break
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        switch textField.tag {
        case 5 :
            if textField.text == "" {
                textField.text = self.genderArray.first
            }
            break

        case 7:
            let email = textField.text!
            if self.adminEmail != email {
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
            break

        case 9:
            if self.selectedDate != "" {
                textField.text = self.selectedDate
                self.selectedDate = ""
            }
            break

        case 10 :
            if  self.selectedTime.count > 1 {
                textField.text = self.selectedTime
                self.selectedTime = ""
            }
            break

        case 11:

            if self.selectedTime.count > 1 {
                if ValidationManager.shared.isDuplicate(text1: self.openningTimeTextField.text!, text2: self.selectedTime) == false{
                    self.closingTimeTextField.text = self.selectedTime
                    self.selectedTime = ""
                } else {
                    self.closingTimeTextField.text = ""
                    duplicateError = "Start time and end time can not be same."
                    self.selectedTime = ""
                }
            }
            break

        default:
            break
        }

        self.allProfileFieldsRequiredValidation(textField: textField)
        ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldsArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField,email: self.emailTextField.text!,password: self.passwordTextField.text!)
    }
    }
    

 extension ProfileAdminViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return  self.weekdayArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekDaysCell", for: indexPath) as! WeekDayTableCell
        cell.weekDayLabel.text = self.weekdayArray[indexPath.row]
        self.selectedWeekdaysArray = self.selectedWeekdaysArray.sorted()
        if self.selectedWeekdaysArray.contains(indexPath.row){
            self.imageName = "checked-checkbox"
        }else {
            self.imageName = "unchecked-checkbox"
        }
        cell.checkBtn.setImage(UIImage(named: self.imageName), for: .normal)
        return cell
    }
 }

extension ProfileAdminViewController : UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if self.selectedWeekdaysArray.contains(indexPath.row){
            self.selectedWeekdaysArray.remove(at: self.selectedWeekdaysArray.firstIndex(of: indexPath.row)!)
        }else{
            self.selectedWeekdaysArray.append(indexPath.row)
        }

        self.weekDaysListTable.reloadData()
    }
}

extension ProfileAdminViewController :UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        view.endEditing(true)
        if touch.view?.isDescendant(of: self.weekDaysListView) == true ||
        touch.view?.tag == 110 {
            return false
        }else {
            return true
        }
    }
}

extension ProfileAdminViewController : UIPickerViewDataSource{
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

extension ProfileAdminViewController:UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField.text = self.genderArray[row]
        DispatchQueue.main.async {
            self.allProfileFieldsRequiredValidation(textField: self.genderTextField)
            ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldsArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNoTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }
    }
}

class WeekDayTableCell: UITableViewCell {
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var weekDayLabel: UILabel!
}
