//
//  AddNewWorkoutViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD


class MemberListForWorkoutCell: UITableViewCell {
    @IBOutlet weak var checkImg: UIImageView!
    @IBOutlet weak var memberName: UILabel!
}

class AddNewWorkoutViewController: BaseViewController {
    
    @IBOutlet weak var workOutTitle: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var errorTitle: UILabel!
    @IBOutlet weak var descriptionError: UILabel!
    @IBOutlet weak var sets: UITextField!
    @IBOutlet weak var setsError: UILabel!
    @IBOutlet weak var reps: UITextField!
    @IBOutlet weak var repsError: UILabel!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var weightError: UILabel!
    @IBOutlet weak var assignToMember: UITextField!
    @IBOutlet weak var assignToMemberErrror: UILabel!
    @IBOutlet weak var addNewWorkoutBtn: UIButton!
    @IBOutlet weak var showMemberListBtn: UIButton!
    @IBOutlet weak var memberListView: UIView!
    @IBOutlet weak var memberListTable: UITableView!
    @IBOutlet weak var memberListDoneBtn: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    private var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return leftBtn
    }()
    
    private var pickerView :UIPickerView = {
       return UIPickerView()
    }()
    
    let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var stackView : UIStackView? = nil
    
    var isNewWorkout:Bool = false
    var workoutID:String = ""
    var textFieldsArray:[UITextField] = []
    var pickerArray:[String] = []
    var memberNameArray:[WorkoutMemberList] = []
    var selectedIndexArray:[Int] = []
    var selectedMemberArray:[String] = []
    var selectedMemberIDArray:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setWorkOutUI()
    }
    
    func setWorkOutUI()  {
        self.textFieldsArray = [workOutTitle,sets,reps,weight,assignToMember]
        self.pickerArray = [
            "1","2","3","4","5","6","7","8","9","10","11",
            "12","13","14","15","16","17","18","19","20"
        ]
        addNewWorkoutBtn.addTarget(self, action: #selector(addNewWorkoutPlan), for: .touchUpInside)
        pickerView.delegate = self
        pickerView.dataSource = self
        memberListTable.delegate = self
        memberListTable.dataSource = self
        memberListTable.tableFooterView = UIView()
        memberListDoneBtn.addTarget(self, action: #selector(memberListAction), for: .touchUpInside)
        showMemberListBtn.addTarget(self, action: #selector(showMemberList), for: .touchUpInside)
        assignToMember.isEnabled = false
        memberListView.isHidden = true
        memberListView.alpha = 0.0
        stackView = UIStackView(arrangedSubviews: [spaceBtn,leftBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        setAddWorkoutNavigationBar()
        setTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getAllMembersNameAndID()
            DispatchQueue.main.async {
                switch result {
                case let  .success(arr) :
                    self.memberNameArray  = arr
                    if self.isNewWorkout == true  {
                        self.clearWokroutFields()
                    }else {
                        self.fetchWorkoutBy(id: self.workoutID)
                    }
                    break
                case .failure(_) :
                    print("FAILURE ")
                    break
                }
            }
        }
        
    }
    
    func fetchWorkoutBy(id:String) {
        SVProgressHUD.show()
        self.selectedMemberArray.removeAll()

            FireStoreManager.shared.getWorkoutByID(id: id, handler: {
                (workOut) in
                
                for singleID in workOut!.members {
                    for member in self.memberNameArray {
                        if member.memberID == singleID {
                            self.selectedMemberArray.append(member.memberName)
                        }
                    }
                }
                self.setWokoutPlanDataToFields(workoutPlan: workOut!)
                self.memberListTable.reloadData()
                self.setDataToAssignMemberField()
                SVProgressHUD.dismiss()
            })
    }

    @objc func workoutPlanFieldsRequiredValidation( _ textField:UITextField)  {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.errorTitle, errorMessage: "Workout Plan title required.")
        case 2:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.setsError, errorMessage: "Empty.")
        case 3:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.repsError, errorMessage: "Empty.")
        case 4:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.weightError, errorMessage: "Empty.")
        case 5:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.assignToMemberErrror, errorMessage: "Please chose atleast one member.")
        default:
            break
        }
        
    ValidationManager.shared.updateBtnValidator(updateBtn: self.addNewWorkoutBtn, textFieldArray: self.textFieldsArray, textView: descriptionTextView, phoneNumberTextField: nil, email: nil, password: nil)
    }

    func setAddWorkoutNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Workout Plan ", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        leftBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
    }
    
    @objc func showMemberList() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = nil
        mainScrollView.isScrollEnabled = false
        addNewWorkoutBtn.isHidden = true
        addNewWorkoutBtn.alpha = 0.0
        memberListView.isHidden = false
        memberListView.alpha = 1.0
    }
    
    @objc func memberListAction() {
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        mainScrollView.isScrollEnabled = true
        addNewWorkoutBtn.isHidden = false
        addNewWorkoutBtn.alpha = 1.0
        memberListView.isHidden = true
        memberListView.alpha = 0.0
        addNewWorkoutBtn.isEnabled = true
        setDataToAssignMemberField()
    }
    
    func setDataToAssignMemberField () {
        var str = ""
        print("array : \(selectedMemberArray)")
        for singleMember in selectedMemberArray {
            str += "\(singleMember)  "
        }
        self.assignToMember.text = str
    }
    
    func workoutPlanValidation()  {
        for textField in self.textFieldsArray {
            self.workoutPlanFieldsRequiredValidation(textField)
        }
        ValidationManager.shared.requiredValidation(textView: self.descriptionTextView, errorLabel: self.descriptionError, errorMessage: "Workout description required.")
    }
    
    @objc func addNewWorkoutPlan() {
        SVProgressHUD.show()
        self.workoutPlanValidation()
        if ValidationManager.shared.isWorkoutPlanFieldsValidated(textFieldArray: self.textFieldsArray, textView: self.descriptionTextView) == true {
            self.isNewWorkout == true ?  addWorkoutPlanToDatabase(id: "\(Int.random(in: 9999..<1000000))") : addWorkoutPlanToDatabase(id: self.workoutID)
        }else {
            SVProgressHUD.dismiss()
            print("ERROR ")
        }
    }
    
    func addWorkoutPlanToDatabase(id:String) {
        FireStoreManager.shared.addNewWorkout(id:id , data: getDataFromTextFields()) { (err) in
            SVProgressHUD.dismiss()
            if err == nil {
                self.showAlert(messageTitle: "Success", message: "New workout plan is added successfully.")
            } else {
                self.showAlert(messageTitle: "Error", message: "Something went wrong, please try again.")
            }
        }
    }
    
    func clearWokroutFields()  {
        self.selectedIndexArray.removeAll()
        self.selectedMemberArray.removeAll()
        self.selectedMemberIDArray.removeAll()
        self.textFieldsArray.forEach { (textField) in
            textField.text = ""
        }
        self.descriptionTextView.text = ""
    }
    
    func showAlert(messageTitle:String,message:String) {
        let alertController = UIAlertController(title: messageTitle, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _  in
            
            if messageTitle == "Success" {
                self.clearWokroutFields()
                self.navigationController?.popViewController(animated: true)
            }else {
                self.clearWokroutFields()
            }
        })
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func menuChange() { self.navigationController?.popViewController(animated: true) }
    
    func setTextFields() {
        descriptionTextView.layer.cornerRadius = 7.0
        descriptionTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        addNewWorkoutBtn.layer.cornerRadius = 7.0
        
        descriptionTextView.clipsToBounds = true
        self.textFieldsArray.forEach { (textField) in
            self.addPaddingToTextField(textField: textField)
            textField.layer.cornerRadius = 7.0
            textField.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            textField.clipsToBounds = true
            textField.addTarget(self, action: #selector(workoutPlanFieldsRequiredValidation(_ :)), for: .editingChanged)
            textField.delegate = self
        }
    }
    
  private  func addPaddingToTextField(textField:UITextField) {
           let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
           textField.leftView = paddingView
           textField.leftViewMode = .always
           textField.backgroundColor = UIColor.white
           textField.textColor = UIColor.black
       }
    
  private  func getDataFromTextFields() -> [String:Any] {
        let dataDic : [String:Any]  = [
            "wokroutTitle" : self.workOutTitle.text!,
            "workoutDescription":self.descriptionTextView.text!,
            "sets":self.sets.text!,
            "reps" : self.reps.text!,
            "weight" : self.weight.text!,
            "members" : selectedMemberIDArray,
            "membersIndexArray" : selectedIndexArray
        ]
        return dataDic
    }
    
    func setWokoutPlanDataToFields(workoutPlan:WorkoutPlan) {
        self.workOutTitle.text = workoutPlan.workoutPlan
        self.descriptionTextView.text = workoutPlan.workoutDescription
        self.sets.text = workoutPlan.sets
        self.reps.text = workoutPlan.reps
        self.weight.text = workoutPlan.weight
        self.selectedMemberIDArray = workoutPlan.members
        self.selectedIndexArray = workoutPlan.memberIndex
    }
}

