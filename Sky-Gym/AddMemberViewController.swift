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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCompleteView()
     
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memberIDTextField.text = "\(UUID().hashValue)"
        self.memberIDTextField.isEnabled = false
        self.memberIDTextField.alpha = 0.4
        self.endDateTextField.isEnabled = false
        self.endDateTextField.alpha = 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            if self.isNewMember == false {
               self.myScrollView.contentSize.height = 800
            }
        })
        
        if self.isNewMember == false {
            self.showMemberScreen()
            self.profileAndMembershipBarView.isUserInteractionEnabled = false
            self.profileAndMembershipBarView.alpha = 0.6
            self.featchMemberDetail(id: AppManager.shared.memberID)
        }else {
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
        if self.isNewMember == true {
             self.registerMember(memberDetail: self.getMemberDetails(), membershipDetail: self.getMembershipDetails())
        }else{
            self.updateMembership(memberDetail: self.getMemberDetails(), membershipDetail: self.getMembershipDetails())
        }
    }
    
       @objc func cancelTextField()  {
           self.view.endEditing(true)
       }
    
    @objc func doneTextField()  {
        self.selectedDate = datePicker.date
        self.view.endEditing(true)
    }
}

extension AddMemberViewController{

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
        imgView.contentMode = UIView.ContentMode.center
        let btn = UIButton()
        
        if imageName == "cam.png"{
            imgView.frame = CGRect(x: 0.0, y: 0.0, width: imgView.image!.size.width + 20.0, height: imgView.image!.size.height)
            btn.frame = imgView.frame
            btn.addTarget(self, action: #selector(openImgPicker), for: .touchUpInside)
        } else {
            imgView.frame = CGRect(x: 0.0, y: 0.0, width: imgView.image!.size.width + 40.0, height: imgView.image!.size.height)
            btn.frame = imgView.frame
            btn.addTarget(self, action: #selector(showMemberPlan), for: .touchUpInside)
        }
        
        btn.setImage(imgView.image, for: .normal)
        toTextField.rightView = btn
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
        }
        
        [self.emailTextField,self.phoneNumberTextField,self.dobTextField,self.membershipPlanTextField,self.amountTextField,self.startDateTextField,self.endDateTextField,self.totalAmountTextField,self.discountTextField,self.firstNameTextField,self.lastNameTextField].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
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
            "membershipPlan": self.membershipPlanTextField.text!,
            "membershipDetail":self.membershipDetailTextView.text!,
            "amount": self.amountTextField.text!,
            "startDate":self.startDateTextField.text!,
            "endDate":self.endDateTextField.text!,
            "totalAmount":self.totalAmountTextField.text!,
            "discount":self.discountTextField.text!,
            "paymentType":self.paymentTypeTextField.text!,
            "dueAmount":self.dueAmountTextField.text!,
            "purchaseTime": "\(AppManager.shared.getTimeFrom(date: Date()))"
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
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            
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
                            self.errorAlert(message: "Member is not registered successfully.")
                        } else {
                            SVProgressHUD.dismiss()
                            self.successAlert(message: "Member is registered successfully.")
                        }
                    })
                }
            })
        })
    }
    
    func updateMembership(memberDetail:[String:String],membershipDetail:[[String:String]]) {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            SVProgressHUD.dismiss()
            FireStoreManager.shared.updateMemberDetails(id: AppManager.shared.memberID, memberDetail: self.getMemberDetails(), handler: {
                (err) in
                if err != nil {
                    self.errorAlert(message: "Member Details are not updated successfully,Try again")
                } else{
                    FireStoreManager.shared.addNewMembeship(memberID: AppManager.shared.memberID, membership: self.getMembershipDetails().first!, completion: {
                        (err) in
                        
                        if err != nil {
                            self.errorAlert(message: "New Membership is not added successfully, Try again.")
                        } else {
                            self.successAlert(message: "New Membership is added successfully.")
                        }
                    })
                }
            })
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
        
        self.datePicker.datePickerMode = .date
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
        getVisitorProfileToMemberImage(id: id, imgView: self.memberImg)
        //self.fetchVisitorBy(id: id)
    }
    
    func getVisitorProfileToMemberImage(id:String,imgView :UIImageView) {
        SVProgressHUD.show()
        FireStoreManager.shared.downloadUserImg(id: id, result: {
            (imgUrl,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                // self.viewDidLoad()
            } else {
                do{
                    let imgData = try Data(contentsOf: imgUrl!)
                    let image = UIImage(data: imgData)
                    imgView.image = AppManager.shared.resizeImage(image: image!, targetSize: self.memberImg.image!.size)
                    imgView.makeRounded()
                    self.fetchVisitorBy(id: id)
                } catch let error as NSError { print(error) }
            }
        })
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
        if textField.tag == 7 || textField.tag == 9 || textField.tag.isMultiple(of: 2) == true{
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag.isMultiple(of: 2) == true {
            textField.inputAccessoryView = self.toolBar
            textField.inputView = datePicker   
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.selectedDate != nil  {
            switch textField.tag {
                              case 2:
                                self.dateOfJoiningTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
                              case 4:
                                self.dobTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
                              case 6:
                                self.startDateTextField.text = AppManager.shared.dateWithMonthName(date: self.selectedDate!)
                                self.endDateTextField.text = AppManager.shared.dateWithMonthName(date: AppManager.shared.getMembershipEndDate(startDate: self.selectedDate!, duration:self.membershipDuration))
                              default:
                                  break
                              }
        }
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



