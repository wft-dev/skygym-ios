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
    @IBOutlet weak var amountTextField: UITextField!
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
    @IBOutlet weak var titleForNonEditLabel: UILabel!
    @IBOutlet weak var amountForNonEditLabel: UILabel!
    @IBOutlet weak var detailForNonEditLabel: UILabel!
    @IBOutlet weak var titleErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var detailErrorLabel: UILabel!
    @IBOutlet weak var weekDaysListBtn: UIButton!

    var isNewMemberhsip:Bool = false
    var selectedIndex:Int = 0
    var selectedOption:String = ""
    var isEdit:Bool = false
    var forNonEditLabelArray:[UILabel]? = nil
    var defaultLabelArray:[UILabel]? = nil
    var errorLabelArray:[UILabel] = []
    var textFieldArray:[UITextField] = []
    var duplicateErrorText:String? = nil
    var weekdayImg = UIImage(named: "unchecked-checkbox")
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMembershipView()
        
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
        self.membershipDropDownTitleTextField.checkMarkEnabled = true

        if self.isNewMemberhsip == false {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: false)
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.detailTextView.isHidden = true
            self.detailTextView.alpha = 0.0
            self.detailNonEditLabel.isHidden = false
            self.detailNonEditLabel.alpha = 1.0
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: true)
            self.hideMembershipTitleDropDown(hide: true)
             self.doneBtn.isHidden = true
            self.doneBtn.setTitle("U P D A T E", for: .normal)
        }else {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: true)
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.detailTextView.isHidden = false
            self.detailTextView.alpha = 1.0
            self.detailNonEditLabel.isHidden = true
            self.detailNonEditLabel.alpha = 0.0
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: false)
            self.hideMembershipTitleDropDown(hide: false)
             self.doneBtn.isHidden = false
            self.doneBtn.setTitle("A D D", for: .normal)
        }
        
        self.membershipDropDownTitleTextField.isEnabled = false
        self.membershipDropDownTitleTextField.isUserInteractionEnabled = false
        
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        self.membershipValidation()
       if ValidationManager.shared.isMembershipFieldsValidated(textFieldArray: self.textFieldArray, textView: self.detailTextView) == true {
            self.isNewMemberhsip ? self.registerNewMembership() : self.updateMembership()
        }
    }
    
    
    @IBAction func showMembershipListBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.membershipDropDownTitleTextField.showList()
        }
        
    }
    
}

extension  MembershipViewScreenViewController {
    
    func membershipValidation()  {
        
        for textField in self.textFieldArray {
            self.allMembershipFieldsRequiredValidation(textField: textField, duplicateDateErrorText: nil)
        }
        ValidationManager.shared.requiredValidation(textView: self.detailTextView, errorLabel: self.detailErrorLabel, errorMessage: "Membership detail required.")
        ValidationManager.shared.requiredValidation(dropDown: self.membershipDropDownTitleTextField, errorLabel: self.titleErrorLabel, errorMessage: "Membership title required.")
    }
    
    func hideMembershipTitleDropDown(hide:Bool) {
        self.titleNonEditLabel.text = self.membershipDropDownTitleTextField.text
        self.membershipDropDownTitleTextField.isHidden = hide
        self.titleNonEditLabel.isHidden = !hide
        self.titleNonEditLabel.alpha = !hide == false ? 1.0 : 0.0
        self.membershipDropDownTitleTextField.alpha = hide == true ? 0.0 : 1.0
    }