extension   AddNewWorkoutViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
}

extension AddNewWorkoutViewController :UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1010 {
            self.sets.text = self.pickerArray[row]
        }else {
            self.reps.text = self.pickerArray[row]
        }
    }
}

extension AddNewWorkoutViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 || textField.tag == 3 {
            return false
        }else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case 2:
            self.pickerView.tag = 1010
            textField.inputView = self.pickerView
            break
        case 3:
            self.pickerView.tag = 1111
            textField.inputView = self.pickerView
            break
        default:
            break
        }
        self.workoutPlanFieldsRequiredValidation(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.workoutPlanFieldsRequiredValidation(textField)
    }
    
}

extension AddNewWorkoutViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberListCell", for: indexPath) as! MemberListForWorkoutCell

        cell.checkImg.image = UIImage(named: self.selectedIndexArray.contains(indexPath.row) || self.selectedMemberIDArray.contains(memberNameArray[indexPath.row].memberID) ? "checked-checkbox" : "unchecked-checkbox")
        cell.memberName.text = memberNameArray[indexPath.row].memberName
        return cell
    }
}

extension AddNewWorkoutViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndexArray.contains(indexPath.row) {
            self.selectedMemberArray.remove(at: self.selectedIndexArray.firstIndex(of: indexPath.row)!)
            self.selectedMemberIDArray.remove(at: self.selectedIndexArray.firstIndex(of: indexPath.row)!)
            self.selectedIndexArray.remove(at: self.selectedIndexArray.firstIndex(of: indexPath.row)!)
        }else {
            self.selectedIndexArray.append(indexPath.row)
            self.selectedMemberArray.append(self.memberNameArray[indexPath.row].memberName)
            self.selectedMemberIDArray.append(self.memberNameArray[indexPath.row].memberID)
        }
        self.memberListTable.reloadData()
    }
}

extension AddNewWorkoutViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.descriptionError, errorMessage: "Work Out descriptio required.")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.descriptionError, errorMessage: "Work Out descriptio required.")
    }
    
}


