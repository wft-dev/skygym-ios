//
//  AddMemberViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 01/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class MemberhsipPlanTableCell: UITableViewCell {
    @IBOutlet weak var membershipPlanLabel: UILabel!
}

class AddMemberViewController: BaseViewController {
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var addMemberNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profileAndMembershipBarView: UIView!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var membershipBtn: UIButton!
    @IBOutlet weak var memberIDTextField: UITextField!
    @IBOutlet weak var dateOfJoiningTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var trainerNameTextField: UITextField!
    @IBOutlet weak var uploadIDTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var membershipPlanTextField: UITextField!
    @IBOutlet weak var membershipDetailTextView: UITextView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var totalAmountTextField: UITextField!
    @IBOutlet weak var discountTextField: UITextField!
    @IBOutlet weak var paymentTypeTextField: UITextField!
    @IBOutlet weak var dueAmountTextField: UITextField!
    @IBOutlet weak var memberProfileView: UIView!
    @IBOutlet weak var membershipView: UIView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var generalTypeOptionBtn: UIButton!
    @IBOutlet weak var personalTypeOptionBtn: UIButton!
    @IBOutlet weak var membershipPlanView: UIView!
    @IBOutlet weak var membershipPlanTable: UITableView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var memberImg: UIImageView!
    
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var memberIDErrorLabel: UILabel!
    @IBOutlet weak var dateOfJoinErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var trainerNameErrorLabel: UILabel!
    @IBOutlet weak var uploadIDErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberErrorLabel: UILabel!
    @IBOutlet weak var dobErrorLabel: UILabel!
    @IBOutlet weak var membershipPlanErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var startDateErrorLabel: UILabel!
    @IBOutlet weak var totalAmountErrorLabel: UILabel!
    @IBOutlet weak var discountErrorLabel: UILabel!
    @IBOutlet weak var paymentErrorLabel: UILabel!
    @IBOutlet weak var dueAmountErrorLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var imgUrl:URL? = nil
    var isNewMember:Bool = false
    var visitorID:String = ""
    var memberhsipPlanArray:[Memberhisp] = []
    var datePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    let borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0).cgColor
    var selectedDate:Date? = nil
    var membershipDuration:Int = 0
    var isRenewMembership:Bool = false
    var membershipID:String = ""
    var renewingMembershipID:String = ""
    var renewingMembershipDuration:String = ""
    var visitorProfileImgData:Data? = nil
    let validation = ValidationManager.shared
    var errorLabelArray:[UILabel] = []
    var memberProfileFieldArray :[UITextField] = []
    var membershipFieldArray:[UITextField] = []
    var textFieldArray:[UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCompleteView()
        
        if self.isRenewMembership == true {
            if self.renewingMembershipID == "" {
                FireStoreManager.shared.getMemberByID(id: AppManager.shared.memberID, completion: {
                    (memberDetail,err) in
                    if err == nil {
                        let memberships = memberDetail!["memberships"] as! NSArray
                        let currentMembership = AppManager.shared.getCurrentMembership(membershipArray: memberships)
                        if currentMembership.count > 0 {
                            self.setRenewingMembershipData(membership: currentMembership.first!)
                            self.renewingMembershipID = currentMembership.first!.membershipID
                        }
                    }
                })
            } else {
                FireStoreManager.shared.getMembershipWith(memberID: AppManager.shared.memberID, membershipID: self.renewingMembershipID, result: {
                    (membershipData,err) in
                    if err != nil {
                        self.viewWillAppear(true)
                    } else{
                        self.setRenewingMembershipData(membership: membershipData!)
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memberIDTextField.text = "\(Int.random(in: 1..<100000))" 
        self.memberIDTextField.isEnabled = false
        self.memberIDTextField.alpha = 0.4
        self.endDateTextField.isEnabled = false
        self.endDateTextField.alpha = 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            if self.isNewMember == false {
               self.myScrollView.contentSize.height = 900
            }
        })
        
        if self.isNewMember == false {
            self.showMemberScreen()
            self.profileAndMembershipBarView.isUserInteractionEnabled = false
            self.profileAndMembershipBarView.alpha = 0.6
            self.featchMemberDetail(id: AppManager.shared.memberID)
        }
        else {
            if self.visitorID.count > 1 {
                self.fetchVisitorDetail(id: self.visitorID)
            } else {
                self.clearAllFields()
            }
        }
    }

    @IBAction func profileBtnAction(_ sender: Any) {
        self.showProfileScreen()
    }
    
    @IBAction func memberBtnAction(_ sender: Any) {
        self.showMemberScreen()
    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        self.showMemberScreen()
    }
    
    @IBAction func generalTypeOpitonBtnAction(_ sender: Any) {
        if  generalTypeOptionBtn.currentImage ==  UIImage(named: "non_selecte") {
            self.generalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
    }
    
    @IBAction func perosnalTypeOptionBtnAction(_ sender: Any) {
        if  personalTypeOptionBtn.currentImage ==  UIImage(named: "non_selecte") {
            self.generalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.personalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        }
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        SVProgressHUD.show()
        if self.isNewMember == true {
            if self.visitorID != "" {
                FireStoreManager.shared.uploadUserImg(imgData: self.visitorProfileImgData!, id: self.memberIDTextField.text!, completion: {
                    (err) in
                    
                    if err != nil {
                        SVProgressHUD.dismiss()
                        self.errorAlert(message: "Error in registering member,Please try again.")
                    }else{
                        self.registerMember(memberDetail: self.getMemberDetails(), membershipDetail: self.getMembershipDetails())
                    }
                })
            } else {
                self.registerMember(memberDetail: self.getMemberDetails(), membershipDetail: self.getMembershipDetails())
            }
        }
            
        else if self.isRenewMembership == true {
            self.updateMembershipBy(memberID: AppManager.shared.memberID, membershipId: self.membershipID)
        }
            
        else{
            self.addNewMembership(membershipDetail: self.getMembershipDetails())
        }
    }
    
       @objc func cancelTextField()  {
           self.view.endEditing(true)
       }
    
    @objc func doneTextField()  {
        self.selectedDate = datePicker.date
        self.view.endEditing(true)
    }
    
    func setRenewingMembershipData(membership:MembershipDetailStructure)  {
        self.membershipID = membership.membershipID
        self.membershipPlanTextField.text = membership.membershipPlan
        self.membershipDetailTextView.text = membership.membershipDetail
        self.amountTextField.text = membership.amount
        self.totalAmountTextField.text = membership.totalAmount
        self.dueAmountTextField.text = membership.dueAmount
        self.discountTextField.text = membership.discount
        self.startDateTextField.text = membership.startDate
        self.endDateTextField.text = membership.endDate
        self.paymentTypeTextField.text = membership.paymentType
        self.renewingMembershipDuration = membership.membershipDuration
        
        [self.membershipPlanTextField,self.amountTextField].forEach{
            $0?.isEnabled = false
            $0?.alpha = 0.4
        }
        self.membershipDetailTextView.isEditable = false
        self.membershipDetailTextView.alpha = 0.4
    }
}

extension AddMemberViewController{
    
    func allNewMemberFieldsRequiredValidation(textField:UITextField)  {
        switch textField.tag {
        case 1:
            validation.requiredValidation(textField: textField, errorLabel: self.firstNameErrorLabel, errorMessage: "First Name required.")
        case 2:
            validation.requiredValidation(textField: textField, errorLabel: self.lastNameErrorLabel, errorMessage: "Last Name required.")
        case 3:
            validation.requiredValidation(textField: textField, errorLabel: self.memberIDErrorLabel, errorMessage: "Member ID required." )
        case 4:
            validation.requiredValidation(textField: textField, errorLabel: self.dateOfJoinErrorLabel, errorMessage: "Date of join required.")
        case 5:
            validation.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "Member's gender required.")
        case 6:
            validation.requiredValidation(textField: textField, errorLabel: self.passwordErrorLabel, errorMessage: "Password required." )
        case 7:
            validation.requiredValidation(textField: textField, errorLabel: self.trainerNameErrorLabel, errorMessage: "Trainer's name required.")
        case 8:
                validation.requiredValidation(textField: textField, errorLabel: self.uploadIDErrorLabel, errorMessage: "Upload ID required." )
        case 9:
                validation.requiredValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Email Required required.")
        case 10:
                validation.phoneNumberValidation(textField: textField, errorLabel: self.phoneNumberErrorLabel, errorMessage: "Phone number must be 10 digits only.")
            
        case 11:
            validation.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required.")
            
        case 12:
            validation.requiredValidation(textField: textField, errorLabel: self.membershipPlanErrorLabel, errorMessage: "Please select membership plan.")
            
        case 13:
            validation.requiredValidation(textField: textField, errorLabel: self.amountErrorLabel, errorMessage: "Membership amount required.")
            
        case 14:
            validation.requiredValidation(textField: textField, errorLabel: self.startDateErrorLabel, errorMessage: "Start date require." )
            
        case 16:
            validation.requiredValidation(textField: textField, errorLabel: self.totalAmountErrorLabel, errorMessage: "Enter total amount." )
            
        case 17:
            validation.requiredValidation(textField: textField, errorLabel: self.discountErrorLabel, errorMessage: "Enter discount amount or 0." )
            
        case 18:
            validation.requiredValidation(textField: textField, errorLabel: self.paymentErrorLabel, errorMessage: "Payment type required.")
            
        case 19:
            validation.requiredValidation(textField: textField, errorLabel: self.dueAmountErrorLabel, errorMessage: "Enter due amount or 0." )

        default:
            break
        }
    }

    func addTopAndBottomBorders(toView:UIView) {
        let thickness: CGFloat = 0.9
        let topBorder = CALayer()
        let bottomBorder = CALayer()
        let borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0).cgColor
        
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: thickness)
        topBorder.backgroundColor = borderColor
        bottomBorder.frame = CGRect(x:0, y: toView.frame.size.height - thickness, width: self.view.frame.size.width, height:thickness)
        bottomBorder.backgroundColor = borderColor
        toView.layer.addSublayer(topBorder)
        toView.layer.addSublayer(bottomBorder)
    }
    
    func addRightView(toTextField:UITextField,imageName:String) {
        let imgView = UIImageView(image: UIImage(named: imageName))
        imgView.contentMode = .scaleAspectFit
        var v:UIView? = nil
        
        if imageName == "cam.png"{
            imgView.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
            v = UIView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width + 10 , height: imgView.frame.height))
            v!.addSubview(imgView)
            v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openImgPicker)))
        } else {
            imgView.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20)
            v = UIView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width + 10 , height: imgView.frame.height))
            v!.addSubview(imgView)
            v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMemberPlan)))
        }
        toTextField.rightView = v
        toTextField.rightViewMode = .always
    }
    
    @objc func openImgPicker(){
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.modalPresentationStyle = .overCurrentContext
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func showMemberPlan(){
        if self.membershipPlanView.isHidden == true {
            self.membershipPlanView.isHidden = false
            self.membershipPlanView.alpha = 1.0
            self.fetchAllMemberships()
        }else{
            self.membershipPlanView.isHidden = true
            self.membershipPlanView.alpha = 0.0
        }
    }
    
    func setTextFields()  {
        [self.memberIDTextField,self.dateOfJoiningTextField,self.genderTextField,self.passwordTextField,self.trainerNameTextField,self.uploadIDTextField,self.paymentTypeTextField,self.dueAmountTextField].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
            $0?.addTarget(self, action:#selector(errorValidator(_:)), for: .editingChanged)
        }
        
        [self.emailTextField,self.phoneNumberTextField,self.dobTextField,self.membershipPlanTextField,self.amountTextField,self.startDateTextField,self.endDateTextField,self.totalAmountTextField,self.discountTextField,self.firstNameTextField,self.lastNameTextField].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
            $0?.addTarget(self, action:#selector(errorValidator(_:)), for: .editingChanged)
        }
        
        [self.addressTextView,self.membershipDetailTextView].forEach{
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
        }
        
        [self.nextBtn,self.updateBtn].forEach{
            $0.layer.cornerRadius = 15.0
        }
    }
    
    @objc func errorValidator(_ textField:UITextField) {
        self.allNewMemberFieldsRequiredValidation(textField: textField)
        self.validation.updateBtnValidator(updateBtn:self.updateBtn , textFieldArray: self.textFieldArray, textView: self.membershipPlanView.isHidden == true ? self.addressTextView : self.membershipDetailTextView, phoneNumberTextField: self.membershipPlanView.isHidden == true ? nil : self.phoneNumberTextField)
        
    }
    
    func addPaddingToTextField(textField:UITextField) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
    }
    
    func showMemberScreen()  {
        self.myScrollView.contentSize.height = 800
        self.membershipBtn.backgroundColor = UIColor(red: 236/255, green: 217/255, blue: 72/255, alpha: 1.0)
        self.profileBtn.backgroundColor = .clear
        self.memberProfileView.isHidden = true
        self.memberProfileView.alpha = 0.0
        self.membershipView.isHidden = false
        self.membershipView.alpha = 1.0
    }
    
    func showProfileScreen() {
        self.myScrollView.contentSize.height = 1157
        self.profileBtn.backgroundColor = UIColor(red: 236/255, green: 217/255, blue: 72/255, alpha: 1.0)
        self.membershipBtn.backgroundColor = .clear
        self.memberProfileView.isHidden = false
        self.memberProfileView.alpha = 1.0
        self.membershipView.isHidden = true
        self.membershipView.alpha = 0.0
    }
    
    func setNavigationBar() {
        addMemberNavigationBar.navigationTitleLabel.text = "Member"
        addMemberNavigationBar.menuBtn.isHidden = true
        addMemberNavigationBar.leftArrowBtn.isHidden = false
        addMemberNavigationBar.leftArrowBtn.alpha = 1.0
        addMemberNavigationBar.searchBtn.isHidden = true
    }
    
    func getMemberDetails() -> [String:String] {
        let memberDetail:[String:String] = [
            "firstName":self.firstNameTextField.text!,
            "lastName": self.lastNameTextField.text!,
            "memberID":self.memberIDTextField.text!,
            "dateOfJoining":self.dateOfJoiningTextField.text!,
            "gender":self.genderTextField.text!,
            "password":self.passwordTextField.text!,
            "type":self.selectedMembershipType(),
            "trainerName":self.trainerNameTextField.text!,
            "uploadIDName":self.uploadIDTextField.text!,
            "email":self.emailTextField.text!,
            "address":self.addressTextView.text!,
            "phoneNo" : self.phoneNumberTextField.text!,
            "dob":self.dobTextField.text!
        ]
        return memberDetail
    }
    
    func getMembershipDetails() -> [[String:String]] {
         let membership:[[String:String]] = [[
            "membershipID": self.membershipID,
            "membershipPlan": self.membershipPlanTextField.text!,
            "membershipDetail":self.membershipDetailTextView.text!,
            "amount": self.amountTextField.text!,
            "startDate":self.startDateTextField.text!,
            "endDate":self.endDateTextField.text!,
            "totalAmount":self.totalAmountTextField.text!,
            "discount":self.discountTextField.text!,
            "paymentType":self.paymentTypeTextField.text!,
            "dueAmount":self.dueAmountTextField.text!,
            "purchaseTime": "\(AppManager.shared.getTimeFrom(date: Date()))",
            "purchaseDate": AppManager.shared.dateWithMonthName(date: Date()),
            "membershipDuration" : "\(self.membershipDuration)"
        ]]
        return membership
    }
    
    func successAlert(message:String)  {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            
            if self.visitorID != "" {
                FireStoreManager.shared.deleteImgBy(id: self.visitorID, result: {
                    err in
                    if err != nil {
                        
                    } else {
                        FireStoreManager.shared.deleteVisitorBy(id: self.visitorID, completion: {
                            err in
                            if err != nil {
                                
                            }else {
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                })
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        alert.addAction(okAlertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func selectedMembershipType() -> String {
        var type :String = ""
        if self.generalTypeOptionBtn.currentImage == UIImage(named: "selelecte"){
            type = "General"
        } else {
            type = "Personal"
        }
        return type
    }
    
    func setMembershipType(type:String) {
        if type == "General" {
            self.generalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        } else {
            self.generalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.personalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        }
    }

    func errorAlert(message:String)  {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAlertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func registerMember(memberDetail:[String:String],membershipDetail:[[String:String]]) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            
            FireStoreManager.shared.uploadImg(url:self.imgUrl!, membeID:self.memberIDTextField.text! , imageName: self.imgUrl!.lastPathComponent, completion: {
                (err) in
                if err != nil {
                    SVProgressHUD.dismiss()
                    self.errorAlert(message: "ID is not uploaded successfully.")
                } else {
                    FireStoreManager.shared.addMember(email:self.emailTextField.text!,password: self.passwordTextField.text!,memberDetail: memberDetail, memberships: membershipDetail, memberID: self.memberIDTextField.text!, handler: {
                        (err) in
                        if err != nil {
                            SVProgressHUD.dismiss()
                            self.errorAlert(message: "\(err?.localizedDescription ?? "Member is not registered successfully.")")
                        } else {
                            SVProgressHUD.dismiss()
                            self.successAlert(message: "Member is registered successfully.")
                        }
                    })
                }
            })
        })
    }
    
    func addNewMembership(membershipDetail:[[String:String]]) {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            SVProgressHUD.dismiss()
            
            FireStoreManager.shared.addNewMembeship(memberID: AppManager.shared.memberID, membership: self.getMembershipDetails().first!, completion: {
                (err) in
                
                if err != nil {
                    self.errorAlert(message: "New Membership is not added successfully, Try again.")
                } else {
                    self.successAlert(message: "New Membership is added successfully.")
                }
            })

//            FireStoreManager.shared.updateMemberDetails(id: AppManager.shared.memberID, memberDetail: self.getMemberDetails(), handler: {
//                (err) in
//                if err != nil {
//                    self.errorAlert(message: "Member Details are not updated successfully,Try again")
//                } else{
//
//                }
//            })
            
        })
    }
    
    func updateMembershipBy(memberID:String,membershipId:String) {
        FireStoreManager.shared.updateMembershipBy(memberID: memberID, membershipID: membershipId, membershipDetail: self.getMembershipDetails().first!, result: {
            err in
            if err != nil {
                self.errorAlert(message: "Error in  renewing current membership.")
            } else {
                self.successAlert(message: "Success in renewing current membership.")
            }
        })
    }
  
    func setCompleteView() {
        self.setNavigationBar()
        self.addTopAndBottomBorders(toView: profileAndMembershipBarView)
        self.addRightView(toTextField: self.uploadIDTextField, imageName: "cam.png")
        self.addRightView(toTextField: self.membershipPlanTextField, imageName: "arrow-down.png")
        self.setTextFields()
        setBackAction(toView: self.addMemberNavigationBar)
        self.generalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        self.personalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        imagePicker.delegate = self
        
        self.membershipPlanView.layer.cornerRadius = 12.0
        self.membershipPlanView.layer.shadowColor = UIColor.black.cgColor
        self.membershipPlanView.layer.shadowOffset = .zero
        self.membershipPlanView.layer.shadowOpacity = 20.0
        self.membershipPlanView.layer.borderColor = UIColor.gray.cgColor
        self.membershipPlanView.layer.borderWidth = 1.0
        self.membershipPlanView.clipsToBounds = true
        self.membershipPlanTable.tableFooterView = UIView()
        
        self.errorLabelArray = [self.firstNameErrorLabel,self.lastNameErrorLabel,self.memberIDErrorLabel,self.dateOfJoinErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.uploadIDErrorLabel,self.trainerNameErrorLabel,self.emailErrorLabel,self.addressErrorLabel,self.phoneNumberErrorLabel,self.dobErrorLabel,self.membershipPlanErrorLabel,self.amountErrorLabel,self.startDateErrorLabel,self.totalAmountErrorLabel,self.discountErrorLabel,self.paymentErrorLabel,self.discountErrorLabel]
        
        self.memberProfileFieldArray = [self.firstNameTextField,self.lastNameTextField,self.memberIDTextField,self.dateOfJoiningTextField,self.genderTextField,self.passwordTextField,self.trainerNameTextField,self.uploadIDTextField,self.emailTextField,self.phoneNumberTextField,self.dobTextField]
        
        self.membershipFieldArray = [self.membershipPlanTextField,self.amountTextField,self.startDateTextField,self.endDateTextField,self.totalAmountTextField,self.discountTextField,self.paymentTypeTextField,self.dueAmountTextField]
        
        self.textFieldArray = Array(Set(self.membershipFieldArray + self.membershipFieldArray ))
        
        self.datePicker.datePickerMode = .date
        self.datePicker.date = Date()
        toolBar.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar.sizeToFit()
    }
    
    func featchMemberDetail(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (docSnapshot,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.retryMemberDataAlert()
            } else {
                let memberDetail = AppManager.shared.getMemberDetailStr(memberDetail: docSnapshot?["memberDetail"] as! NSDictionary)
                self.fillMemberDetail(memberDetail: memberDetail)
            }
        })
    }

    func fillMemberDetail(memberDetail:MemberDetailStructure) {
        self.firstNameTextField.text = memberDetail.firstName
        self.lastNameTextField.text = memberDetail.lastName
        self.memberIDTextField.text = memberDetail.memberID
        self.dateOfJoiningTextField.text = memberDetail.dateOfJoining
        self.genderTextField.text = memberDetail.gender
        self.passwordTextField.text = memberDetail.password
        self.setMembershipType(type: memberDetail.type)
        self.trainerNameTextField.text = memberDetail.trainerName
        self.uploadIDTextField.text = memberDetail.uploadIDName
        self.emailTextField.text = memberDetail.email
        self.addressTextView.text = memberDetail.address
        self.phoneNumberTextField.text = memberDetail.phoneNo
        self.dobTextField.text = memberDetail.dob
    }
       func retryMemberDataAlert() {
            let retryAlertController = UIAlertController(title: "Error", message: "Error in getting the member Detail.", preferredStyle: .alert)
            let retryAlertBtn = UIAlertAction(title: "Retry", style: .default, handler: {
                (action) in
               self.featchMemberDetail(id: AppManager.shared.memberID)
            })
            retryAlertController.addAction(retryAlertBtn)
            present(retryAlertController, animated: true, completion: nil)
        }
    
    func clearAllFields() {
            [self.dateOfJoiningTextField,self.genderTextField,self.passwordTextField,self.trainerNameTextField,self.uploadIDTextField,self.paymentTypeTextField,self.dueAmountTextField].forEach{
                $0?.text = ""
                  }
            
            [self.emailTextField,self.phoneNumberTextField,self.dobTextField,self.membershipPlanTextField,self.amountTextField,self.startDateTextField,self.endDateTextField,self.totalAmountTextField,self.discountTextField,self.firstNameTextField,self.lastNameTextField].forEach{
                $0?.text = ""
                }
    }
    
    func fetchVisitorBy(id:String) {
        FireStoreManager.shared.getVisitorBy(id: id, result: {
            (visitor,err ) in
            
            if err != nil {
                self.viewWillAppear(true)
            } else{
                self.fillVisitorDetail(visitor: AppManager.shared.getVisitor(visitorDetail: visitor?["visitorDetail"] as! [String : String], id: visitor?["id"] as! String))
            }
        })
    }
    
    func fetchVisitorDetail(id:String) {
       // getVisitorProfileToMemberImage(id: id, imgView: self.memberImg)
      self.fetchVisitorBy(id: id)
    }

    func fillVisitorDetail(visitor:Visitor) {
          self.firstNameTextField.text = visitor.firstName
              self.lastNameTextField.text = visitor.lastName
              self.dateOfJoiningTextField.text = visitor.dateOfJoin
              self.genderTextField.text = visitor.gender
              self.emailTextField.text = visitor.email
              self.addressTextView.text = visitor.address
              self.phoneNumberTextField.text = visitor.phoneNo
    }
    
    func fetchAllMemberships() {
        SVProgressHUD.show()
        FireStoreManager.shared.getAllMembership(result: {
        (data,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.viewDidLoad()
            }else {
                self.memberhsipPlanArray.removeAll()
                for singleData in data!{
                    let membershipPlanDetail = singleData["membershipDetail"] as! [String:String]
                    let membershipID = singleData["id"] as! String
                    self.memberhsipPlanArray.append(AppManager.shared.getMembership(membership: membershipPlanDetail, membershipID: membershipID))
                }
                self.membershipPlanTable.reloadData()
            }
        })
    }
}