    func allMembershipFieldsRequiredValidation(textField:UITextField,duplicateDateErrorText:String?)  {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.titleErrorLabel, errorMessage: "Membership Title required.")
        case 2:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.amountErrorLabel, errorMessage: "Membership Amount required.")
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
        self.membershipDropDownTitleTextField.listWillAppear {
            self.membershipDropDownTitleTextField.text =  self.titleNonEditLabel.text!.count > 0 ? self.titleNonEditLabel.text : self.selectedOption
            self.membershipDropDownTitleTextField.selectedIndex = self.selectedIndex
        }
        
        self.membershipDropDownTitleTextField.didSelect(completion: {
            (selectedText,index,id) in
            if selectedText.count > 0 {
                self.selectedOption = selectedText
                self.selectedIndex = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                   ValidationManager.shared.requiredValidation(dropDown: self.membershipDropDownTitleTextField, errorLabel: self.titleErrorLabel, errorMessage: "Membership Title required.")
                })
            }
        })
    }

    func setMembershipViewScreenNavigationBar() {
        self.viewMembershipNavigationBar.menuBtn.isHidden = true
        self.viewMembershipNavigationBar.leftArrowBtn.isHidden = false
        self.viewMembershipNavigationBar.leftArrowBtn.alpha = 1.0
        self.viewMembershipNavigationBar.searchBtn.isHidden = true
        self.viewMembershipNavigationBar.navigationTitleLabel.text = "Membership"
        
        if AppManager.shared.loggedInRole == LoggedInRole.Member {
            self.hideMemberhsipEditBtn(hide: true)
        }else{
            self.hideMemberhsipEditBtn(hide: self.isNewMemberhsip)
        }
    }
    
    func hideMemberhsipEditBtn(hide:Bool) {
        if hide == true {
            self.viewMembershipNavigationBar.editBtn.isHidden = true
            self.viewMembershipNavigationBar.editBtn.alpha = 0.0
        }else {
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
            self.doneBtn.isHidden = true
            self.hideMembershipTitleDropDown(hide: true)
        } else{
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:self.defaultLabelArray!, errorLabels: self.errorLabelArray, flag: false)
            AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
            self.isEdit = true
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.detailTextView.isHidden = false
            self.detailTextView.alpha = 1.0
            self.detailNonEditLabel.isHidden = true
            self.detailNonEditLabel.alpha = 0.0
            self.doneBtn.isHidden = false
            self.doneBtn.alpha = 1.0
            self.hideMembershipTitleDropDown(hide: false)
        }
    }
    
    func getFieldsAndLabelDic() -> [UITextField:UILabel] {
        let dir = [ self.amountTextField! : self.amountNonEditLabel!  ]
        return dir
    }
      func setHrLineView(isHidden:Bool,alpha:CGFloat) {
        [self.titleHrLineView,self.amountHrLineView,self.detailHrLineView].forEach{
              $0?.isHidden = isHidden
              $0?.alpha = alpha
          }
      }
    
    func setTextFields() {

        self.amountTextField.addPaddingToTextField(height: 10, Width: 10)
        self.amountTextField.layer.cornerRadius = 7.0
        self.amountTextField.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.amountTextField.clipsToBounds = true
        self.amountTextField.addTarget(self, action: #selector(fieldsValidatorAction(_:)), for: .editingChanged)

        self.membershipDropDownTitleTextField.addPaddingToTextField(height: 10, Width: 10)
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
        ValidationManager.shared.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: self.detailTextView, phoneNumberTextField: nil,email: nil,password: nil)
    }
    
    func getMembershipData() -> [String:String] {
        let membership = [
            "title": self.membershipDropDownTitleTextField.text!,
            "detail":self.detailTextView.text!,
            "amount":self.amountTextField.text!,
            "duration": "\(selectedIndex + 1)",
            "selectedIndex" : "\(selectedIndex)"
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

        self.membershipDropDownTitleTextField.text = membership.title
        self.amountTextField.text = membership.amount
        self.detailTextView.text = membership.detail
        self.selectedIndex = Int(membership.selectedIndex)!
    }
    
    func clearMembershipFields() {
        self.amountTextField.text = ""
        self.detailTextView.text = ""
    }
}

extension MembershipViewScreenViewController :UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         if textField.tag == 1 {

                   return false
               }else{
                   return true
               }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//           if textField.tag == 1 {
//            self.view.endEditing(true)
//            DispatchQueue.main.async {
//                self.view.endEditing(true)
//            }
//            self.membershipDropDownTitleTextField.showList()
//           }
       }
       
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.allMembershipFieldsRequiredValidation(textField: textField, duplicateDateErrorText: duplicateErrorText)
        ValidationManager.shared.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: self.detailTextView, phoneNumberTextField: nil,email: nil,password: nil)
    }
}


extension MembershipViewScreenViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.detailErrorLabel, errorMessage: "Membership details required.")
       ValidationManager.shared.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: nil,email: nil,password: nil)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.detailErrorLabel, errorMessage: "Membership details required.")
        ValidationManager.shared.updateBtnValidator(updateBtn: self.doneBtn, textFieldArray: self.textFieldArray, textView: textView, phoneNumberTextField: nil,email: nil,password: nil)
    }
}

