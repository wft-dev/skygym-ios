//
//  AddNewWorkoutViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var addNewEditorBtn: UIButton!
    
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
    
    var isNewWorkout:Bool = false
    var textFieldsArray:[UITextField] = []
    var pickerArray:[String] = []
   // var
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldsArray = [workOutTitle,sets,reps,weight,assignToMember]
        self.pickerArray = [
            "1","2","3","4","5","6","7","8","9","10",
            "11","12","13","14","15","16","17","18","19","20",
        ]
        addNewEditorBtn.addTarget(self, action: #selector(addNewWorkoutPlan), for: .touchUpInside)
        pickerView.delegate = self
        pickerView.dataSource = self
        setAddWorkoutNavigationBar()
        setTextFields()
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
        
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,leftBtn])
        stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView), animated: true)
    }
    
    @objc func addNewWorkoutPlan() {
        let data = getDataFromTextFields()
        print("DATA IS  : \(data)")
    }
    
    @objc func menuChange() { self.navigationController?.popViewController(animated: true) }
    
    func setTextFields() {
        descriptionTextView.layer.cornerRadius = 7.0
        descriptionTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        addNewEditorBtn.layer.cornerRadius = 7.0
        
        descriptionTextView.clipsToBounds = true
        self.textFieldsArray.forEach { (textField) in
            self.addPaddingToTextField(textField: textField)
            textField.layer.cornerRadius = 7.0
            textField.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            textField.clipsToBounds = true
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
            "members" : ["1111","1122","1133"]
        ]
        return dataDic
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
    }
}
