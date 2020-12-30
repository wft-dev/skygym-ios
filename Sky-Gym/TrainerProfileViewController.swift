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
    
    var editMode:Bool = false
    var textFieldArray:[UITextField] = []
    var nonEditLabelArray:[UILabel] = []
    var defaultLabelArray:[UILabel] = []
    
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
        self.defaultLabelArray = [self.firstNameLabel,self.lastNameLabel,self.genderLabel,self.passwordLabel,self.emailLabel,self.dobLabel,self.phoneNoLabel]
        
        self.textFieldArray.forEach{
            self.addPaddingToTextField(textField: $0)
            $0.layer.cornerRadius = 7.0
            $0.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0.clipsToBounds = true
         //   $0?.addTarget(self, action: #selector(errorValidator(_:)), for: .editingChanged)
        }
        self.updateBtn.layer.cornerRadius = 15.0
        self.fetchTrainerProfile(id: AppManager.shared.trainerID)
    }
    
    func addPaddingToTextField(textField:UITextField) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
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
        if self.editMode == true {
          //  AppManager.shared.performEditAction(dataFields: <#T##[UITextField : UILabel]#>, edit: <#T##Bool#>)
        }
    }
    
    func setTrainerDetail(trainerDetail:TrainerDataStructure) {
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
    
}
