//
//  MembershipViewScreenViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 09/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD
import iOSDropDown

class MembershipViewScreenViewController: BaseViewController {
    
    @IBOutlet weak var viewMembershipNavigationBar: CustomNavigationBar!
    
    @IBOutlet weak var membershipDropDownTitleTextField: DropDown!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleNonEditLabel: UILabel!
    @IBOutlet weak var titleHrLineView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountNonEditLabel: UILabel!
    @IBOutlet weak var amountHrLineView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailNonEditLabel: UILabel!
    @IBOutlet weak var detailHrLineView: UIView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateNonEdtiLabel: UILabel!
    @IBOutlet weak var startDateHrLineView: UIView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateNonEditLabel: UILabel!
    @IBOutlet weak var titleForNonEditLabel: UILabel!
    @IBOutlet weak var amountForNonEditLabel: UILabel!
    @IBOutlet weak var detailForNonEditLabel: UILabel!
    @IBOutlet weak var startDateForNonEditLabel: UILabel!
    @IBOutlet weak var endDateForNonEditLabel: UILabel!
    
    @IBOutlet weak var titleErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var detailErrorLabel: UILabel!
    @IBOutlet weak var startDateErrorLabel: UILabel!
    @IBOutlet weak var endDateErrorLabel: UILabel!
    
    var isNewMemberhsip:Bool = false
//    var datePicker = UIDatePicker()
//    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
//    var selectedDate:String = ""
//    var startDate:Date? = nil
//    var endDate:Date? = nil
    var duration:Int = 0
    var selectedOption:String = ""
    var isEdit:Bool = false
    var forNonEditLabelArray:[UILabel]? = nil
    var defaultLabelArray:[UILabel]? = nil
    var errorLabelArray:[UILabel] = []
    var textFieldArray:[UITextField] = []
    let validation = ValidationManager.shared
    var duplicateErrorText:String? = nil
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMembershipView()
        self.doneBtn.isEnabled = false
        self.doneBtn.alpha = 0.4
        
        self.forNonEditLabelArray = [self.titleForNonEditLabel,self.amountForNonEditLabel,self.detailForNonEditLabel]
        
        self.defaultLabelArray = [self.titleLabel,self.amountLabel,self.detailLabel]
        
        self.errorLabelArray = [self.titleErrorLabel,self.amountErrorLabel,self.detailErrorLabel]
        
        self.textFieldArray = [self.amountTextField]
        
        self.membershipDropDownTitleTextField.optionArray = [
            "Membership for 1 month",
            "Membership for 2 months",
            "Membership for 3 months",
            "Membership for 4 months",
            "Membership for 5 months",
            "Membership for 6 months",
            "Membership for 7 months",
            "Membership for 8 months",
            "Membership for 9 months",
            "Membership for 10 months",
            "Membership for 11 months",
            "Membership for 12 months"
        ]
        
        self.membershipDropDownTitleTextField.optionIds = [1,2,3,4,5,6,7,8,9,10,11,12]

        
        if self.isNewMemberhsip == false {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: false)
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.detailTextView.isHidden = true
            self.detailTextView.alpha = 0.0
            self.detailNonEditLabel.isHidden = false
            self.detailNonEditLabel.alpha = 1.0
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: true)

        }else {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: true)
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.detailTextView.isHidden = false
            self.detailTextView.alpha = 1.0
            self.detailNonEditLabel.isHidden = true
            self.detailNonEditLabel.alpha = 0.0
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: false)
        }
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        self.isNewMemberhsip ? self.registerNewMembership() : self.updateMembership()
   }
}

extension  MembershipViewScreenViewController {

    func allMembershipFieldsRequiredValidation(textField:UITextField,duplicateDateErrorText:String?)  {
        switch textField.tag {
        case 1:
            validation.requiredValidation(textField: textField, errorLabel: self.titleErrorLabel, errorMessage: "Membership Title required.")
        case 2:
            validation.requiredValidation(textField: textField, errorLabel: self.amountErrorLabel, errorMessage: "Membership Amount required.")
//        case 3:
//            validation.requiredValidation(textField: textField, errorLabel: self.startDateErrorLabel, errorMessage: "Start date required.")
//        case 4:
//            validation.requiredValidation(textField: textField, errorLabel: self.endDateErrorLabel, errorMessage: (duplicateDateErrorText != nil ? (duplicateDateErrorText):" End date required.")! )
        default:
            break
        }
    }

