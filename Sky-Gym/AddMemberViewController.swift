//
//  AddMemberViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 01/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD
import Stripe

class MemberhsipPlanTableCell: UITableViewCell {
    @IBOutlet weak var membershipPlanLabel: UILabel!
}

class TrainerListTableCell: UITableViewCell {
    @IBOutlet weak var trainerName: UILabel!
}

class AddMemberViewController: BaseViewController {
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
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
    @IBOutlet weak var membershipDetailErrorLabel: UILabel!
    @IBOutlet weak var endDateErrorLabel: UILabel!
    @IBOutlet weak var topConstraintOfMembershipView: NSLayoutConstraint!
    @IBOutlet weak var generalTypeLabel: UILabel!
    @IBOutlet weak var personalTypeLabel: UILabel!
    @IBOutlet weak var trainerListView: UIView!
    @IBOutlet weak var trainerListTable: UITableView!
    @IBOutlet weak var membershipPlanBtn: UIButton!
    
    private lazy var imagePicker:UIImagePickerController = {
        return UIImagePickerController()
    }()
    
    private lazy var datePicker:UIDatePicker = {
        return UIDatePicker()
    }()
    
    private lazy var genderPickerView:UIPickerView = {
        return UIPickerView()
    }()
    
    private lazy var paymentTypePickerView:UIPickerView = {
        return UIPickerView()
    }()
    
    var imgUrl:URL? = nil
    var isNewMember:Bool = false
    var visitorID:String = ""
    var memberhsipPlanArray:[Memberhisp] = []
    var toolBar:UIToolbar? = nil
    var selectedDate:Date? = nil
    var membershipDuration:Int = 0
    var isRenewMembership:Bool = false
    var membershipID:String = ""
    var renewingMembershipID:String = ""
    var renewingMembershipDuration:String = ""
    var visitorProfileImgData:Data? = nil
    var errorLabelArray:[UILabel] = []
    var memberProfileFieldArray :[UITextField] = []
    var completeMemberProfileFieldArray :[UITextField] = []
    var membershipFieldArray:[UITextField] = []
    var textFieldArray:[UITextField] = []
    var previousDiscount:Int = 0
    var previousDueAmount:Int = 0
    var selectedTrainerType:String = ""
    var listOfTrainers:[TrainerDataStructure] = []
    var trainerID:String = ""
    var isAlreadyExistsEmail:Bool = false
    let genderArray  = ["Male","Female","Other"]
    let paymentTypeArray = ["Cash","Card"]
    var visitorEmail:String = ""
    var visitorProfileImageExists = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addClickToDismissMembershipList()
        self.setCompleteView()
        self.dueAmountTextField.isEnabled = false
        self.dueAmountTextField.alpha = 0.4
        self.updateBtn.tag = 0101
        NotificationCenter.default.addObserver(self, selector: #selector(completePaymentOperation(notification:)), name: NSNotification.Name(rawValue: "paymentSuccess"), object: nil)
        self.membershipPlanTextField.isUserInteractionEnabled = false
        self.membershipPlanTextField.isEnabled = false
        membershipPlanBtn.addTarget(self, action: #selector(showMembershipPlan), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memberIDTextField.text = "\(Int.random(in: 9999..<1000000))"
        self.memberIDTextField.isEnabled = false
        self.memberIDTextField.alpha = 0.4
        self.endDateTextField.isEnabled = false
        self.endDateTextField.alpha = 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            if self.memberProfileView.isHidden == true{
               self.myScrollView.contentSize.height = 800
            }
        })
        
