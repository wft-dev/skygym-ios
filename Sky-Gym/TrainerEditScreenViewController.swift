//
//  TrainerEditScreenViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class TrainerEditScreenViewController: BaseViewController {
    
    @IBOutlet weak var trainerEditScreenNavigationBar: CustomNavigationBar!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressView: UITextView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var uploadIDProofTextField: UITextField!
    @IBOutlet weak var shiftDaysTextField: UITextField!
    @IBOutlet weak var shiftTimingsTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var dateOfJoinTextField: UITextField!
    @IBOutlet weak var visitorPermissionView: UIView!
    @IBOutlet weak var memberPermissionView: UIView!
    @IBOutlet weak var eventPermissionView: UIView!
    @IBOutlet weak var attandanceBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var generalTypeBtn: UIButton!
    @IBOutlet weak var personalTypeBtn: UIButton!
    @IBOutlet weak var visitorPermissionToggleBtn: UIButton!
    @IBOutlet weak var eventPermissionToggleBtn: UIButton!
    @IBOutlet weak var memberPermissionToggleBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var firstNameNonEditableLabel: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastNameNonEditableLabel: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var NameHrLineView: UIView!
    @IBOutlet weak var idNonEditLabel: UILabel!
    @IBOutlet weak var idHrLineView: UIView!
    @IBOutlet weak var phoneNonEditLabel: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var phoneNo: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailNonEditLabel: UILabel!
    @IBOutlet weak var emailHrLineView: UIView!
    @IBOutlet weak var passwordNonEditLabel: UILabel!
    @IBOutlet weak var passwordHrLineView: UIView!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressNonEditLabel: UILabel!
    @IBOutlet weak var addressHrLineView: UIView!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var genderNonEditLabel: UILabel!
    @IBOutlet weak var genderHrLineView: UIView!
    @IBOutlet weak var salaryNonEditLabel: UILabel!
    @IBOutlet weak var idProof: UILabel!
    @IBOutlet weak var idProofNonEditLabel: UILabel!
    @IBOutlet weak var idProofHrLineView: UIView!
    @IBOutlet weak var shiftDays: UILabel!
    @IBOutlet weak var shiftDayHrLineView: UIView!
    @IBOutlet weak var shiftDaysNonEditLabel: UILabel!
    @IBOutlet weak var shiftTimings: UILabel!
    @IBOutlet weak var shiftTimingsNonEditLabel: UILabel!
    @IBOutlet weak var shiftTimingHrLineView: UIView!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var dobNonEditLabel: UILabel!
    @IBOutlet weak var dobHrLineView: UIView!
    @IBOutlet weak var dateOfJoin: UILabel!
    @IBOutlet weak var dateOfJoinNonEditLabel: UILabel!
    @IBOutlet weak var dateOfJoinHrLineView: UIView!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var permissions: UILabel!
    @IBOutlet weak var firstNameForNonEditLabel: UILabel!
    @IBOutlet weak var lastNameForNonEditLabel: UILabel!
    @IBOutlet weak var idForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    @IBOutlet weak var passwordForNonEditLabel: UILabel!
    @IBOutlet weak var addressForNonEditLabel: UILabel!
    @IBOutlet weak var dobForNonEditLabel: UILabel!
    @IBOutlet weak var dateOfJoinForNonEditLabel: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var salaryForNonEditLabel: UILabel!
    @IBOutlet weak var shiftDaysForNonEditLabel: UILabel!
    @IBOutlet weak var shiftTimingForNonEditLabel: UILabel!
    @IBOutlet weak var idProofForNonEditLabel: UILabel!
    @IBOutlet weak var trainerEditScrollView: UIScrollView!
    @IBOutlet weak var typeForNonEditLabel: UILabel!
    @IBOutlet weak var generalBtnForNonEditLabel: UIButton!
    @IBOutlet weak var personalBtnForNonEditLabel: UIButton!
    @IBOutlet weak var generalTypeForNonEditLabel: UILabel!
    @IBOutlet weak var personalTypeForNonEditLabel: UILabel!
    @IBOutlet weak var generalTypeLabel: UILabel!
    @IBOutlet weak var personalTypeLabel: UILabel!
    
    var isNewTrainer:Bool = false
    let imagePicker = UIImagePickerController()
    var imgURL:URL? = nil
    var name:String = ""
    var addressStr:String = ""
    var datePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    var selectedDate:String = ""
    var isUserImgSelected:Bool = false
    var img:UIImage? = nil
    var isEdit: Bool = false
    var forNonEditLabelArray:[UILabel] = []
    var defaultArray:[UILabel] = []
    var trainerType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTrainerEditView()
        self.showTrainerBy(id: AppManager.shared.trainerID)
        //AppManager.shared.setScrollViewContentSize(scrollView: self.trainerEditScrollView)
        self.idTextField.text = "\(Int.random(in: 1..<100000))" 
        self.idTextField.isEnabled = false
        self.idTextField.layer.opacity = 0.4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func trainerAttendanceAction(_ sender: Any) {
        performSegue(withIdentifier: "trainerAttendanceSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trainerAttendanceSegue" {
            let destinationVC = segue.destination as! TrainerAttendanceViewController
            destinationVC.trainerName = self.name
            destinationVC.trainerAddress = self.addressStr
        }
    }
    
    @IBAction func generalTypeBtnAction(_ sender: Any) {
        if  generalTypeBtn.currentImage ==  UIImage(named: "non_selecte") {
            self.generalTypeBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            self.personalTypeBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
    }
    
    @IBAction func personalTypeBtnAction(_ sender: Any) {
        if  personalTypeBtn.currentImage ==  UIImage(named: "non_selecte") {
            self.generalTypeBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
            self.personalTypeBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        }
    }
    
    @IBAction func visitorPermissionBtnAction(_ sender: Any) {
        if self.visitorPermissionToggleBtn.currentImage == UIImage(named: "toggle-off"){
            self.visitorPermissionToggleBtn.setImage(UIImage(named: "toggle-on"), for: .normal)
        } else {
               self.visitorPermissionToggleBtn.setImage(UIImage(named: "toggle-off"), for: .normal)
        }
    }
    
    @IBAction func memberPermissionBtnAction(_ sender: Any) {
        if self.memberPermissionToggleBtn.currentImage == UIImage(named: "toggle-off"){
            self.memberPermissionToggleBtn.setImage(UIImage(named: "toggle-on"), for: .normal)
        }else {
               self.memberPermissionToggleBtn.setImage(UIImage(named: "toggle-off"), for: .normal)
        }
    }
    
    @IBAction func eventPermissionBtnAction(_ sender: Any) {
        if self.eventPermissionToggleBtn.currentImage == UIImage(named: "toggle-off"){
            self.eventPermissionToggleBtn.setImage(UIImage(named: "toggle-on"), for: .normal)
        }else {
               self.eventPermissionToggleBtn.setImage(UIImage(named: "toggle-off"), for: .normal)
        }
    }
    
    @IBAction func doneBtnAction(_ sender: Any) {
        self.registerTrainer(email: self.emailTextField.text!, password: self.passwordTextField.text!, id: self.idTextField.text!, trainerDetail: self.getTrainerFieldsData(), trainerPermission: self.getTrainerPermissionData())
    }
}

extension TrainerEditScreenViewController {

    func setTrainerEditScreenNavigationBar()  {
        let navigationBar  = self.trainerEditScreenNavigationBar
        navigationBar?.menuBtn.isHidden = true
        navigationBar?.leftArrowBtn.isHidden = false
        navigationBar?.leftArrowBtn.alpha = 1.0
        navigationBar?.navigationTitleLabel.text = "Trainer"
        navigationBar?.searchBtn.isHidden = true
        if self.isNewTrainer == false{
            navigationBar?.editBtn.isHidden = false
            navigationBar?.editBtn.alpha = 1.0
            navigationBar?.editBtn.addTarget(self, action: #selector(makeEditable), for: .touchUpInside)
        }
    }

   @objc func makeEditable() {
    if self.isEdit == true {
        AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  false)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultArray, flag: true)
        self.addressNonEditLabel.isHidden = false
        self.addressView.isHidden  = true
        self.addressView.alpha = 0.0
        self.isEdit = false
        self.setHrLineView(isHidden: false, alpha: 1.0)
        self.setToggleBtns(isEnabled: false, alpha: 0.9)
        self.type.textColor = .lightGray
        self.permissions.textColor = .lightGray
        [self.generalTypeBtn,self.personalTypeBtn].forEach{
            $0?.isHidden = true
            $0?.alpha = 0.0
        }
        [self.generalBtnForNonEditLabel,self.personalBtnForNonEditLabel].forEach{
            $0?.isHidden = false
            $0?.alpha = 1.0
        }
        self.setTrainerType(type: self.trainerType, generalBtn: self.generalBtnForNonEditLabel, personalBtn: self.personalBtnForNonEditLabel)
        self.updateBtn.isEnabled = false
        self.updateBtn.alpha = 0.4
    } else{
        AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultArray, flag: false)
        self.setToggleBtns(isEnabled: true, alpha: 1.0)
        self.idTextField.isEnabled = true
        self.idTextField.layer.opacity = 0.4
        self.addressNonEditLabel.isHidden = true
        self.addressView.isHidden = false
        self.addressView.alpha = 1.0
        self.addressView.text = self.addressNonEditLabel.text
        self.isEdit = true
        self.setHrLineView(isHidden: true, alpha: 0.0)
        self.type.textColor = .black
        self.permissions.textColor = .black
        [self.generalTypeBtn,self.personalTypeBtn].forEach{
            $0?.isHidden = false
            $0?.alpha = 1.0
        }
        [self.generalBtnForNonEditLabel,self.personalBtnForNonEditLabel].forEach{
            $0?.isHidden = true
            $0?.alpha = 0.0
        }
        self.setTrainerType(type: self.trainerType, generalBtn: self.generalTypeBtn, personalBtn: self.personalTypeBtn)
        self.updateBtn.isEnabled = true
        self.updateBtn.alpha = 1.0
    }
    }

    func setHrLineView(isHidden:Bool,alpha:CGFloat) {
        [self.NameHrLineView,self.idHrLineView,self.emailHrLineView,self.passwordHrLineView,self.addressHrLineView,self.genderHrLineView,self.idProofHrLineView,self.shiftDayHrLineView,self.shiftTimingHrLineView,self.dobHrLineView,self.dateOfJoinHrLineView].forEach{
            $0?.isHidden = isHidden
            $0?.alpha = alpha
        }
    }

    func getFieldsAndLabelDic() -> [UITextField:UILabel] {
        let dir = [
            self.firstNameTextField! :self.firstNameNonEditableLabel!,
            self.secondNameTextField! :self.lastNameNonEditableLabel!,
            self.idTextField! : self.idNonEditLabel!,
            self.phoneNoTextField!:self.phoneNonEditLabel!,
            self.emailTextField! : self.emailNonEditLabel!,
            self.passwordTextField! : self.passwordNonEditLabel!,
            self.genderTextField! : self.genderNonEditLabel!,
            self.salaryTextField! : self.salaryNonEditLabel!,
            self.uploadIDProofTextField! : self.idProofNonEditLabel!,
            self.shiftDaysTextField! : self.shiftDaysNonEditLabel!,
            self.shiftTimingsTextField! : self.shiftTimingsNonEditLabel!,
            self.dobTextField! :self.dobNonEditLabel!,
            self.dateOfJoinTextField! : self.dateOfJoinNonEditLabel!,
        ]
        return dir
    }
    
    func setToggleBtns(isEnabled:Bool,alpha:CGFloat) {
        [self.generalTypeBtn,self.personalTypeBtn,self.visitorPermissionToggleBtn,self.memberPermissionToggleBtn,self.eventPermissionToggleBtn].forEach{
            $0?.isEnabled = isEnabled
            $0?.alpha = alpha
        }
    }
    
    func setTrainerEditScreenTextFields() {
        [self.firstNameTextField,self.secondNameTextField,self.idTextField,self.phoneNoTextField,self.emailTextField,self.genderTextField,self.salaryTextField,self.uploadIDProofTextField,self.shiftDaysTextField,self.shiftTimingsTextField,
         self.dobTextField,
         self.dateOfJoinTextField ,self.passwordTextField].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
        }
        
        [self.addressView].forEach{
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
        }
        
        [self.visitorPermissionView,self.memberPermissionView,self.eventPermissionView].forEach{
            $0?.layer.cornerRadius = 7.0
            $0?.layer.borderColor =  UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0).cgColor
            $0?.layer.borderWidth = 1.2
            $0?.clipsToBounds = true
        }
        
        [self.attandanceBtn,self.updateBtn].forEach{
            $0?.layer.cornerRadius = 15.0
            $0?.layer.borderColor = UIColor.black.cgColor
            $0?.layer.borderWidth = 0.7
            $0?.clipsToBounds = true
        }
    }
    
    func addPaddingToTextField(textField:UITextField) {
           let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
           textField.leftView = paddingView
           textField.leftViewMode = .always
           textField.backgroundColor = UIColor.white
           textField.textColor = UIColor.black
       }
    
    func addRightViewToMemberShipField(imageName:String) {
        let imgView = UIImageView(image: UIImage(named: imageName))
        var v:UIView? = nil
        imgView.contentMode = UIView.ContentMode.center
        imgView.frame = CGRect(x: 0.0, y: 0.0, width:20, height: 20)
        v = UIView(frame: CGRect(x: 0, y: 0, width: imgView.frame.width + 10 , height: imgView.frame.height))
        v!.addSubview(imgView)
        v?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPicker)))
        self.uploadIDProofTextField.rightView = v
        self.uploadIDProofTextField.rightViewMode = .always
    }
    
    @objc func showPicker(){
        self.imagePicker.allowsEditing = true
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func showUserImgPicker(){
        self.isUserImgSelected = true
        self.imagePicker.allowsEditing = true
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
      }
    
    func getTrainerFieldsData() -> [String:String] {
         let memberDetail:[String:String] = [
            "firstName":self.firstNameTextField.text!,
            "lastName": self.secondNameTextField.text!,
            "trainerID":self.idTextField.text!,
            "phoneNo" : self.phoneNoTextField.text!,
            "email":self.emailTextField.text!,
            "password":self.passwordTextField.text!,
            "address":self.addressView.text!,
            "gender":self.genderTextField.text!,
            "salary":self.salaryTextField.text!,
            "uploadIDName":self.uploadIDProofTextField.text!,
            "shiftDays":self.shiftDaysTextField.text!,
            "shiftTimings":self.shiftTimingsTextField.text!,
            "type":self.getTrainerType(),
            "dob":self.dobTextField.text!,
            "dateOfJoining":self.dateOfJoinTextField.text!,
              ]
              return memberDetail
    }
    
    func getTrainerType() -> String {
        var type :String = ""
               if self.generalTypeBtn.currentImage == UIImage(named: "selelecte"){
                   type = "General"
               } else {
                   type = "Personal"
               }
               return type
    }
    
    func getPermissionFor(toggleBtn:UIButton) -> Bool {
        if toggleBtn.currentImage == UIImage(named: "toggle-on"){
            return true
        } else {
            return false
        }
    }
    
    func getTrainerPermissionData() -> [String:Bool] {
        let trainerPermission = [
            "visitorPermission":self.getPermissionFor(toggleBtn: self.visitorPermissionToggleBtn),
            "memberPermission": self.getPermissionFor(toggleBtn: self.memberPermissionToggleBtn),
            "eventPermission": self.getPermissionFor(toggleBtn: self.eventPermissionToggleBtn)
        ]
        return trainerPermission
    }
    
    func setTrainerEditView() {
        assignbackground()
        self.setTrainerEditScreenNavigationBar()
        self.setTrainerEditScreenTextFields()
        self.addRightViewToMemberShipField(imageName: "cam.png")
        setBackAction(toView: self.trainerEditScreenNavigationBar)
        self.generalTypeBtn.setImage(UIImage(named: "selelecte"), for: .normal)
        self.personalTypeBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        self.imagePicker.delegate = self
        self.attandanceBtn.isHidden = self.isNewTrainer
        [self.visitorPermissionToggleBtn,self.memberPermissionToggleBtn,self.eventPermissionToggleBtn].forEach{
            $0?.setImage(UIImage(named: "toggle-off"), for: .normal)
        }
        self.datePicker.datePickerMode = .date
        toolBar.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar.sizeToFit()
        
        self.forNonEditLabelArray = [self.firstNameForNonEditLabel,self.lastNameForNonEditLabel,self.idForNonEditLabel,self.phoneNoForNonEditLabel,self.emailForNonEditLabel,self.passwordForNonEditLabel,self.addressForNonEditLabel,self.genderForNonEditLabel,self.salaryForNonEditLabel,self.idProofForNonEditLabel,self.shiftDaysForNonEditLabel,self.shiftTimingForNonEditLabel,self.dobForNonEditLabel,self.dateOfJoinForNonEditLabel,self.typeForNonEditLabel,self.generalTypeForNonEditLabel,self.personalTypeForNonEditLabel]
        
        self.defaultArray = [self.firstName,self.lastName,self.id,self.phoneNo,self.email,self.password,self.address,self.gender,self.salary,self.shiftDays,self.idProof,self.shiftTimings,self.dob,self.dateOfJoin,self.generalTypeLabel,self.type,self.personalTypeLabel]
        userImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserImgPicker)))
        userImg.makeRounded()
        if self.isNewTrainer == false {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit:  false)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultArray, flag: true)
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.setToggleBtns(isEnabled: false, alpha: 0.9)
            self.addressNonEditLabel.isHidden = false
            self.addressView.isHidden = true
            self.addressView.alpha = 0.0
            self.addressView.text = self.addressNonEditLabel.text
            self.addressNonEditLabel.alpha = 1.0
            [self.generalTypeBtn,self.personalTypeBtn].forEach{
                $0?.isHidden = true
                $0?.alpha = 0.0
            }
            self.permissions.textColor = .lightGray
        } else {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit:  true)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultArray, flag: false)
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.setToggleBtns(isEnabled: true, alpha: 1.0)
            self.addressNonEditLabel.isHidden = true
            self.addressView.isHidden = false
            self.addressView.alpha = 1.0
            self.addressView.text = self.addressNonEditLabel.text
            self.addressNonEditLabel.alpha = 0.0
            [self.generalTypeBtn,self.personalTypeBtn].forEach{
                $0?.isHidden = false
                $0?.alpha = 1.0
            }
            self.permissions.textColor = .black
        }
   
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
    
    func showTrainerBy(id:String)  {
        SVProgressHUD.show()
        if self.isNewTrainer ==  false {
            self.doneBtn.setTitle("U P D A T E ", for: .normal)
            FireStoreManager.shared.getTrainerBy(id: id, completion: {
                (data,err) in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.retryAlert()
                } else {
                    self.setTrainerDataToFields(trainerDetails: AppManager.shared.getTrainerDetailS(trainerDetail: data?["trainerDetail"] as! [String : String]), trainerPermissions:AppManager.shared.getTrainerPermissionS(trainerPermission: data?["trainerPermission"] as! [String:Bool]) )
                }
               // self.userImg.image = self.img
                self.userImg.image = AppManager.shared.resizeImage(image: self.img!, targetSize: self.userImg.image!.size)
            })
        } else {
            SVProgressHUD.dismiss()
            self.doneBtn.setTitle("A D D ", for: .normal)
            self.clearTextFields()
        }
    }
    
    func registerTrainer(email:String,password:String,id:String,trainerDetail:[String:String],trainerPermission:[String:Bool]) {
        SVProgressHUD.show()
        if imgURL == nil && self.isNewTrainer == false {
            FireStoreManager.shared.addTrainer(email: email, password: password, trainerID: id, trainerDetail: trainerDetail, trainerPermission: trainerPermission, completion: {
                err in
                if err != nil {
                    self.showAlert(title: "Error", message: "Error in updating the trainer details, please try again.")
                } else {
                    self.showAlert(title: "Success", message: "Trainer Detail is updated successfully.")
                }
            })

        } else {
            if imgURL == nil {
                 self.showAlert(title: "Error", message: "Please select id proof.")
            } else {
                FireStoreManager.shared.uploadImgForTrainer(url: self.imgURL!, trainerid: id, imageName: self.uploadIDProofTextField.text!, completion: {
                    err in
                    SVProgressHUD.dismiss()
                    if err != nil {
                        self.showAlert(title: "Error", message: "Error in uploading the id proof.")
                    } else {
                        FireStoreManager.shared.uploadUserImg(imgData: (self.userImg.image?.pngData())!, id: id, completion: {
                            err in
                            
                            if err != nil {
                                self.showAlert(title: "Error", message: "Error in uploading the user profile imgage.")
                            } else {
                                FireStoreManager.shared.addTrainer(email: email, password: password, trainerID: id, trainerDetail: trainerDetail, trainerPermission: trainerPermission, completion: {
                                    err in
                                    if err != nil {
                                        self.showAlert(title: "Error", message: "Error in registering the trainer, please try again.")
                                    } else {
                                        self.showAlert(title: "Success", message: "Trainer is registerd successfully.")
                                    }
                                })
                            }
                        })
                    }
                })
            }
        }
    }
    
    func showAlert(title:String,message:String) {
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
    
    func retryAlert() {
           let retryAlertController = UIAlertController(title: "Error", message: "Error in getting the member Detail.", preferredStyle: .alert)
           let retryAlertBtn = UIAlertAction(title: "Retry", style: .default, handler: {
               (action) in
            self.showTrainerBy(id: AppManager.shared.trainerID)
           })
           retryAlertController.addAction(retryAlertBtn)
           present(retryAlertController, animated: true, completion: nil)
       }
    
    func setTrainerDataToFields(trainerDetails:TrainerDataStructure,trainerPermissions:TrainerPermissionStructure) {
        self.firstNameNonEditableLabel.text = trainerDetails.firstName
        self.lastNameNonEditableLabel.text = trainerDetails.lastName
        self.idNonEditLabel.text = trainerDetails.trainerID
        self.phoneNonEditLabel.text = trainerDetails.phoneNo
        self.emailNonEditLabel.text = trainerDetails.email
        self.passwordNonEditLabel.text = trainerDetails.password
        self.addressNonEditLabel.text = trainerDetails.address
        self.genderNonEditLabel.text = trainerDetails.gender
        self.salaryNonEditLabel.text = trainerDetails.salary
        self.idProofNonEditLabel.text = trainerDetails.uploadID
        self.shiftDaysNonEditLabel.text = trainerDetails.shiftDays
        self.shiftTimingsNonEditLabel.text = trainerDetails.shiftTimings
        self.dobNonEditLabel.text = trainerDetails.dob
        self.dateOfJoinNonEditLabel.text = trainerDetails.dateOfJoining
        
        self.firstNameTextField.text = trainerDetails.firstName
        self.secondNameTextField.text = trainerDetails.lastName
        self.idTextField.text = trainerDetails.trainerID
        self.phoneNoTextField.text = trainerDetails.phoneNo
        self.emailTextField.text = trainerDetails.email
        self.passwordTextField.text = trainerDetails.password
        self.addressView.text = trainerDetails.address
        self.genderTextField.text = trainerDetails.gender
        self.salaryTextField.text = trainerDetails.salary
        self.uploadIDProofTextField.text = trainerDetails.uploadID
        self.shiftDaysTextField.text = trainerDetails.shiftDays
        self.shiftTimingsTextField.text = trainerDetails.shiftTimings
        self.dateOfJoinTextField.text = trainerDetails.dateOfJoining
        self.dobTextField.text = trainerDetails.dob
        
        self.idTextField.isEnabled = false
        self.idTextField.layer.opacity = 0.4
        
        self.setTrainerType(type:trainerDetails.type,generalBtn:self.generalBtnForNonEditLabel,personalBtn: self.personalBtnForNonEditLabel )
        self.setTrainerPermission(memberPermission: trainerPermissions.canAddMember, visitorPermission: trainerPermissions.canAddVisitor, eventPermission:trainerPermissions.canAddEvent)
        
        self.name = "\(trainerDetails.firstName) \(trainerDetails.lastName)"
        self.addressStr = trainerDetails.address
        self.trainerType = trainerDetails.type
    }

    func clearTextFields() {
        [self.firstNameTextField,self.secondNameTextField,self.idTextField,self.phoneNoTextField,self.emailTextField,self.passwordTextField,self.genderTextField,self.salaryTextField,self.dobTextField,self.dateOfJoinTextField,self.shiftTimingsTextField,self.shiftDaysTextField,self.uploadIDProofTextField].forEach{
            $0?.text = ""
        }
        self.addressView.text = ""
    }
    
    func setTrainerType(type:String,generalBtn:UIButton,personalBtn:UIButton) {
        if type == "General"{
            generalBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            personalBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
        if type == "Personal"{
            personalBtn.setImage(UIImage(named: "selelecte"), for: .normal)
            generalBtn.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
    }
    
    func setTrainerPermission(memberPermission:Bool,visitorPermission:Bool,eventPermission:Bool) {
        self.memberPermissionToggleBtn.setImage(UIImage(named: memberPermission ? "toggle-on": "toggle-off"), for: .normal)
        self.visitorPermissionToggleBtn.setImage(UIImage(named: visitorPermission ? "toggle-on" : "toggle-off"), for: .normal)
        self.eventPermissionToggleBtn.setImage(UIImage(named: eventPermission ? "toggle-on" : "toggle-off"), for: .normal)
    }
}


extension TrainerEditScreenViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if self.isUserImgSelected == true{
            if let img = info[.editedImage] as? UIImage{
                self.userImg.image = img
                self.isUserImgSelected = false
                dismiss(animated: true, completion: nil)
            }
        }else {
            if let selectedImgURL:URL = info[ .imageURL ] as? URL {
                self.imgURL = selectedImgURL
                let imgaeName = selectedImgURL.lastPathComponent
                self.uploadIDProofTextField.text = imgaeName
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension TrainerEditScreenViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField.tag == 1 || textField.tag == 2 {
                      return false
                  }else{
                      return true
                  }
       }
       
       func textFieldDidBeginEditing(_ textField: UITextField) {
              if textField.tag == 1 || textField.tag == 2 {
                  textField.inputAccessoryView = self.toolBar
                  textField.inputView = datePicker
              }
          }
          
          func textFieldDidEndEditing(_ textField: UITextField) {
            if self.selectedDate.count > 1 {
                switch textField.tag {
                case 1:
                    self.dobTextField.text = self.selectedDate
                case 2:
                   self.dateOfJoinTextField.text = self.selectedDate
                default:
                    break
                }

            }
        }
}