    func setMembershipView() {
        self.setMembershipViewScreenNavigationBar()
        assignbackground()
        self.setTextFields()
        self.doneBtn.layer.cornerRadius = 15.0
        setBackAction(toView: self.viewMembershipNavigationBar)
        self.isNewMemberhsip ? self.clearMembershipFields() : self.fetchMembersipBy(id: AppManager.shared.membershipID)
//        self.datePicker.datePickerMode = .date
//        toolBar.barStyle = .default
//        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
//        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
//        toolBar.items = [cancelToolBarItem,space,okToolBarItem]
//        toolBar.sizeToFit()
        
        self.membershipDropDownTitleTextField.listWillAppear {
            self.membershipDropDownTitleTextField.text = self.selectedOption

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.validation.requiredValidation(dropDown: self.membershipDropDownTitleTextField, errorLabel: self.titleErrorLabel, errorMessage: "Membership Title required.")
            })
        }
        
        self.membershipDropDownTitleTextField.didSelect(completion: {
            (selectedText,index,id) in
            self.selectedOption = selectedText
            self.validation.requiredValidation(dropDown: self.membershipDropDownTitleTextField, errorLabel: self.titleErrorLabel, errorMessage: "Membership Title required.")
        })
        
    }
    
//    @objc func cancelTextField()  {
//        self.startDate = nil
//           self.view.endEditing(true)
//       }
//
//    @objc func doneTextField()  {
//        self.selectedDate = AppManager.shared.dateWithMonthName(date: datePicker.date)
//        self.view.endEditing(true)
//     }
  
    func setMembershipViewScreenNavigationBar() {
        self.viewMembershipNavigationBar.menuBtn.isHidden = true
        self.viewMembershipNavigationBar.leftArrowBtn.isHidden = false
        self.viewMembershipNavigationBar.leftArrowBtn.alpha = 1.0
        self.viewMembershipNavigationBar.searchBtn.isHidden = true
        self.viewMembershipNavigationBar.navigationTitleLabel.text = "Membership"
        if self.isNewMemberhsip == false {
            self.viewMembershipNavigationBar.editBtn.isHidden = false
            self.viewMembershipNavigationBar.editBtn.alpha = 1.0
            self.viewMembershipNavigationBar.editBtn.addTarget(self, action: #selector(editMembership), for: .touchUpInside)
        }
    }
    
    @objc func editMembership() {
        if self.isEdit == true {
            AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  false)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: true)
            self.isEdit = false
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.detailTextView.isHidden = true
            self.detailTextView.alpha = 0.0
            self.detailNonEditLabel.isHidden = false
            self.detailNonEditLabel.alpha = 1.0
            self.doneBtn.isEnabled = false
            self.doneBtn.alpha = 0.4
        } else{
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: false)
            AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
            self.isEdit = true
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.detailTextView.isHidden = false
            self.detailTextView.alpha = 1.0
            self.detailNonEditLabel.isHidden = true
            self.detailNonEditLabel.alpha = 0.0
            self.doneBtn.isEnabled = true
            self.doneBtn.alpha = 1.0
        }
    }
    
    func getFieldsAndLabelDic() -> [UITextField:UILabel] {
        let dir = [
           // self.titleTextField! : self.titleNonEditLabel!,
            self.amountTextField! : self.amountNonEditLabel!,
//            self.startDateTextField! : self.startDateNonEdtiLabel!,
//            self.endDateTextField! : self.endDateNonEditLabel!
        ]
        return dir
    }
      func setHrLineView(isHidden:Bool,alpha:CGFloat) {
        [self.titleHrLineView,self.amountHrLineView,self.detailHrLineView,self.startDateHrLineView].forEach{
              $0?.isHidden = isHidden
              $0?.alpha = alpha
          }
      }
    
    func setTextFields() {
//        [self.amountTextField,].forEach{
//            $0?.addPaddingToTextField(height: 10, Width: 10)
//            $0?.layer.cornerRadius = 7.0
//            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
//            $0?.clipsToBounds = true
//            $0?.addTarget(self, action: #selector(fieldsValidatorAction(_:)), for: .editingChanged)
//        }
        
        self.amountTextField.addPaddingToTextField(height: 10, Width: 10)
        self.amountTextField.layer.cornerRadius = 7.0
        self.amountTextField.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.amountTextField.clipsToBounds = true
        self.amountTextField.addTarget(self, action: #selector(fieldsValidatorAction(_:)), for: .editingChanged)

        self.membershipDropDownTitleTextField.addPaddingToTextField()
        self.membershipDropDownTitleTextField.borderStyle = .none
        self.membershipDropDownTitleTextField.cornerRadius = 7.0
        self.membershipDropDownTitleTextField.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.membershipDropDownTitleTextField.addTarget(self, action: #selector(fieldsValidatorAction(_:)), for: .editingChanged)
        self.membershipDropDownTitleTextField.listHeight = 300
        self.membershipDropDownTitleTextField.rowHeight = 50
        self.membershipDropDownTitleTextField.selectedRowColor = .lightGray
        self.membershipDropDownTitleTextField.checkMarkEnabled = false
        
        self.detailTextView.addPaddingToTextView(top: 0, right: 8, bottom: 0, left: 8)
        self.detailTextView.layer.cornerRadius = 7.0
        self.detailTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.detailTextView.clipsToBounds = true
    }
    
    @objc func fieldsValidatorAction(_ textField:UITextField) {
        self.allMembershipFieldsRequiredValidation(textField: textField, duplicateDateErrorText: duplicateErrorText)
        validation.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: self.detailTextView, phoneNumberTextField: nil,email: nil,password: nil)
    }
    
    func getMembershipData() -> [String:String] {
//        self.startDate = AppManager.shared.getDate(date: self.startDateTextField.text!)
//        self.endDate = AppManager.shared.getDate(date: self.endDateTextField.text!)
        let membership = [
            "title":self.titleTextField.text!,
            "detail":self.detailTextView.text!,
            "amount":self.amountTextField.text!,
            "duration": "\(duration)"
        ]
        return membership
    }

    func registerMembership(id:String,membershipDetail:[String:String],compltion:@escaping (Error?)->Void) {
        FireStoreManager.shared.addMembership(id: id, membershipDetail: membershipDetail, completion: {
            err in
            compltion(err)
        })
    }
    
    func registerNewMembership() {
        self.registerMembership(id:"\(Int.random(in: 1..<1000000))", membershipDetail: self.getMembershipData(), compltion: {
            err in
            if err != nil {
                self.showMembershipAlert(title: "Error", message: "Error in adding membership,plese try again.")
            }else {
                self.showMembershipAlert(title: "Success", message: "Membership is added successfully.")
            }
        })
    }
    
    func updateMembership() {
        self.registerMembership(id:AppManager.shared.membershipID, membershipDetail: self.getMembershipData(), compltion: {
            err in
            if err != nil {
                self.showMembershipAlert(title: "Error", message: "Error in updating membership,plese try again.")
            }else {
                self.showMembershipAlert(title: "Success", message: "Membership is updated successfully.")
            }
        })
    }
    
    func showMembershipAlert(title:String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler:{
            _ in
            if title == "Success"{
                 self.dismiss(animated: true, completion: nil)
            }
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func retryMembershipAlert() {
        let retryAlertController = UIAlertController(title: "Error", message: "Error in getting the membership Detail.", preferredStyle: .alert)
        let retryAlertBtn = UIAlertAction(title: "Retry", style: .default, handler: {
            (action) in
            self.viewWillAppear(true)
        })
        retryAlertController.addAction(retryAlertBtn)
        present(retryAlertController, animated: true, completion: nil)
    }
    
    func fetchMembersipBy(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMembershipBy(id: id, result: {
            (membership,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.retryMembershipAlert()
            } else {
                self.setMembershipData(membership: membership!)
            }
        })
    }
    
    func setMembershipData(membership:Memberhisp) {
        self.titleNonEditLabel.text = membership.title
        self.amountNonEditLabel.text = membership.amount
        self.detailNonEditLabel.text = membership.detail
//        self.startDateNonEdtiLabel.text = membership.startDate
//        self.endDateNonEditLabel.text  = membership.endDate
        
        self.membershipDropDownTitleTextField.text = membership.title
        self.amountTextField.text = membership.amount
        self.detailTextView.text = membership.detail
//        self.startDateTextField.text  = membership.startDate
//        self.endDateTextField.text = membership.endDate
    }
    
    func clearMembershipFields() {
     //   self.titleTextField.text = ""
        self.amountTextField.text = ""
        self.detailTextView.text = ""
//        self.startDateTextField.text  = ""
//        self.endDateTextField.text = ""
    }
}

extension MembershipViewScreenViewController :UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//         if textField.tag == 3 || textField.tag == 4 {
//                   return false
//               }else{
//                   return true
//               }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//           if textField.tag == 3 || textField.tag  == 4 {
//               textField.inputAccessoryView = self.toolBar
//               textField.inputView = datePicker
//            if textField.text!.count > 0  {
//                let df = DateFormatter()
//                df.dateFormat = "dd-MM-yyyy"
//                self.datePicker.date = df.date(from: textField.text!)!
//            }
//           }
       }
       
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if self.selectedDate.count > 1  {
//            switch textField.tag {
//            case 3:
//                self.startDateTextField.text = self.selectedDate
//                self.startDate = datePicker.date
//            case 4:
//                if validation.isDuplicate(text1: self.startDateTextField.text!, text2: self.selectedDate) == false{
//                    self.endDateTextField.text = self.selectedDate
//                    self.endDate = datePicker.date
//                    self.selectedDate = ""
//                    self.duplicateErrorText = nil
//                } else {
//                    self.endDateTextField.text = ""
//                    duplicateErrorText = "Start time and end time can not be same."
//                    self.selectedDate = ""
//                }
//            default:
//                break
//            }
//        }
        self.allMembershipFieldsRequiredValidation(textField: textField, duplicateDateErrorText: duplicateErrorText)
        validation.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: self.detailTextView, phoneNumberTextField: nil,email: nil,password: nil)
    }
}


extension MembershipViewScreenViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.validation.requiredValidation(textView: textView, errorLabel: self.detailErrorLabel, errorMessage: "Membership details required.")
        validation.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: nil,email: nil,password: nil)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.validation.requiredValidation(textView: textView, errorLabel: self.detailErrorLabel, errorMessage: "Membership details required.")
                validation.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: nil,email: nil,password: nil)
    }
}