        if self.isNewMember == false {
            self.showMembershipScreen()
            self.profileAndMembershipBarView.isUserInteractionEnabled = false
            self.profileAndMembershipBarView.isHidden = true
            DispatchQueue.main.async {
                self.topConstraintOfMembershipView.constant = -(self.profileAndMembershipBarView.frame.size.height - 20)
                 self.updateBtn.setTitle("U P D A T E", for: .normal)
            }
        }
        else {
            DispatchQueue.main.async {
                self.topConstraintOfMembershipView.constant = 0
                 self.updateBtn.setTitle("A D D", for: .normal)
            }
            if self.visitorID.count > 1 {
                self.fetchVisitorDetail(id: self.visitorID)
            } else {
                self.clearAllFields()
            }
        }
    }
    
    @objc func completePaymentOperation(notification:Notification) {
      // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
             self.cashPaymentUpdateBtnAction()
        print("User info : \(self.getMemberDetails())")
        print("Member ship info : \(self.getMembershipDetails())")
      //  })
    }
    
    @objc func showTrainerList() {
        self.view.endEditing(true)
        self.trainerListView.isHidden = !self.trainerListView.isHidden
        self.trainerListView.alpha = self.trainerListView.isHidden == true ? 0.0 : 1.0
    }

    @IBAction func profileBtnAction(_ sender: Any) {
        self.showProfileScreen()
    }
    
    @IBAction func memberBtnAction(_ sender: Any) {
        self.memberValidation()
    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        self.memberValidation()
    }
    
    @IBAction func trainerListBtnAction(_ sender: Any) {
        self.showTrainerList()
    }
        
    @IBAction func generalTypeOpitonBtnAction(_ sender: Any) {
        if  generalTypeOptionBtn.currentImage ==  UIImage(named: "non_selecte") {
            self.generalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
        self.fetchTrainersByCategory(category: .general)
    }
    
    @IBAction func perosnalTypeOptionBtnAction(_ sender: Any) {
        if  personalTypeOptionBtn.currentImage ==  UIImage(named: "non_selecte") {
            self.generalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.personalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        }
        self.fetchTrainersByCategory(category: .personal)
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        self.membershipValidation()
        if ValidationManager.shared.isMembershipFieldsValidated(textFieldArray: self.membershipFieldArray, textView: self.membershipDetailTextView) == true {
            switch self.updateBtn.tag {
            case 0101:
                self.cashPaymentUpdateBtnAction()
                break
            case 1011 :
                self.onlinePaymentUpdateAction()
                break
            default:
                break
            }
        }
    }
    
    func onlinePaymentUpdateAction() {
        let paymentController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "paymentVC") as! CardPaymentViewController
        paymentController.membershipPlanStr = self.membershipPlanTextField.text!
        paymentController.startDateStr = self.startDateTextField.text!
        paymentController.endDateStr = self.endDateTextField.text!
        paymentController.amountStr = self.totalAmountTextField.text!
        self.navigationController?.pushViewController(paymentController, animated: true)
    }
    
    func cashPaymentUpdateBtnAction() {
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
        self.selectedDate = AppManager.shared.getStandardFormatDate(date: datePicker.date)
        self.view.endEditing(true)
    }
    
    func setRenewingMembershipData(membership:MembershipDetailStructure)  {
        self.membershipID = membership.membershipID
        self.membershipPlanTextField.text = membership.membershipPlan
        self.membershipDetailTextView.text = membership.membershipDetail
        self.amountTextField.text = membership.amount
        self.totalAmountTextField.text = membership.paidAmount
        self.previousDueAmount = Int(membership.dueAmount)!
        self.dueAmountTextField.text =  membership.dueAmount
        self.previousDiscount = Int(membership.discount)!
        self.discountTextField.text = "\(self.getDiscountPercentage(totalAmount: Int(membership.amount)!, discount: Int(membership.discount)!))"
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

    func fetchTrainersByCategory(category:TrainerType) {
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getTrainerByCategory(category: category)
            
            DispatchQueue.main.async {
                switch result {
                    
                case  let .success(trainerList):
                    self.listOfTrainers = trainerList
                    self.trainerListTable.reloadData()
                case .failure(_):
                    self.listOfTrainers = []
                }
            }
        }
    }
    
    func memberValidation() {
        for textField in self.completeMemberProfileFieldArray {
            self.allNewMemberFieldsRequiredValidation(textField: textField)
        }
        ValidationManager.shared.requiredValidation(textView: self.addressTextView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
        
        if ValidationManager.shared.isMemberProfileValidated(textFieldArray: self.completeMemberProfileFieldArray, textView: self.addressTextView, phoneNumberTextField: self.phoneNumberTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!) ==  true {
            self.showMembershipScreen()
        }
    }
    
    func membershipValidation()  {
        for textField in self.membershipFieldArray  {
            self.allNewMemberFieldsRequiredValidation(textField: textField)
        }
        ValidationManager.shared.requiredValidation(textView: self.membershipDetailTextView, errorLabel: self.membershipDetailErrorLabel, errorMessage: "Membership Detail required.")
    }
    
    
    func allNewMemberFieldsRequiredValidation(textField:UITextField)  {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.firstNameErrorLabel, errorMessage: "First Name required.")
        case 2:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.lastNameErrorLabel, errorMessage: "Last Name required.")
        case 3:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.memberIDErrorLabel, errorMessage: "Member ID required." )
        case 4:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.dateOfJoinErrorLabel, errorMessage: "Date of join required.")
        case 5:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.genderErrorLabel, errorMessage: "Member's gender required.")
        case 6:
            ValidationManager.shared.passwordValidation(textField: textField, errorLabel: self.passwordErrorLabel, errorMessage: "Password must be greater than 8 character.")
        case 7:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.trainerNameErrorLabel, errorMessage: "Trainer's name required.")
        case 8:
                ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.uploadIDErrorLabel, errorMessage: "Upload ID required." )
        case 9:
            ValidationManager.shared.emailValidation(textField: textField, errorLabel: self.emailErrorLabel, errorMessage: "Invalid Email.")
        case 10:
                ValidationManager.shared.phoneNumberValidation(textField: textField, errorLabel: self.phoneNumberErrorLabel, errorMessage: "Phone number must be 10 digits only.")
            
        case 11:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.dobErrorLabel, errorMessage: "D.O.B. required.")
            
        case 12:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.membershipPlanErrorLabel, errorMessage: "Please select membership plan.")
            
        case 13:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.amountErrorLabel, errorMessage: "Membership amount required.")
            
        case 14:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.startDateErrorLabel, errorMessage: "Start date require." )
            
        case 15:
                ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.endDateErrorLabel, errorMessage: "End date require." )
            
        case 16:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.totalAmountErrorLabel, errorMessage: "Enter Paying amount." )
            
        case 17:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.discountErrorLabel, errorMessage: "Enter discount amount or 0." )
            
        case 18:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.paymentErrorLabel, errorMessage: "Payment type required.")
            
