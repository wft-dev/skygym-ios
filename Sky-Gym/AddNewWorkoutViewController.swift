//
//  AddNewWorkoutViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD
import UserNotifications


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
    @IBOutlet weak var assignToMemberLabel: UILabel!
    
    @IBOutlet weak var workoutPlanNonEdit: UILabel!
    @IBOutlet weak var workoutPlanHrLineView: UIView!
    @IBOutlet weak var workoutDescritptionNonEdit: UILabel!
    @IBOutlet weak var workoutDescriptionHrLineView: UIView!
    @IBOutlet weak var noOfSetsNonEdit: UILabel!
    @IBOutlet weak var setsHrLineView: UIView!
    @IBOutlet weak var noOfRepsNonEdit: UILabel!
    @IBOutlet weak var repsHrLineView: UIView!
    @IBOutlet weak var weightNonEdit: UILabel!
    @IBOutlet weak var weightHrLineView: UIView!
    @IBOutlet weak var assignToMemberNonEditLabel: UILabel!
    @IBOutlet weak var assignToMemberHrLineView: UIView!
    
    @IBOutlet  var nonEditDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet  var nonEditSetsTopConstraint: NSLayoutConstraint!
    @IBOutlet  var nonEditRepsTopConstraint: NSLayoutConstraint!
    @IBOutlet  var desctiptionTopConstraint: NSLayoutConstraint!
    @IBOutlet  var setTopConstraint: NSLayoutConstraint!
    @IBOutlet  var repTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topRepConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addReminderBtn: UIButton!
 
    private var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return leftBtn
    }()
    
    private var editBtn:UIButton = {
        let editBtn = UIButton()
        editBtn.setImage(UIImage(named: "edit"), for: .normal)
        editBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        editBtn.heightAnchor.constraint(equalToConstant: 18).isActive = true
        editBtn.widthAnchor.constraint(equalToConstant: 18).isActive = true
        return editBtn
    }()
    
    private var pickerView :UIPickerView = {
       return UIPickerView()
    }()
    
    let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var stackView : UIStackView? = nil
    
    let rightSpaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var rightStackView : UIStackView? = nil
    
    var isNewWorkout:Bool = false
    var workoutID:String = ""
    var textFieldsArray:[UITextField] = []
    var pickerArray:[String] = []
    var memberNameArray:[WorkoutMemberList] = []
    var selectedIndexArray:[Int] = []
    var selectedMemberArray:[String] = []
    var selectedMemberIDArray:[String] = []
    var nonEditLabelsArray:[UILabel] = []
    var hrLineView:[UIView] = []
    var isEdit: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        requestReminder()
        setWorkOutUI()
    }
    
    func setWorkOutUI()  {
        self.textFieldsArray = [workOutTitle,sets,reps,weight,assignToMember]
        self.pickerArray = [
            "1","2","3","4","5","6","7","8","9","10","11",
            "12","13","14","15","16","17","18","19","20"
        ]
        
        self.nonEditLabelsArray = [ workoutPlanNonEdit,workoutDescritptionNonEdit, noOfSetsNonEdit,noOfRepsNonEdit,weightNonEdit]
        
        self.hrLineView = [ workoutPlanHrLineView,workoutDescriptionHrLineView, setsHrLineView, repsHrLineView, weightHrLineView]
        
        if AppManager.shared.loggedInRole != LoggedInRole.Member {
            self.nonEditLabelsArray.append(assignToMemberNonEditLabel)
            self.hrLineView.append(assignToMemberHrLineView)
        }
        
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
        
        rightStackView = UIStackView(arrangedSubviews: [editBtn,rightSpaceBtn])
        rightStackView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        
        setAddWorkoutNavigationBar()
        
        setTextFields()
        
        addReminderBtn.addTarget(self, action: #selector(addReminder), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memberNameArray.removeAll()
        self.changeView()
        SVProgressHUD.show()
        
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getAllMembersNameAndID()
            DispatchQueue.main.async {
                switch result {
                case let  .success(arr) :
                    self.memberNameArray  = arr
                    if self.isNewWorkout == true  {
                        self.addNewWorkoutBtn.setTitle("A D D", for: .normal)
                        self.clearWokroutFields()
                        self.memberListTable.reloadData()
                    }else {
                        self.addNewWorkoutBtn.setTitle("U P D A T E", for: .normal)
                        self.fetchWorkoutBy(id: self.workoutID)
                    }
                    
                    SVProgressHUD.dismiss()
                    break
                case .failure(_) :
                    print("FAILURE ")
                    SVProgressHUD.dismiss()
                    break
                }
            }
        }
    }
    
    func changeView()  {
        addReminderBtn.isHidden = AppManager.shared.loggedInRole == LoggedInRole.Member ? false : true
        addReminderBtn.alpha = AppManager.shared.loggedInRole == LoggedInRole.Member ? 1.0 : 0.0
        
        if AppManager.shared.loggedInRole != LoggedInRole.Member && self.workoutID  != "" {
           navigationItem.setRightBarButton(UIBarButtonItem(customView: rightStackView!), animated: true)
        }else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        if self.isNewWorkout == false || self.workoutID  != "" {
            showMemberListBtn.isEnabled = false
            
            if AppManager.shared.loggedInRole == LoggedInRole.Member {
                assignToMemberLabel.isHidden = true
                assignToMemberLabel.alpha = 0.0
                assignToMemberHrLineView.isHidden = true
                assignToMemberHrLineView.alpha =  0.0
                assignToMemberNonEditLabel.isHidden = true
                assignToMemberNonEditLabel.alpha = 0.0
            }

            addNewWorkoutBtn.isHidden = true
            addNewWorkoutBtn.alpha = 0.0
            descriptionTextView.isHidden = true
            descriptionTextView.alpha = 0.0
            
            nonEditRepsTopConstraint.isActive = true
            nonEditSetsTopConstraint.isActive = true
            nonEditDescriptionTopConstraint.isActive = true
            
            setTopConstraint.priority = .defaultLow
            desctiptionTopConstraint.priority = .defaultLow
            repTopConstraint.priority = .defaultLow
            
            hideTextFieldArray(hide: true)
            hideNonEditLabel(hide: false)
            hideHrLineView(hide: false)
   
        } else {
            
            showMemberListBtn.isEnabled = true
            if AppManager.shared.loggedInRole == LoggedInRole.Member {
                assignToMemberLabel.isHidden = false
                assignToMemberLabel.alpha = 1.0
                assignToMemberHrLineView.isHidden = false
                assignToMemberHrLineView.alpha = 1.0
                assignToMemberNonEditLabel.isHidden = false
                assignToMemberNonEditLabel.alpha = 1.0
            }
            addNewWorkoutBtn.isHidden = false
            addNewWorkoutBtn.alpha = 1.0
            descriptionTextView.isHidden = false
            descriptionTextView.alpha = 1.0
            
            nonEditRepsTopConstraint.isActive = true
            nonEditSetsTopConstraint.isActive = true
            nonEditDescriptionTopConstraint.isActive = true
            
            setTopConstraint.priority = .defaultHigh
            desctiptionTopConstraint.priority = .defaultHigh
            repTopConstraint.priority = .defaultHigh
            
            hideTextFieldArray(hide: false)
            hideNonEditLabel(hide: true)
            hideHrLineView(hide: true)
        }
    }
    
    func hideTextFieldArray(hide:Bool) {
        self.textFieldsArray.forEach { (textField) in
            textField.isHidden = hide
            textField.alpha = hide == false ? 1.0 : 0.0
        }
    }
    
    func hideNonEditLabel(hide:Bool) {
        self.nonEditLabelsArray.forEach {
            $0.isHidden = hide
            $0.alpha = hide == false ? 1.0 : 0.0
        }
    }
    
    func hideHrLineView(hide:Bool) {
        self.hrLineView.forEach {
            $0.isHidden = hide
            $0.alpha = hide == false ? 1.0 : 0.0
        }
    }
    
    func requestReminder()  {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: {
            (result,err) in
            if result {
                print("All set!")
            } else if let error = err {
                print(error.localizedDescription)
            }
        })
    }
    
    @objc func addReminder()  {
        
        let reminderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "reminderVC") as! AddReminderViewController
        reminderVC.workoutID = self.workoutID
        reminderVC.workoutName = self.workoutPlanNonEdit.text!
        self.navigationController?.pushViewController(reminderVC, animated: true)
    
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
        
        if AppManager.shared.loggedInRole == LoggedInRole.Trainer  {
            editBtn.addTarget(self, action: #selector(makeProfileEditable), for: .touchUpInside)
            navigationItem.setRightBarButton(UIBarButtonItem(customView: rightStackView!), animated: true)
        }
    }
    
    @objc func makeProfileEditable(){
        isEdit = !isEdit
        let priority:UILayoutPriority = !isEdit == true ? .defaultHigh : .defaultLow
        
        if AppManager.shared.loggedInRole == LoggedInRole.Member {
                    assignToMemberLabel.isHidden = isEdit
                    assignToMemberLabel.alpha =  isEdit == true ? 0.0 : 1.0
        }

        addNewWorkoutBtn.isHidden = isEdit
        addNewWorkoutBtn.alpha = isEdit == true ? 0.0 : 1.0
        descriptionTextView.isHidden = isEdit
        descriptionTextView.alpha = isEdit == true ? 0.0 : 1.0
        showMemberListBtn.isEnabled = !isEdit
        
        self.nonEditRepsTopConstraint.isActive =  self.isEdit
        self.nonEditSetsTopConstraint.isActive = self.isEdit
        self.nonEditDescriptionTopConstraint.isActive = self.isEdit
        
        setTopConstraint.priority = priority
        desctiptionTopConstraint.priority = priority
        repTopConstraint.priority = priority
        topRepConstraint.priority = priority
        
        hideTextFieldArray(hide: isEdit)
        hideNonEditLabel(hide: !isEdit)
        hideHrLineView(hide: !isEdit)
    }
    
    @objc func showMemberList() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = nil
        mainScrollView.isScrollEnabled = false
        addNewWorkoutBtn.isHidden = true
        addNewWorkoutBtn.alpha = 0.0
        memberListView.isHidden = false
        memberListView.alpha = 1.0
    }
    
    @objc func memberListAction() {
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        navigationItem.setRightBarButton(UIBarButtonItem(customView: rightStackView!), animated: true)
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
            let parentID = AppManager.shared.trainerID != "" ? AppManager.shared.trainerID : AppManager.shared.adminID
            self.isNewWorkout == true ?  addWorkoutPlanToDatabase(id: "\(Int.random(in: 9999..<1000000))",parentID:parentID ) : updateWorkoutPlan(id: self.workoutID)
        }else {
            SVProgressHUD.dismiss()
            print("ERROR ")
        }
    }

    func addWorkoutPlanToDatabase(id:String,parentID:String) {
        FireStoreManager.shared.addNewWorkout(id:id,parentID:parentID,data:getDataFromTextFields()) { (err) in
            SVProgressHUD.dismiss()
            if err == nil {
                for (index,singleMemberID) in self.selectedMemberIDArray.enumerated() {
                    FireStoreManager.shared.addWorkoutPlansToMember(memberID: singleMemberID, workoutID: id, handler: {
                        err  in
                        if err == nil {
                            if index  == self.selectedMemberIDArray.count - 1  {
                                self.showAlert(messageTitle: "Success", message: "New workout plan is added successfully.")
                            }
                        }else {
                         self.showAlert(messageTitle: "Error", message: "Something went wrong, please try again.")
                        }
                    })
                }
                
            } else {
                self.showAlert(messageTitle: "Error", message: "Something went wrong, please try again.")
            }
        }
    }
    
    func updateWorkoutPlan(id:String) {
        FireStoreManager.shared.updateWorkoutPlan(id: id, data: getDataFromTextFields()) { (err) in
            if err == nil {
                SVProgressHUD.dismiss()
                for (index,singleMemberID) in self.selectedMemberIDArray.enumerated() {
                    FireStoreManager.shared.addWorkoutPlansToMember(memberID: singleMemberID, workoutID: id, handler: {
                        err  in
                        if err == nil {
                            if index  == self.selectedMemberIDArray.count - 1  {
                                self.showAlert(messageTitle: "Success", message: "Workout plan is updated successfully.")
                            }
                        }else {
                            self.showAlert(messageTitle: "Error", message: "Something went wrong, please try again.")
                        }
                    })
                }
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
        addReminderBtn.layer.cornerRadius = 7.0
        
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
        
        self.workoutPlanNonEdit.text = workoutPlan.workoutPlan
        self.workoutDescritptionNonEdit.text = workoutPlan.workoutDescription
        self.noOfSetsNonEdit.text = workoutPlan.sets
        self.noOfRepsNonEdit.text = workoutPlan.reps
        self.weightNonEdit.text = workoutPlan.weight
        
        self.assignToMemberNonEditLabel.text = ""
        for (i,singleMember) in self.selectedMemberArray.enumerated() {
            if i == self.selectedMemberArray.count - 1 {
                self.assignToMemberNonEditLabel.text! += "\(singleMember)"
            }else {
                self.assignToMemberNonEditLabel.text! += "\(singleMember),  "
            }
        }
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


//extension URL {
//    static func localURLForXCAsset(name: String,ext:String) -> URL? {
//        let fileManager = FileManager.default
//        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
//        let url = cacheDirectory.appendingPathComponent("\(name).\(ext)")
//        guard fileManager.fileExists(atPath: url.path) else {
//            guard
//                let image = UIImage(named: name),
//                let data = image.pngData()
//                else { return nil }
//
//            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
//            return url
//        }
//        return url
//    }
//}

