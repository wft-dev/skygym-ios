//
//  AdminProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 12/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class AdminProfileViewController: UIViewController {
    
    @IBOutlet weak var adminProfileNavigationBar: CustomNavigationBar!
    @IBOutlet weak var gymNameTextField: UITextField!
    @IBOutlet weak var gymIDTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var adminFirstNameTextField: UITextField!
    @IBOutlet weak var adminLastNameTextField: UITextField!
    @IBOutlet weak var adminGenderTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var adminImg: UIImageView!
    @IBOutlet weak var gymName: UILabel!
    @IBOutlet weak var gymNameHrLineView: UIView!
    @IBOutlet weak var gymIDNonEditLabel: UILabel!
    @IBOutlet weak var gymID: UILabel!
    @IBOutlet weak var gymNameNonEditLabel: UILabel!
    @IBOutlet weak var gymAddress: UILabel!
    @IBOutlet weak var gymAddressNoEditLabel: UILabel!
    @IBOutlet weak var gymAddressHrLineView: UIView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var firstNameNonEditLabel: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var lastNameNonEditLabel: UILabel!
    @IBOutlet weak var firstNameHrLineView: UIView!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var genderNonEditLabel: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var passwordNonEditLabel: UILabel!
    @IBOutlet weak var genderHrLineView: UIView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailNonEditLabel: UILabel!
    @IBOutlet weak var emailHrLineView: UIView!
    @IBOutlet weak var phoneNo: UILabel!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var phoneNoHrLineView: UIView!
    @IBOutlet weak var dobNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoNonEditLabel: UILabel!
    @IBOutlet weak var gymNameForNonEditLabel: UILabel!
    @IBOutlet weak var gymIDForNonEditLabel: UILabel!
    @IBOutlet weak var gymAddressForNonEditLabel: UILabel!
    @IBOutlet weak var firstNameForNonEditLabel: UILabel!
    @IBOutlet weak var lastNameForNonEditLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var passwordForNonEditLabel: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    @IBOutlet weak var dobForNonEditLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    var isProfileImgSelected:Bool = false
    var isEdit:Bool = false
    var forNonEditLabelArray:[UILabel] = []
    var defaultLabelArray:[UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAdminProfileNavigationBar()
        setTextFields()
        self.adminImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPicker)))
        self.imagePicker.delegate = self
        self.forNonEditLabelArray = [self.gymNameForNonEditLabel,self.gymIDForNonEditLabel,self.gymAddressForNonEditLabel,self.firstNameForNonEditLabel,self.lastNameForNonEditLabel,self.emailForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel,self.genderForNonEditLabel,self.passwordForNonEditLabel]
        self.defaultLabelArray = [self.gymName,self.gymID,self.gymAddress,self.firstName,self.lastName,self.email,self.gender,self.password,self.phoneNo,self.dob]
        self.adminImg.makeRounded()
        AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit: false)
        AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, flag: true)
        self.setHrLineView(isHidden: false, alpha: 1.0)
        self.addressTextView.isHidden = true
        self.addressTextView.alpha = 0.0
        self.gymAddressNoEditLabel.isHidden = false
        self.gymAddressNoEditLabel.alpha = 1.0
        self.updateBtn.isEnabled = false
        self.updateBtn.alpha = 0.4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchAdminDetailBy(id: AppManager.shared.adminID)
    }
 
    @IBAction func updateBtnAction(_ sender: Any) {
        let adminID = AppManager.shared.adminID
        SVProgressHUD.show()
        if self.isProfileImgSelected == true {
            FireStoreManager.shared.uploadUserImg(imgData: (self.adminImg.image?.pngData())!, id: AppManager.shared.adminID, completion: {
                err in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.showAdminProfileAlert(title: "Error", message: "Error in uploading the user profile image, Please try again.")
                } else {
                    FireStoreManager.shared.register(id: adminID, adminDetail: self.getAdminDetailForUpdate(), result: {
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
            FireStoreManager.shared.register(id: adminID, adminDetail: self.getAdminDetailForUpdate(), result: {
                (err) in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.showAdminProfileAlert(title: "Error", message: "Error in updating admin details, please try again.")
                } else {
                    self.showAdminProfileAlert(title: "Success", message: "Admin details are updated successfully.")
                }
            })
        }
    }
}

extension AdminProfileViewController {
    func setAdminProfileNavigationBar() {
        self.adminProfileNavigationBar.menuBtn.isHidden = false
        self.adminProfileNavigationBar.searchBtn.isHidden = true
        self.adminProfileNavigationBar.navigationTitleLabel.text = "Profile"
        self.adminProfileNavigationBar.editBtn.isHidden = false
        self.adminProfileNavigationBar.editBtn.alpha = 1.0
        self.adminProfileNavigationBar.editBtn.addTarget(self, action: #selector(editAdmin), for: .touchUpInside)
        
    }
    
    @objc func editAdmin() {
             if self.isEdit == true {
                  AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  false)
                  AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, flag: true)
                  self.isEdit = false
                  self.setHrLineView(isHidden: false, alpha: 1.0)
                 self.addressTextView.isHidden = true
                 self.addressTextView.alpha = 0.0
                 self.gymAddressNoEditLabel.isHidden = false
                 self.gymAddressNoEditLabel.alpha = 1.0
                self.updateBtn.isEnabled = false
                self.updateBtn.alpha = 0.4
             } else{
                AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
                AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray, defaultLabels: self.defaultLabelArray, flag: false)
                self.isEdit = true
                self.setHrLineView(isHidden: true, alpha: 0.0)
                self.gymIDTextField.isEnabled = true
                self.gymIDTextField.layer.opacity = 0.4
                self.addressTextView.isHidden = false
                self.addressTextView.alpha = 1.0
                self.gymAddressNoEditLabel.isHidden = true
                self.gymAddressNoEditLabel.alpha = 0.0
                self.updateBtn.isEnabled = true
                self.updateBtn.alpha = 1.0
        }
         }

    func getFieldsAndLabelDic() -> [UITextField:UILabel] {
                let dir = [
                    self.gymNameTextField! : self.gymNameNonEditLabel!,
                    self.gymIDTextField! : self.gymIDNonEditLabel!,
                    self.adminFirstNameTextField! : self.firstNameNonEditLabel!,
                    self.adminLastNameTextField! : self.lastNameNonEditLabel!,
                    self.adminGenderTextField! : self.genderNonEditLabel!,
                    self.adminPasswordTextField! : self.passwordNonEditLabel!,
                    self.emailTextField! : self.emailNonEditLabel!,
                    self.phoneNoTextField! : self.phoneNoNonEditLabel!,
                    self.dobTextField! : self.dobNonEditLabel!
            ]
                return dir
            }

              func setHrLineView(isHidden:Bool,alpha:CGFloat) {
                [self.gymNameHrLineView,self.gymAddressHrLineView,self.firstNameHrLineView,self.phoneNoHrLineView,self.emailHrLineView,self.genderHrLineView].forEach{
                      $0?.isHidden = isHidden
                      $0?.alpha = alpha
                  }
              }
    
    func setTextFields() {
        [self.gymNameTextField,self.gymIDTextField,self.adminFirstNameTextField,self.adminLastNameTextField,self.adminGenderTextField,self.dobTextField,self.phoneNoTextField,self.adminPasswordTextField,self.emailTextField].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
        }
        
        self.updateBtn.layer.cornerRadius = 12.0
        self.updateBtn.layer.borderColor = UIColor.black.cgColor
        self.updateBtn.layer.borderWidth = 0.7
        self.updateBtn.clipsToBounds = true
        self.adminPasswordTextField.isSecureTextEntry = true
        self.addressTextView.addPaddingToTextField()
        self.addressTextView.layer.cornerRadius = 7.0
        self.addressTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.addressTextView.clipsToBounds = true
    }

       func addPaddingToTextField(textField:UITextField) {
                let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                textField.leftView = paddingView
                textField.leftViewMode = .always
                textField.backgroundColor = UIColor.white
                textField.textColor = UIColor.black
            }
    
    func fetchAdminDetailBy(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.downloadUserImg(id: AppManager.shared.adminID, result: {
            (url,err) in
            if err != nil {
                self.viewDidLoad()
            } else{
                if AppManager.shared.isInitialUploaded == true {
                    do {
                        let imgData = try Data(contentsOf: url!)
                        self.adminImg.image = UIImage(data: imgData)
                    } catch let error as NSError {
                        print(error)
                    }
                }
                FireStoreManager.shared.getAdminDetailBy(id: AppManager.shared.adminID, result: {
                    (data,err) in
                    SVProgressHUD.dismiss()
                    if err != nil {
                        print("Error in fetching the admin details.")
                    }else{
                        let adminDetail = data?["adminDetail"] as! NSDictionary
                        self.fillAdminDetail(adminDetail: AppManager.shared.getAdminProfile(adminDetails: adminDetail as! [String : String] ))
                        
                    }
                })
            }
        })
    }
    
    func fillAdminDetail(adminDetail:AdminProfile) {
        self.gymNameNonEditLabel.text = adminDetail.gymName
        self.gymIDNonEditLabel.text = adminDetail.gymID
        self.gymAddressNoEditLabel.text = adminDetail.gymAddress
        self.firstNameNonEditLabel.text = adminDetail.firstName
        self.lastNameNonEditLabel.text = adminDetail.lastName
        self.genderNonEditLabel.text = adminDetail.gender
        self.passwordNonEditLabel.text = adminDetail.password
        self.emailNonEditLabel.text = adminDetail.email
        self.phoneNoNonEditLabel.text = adminDetail.phoneNO
        self.dobNonEditLabel.text = adminDetail.dob
        
        self.gymNameTextField.text = adminDetail.gymName
        self.gymIDTextField.text = adminDetail.gymID
        self.addressTextView.text = adminDetail.gymAddress
        self.adminFirstNameTextField.text = adminDetail.firstName
        self.adminLastNameTextField.text = adminDetail.lastName
        self.adminGenderTextField.text = adminDetail.gender
        self.adminPasswordTextField.text = adminDetail.password
        self.emailTextField.text = adminDetail.email
        self.phoneNoTextField.text = adminDetail.phoneNO
        self.dobTextField.text = adminDetail.dob
    }

    
    func getAdminDetailForUpdate() -> [String:Any] {
        let admin:[String:Any] =  [
            "dob":self.dobTextField.text!,
            "email":self.emailTextField.text!,
            "firstName":self.adminFirstNameTextField.text!,
            "lastName":self.adminLastNameTextField.text!,
            "gender":self.adminGenderTextField.text!,
            "gymAddress":self.addressTextView.text!,
            "gymID":self.gymIDTextField.text!,
            "gymName":self.gymNameTextField.text!,
            "mobileNo":self.phoneNoTextField.text!,
            "password":self.adminPasswordTextField.text!
        ]
        return admin
    }
    func showAdminProfileAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "Ok", style: .default, handler:nil)
         alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showPicker(){
        self.isProfileImgSelected = true
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.modalPresentationStyle = .fullScreen
        present(self.imagePicker, animated: true, completion: nil)
    }
}


extension AdminProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let img:UIImage = info[.editedImage] as? UIImage{
            self.adminImg.image = img
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