//        case 19:
//            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.dueAmountErrorLabel, errorMessage: "Enter due amount or 0." )

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
            v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMembershipPlan)))
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
    
    @objc func showMembershipPlan(){
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
        if self.isNewMember == true {
            ValidationManager.shared.updateBtnValidator(updateBtn:self.updateBtn , textFieldArray: self.textFieldArray, textView: self.membershipPlanView.isHidden == true ? self.addressTextView : self.membershipDetailTextView, phoneNumberTextField: self.phoneNumberTextField,email: self.emailTextField.text!,password: self.passwordTextField.text!)
        } else {
            ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.membershipFieldArray, textView: self.membershipDetailTextView, phoneNumberTextField: nil, email: nil, password: nil)
        }
    }
    
    func addPaddingToTextField(textField:UITextField) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
    }
    
    func showMembershipScreen()  {
        SVProgressHUD.show()
        DispatchQueue.main.async {
            self.myScrollView.contentSize.height = 850
            self.membershipBtn.backgroundColor = UIColor(red: 236/255, green: 217/255, blue: 72/255, alpha: 1.0)
            self.profileBtn.backgroundColor = .clear
            self.memberProfileView.isHidden = true
            self.memberProfileView.alpha = 0.0
            self.membershipView.isHidden = false
            self.membershipView.alpha = 1.0
            SVProgressHUD.dismiss()
        }
    }
    
    func showProfileScreen() {
        DispatchQueue.main.async {
            self.myScrollView.contentSize.height = 1240
            self.profileBtn.backgroundColor = UIColor(red: 236/255, green: 217/255, blue: 72/255, alpha: 1.0)
            self.membershipBtn.backgroundColor = .clear
            self.memberProfileView.isHidden = false
            self.memberProfileView.alpha = 1.0
            self.membershipView.isHidden = true
            self.membershipView.alpha = 0.0
        }
    }
    
    func setAddMemberNavigationBar() {
        let str = self.isNewMember == true ? "Member" : "Membership"
        let title = NSAttributedString(string: str, attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(addMemberBackBtnAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,backButton])
        stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let backBtn = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc func  addMemberBackBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func getMemberDetails() -> [String:String] {
        let memberDetail:[String:String] = [
            "firstName":self.firstNameTextField.text!,
            "lastName": self.lastNameTextField.text!,
            "memberID":self.memberIDTextField.text!,
            "dateOfJoining":self.dateOfJoiningTextField.text!,
            "gender":self.genderTextField.text!,
            "password":AppManager.shared.encryption(plainText: self.passwordTextField.text!),
            "type":self.selectedMembershipType(),
            "trainerName":self.trainerNameTextField.text!,
            "uploadIDName":self.uploadIDTextField.text!,
            "email":self.emailTextField.text!,
            "address":self.addressTextView.text!,
            "phoneNo" : self.phoneNumberTextField.text!,
            "dob":self.dobTextField.text!,
            "trainerID": self.trainerID
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
            "totalAmount":"\(self.getTotalAmount())",
            "paidAmount" : self.totalAmountTextField.text!,
            "discount":"\(self.getTotalDiscount())",
            "paymentType":self.paymentTypeTextField.text!,
            "dueAmount":self.dueAmountTextField.text!,
            "purchaseTime": "\(AppManager.shared.getTime(date: Date()))",
            "purchaseDate": AppManager.shared.dateWithMonthName(date: Date()),
            "membershipDuration" : "\(self.getMembershipDuration())",
            "purchaseTimeStamp" : "\(Date().timeIntervalSince1970)"
        ]]
        return membership
    }
    
    func getMembershipDuration() -> String {
        let s = self.isRenewMembership == true ? self.renewingMembershipDuration : "\(self.membershipDuration)"
        return s
    }
    
    private func addClickToDismissMembershipList() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMembershipList(_:)))
        tapRecognizer.cancelsTouchesInView = false
        self.view.isUserInteractionEnabled = true
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissMembershipList(_ gesture : UITapGestureRecognizer) {
        self.membershipPlanView.isHidden = true
        self.membershipPlanView.alpha = 0.0
        self.trainerListView.isHidden = true
        self.trainerListView.alpha = 0.0
    }
    
    @objc func trainerTypeSelection(_ gesture:UITapGestureRecognizer) {
        let selectedLabel = gesture.view as! UILabel
        self.setMembershipType(type: selectedLabel.text!)
       
    }
    
    func getTotalAmount() -> Int {
        let membershipAmount =  Int(self.amountTextField.text!) ?? 0
        let dueAmount = self.getDueAmount()
        return membershipAmount - (dueAmount + self.getTotalDiscount())
    }
    
    func getTotalDiscount() -> Int {
        let currentDiscount = self.getDiscountAmount()
        if self.previousDiscount == currentDiscount {
            return previousDiscount
        }else {
            self.previousDiscount = currentDiscount
            return self.previousDiscount
        }
    }
    
    func successAlert(message:String)  {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            
            if self.visitorID != "" {
                SVProgressHUD.show()
                FireStoreManager.shared.deleteUserCredentials(id: self.visitorID, handler: {
                    (err) in
                    
                    if err == nil {
                        if self.visitorProfileImageExists == true {

                            DispatchQueue.global(qos: .background).async {
                                let result = FireStoreManager.shared.deleteImgBy(id: self.visitorID)
                                
                                DispatchQueue.main.async {
                                    switch result {
                                    case .failure(_) :
                                        SVProgressHUD.dismiss()
                                        self.errorAlert(message: "Error in deleting member.")
                                    case  let .success(flag) :
                                        if flag == true {
                                            FireStoreManager.shared.deleteVisitorBy(id: self.visitorID, completion: {
                                                err in
                                                if err != nil {
                                                    SVProgressHUD.dismiss()
                                                    self.errorAlert(message: "Error in deleting member.")
                                                }else {
                                                    SVProgressHUD.dismiss()
                                                    self.navigationController?.popViewController(animated: true)
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        }else {
                            FireStoreManager.shared.deleteVisitorBy(id: self.visitorID, completion: {
                                err in
                                if err != nil {
                                    SVProgressHUD.dismiss()
                                    self.errorAlert(message: "Error in deleting member.")
                                }else {
                                    SVProgressHUD.dismiss()
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })

                        }
                    }
                })
            } else {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
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
            self.fetchTrainersByCategory(category: .general)
        } else {
            self.generalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.personalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.fetchTrainersByCategory(category: .personal)
        }
    }

    func errorAlert(message:String)  {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            //self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(okAlertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func registerMember(memberDetail:[String:String],membershipDetail:[[String:String]]) {
        SVProgressHUD.show()
        let encryptedPassword = memberDetail["password"]
        let memberID = memberDetail["memberID"]
        let email = memberDetail["email"]
        if self.isAlreadyExistsEmail == false {
            FireStoreManager.shared.addNewUserCredentials(id: memberID!, email: email!, password:encryptedPassword!, handler: {
                (err) in
                
                if err == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        FireStoreManager.shared.uploadImg(url:self.imgUrl!, membeID:memberID! , imageName: self.imgUrl!.lastPathComponent, completion: {
                            (err) in
                            if err != nil {
                                SVProgressHUD.dismiss()
                                self.errorAlert(message: "ID is not uploaded successfully.")
                            } else {
                                FireStoreManager.shared.addMember(email:email!,password: encryptedPassword!,memberDetail: memberDetail, memberships: membershipDetail, memberID: memberID!, handler: {
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
            })
            
        }else {
            print("ALREADY EXISTS EMAIL")
        }
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
        self.toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        self.setAddMemberNavigationBar()
        self.addTopAndBottomBorders(toView: profileAndMembershipBarView)
        self.addRightView(toTextField: self.uploadIDTextField, imageName: "cam.png")
        self.addRightView(toTextField: self.membershipPlanTextField, imageName: "arrow-down.png")
        self.setTextFields()
        self.generalTypeOptionBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        self.personalTypeOptionBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        imagePicker.delegate = self
        
        datePicker.timeZone = TimeZone(secondsFromGMT: 0)
        self.membershipPlanView.layer.cornerRadius = 12.0
        self.membershipPlanView.layer.shadowColor = UIColor.black.cgColor
        self.membershipPlanView.layer.shadowOffset = .zero
        self.membershipPlanView.layer.shadowOpacity = 20.0
        self.membershipPlanView.layer.borderColor = UIColor.gray.cgColor
        self.membershipPlanView.layer.borderWidth = 1.0
        self.membershipPlanView.clipsToBounds = true
        self.membershipPlanTable.tableFooterView = UIView()
        self.membershipDetailTextView.isEditable = false
        self.membershipDetailTextView.alpha = 0.6
        self.amountTextField.isEnabled = false
        self.amountTextField.alpha = 0.6
        
        self.paymentTypePickerView.tag = 0101
        self.paymentTypePickerView.delegate = self
        self.paymentTypePickerView.dataSource = self
        
        self.errorLabelArray = [self.firstNameErrorLabel,self.lastNameErrorLabel,self.memberIDErrorLabel,self.dateOfJoinErrorLabel,self.genderErrorLabel,self.passwordErrorLabel,self.uploadIDErrorLabel,self.trainerNameErrorLabel,self.emailErrorLabel,self.addressErrorLabel,self.phoneNumberErrorLabel,self.dobErrorLabel,self.membershipPlanErrorLabel,self.amountErrorLabel,self.startDateErrorLabel,self.totalAmountErrorLabel,self.discountErrorLabel,self.paymentErrorLabel,self.discountErrorLabel]
        
        self.memberProfileFieldArray = [self.firstNameTextField,self.lastNameTextField,self.memberIDTextField,self.dateOfJoiningTextField,self.genderTextField,self.trainerNameTextField,self.uploadIDTextField,self.emailTextField,self.dobTextField]
        
        self.membershipFieldArray = [self.membershipPlanTextField,self.amountTextField,self.startDateTextField,self.endDateTextField,self.totalAmountTextField,self.discountTextField,self.paymentTypeTextField,self.dueAmountTextField]
        
        self.completeMemberProfileFieldArray = [
            self.firstNameTextField,self.lastNameTextField,self.memberIDTextField,self.dateOfJoiningTextField,self.genderTextField,self.trainerNameTextField,self.uploadIDTextField,self.emailTextField,self.dobTextField,self.phoneNumberTextField,self.passwordTextField
        ]
        
        self.textFieldArray = Array(Set(self.membershipFieldArray + self.membershipFieldArray ))
        
        self.generalTypeLabel.isUserInteractionEnabled = true
        self.personalTypeLabel.isUserInteractionEnabled = true
        self.generalTypeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trainerTypeSelection(_:))))
        self.personalTypeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trainerTypeSelection(_:))))
        
        self.datePicker.datePickerMode = .date
        self.datePicker.date = Date()
        toolBar?.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar?.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar?.sizeToFit()
        
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
        
        if self.isRenewMembership == true {
            if self.renewingMembershipID == "" {
                FireStoreManager.shared.getMemberByID(id: AppManager.shared.memberID, completion: {
                    (memberDetail,err) in
                    if err == nil {
                        let memberships = memberDetail!["memberships"] as! Array<Dictionary<String,String>>
                        let currentMembership = AppManager.shared.getCurrentMembership(membershipArray: memberships)
                        if currentMembership.count > 0 {
                            self.setRenewingMembershipData(membership: currentMembership.first!)
                            self.renewingMembershipID = currentMembership.first!.membershipID
                        } else {
                            let previousMembership = AppManager.shared.getPreviousMembership(membershipArray: memberships)
                            self.setRenewingMembershipData(membership: previousMembership)
                            self.renewingMembershipID = previousMembership.membershipID
                        }
                    }
                })
            } else {
                FireStoreManager.shared.getMembershipWith(memberID: AppManager.shared.memberID, membershipID: self.renewingMembershipID, result: {
                    (membershipData,err) in
                    if err != nil {
                        
                    } else{
                        self.setRenewingMembershipData(membership: membershipData!)
                    }
                })
            }
            DispatchQueue.main.async {
                self.updateBtn.setTitle("U P D A T E", for: .normal)
            }
        }
        self.trainerListView.layer.cornerRadius = 12.0
        self.trainerListView.layer.borderWidth = 1.0
        self.trainerListTable.layer.cornerRadius = 12.0
        self.trainerListTable.layer.borderWidth = 1.0
        self.trainerListView.layer.borderColor = UIColor.black.cgColor
        self.trainerListView.isHidden = true
        self.trainerListView.alpha = 0.0
        self.trainerNameTextField.isUserInteractionEnabled = false
        self.fetchTrainersByCategory(category: .general)
    }
    
       func retryMemberDataAlert() {
            let retryAlertController = UIAlertController(title: "Error", message: "Error in getting the member Detail.", preferredStyle: .alert)
            let retryAlertBtn = UIAlertAction(title: "Retry", style: .default, handler: {
                (action) in
              // self.featchMemberDetail(id: AppManager.shared.memberID)
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
                
                FireStoreManager.shared.downloadUserImg(id:id, result: {
                    (imgUrl,err) in
                    if err == nil {
                        do {
                            self.visitorProfileImgData =  try Data(contentsOf: imgUrl!)
                            self.visitorProfileImageExists = true
                        } catch _ {}
                    }
                })
                
            }
        })
    }
    
    func getDueAmount() -> Int {
        let currentPaidAmount = Int(self.totalAmountTextField.text!) ?? 0
        let discount = self.getDiscountAmount()
        let membershipAmount = Int(self.amountTextField.text!) ?? 0
        
        if discount > 0 && discount == self.previousDiscount && self.previousDueAmount > 0 {
             return self.previousDueAmount - currentPaidAmount
        }else {
            if self.previousDueAmount == 0 {
                return membershipAmount - (currentPaidAmount + discount)
            }else {
                return self.previousDueAmount - (currentPaidAmount + discount)
            }
        }
    }
    
    func getDiscountPercentage(totalAmount:Int,discount:Int) -> Int {
        let percentage = (discount * 100)/totalAmount
        return percentage
    }
    
    func getDiscountAmount() -> Int {
        let membershipAmount = Double(self.amountTextField.text!) ?? 0
        let discountInPercentage = Double(self.discountTextField.text!) ?? 0
        let d = (discountInPercentage/100.0)
        let s = (membershipAmount * d )
        return Int(s)
    }
    
    func fetchVisitorDetail(id:String) {
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
        self.visitorEmail = visitor.email
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
        ValidationManager.shared.requiredValidation(textField: self.uploadIDTextField, errorLabel: self.uploadIDErrorLabel, errorMessage: "Upload ID required.")
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
       ValidationManager.shared.requiredValidation(textField: self.uploadIDTextField, errorLabel: self.uploadIDErrorLabel, errorMessage: "Upload ID required.")
    }
}

extension AddMemberViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 4 || textField.tag == 11 || textField.tag == 12  || textField.tag == 13  ||   textField.tag == 14 || textField.tag == 8 || textField.tag == 7 || textField.tag == 18 {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.trainerListView.isHidden == false && textField.tag != 7 {
            self.trainerListView.isHidden = true
            self.trainerListView.alpha = 0.0
        }
        if textField.tag == 4 || textField.tag == 11 || textField.tag == 14 {
            textField.inputAccessoryView = self.toolBar
            textField.inputView = datePicker
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                df.timeZone = TimeZone(secondsFromGMT: 0)
                self.datePicker.date = df.date(from: textField.text!)!
            }else {
                self.datePicker.date = Date()
            }
        }

        if textField.tag == 8 || textField.tag == 7 {
            self.view.endEditing(true)
        }
        
//        if textField.tag == 12  {
//            self.view.endEditing(true)
//            self.showMembershipPlan()
//        }
        
        if textField.tag == 5 {
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
        
        if textField.tag == 18 {
            var row:Int = 0
                switch textField.text {
                case "Cash":
                    row = 0
                case "Card":
                    row = 1
                default:
                    row = 0
                }
            textField.inputView = self.paymentTypePickerView
            self.paymentTypePickerView.selectRow(row, inComponent: 0, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
            switch textField.tag {
            case 4:
                if self.selectedDate != nil  {
                self.dateOfJoiningTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
                }
            case 5 :
                if textField.text == "" {
                    textField.text = self.genderArray.first
                }
                
            case 9:
                let email = textField.text!
                if self.visitorID == "" || self.visitorEmail != email {
                    DispatchQueue.global(qos: .background).async {
                        let result = FireStoreManager.shared.isUserExists(email: email)
                        
                        DispatchQueue.main.async {
                            switch result {
                            case let .success(flag):
                                if flag == false {
                                    textField.layer.borderColor = .none
                                    textField.layer.borderWidth = 0.0
                                    self.emailErrorLabel.text = ""
                                    self.isAlreadyExistsEmail = false
                                    self.nextBtn.isEnabled = true
                                    self.nextBtn.alpha = 1.0
                                    self.profileAndMembershipBarView.isUserInteractionEnabled = true
                                    self.profileAndMembershipBarView.alpha = 1.0
                                }else {
                                    textField.layer.borderColor = UIColor.red.cgColor
                                    textField.layer.borderWidth = 1.0
                                    self.emailErrorLabel.text = "Email already exists."
                                    self.isAlreadyExistsEmail = true
                                    self.nextBtn.isEnabled = false
                                    self.nextBtn.alpha = 0.4
                                    self.profileAndMembershipBarView.isUserInteractionEnabled = false
                                    self.profileAndMembershipBarView.alpha = 0.4
                                }
                            case .failure(_):
                                break
                            }
                        }
                    }
                }else {
                    self.isAlreadyExistsEmail = false
                    self.nextBtn.isEnabled = true
                    self.nextBtn.alpha = 1.0
                    self.profileAndMembershipBarView.isUserInteractionEnabled = true
                    self.profileAndMembershipBarView.alpha = 1.0
                }
                
            case 11:
                self.dobTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate ?? Date())
                
            case 14:
                if self.isRenewMembership == true {
                    self.membershipDuration = Int(self.renewingMembershipDuration)!
                }
                self.startDateTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate ?? Date())
                let endDate = AppManager.shared.getMembershipEndDate(startDate:self.selectedDate ?? Date(), duration: self.membershipDuration)
                let endDateFormatted = AppManager.shared.dateWithMonthName(date: endDate)
                self.endDateTextField.text =  endDateFormatted
                ValidationManager.shared.requiredValidation(textField: self.endDateTextField, errorLabel: self.endDateErrorLabel, errorMessage: "End Date require.")
                
            case 16:
                
                if self.getDiscountAmount() > 0 {
                    let amountInTotalTextField = Int(self.totalAmountTextField.text!) ?? 0
                    let membershipAmount = Int(self.amountTextField.text!) ?? 0
                    let discountAmount = self.getDiscountAmount()
                    let calculatedTotalAmount = membershipAmount - discountAmount
                    if amountInTotalTextField > calculatedTotalAmount {
                        DispatchQueue.main.async {
                            self.totalAmountErrorLabel.text = "Amount is larger than actual amount Rs. \(calculatedTotalAmount)"
                            self.dueAmountTextField.text = "\(self.previousDueAmount)"
                            textField.layer.borderColor = UIColor.red.cgColor
                            textField.layer.borderWidth = 1.0
                            self.discountTextField.isEnabled = false
                            self.discountTextField.alpha = 0.4
                        }
                    }else {
                        self.totalAmountErrorLabel.text = ""
                        self.dueAmountTextField.text = "\(self.getDueAmount())"
                        textField.layer.borderColor = .none
                        textField.layer.borderWidth = 0.0
                        self.discountTextField.isEnabled = true
                        self.discountTextField.alpha = 1.0
                    }
                }else {
                    let referenceAmount = self.previousDueAmount > 0  ? self.previousDueAmount : Int(self.amountTextField.text!) ?? 0
                    var referenceText = self.previousDueAmount > 0 ? "Amount is greater than due amount." :  "Amount is greater than membership amount."
                    let calculatedTotalAmount = self.getTotalAmount()
                    let amountInTotalTextField = Int(self.totalAmountTextField.text!) ?? 0
                    if amountInTotalTextField <= referenceAmount && amountInTotalTextField <= calculatedTotalAmount  {
                        self.dueAmountTextField.text = "\(self.getDueAmount())"
                        self.totalAmountErrorLabel.text = ""
                        textField.borderStyle = .none
                        textField.layer.borderColor = UIColor.clear.cgColor
                        textField.layer.borderWidth = 0.0
                        self.discountTextField.isEnabled = true
                        self.discountTextField.alpha = 1.0
                    } else {
                        DispatchQueue.main.async {
                            referenceText = amountInTotalTextField >= calculatedTotalAmount ? "Amount is larger than actual payable amount." : referenceText
                            self.totalAmountErrorLabel.text = "\(referenceText)"
                            self.dueAmountTextField.text = "\(self.previousDueAmount)"
                            textField.layer.borderColor = UIColor.red.cgColor
                            textField.layer.borderWidth = 1.0
                            self.discountTextField.text = "0"
                            self.discountTextField.isEnabled = false
                            self.discountTextField.alpha = 0.4
                        }
                    }
                }
    
            case 17:
                let discoutAmount = self.getDiscountAmount()
                if self.previousDiscount != discoutAmount || self.previousDueAmount == 0 {
                    let membershipAmount = Int(self.amountTextField.text!) ?? 0
                    self.totalAmountTextField.text = "\(membershipAmount - discoutAmount)"
                    self.dueAmountTextField.text = "0"
                }
            case 18:
                if self.paymentTypeTextField.text == "" {
                   self.paymentTypeTextField.text = self.paymentTypeArray.first
                }
                
                if self.myScrollView.contentSize.height != 800 {
                    self.myScrollView.contentSize.height = 820
                }
                
            default:
                break
            }

        self.allNewMemberFieldsRequiredValidation(textField: textField)
        if self.isNewMember == true {
            ValidationManager.shared.updateBtnValidator(updateBtn:self.updateBtn , textFieldArray: self.textFieldArray, textView: self.membershipPlanView.isHidden == true ? self.addressTextView : self.membershipDetailTextView, phoneNumberTextField: self.phoneNumberTextField,email: self.emailTextField.text!,password: self.passwordTextField.text!)
        } else {
            ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.membershipFieldArray, textView: self.membershipDetailTextView, phoneNumberTextField: nil, email: nil, password: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2  , execute: {
            if self.discountTextField.isEnabled == false {
                    self.updateBtn.isEnabled = false
                    self.updateBtn.alpha = 0.4
            }

        })
    }
}

extension AddMemberViewController:UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if memberProfileView.isHidden == false {
            ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
        }
        if textView.tag == 2 {
            return false
        }else{
            return true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
       ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.addressErrorLabel, errorMessage: "Member's address required.")
        if self.isNewMember == true {
            ValidationManager.shared.updateBtnValidator(updateBtn:self.updateBtn , textFieldArray: self.textFieldArray, textView: self.membershipPlanView.isHidden == true ? self.addressTextView : self.membershipDetailTextView, phoneNumberTextField: self.phoneNumberTextField,email: self.emailTextField.text!,password: self.passwordTextField.text!)
        } else {
            ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.membershipFieldArray, textView: self.membershipDetailTextView, phoneNumberTextField: nil, email: nil, password: nil)
        }
    
    }
 
}

extension AddMemberViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1111 {
            return self.listOfTrainers.count
        }else {
             return self.memberhsipPlanArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1111 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainerListCell", for: indexPath) as! TrainerListTableCell
            let singleTrainer = self.listOfTrainers[indexPath.row]
            cell.trainerName.text = "\(singleTrainer.firstName) \(singleTrainer.lastName)"
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "membershipPlanCell", for: indexPath) as! MemberhsipPlanTableCell
            let membership = self.memberhsipPlanArray[indexPath.row]
            cell.membershipPlanLabel.text = membership.title
            return cell
        }
    }
}

