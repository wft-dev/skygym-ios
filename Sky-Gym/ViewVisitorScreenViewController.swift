//
//  ViewVisitorScreenViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 12/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class ViewVisitorScreenViewController: BaseViewController {

    @IBOutlet weak var visitorViewNavigationBar: CustomNavigationBar!
    @IBOutlet weak var visitorFirstName: UITextField!
    @IBOutlet weak var visitorLastName: UITextField!
    @IBOutlet weak var visitorEmailTextField: UITextField!
    @IBOutlet weak var visitorDetailTextView: UITextView!
    @IBOutlet weak var visitorDateOfJoinTextField: UITextField!
    @IBOutlet weak var visitorDateOfVisitTextField: UITextField!
    @IBOutlet weak var noOfVisitTextField: UITextField!
    @IBOutlet weak var visitorGenderTextField: UITextField!
    @IBOutlet weak var visitorPhoneNoTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var firstNameNonEditLabel: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var firstNameHrLineView: UIView!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var lastNameNonEditLabel: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailHrLineView: UIView!
    @IBOutlet weak var emailNonEditLabel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressNonEditLabel: UILabel!
    @IBOutlet weak var addressHrLineView: UIView!
    @IBOutlet weak var dateOfJoin: UILabel!
    @IBOutlet weak var dateOfJoinNonEditLabel: UILabel!
    @IBOutlet weak var dateOfJoinHrLineView: UIView!
    @IBOutlet weak var dateOfVisit: UILabel!
    @IBOutlet weak var dateOfVisitNonEditLabel: UILabel!
    @IBOutlet weak var noOfVisitNonEditLabel: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var noOfVisit: UILabel!
    @IBOutlet weak var noOfVisitHrLineView: UIView!
    @IBOutlet weak var genderNonEditLabel: UILabel!
    @IBOutlet weak var phoneNo: UILabel!
    @IBOutlet weak var phoneNoNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoHrLineView: UIView!
    @IBOutlet weak var firstNameForNonEditLabel: UILabel!
    @IBOutlet weak var lastNameForNonEditLabel: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var addressForNonEditLabel: UILabel!
    @IBOutlet weak var dateOfJoinForNonEditLabel: UILabel!
    @IBOutlet weak var dateOfVisitForNonEditLabel: UILabel!
    @IBOutlet weak var noOfVisitForNonEditLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var secondNameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var dateOfJoinErrorLabel: UILabel!
    @IBOutlet weak var dateOfVisitErrorLabel: UILabel!
    @IBOutlet weak var noOfVisitErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberErrorLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    var isNewVisitor:Bool = false
    var datePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    var selectedDate:String = ""
    var isImgPickerOpened:Bool = false
    var selectedVisitorImg:UIImage? = nil
    var isEdit:Bool = false
    var forNonEditLabelArray:[UILabel]? = nil
    var defaultLabelArray:[UILabel]? = nil
    var errorLabelArray:[UILabel] = []
    var textFieldArray:[UITextField] = []
    let validation = ValidationManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setVisitorView()
        
        self.forNonEditLabelArray = [self.addressForNonEditLabel,self.firstNameForNonEditLabel,self.lastNameForNonEditLabel,self.emailForNonEditLabel,self.dateOfJoinForNonEditLabel,self.dateOfVisitForNonEditLabel,self.genderForNonEditLabel,self.noOfVisitForNonEditLabel,self.phoneNoForNonEditLabel]
        
        self.defaultLabelArray = [self.firstName,self.lastName,self.address,self.email,self.dateOfJoin,self.dateOfVisit,self.gender,self.noOfVisit,self.phoneNo]
    
        self.textFieldArray = [self.visitorFirstName,self.visitorLastName,self.visitorDateOfJoinTextField,self.visitorDateOfVisitTextField,self.noOfVisitTextField,self.visitorGenderTextField,self.visitorPhoneNoTextField,self.visitorEmailTextField]
        
        self.errorLabelArray = [self.firstNameErrorLabel,self.secondNameErrorLabel,self.emailErrorLabel,self.addressErrorLabel,self.dateOfJoinErrorLabel,self.dateOfVisitErrorLabel,self.noOfVisitErrorLabel,self.genderErrorLabel,self.phoneNumberErrorLabel]
        
        
        if self.isNewVisitor == false {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: false)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: true)
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.visitorDetailTextView.isHidden = true
            self.visitorDetailTextView.alpha = 0.0
            self.addressNonEditLabel.isHidden = false
            self.addressNonEditLabel.alpha = 1.0
            self.updateBtn.isHidden = true
            self.userImg.isUserInteractionEnabled = false

        }else {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: true)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: false)
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.visitorDetailTextView.isHidden = false
            self.visitorDetailTextView.alpha = 1.0
            self.addressNonEditLabel.isHidden = true
            self.addressNonEditLabel.alpha = 0.0
            self.updateBtn.isHidden = false
            self.userImg.isUserInteractionEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userImg.makeRounded()
        self.isNewVisitor == false ? self.fetchVisitor(id: AppManager.shared.visitorID) : self.clearVisitorTextFields()
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        self.visitorValidation()
        
        if self.validation.isVisitorValidated(textFieldArray: self.textFieldArray, textView: self.visitorDetailTextView, phoneNumberTextField: self.visitorPhoneNoTextField, email: self.visitorEmailTextField.text!) {
          self.isNewVisitor ? self.registerVisitor() : self.updateVisitor()
        }
    }
    
    func visitorValidation() {
        for textField in self.textFieldArray{
            self.allVisitorFieldsRequiredValidation(textField: textField)
        }
        self.validation.requiredValidation(textView: self.visitorDetailTextView, errorLabel: self.addressErrorLabel, errorMessage: "Visitor address require.")
    }
}

