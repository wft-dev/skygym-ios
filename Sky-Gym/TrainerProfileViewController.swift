//
//  TrainerProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/12/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class TrainerProfileViewController: BaseViewController {
    
    @IBOutlet weak var trainerProfileCustomNavigationView: CustomNavigationBar!
    @IBOutlet weak var trainerFirstNameTextField: UITextField!
    @IBOutlet weak var trainerLastNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var trainerFirstNameNonEditLabel: UILabel!
    @IBOutlet weak var trainerLastNameNonEditLabel: UILabel!
    @IBOutlet weak var firstNameHrLineView: UIView!
    @IBOutlet weak var genderNonEditLabel: UILabel!
    @IBOutlet weak var passwordNonEditLabel: UILabel!
    @IBOutlet weak var genderHrLineView: UIView!
    @IBOutlet weak var emailNonEditLabel: UILabel!
    @IBOutlet weak var emailHrLineView: UIView!
    @IBOutlet weak var phoneNoNonEditLabel: UILabel!
    @IBOutlet weak var dobNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoHrLineView: UIView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNoErrorLabel: UILabel!
    @IBOutlet weak var dobErrorLabel: UILabel!
    @IBOutlet weak var genderForNonEditLabel: UILabel!
    @IBOutlet weak var passwordForNonEditLabel: UILabel!
    @IBOutlet weak var emailForNonEditLabel: UILabel!
    @IBOutlet weak var phoneNoForNonEditLabel: UILabel!
    @IBOutlet weak var dobForNonEditLabel: UILabel!
    
    var editMode:Bool = false
    var textFieldArray:[UITextField] = []
    var nonEditLabelArray:[UILabel] = []
    var defaultLabelArray:[UILabel] = []
    var forNonEditLabelArray:[UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground()
        self.trainerProfileCustomNavigationView.navigationTitleLabel.text = "Profile"
        self.trainerProfileCustomNavigationView.searchBtn.isHidden = true
        self.trainerProfileCustomNavigationView.searchBtn.alpha = 0.0
        self.trainerProfileCustomNavigationView.editBtn.isHidden = false
        self.trainerProfileCustomNavigationView.editBtn.alpha = 1.0
        self.trainerProfileCustomNavigationView.editBtn.addTarget(self, action: #selector(makeProfileEditable), for: .touchUpInside)
        self.textFieldArray = [self.trainerFirstNameTextField,self.trainerLastNameTextField,self.genderTextField,self.passwordTextField,self.emailTextField,self.phoneNoTextField,self.dobTextField]
        self.nonEditLabelArray = [self.trainerFirstNameNonEditLabel,self.trainerLastNameNonEditLabel,self.genderNonEditLabel,self.passwordNonEditLabel,self.emailNonEditLabel,self.phoneNoNonEditLabel,self.dobNonEditLabel]
        self.defaultLabelArray = [self.genderLabel,self.passwordLabel,self.emailLabel,self.dobLabel,self.phoneNoLabel]
        self.forNonEditLabelArray = [self.genderForNonEditLabel,self.passwordForNonEditLabel,self.emailForNonEditLabel,self.phoneNoForNonEditLabel,self.dobForNonEditLabel]
        
        self.textFieldArray.forEach{
            self.addPaddingToTextField(textField: $0)
            $0.layer.cornerRadius = 7.0
            $0.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0.clipsToBounds = true
         //   $0?.addTarget(self, action: #selector(errorValidator(_:)), for: .editingChanged)
        }
        self.updateBtn.layer.cornerRadius = 15.0
        self.updateBtn.addTarget(self, action: #selector(updateTrainerInfo), for: .touchUpInside)
        self.fetchTrainerProfile(id: AppManager.shared.trainerID)
        
        AppManager.shared.performEditAction(dataFields: self.dataFieldsDir(), edit: false)
        self.hideHrLine(hide: false)
        self.labelColor(color: .lightGray)
        self.hideNonEditLabel(hide: false)
        self.hideDefaultLabel(hide: true)
        self.hideForNonEditLabel(hide: false)
        self.updateBtn.isHidden = true
        self.updateBtn.alpha =  0.0
    }
    
    func addPaddingToTextField(textField:UITextField) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
    }
    
    @objc func updateTrainerInfo(){
        SVProgressHUD.show()
        let trainerInfo = self.getTrainerInfo()
        DispatchQueue.global(qos: .background).async {
            SVProgressHUD.dismiss()
            let result = FireStoreManager.shared.updateTrainerDetailBy(id: AppManager.shared.trainerID, trainerInfo: trainerInfo)
            
            switch result{
            case .failure(_) :
                print("Errror")
                self.showAlert(title: "Error", message: "Error in updating the trainer detail.")
            case let .success(flag) :
                print("SUCCESS IS :\(flag)")
                self.showAlert(title: "Success", message: "Trainer detail is updated successfully.")
            }
        }
    }
    
    func fetchTrainerProfile(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getTrainerBy(id: id, completion: {
            (trainerData,err) in
            if err == nil {
                SVProgressHUD.dismiss()
                let trainerDetail = trainerData!["trainerDetail"] as! Dictionary<String,String>
                 self.setTrainerDetail(trainerDetail: AppManager.shared.getTrainerDetailS(trainerDetail: trainerDetail))
            }
        })
    }
    
    @objc func makeProfileEditable(){
        self.editMode = !self.editMode
        AppManager.shared.performEditAction(dataFields: self.dataFieldsDir(), edit: self.editMode)
        self.hideHrLine(hide: self.editMode)
        self.labelColor(color: self.editMode ? .black : .lightGray)
        self.hideNonEditLabel(hide: self.editMode)
        self.hideDefaultLabel(hide: !self.editMode)
        self.hideForNonEditLabel(hide: self.editMode)
        self.updateBtn.isHidden = !self.editMode
        self.updateBtn.alpha = self.editMode == false ? 0.0 : 1.0
    }
    
    func setTrainerDetail(trainerDetail:TrainerDataStructure) {
        self.trainerFirstNameNonEditLabel.text = trainerDetail.firstName
        self.trainerLastNameNonEditLabel.text = trainerDetail.lastName
        self.genderNonEditLabel.text = trainerDetail.gender
        self.passwordNonEditLabel.text = AppManager.shared.getSecureTextFor(text: trainerDetail.password)
        self.emailNonEditLabel.text = trainerDetail.email
        self.phoneNoNonEditLabel.text = trainerDetail.phoneNo
        self.dobNonEditLabel.text = trainerDetail.dob
        
        self.trainerFirstNameTextField.text = trainerDetail.firstName
        self.trainerLastNameTextField.text = trainerDetail.lastName
        self.genderTextField.text = trainerDetail.gender
        self.passwordTextField.text = trainerDetail.password
        self.emailTextField.text = trainerDetail.email
        self.phoneNoTextField.text = trainerDetail.phoneNo
        self.dobTextField.text = trainerDetail.dob
    }
    
    func dataFieldsDir() -> [UITextField:UILabel] {
        let dir = [
            self.trainerFirstNameTextField! : self.trainerFirstNameNonEditLabel!,
            self.trainerLastNameTextField! : self.trainerLastNameNonEditLabel!,
            self.genderTextField! : self.genderNonEditLabel!,
            self.passwordTextField! : self.passwordNonEditLabel!,
            self.emailTextField! : self.emailNonEditLabel! ,
            self.dobTextField! : self.dobNonEditLabel!,
            self.phoneNoTextField! : self.phoneNoNonEditLabel!
        ]
        return dir
    }
    
    func hideHrLine(hide:Bool)  {
        [self.firstNameHrLineView,self.genderHrLineView,self.emailHrLineView,self.phoneNoHrLineView].forEach{
            $0?.isHidden = hide
            $0?.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func labelColor(color:UIColor) {
        [self.firstNameLabel,self.lastNameLabel].forEach{
            $0.textColor = color
        }
    }
    
    func hideNonEditLabel(hide:Bool)  {
        self.nonEditLabelArray.forEach{
            $0.isHidden = hide
            $0.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func hideForNonEditLabel(hide:Bool) {
        self.forNonEditLabelArray.forEach{
            $0.isHidden = hide
            $0.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func hideDefaultLabel(hide : Bool)  {
        self.defaultLabelArray.forEach{
            $0.isHidden = hide
            $0.alpha = hide ? 0.0 : 1.0
        }
    }
    
    func getTrainerInfo() -> Dictionary<String,String> {
        let info = [
            "firstName" : self.trainerFirstNameTextField.text!,
            "lastName" : self.trainerLastNameTextField.text!,
            "gender" : self.genderTextField.text!,
            "password" : self.passwordTextField.text!,
            "email" : self.emailTextField.text!,
            "phoneNo" : self.phoneNoTextField.text!,
            "dob" : self.dobTextField.text!
         ]
        return info
    }
    
    func showAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            self.fetchTrainerProfile(id: AppManager.shared.trainerID)
        })
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