extension AddMemberViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 1111 {
            let singleTrainer = self.listOfTrainers[indexPath.row]
            self.trainerNameTextField.text = "\(singleTrainer.firstName) \(singleTrainer.lastName)"
            self.trainerID = singleTrainer.trainerID
            self.trainerListView.isHidden = true
            self.allNewMemberFieldsRequiredValidation(textField: self.trainerNameTextField)
        }else {
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
                SVProgressHUD.dismiss()
                let membership = self.memberhsipPlanArray[indexPath.row]
                self.membershipID = membership.membershipID
                self.membershipPlanTextField.text = membership.title
                self.membershipDetailTextView.text = membership.detail
                self.amountTextField.text = membership.amount
                self.membershipDuration = Int(membership.duration)!
               ValidationManager.shared.requiredValidation(textField: self.membershipPlanTextField, errorLabel: self.membershipPlanErrorLabel, errorMessage: "Please select a membership plan.")
                ValidationManager.shared.requiredValidation(textField: self.amountTextField, errorLabel: self.amountErrorLabel, errorMessage: "Amount required.")
                ValidationManager.shared.requiredValidation(textView: self.membershipDetailTextView, errorLabel: self.membershipDetailErrorLabel, errorMessage: "Membership Detail Required.")
            })
            self.membershipPlanView.isHidden = true
        }
    }
}

