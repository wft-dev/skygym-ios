//
//  AddReminderViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 02/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController {
    
    private var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return leftBtn
    }()
    
    private var datePicker :UIDatePicker = {
       return UIDatePicker()
    }()
    
    private var timePicker :UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
       return timePicker
    }()
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var setReminderBtn: UIButton!
    @IBOutlet weak var dateErrorText: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeErrorLabel: UILabel!
    @IBOutlet weak var noteErrorLabel: UILabel!
    
    let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var stackView : UIStackView? = nil
    var reminderDateComponent = DateComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setReminderNavigationBar()
        setReminderTextField()
    }
    
    func setReminderNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Add A Reminder", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        stackView = UIStackView(arrangedSubviews: [spaceBtn,leftBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
    }
    
    func setReminderTextField()  {
        reminderTextField.tag = 1
        timeTextField.tag = 2
        
        reminderTextField.addPaddingToTextField(height: 10, Width: 10)
        reminderTextField.layer.cornerRadius = 7.0
        reminderTextField.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        reminderTextField.addTarget(self, action: #selector(reminderFieldsRequiredValidation), for: .editingChanged)
        
        timeTextField.addPaddingToTextField(height: 10, Width: 10)
        timeTextField.layer.cornerRadius = 7.0
        timeTextField.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        timeTextField.addTarget(self, action: #selector(reminderFieldsRequiredValidation), for: .editingChanged)
        
        noteTextView.layer.cornerRadius = 7.0
        noteTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        noteTextView.addPaddingToTextField()
        noteTextView.delegate = self
        
        setReminderBtn.layer.cornerRadius = 7.0
        setReminderBtn.addTarget(self, action: #selector(addReminder), for: .touchUpInside)
    }
    
    @objc func menuChange() { self.navigationController?.popViewController(animated: true) }
    
    @objc func addReminder() {
        [reminderTextField,timeTextField].forEach{
             reminderFieldsRequiredValidation($0)
        }
        
        ValidationManager.shared.requiredValidation(textView: self.noteTextView, errorLabel: self.noteErrorLabel, errorMessage: "Empty.")
       
        if ValidationManager.shared.isReminderFieldsValidated(textFieldArray: [reminderTextField,timeTextField], textView: noteTextView) {
            let content = UNMutableNotificationContent()
            content.title = "Sky-Gym"
            content.subtitle = "Workout reminder"
            content.body = "Your today's workout is coming.\(noteTextView.text!)"
            content.categoryIdentifier = "local"
            
            guard let imageURL = URL.localURLForXCAsset(name: "logo", ext: "png") else {
                print("no image found.")
                return
            }
            
            let attachment = try! UNNotificationAttachment(identifier: "image", url: imageURL, options: [:])
            content.attachments = [attachment]
            
           //
            //UNCalendarNotificationTrigger(dateMatching: , repeats: false)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8, repeats: false)
            let request = UNNotificationRequest(identifier: "workoutReminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: {
                err in
                if err == nil {
                    print("Success in reminder")
                }else {
                    print("Failure")
                }
            })
        }
    }
    
    @objc func reminderFieldsRequiredValidation( _ textField:UITextField)  {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.dateErrorText, errorMessage: "Reminder date required.")
        case 2:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.timeErrorLabel, errorMessage: "Reminder time required.")
        default:
            break
        }
        
        ValidationManager.shared.updateBtnValidator(updateBtn: self.setReminderBtn, textFieldArray: [reminderTextField,timeTextField], textView: nil, phoneNumberTextField: nil, email: nil, password: nil)
        
    }
}

extension AddReminderViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            textField.inputView = self.datePicker
        }else {
            textField.inputView = self.timePicker
        }
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            //let d = Calendar.current.dateComponents([.calendar,.day,.era,.timeZone,.weekday,.year], from: <#T##Date#>)
          textField.text = AppManager.shared.dateWithMonthName(date: self.datePicker.date)
        }else {
            textField.text = AppManager.shared.getTimeFrom(date: self.timePicker.date)
        }
        reminderFieldsRequiredValidation(textField)
    }
    
}


extension AddReminderViewController : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.noteErrorLabel, errorMessage:      "Empty.")
    }
}