extension AddMemberViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImgURL:URL = info[ .imageURL ] as? URL {
            self.imgUrl = selectedImgURL
            let imgaeName = selectedImgURL.lastPathComponent
            self.uploadIDTextField.text = imgaeName
            picker.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddMemberViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 4 || textField.tag == 11 || textField.tag == 14 || textField.tag == 8{
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 4 || textField.tag == 11 || textField.tag == 14{
            textField.inputAccessoryView = self.toolBar
            textField.inputView = datePicker
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
        }
//        self.allNewMemberFieldsRequiredValidation(textField: textField)
//        self.validation.updateBtnValidator(updateBtn:self.updateBtn , textFieldArray: self.membershipPlanView.isHidden == false ? self.membershipFieldArray : self.memberProfileFieldArray, textView: self.membershipPlanView.isHidden == true ? self.addressTextView : self.membershipDetailTextView, phoneNumberTextField: self.membershipPlanView.isHidden == true ? nil : self.phoneNumberTextField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.selectedDate != nil  {
            switch textField.tag {
                              case 4:
                                self.dateOfJoiningTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
                              case 11:
                                self.dobTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
                              case 14:
                                if self.isRenewMembership == true {
                                    self.membershipDuration = Int(self.renewingMembershipDuration)!
                                }
                                self.startDateTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
                                self.endDateTextField.text = AppManager.shared.dateWithMonthName(date: AppManager.shared.getMembershipEndDate(startDate: self.selectedDate!, duration:self.membershipDuration))
                              default:
                                  break
                              }
        }
        self.allNewMemberFieldsRequiredValidation(textField: textField)
        self.validation.updateBtnValidator(updateBtn:self.updateBtn , textFieldArray: self.textFieldArray, textView: self.membershipPlanView.isHidden == true ? self.addressTextView : self.membershipDetailTextView, phoneNumberTextField: self.membershipPlanView.isHidden == true ? nil : self.phoneNumberTextField)
    }
}

extension AddMemberViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if memberProfileView.isHidden == false {
            self.validation.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
        }
        
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.validation.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
        self.validation.updateBtnValidator(updateBtn:self.updateBtn , textFieldArray: self.membershipPlanView.isHidden == false ? self.membershipFieldArray : self.memberProfileFieldArray, textView: textView, phoneNumberTextField: self.membershipPlanView.isHidden == true ? nil : self.phoneNumberTextField)
    }
}

extension AddMemberViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberhsipPlanArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "membershipPlanCell", for: indexPath) as! MemberhsipPlanTableCell
        let membership = self.memberhsipPlanArray[indexPath.row]
        cell.membershipPlanLabel.text = membership.title
        return cell
    }
}

extension AddMemberViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            SVProgressHUD.dismiss()
            let membership = self.memberhsipPlanArray[indexPath.row]
            self.membershipID = membership.membershipID
            self.membershipPlanTextField.text = membership.title
            self.membershipDetailTextView.text = membership.detail
            self.amountTextField.text = membership.amount
            self.startDateTextField.text = membership.startDate
            self.endDateTextField.text = membership.endDate
            self.membershipDuration = Int(membership.duration)!
        })
        self.membershipPlanView.isHidden = true
    }
}