extension AddMemberViewController:UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 0101 ? self.paymentTypeArray.count : self.genderArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return  pickerView.tag == 0101 ? self.paymentTypeArray[row] : self.genderArray[row]
    }
    
}

extension AddMemberViewController:UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if pickerView.tag == 0101 {
            self.paymentTypeTextField.text = self.paymentTypeArray[row]
            if self.paymentTypeArray[row] == "Card" {
                self.updateBtn.tag = 1011
                self.updateBtn.setTitle("Pay via card", for: .normal)
            }else {
                self.updateBtn.tag = 0101
                self.updateBtn.setTitle("U P D A T E ", for: .normal)
            }
        }else {
            self.genderTextField.text = self.genderArray[row]
        }
        
        DispatchQueue.main.async {
            self.allNewMemberFieldsRequiredValidation(textField: self.genderTextField)
            ValidationManager.shared.updateBtnValidator(updateBtn: self.updateBtn, textFieldArray: self.textFieldArray, textView: nil, phoneNumberTextField: self.phoneNumberTextField, email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }
    }
    
}

extension AddMemberViewController:UIGestureRecognizerDelegate{
 
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.trainerListView) == true ||
        touch.view?.tag == 110 {
            return false
        }else {
            return true
        }
    }
    
}

extension AddMemberViewController:STPAddCardViewControllerDelegate, STPPaymentCardTextFieldDelegate{
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            self.navigationController?.popToRootViewController(animated: true)
        })
    
    }
    
}