extension ViewVisitorScreenViewController {

    func allVisitorFieldsRequiredValidation(textField:UITextField)  {
        switch textField.tag {
        case 1:
            validation.requiredValidation(textField: textField, errorLabel: self.firstNameErrorLabel, errorMessage: "First Name required.")
        case 2:
            validation.requiredValidation(textField: textField, errorLabel: self.secondNameErrorLabel, errorMessage: "Last Name required.")
        case 3:
            validation.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "invalid email address.")
        case 4:
            validation.requiredValidation(textField: textField, errorLabel: self.dateOfJoinErrorLabel, errorMessage: "Date of join required.")
        case 5:
            validation.requiredValidation(textField: textField, errorLabel: self.dateOfVisitErrorLabel, errorMessage: "Date of visit required.")
        case 6:
            validation.requiredValidation(textField: textField, errorLabel: self.noOfVisitErrorLabel, errorMessage: "No. of visit required." )
        case 7:
            validation.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "gender required.")
        case 8:
            validation.phoneNumberValidation(textField: textField, errorLabel: self.phoneNumberErrorLabel, errorMessage: "Phone number must be 10 digits only.")

        default:
            break
        }
    }

    func setVisitorView()  {
        self.setVisitorViewNavigationBar()
        self.setTextFields()
        setBackAction(toView: self.visitorViewNavigationBar)
        self.isNewVisitor ? updateBtn.setTitle("A D D", for: .normal) : updateBtn.setTitle("U P D A T E ", for: .normal)
        self.datePicker.datePickerMode = .date
        toolBar.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar.sizeToFit()
        self.imagePicker.delegate = self
        self.userImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPicker)))
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
    
    @objc func showPicker(){
        self.isImgPickerOpened = true
        self.imagePicker.allowsEditing = true
        self.imagePicker.modalPresentationStyle = .overCurrentContext
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    func setVisitorViewNavigationBar() {
        self.visitorViewNavigationBar.menuBtn.isHidden = true
        self.visitorViewNavigationBar.leftArrowBtn.isHidden = false
        self.visitorViewNavigationBar.leftArrowBtn.alpha = 1.0
        self.visitorViewNavigationBar.searchBtn.isHidden = true
        self.visitorViewNavigationBar.navigationTitleLabel.text = "Visitor"
        if self.isNewVisitor == false {
            self.visitorViewNavigationBar.editBtn.isHidden = false
            self.visitorViewNavigationBar.editBtn.alpha = 1.0
            self.visitorViewNavigationBar.editBtn.addTarget(self, action: #selector(editVisitor), for: .touchUpInside)
        }
    }
    
    @objc func editVisitor() {
        if self.isEdit == true {
            AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  false)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: true)
            self.isEdit = false
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.visitorDetailTextView.isHidden = true
            self.visitorDetailTextView.alpha = 0.0
            self.addressNonEditLabel.isHidden = false
            self.addressNonEditLabel.alpha = 1.0
            self.updateBtn.isHidden = true
            self.userImg.isUserInteractionEnabled = false
        } else{
            AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: false)
            self.isEdit = true
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.visitorDetailTextView.isHidden = false
            self.visitorDetailTextView.alpha = 1.0
            self.addressNonEditLabel.isHidden = true
            self.addressNonEditLabel.alpha = 0.0
            self.updateBtn.isHidden = false
            self.userImg.isUserInteractionEnabled = true
        }
    }

    func getFieldsAndLabelDic() -> [UITextField:UILabel] {
            let dir = [
                self.visitorFirstName! : self.firstNameNonEditLabel!,
                self.visitorLastName! : self.lastNameNonEditLabel!,
                self.visitorEmailTextField! : self.emailNonEditLabel!,
                self.visitorDateOfJoinTextField! : self.dateOfJoinNonEditLabel,
                self.visitorDateOfVisitTextField! : self.dateOfVisitNonEditLabel!,
                self.noOfVisitTextField! : self.noOfVisitNonEditLabel!,
                self.visitorGenderTextField! : self.genderNonEditLabel!,
                self.visitorPhoneNoTextField! :self.phoneNoNonEditLabel!
        ] as! [UITextField : UILabel]
            return dir
        }

          func setHrLineView(isHidden:Bool,alpha:CGFloat) {
            [self.firstNameHrLineView,self.emailHrLineView,self.addressHrLineView,self.dateOfJoinHrLineView,self.noOfVisitHrLineView,self.phoneNoHrLineView].forEach{
                  $0?.isHidden = isHidden
                  $0?.alpha = alpha
              }
          }

    func setTextFields() {
        [ self.visitorFirstName,self.visitorLastName,self.visitorEmailTextField,
          self.visitorDateOfJoinTextField,self.visitorDateOfVisitTextField,
          self.noOfVisitTextField,self.visitorGenderTextField,self.visitorPhoneNoTextField].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
            $0?.addTarget(self, action: #selector(fieldsValidatorAction(_:)), for: .editingChanged)
        }
        self.visitorDetailTextView.addPaddingToTextView(top: 0, right: 10, bottom: 0, left: 10)
        self.visitorDetailTextView.layer.cornerRadius = 7.0
        self.visitorDetailTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.visitorDetailTextView.clipsToBounds = true
        self.updateBtn.layer.cornerRadius = 12.0
        self.updateBtn.layer.borderColor = UIColor.black.cgColor
        self.updateBtn.layer.borderWidth = 0.7
        self.updateBtn.clipsToBounds = true
    }
    
    @objc func fieldsValidatorAction(_ textField:UITextField)  {
        self.allVisitorFieldsRequiredValidation(textField: textField)
        validation.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.visitorDetailTextView, phoneNumberTextField: self.visitorPhoneNoTextField,email: visitorEmailTextField.text!,password:nil)
    }
    
        
    func addPaddingToTextField(textField:UITextField) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
    }
    
    func getVisitorData() -> [String:String] {
        let visitor:[String:String] = [
            "firstName":self.visitorFirstName.text!,
            "lastName" : self.visitorLastName.text!,
            "email":self.visitorEmailTextField.text!,
            "address":self.visitorDetailTextView.text!,
            "dateOfJoin":self.visitorDateOfJoinTextField.text!,
            "dateOfVisit":self.visitorDateOfVisitTextField.text!,
            "noOfVisit":self.noOfVisitTextField.text!,
            "gender":self.visitorGenderTextField.text!,
            "phoneNo":self.visitorPhoneNoTextField.text!
        ]
        return visitor
    }
    
    func register(id:String,visitorDetail:[String:String],completion:@escaping (Error?)->Void) {
        if self.isImgPickerOpened == true {
            FireStoreManager.shared.uploadUserImg(imgData: (self.userImg.image?.pngData())!, id: id, completion: {
                err in
                if err != nil {
                    self.showVisitorAlert(title: "Error", message: "Error in uploading the image, Please try again.")
                } else {
                    FireStoreManager.shared.addVisitor(id: id, visitorDetail: visitorDetail, completion: {
                        (err) in
                        completion(err)
                    })
                }
                self.isImgPickerOpened = false
            })
        } else{
            FireStoreManager.shared.addVisitor(id: id, visitorDetail: visitorDetail, completion: {
                (err) in
                completion(err)
            })
        }
    }
    
    func showVisitorAlert(title:String,message:String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "OK", style: .default, handler:{
               _ in
               if title == "Success" || title == "Retry"{
                if message == "Visitor is added successfully." {
                    self.dismiss(animated: true, completion: nil)
                }else { self.fetchVisitor(id: AppManager.shared.visitorID) }
               }
           })
           alert.addAction(okAction)
           present(alert, animated: true, completion: nil)
       }
    
    func registerVisitor() {
        SVProgressHUD.show()
        self.register(id: "\(Int.random(in: 1..<100000))" , visitorDetail: self.getVisitorData(), completion: {
            err in
            SVProgressHUD.dismiss()
            if err != nil {
                self.showVisitorAlert(title: "Error", message: "Error in adding the visitor,Please try again.")
            }else{
                self.showVisitorAlert(title: "Success", message: "Visitor is added successfully.")
            }
        })
    }
    
    func updateVisitor() {
        SVProgressHUD.show()
        self.register(id: "\(AppManager.shared.visitorID)", visitorDetail: self.getVisitorData(), completion: {
            err in
            SVProgressHUD.dismiss()
            if err != nil {
                self.showVisitorAlert(title: "Error", message: "Error in updating visitor details,Please try again.")
            }else{
                self.showVisitorAlert(title: "Success", message: "Visitor details are updated successfully. ")
            }
        })
    }
    
    func fetchVisitor(id:String) {
        SVProgressHUD.show()
        
        FireStoreManager.shared.getVisitorBy(id: id, result: {
            (visitor,err) in
            if err != nil {
                self.showVisitorAlert(title: "Retry", message: "Error in fetching visitor details, Please try again.")
            } else {
                self.fillVisitorDetails(visitor: AppManager.shared.getVisitor(visitorDetail: visitor?["visitorDetail"] as! [String : String], id: visitor?["id"] as! String))
                
                FireStoreManager.shared.downloadUserImg(id: id, result: {
                    (url,err) in
                    SVProgressHUD.dismiss()
                    if err != nil {
                         
                    } else {
                        do {
                            self.userImg.image =  try UIImage(data: Data(contentsOf: url!))
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                })
            }
        })
    }
    
    func fillVisitorDetails(visitor:Visitor) {
        self.firstNameNonEditLabel.text = visitor.firstName
        self.lastNameNonEditLabel.text = visitor.lastName
        self.emailNonEditLabel.text = visitor.email
        self.addressNonEditLabel.text = visitor.address
        self.dateOfJoinNonEditLabel.text = visitor.dateOfJoin
        self.dateOfVisitNonEditLabel.text = visitor.dateOfVisit
        self.noOfVisitNonEditLabel.text = visitor.noOfVisit
        self.genderNonEditLabel.text = visitor.gender
        self.phoneNoNonEditLabel.text = visitor.phoneNo

        self.visitorFirstName.text = visitor.firstName
        self.visitorLastName.text = visitor.lastName
        self.visitorEmailTextField.text = visitor.email
        self.visitorDetailTextView.text = visitor.address
        self.visitorDateOfJoinTextField.text = visitor.dateOfJoin
        self.visitorDateOfVisitTextField.text = visitor.dateOfVisit
        self.noOfVisitTextField.text = visitor.noOfVisit
        self.visitorGenderTextField.text = visitor.gender
        self.visitorPhoneNoTextField.text = visitor.phoneNo
    }
    
    func clearVisitorTextFields() {
          self.visitorFirstName.text = ""
          self.visitorLastName.text =  ""
          self.visitorEmailTextField.text =  ""
          self.visitorDetailTextView.text =  ""
          self.visitorDateOfJoinTextField.text =  ""
          self.visitorDateOfVisitTextField.text =  ""
          self.noOfVisitTextField.text =  ""
          self.visitorGenderTextField.text = ""
          self.visitorPhoneNoTextField.text = ""
      }
}

extension ViewVisitorScreenViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 4 || textField.tag == 5 {
            return false
        }else{
            return true
        }
    }
       
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 4 || textField.tag == 5 {
            textField.inputAccessoryView = self.toolBar
            textField.inputView = datePicker
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
        }
        self.allVisitorFieldsRequiredValidation(textField: textField)
        validation.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.visitorDetailTextView, phoneNumberTextField: self.visitorPhoneNoTextField,email:self.visitorEmailTextField.text!,password: nil)
    }
          
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 4:
            if  self.selectedDate != "" {
                self.visitorDateOfJoinTextField.text = self.selectedDate
                self.selectedDate = ""
            }
        case 5:
             if  self.selectedDate != "" {
            self.visitorDateOfVisitTextField.text = self.selectedDate
            self.selectedDate = ""
            }
        default:
            break
        }
        self.allVisitorFieldsRequiredValidation(textField: textField)
        validation.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: self.visitorDetailTextView, phoneNumberTextField: self.visitorPhoneNoTextField,email:self.visitorEmailTextField.text!,password: nil)
    }
}

extension ViewVisitorScreenViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img:UIImage =  info[.editedImage] as? UIImage {
            self.userImg.image = img
            dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension ViewVisitorScreenViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
     self.validation.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Visitor address required.")
        validation.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: self.visitorPhoneNoTextField,email:self.visitorEmailTextField.text!,password: nil)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.validation.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Visitor address required.")
    }
}
