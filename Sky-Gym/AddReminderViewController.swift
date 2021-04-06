//
//  AddReminderViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 02/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class ReminderWeekdaysTableCell: UITableViewCell {
    @IBOutlet weak var checkBoxImgView: UIImageView!
    @IBOutlet weak var weekdaysNameLabel: UILabel!
    //reminderWeekdayCell
}

class AddReminderViewController: UIViewController {
    
    private var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return leftBtn
    }()
    
    private var timePicker :UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
       return timePicker
    }()
    
    private var notificationCenter :UNUserNotificationCenter = {
        return UNUserNotificationCenter.current()
    }()
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var setReminderBtn: UIButton!
    @IBOutlet weak var dateErrorText: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeErrorLabel: UILabel!
    @IBOutlet weak var noteErrorLabel: UILabel!
    @IBOutlet weak var repeatImgView: UIImageView!
    @IBOutlet weak var weekdaysView: UIView!
    @IBOutlet weak var weekdaysTable: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var showWeekDaysListBtn: UIButton!
    @IBOutlet weak var repeatLabel: UILabel!
    
    let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var stackView : UIStackView? = nil
    var repeatReminder:Bool = false
    var weekDaysArray:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thrusday","Friday","Saturday"]
    var selectedWeekDaysIndexes:[Int] = []
    var reminderTime:String = ""
    var reminderImgURL:URL? = nil
    var workoutID:String = ""
    var workoutName:String = ""
    var notificationIdentifiers:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setReminderUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.fetchUserNotifications()
        }
    }
    
    func setReminderUI() {
         SVProgressHUD.show()
        setReminderNavigationBar()
        setReminderTextField()
        
        self.weekdaysTable.delegate = self
        self.weekdaysTable.dataSource = self
        
        self.reminderTextField.isEnabled = false
        self.showWeekDaysListBtn.addTarget(self, action: #selector(showWeekdaysList), for: .touchUpInside)
        self.doneBtn.addTarget(self, action: #selector(doneWeekBtnAction), for: .touchUpInside)
        
        self.repeatLabel.isUserInteractionEnabled = true
        self.repeatImgView.isUserInteractionEnabled = true
        
        self.repeatImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleRepeat)))
        self.repeatLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleRepeat)))
//        notificationCenter.removeAllDeliveredNotifications()
//        notificationCenter.removeAllPendingNotificationRequests()

    }
    
    func fetchUserNotifications() {
        var note = ""
        var time = ""
        var  reminderRepeat = false
        self.selectedWeekDaysIndexes.removeAll()
        self.notificationIdentifiers.removeAll()
        notificationCenter.getPendingNotificationRequests(completionHandler: {
            notificationArray in
            
            for (i,notification) in notificationArray.enumerated() {
                let userReminder = notification.content
                let userReminderInfo = userReminder.userInfo
                let reminderWorkoutID = (userReminderInfo["workoutID"] ?? "0") as! String
                if reminderWorkoutID  == self.workoutID {
                    self.selectedWeekDaysIndexes.append((userReminderInfo["weekDay"] as! Int) - 1 )
                    self.notificationIdentifiers.append(notification.identifier)
                }
                if i == notificationArray.firstIndex(of: notificationArray.last!) {
                    note = userReminderInfo["note"] as! String
                    time  = self.convert12HrTimeZone(time: "\(userReminderInfo["hour"]!):\(userReminderInfo["min"]!)")
                    reminderRepeat = notification.trigger!.repeats
                }
            }
            
            self.notificationCenter.getDeliveredNotifications(completionHandler: {
                (notificationArray) in
                
                for (index,notification) in notificationArray.enumerated() {
                    let userReminder = notification.request.content
                    let userReminderInfo = userReminder.userInfo
                    let reminderWorkoutID = (userReminderInfo["workoutID"] ?? "0") as! String
                    if reminderWorkoutID  == self.workoutID {
                        if self.selectedWeekDaysIndexes.contains((userReminderInfo["weekDay"] as! Int) - 1) == false {
                            self.selectedWeekDaysIndexes.append((userReminderInfo["weekDay"] as! Int) - 1 )
                        }
                        if self.notificationIdentifiers.contains(notification.request.identifier) == false {
                            self.notificationIdentifiers.append(notification.request.identifier)
                        }
                    }
                    
                    if index == notificationArray.firstIndex(of: notificationArray.last!) {
                        note = userReminderInfo["note"] as! String
                        time  = self.convert12HrTimeZone(time: "\(userReminderInfo["hour"]!):\(userReminderInfo["min"]!)")
                        reminderRepeat = notification.request.trigger!.repeats
                    }
                }
                
                DispatchQueue.main.async {
                    if self.notificationIdentifiers.count > 0 {
                        print("IDENTIFIERS ARRAY : \(self.notificationIdentifiers)")
                        self.weekdaysTable.reloadData()
                        self.setValuesToWeekdaysTextField()
                        self.noteTextView.text = note
                        self.reminderTime = time
                        self.timeTextField.text = time
                        self.repeatImgView.image = UIImage(named: reminderRepeat == true ? "checked-checkbox": "unchecked-checkbox")
                        SVProgressHUD.dismiss()
                    }else {
                       SVProgressHUD.dismiss()
                    }
                }
            })
            
        })
    }
    
    
    func convert12HrTimeZone(time:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var time = dateFormatter.date(from: time)!
        time = Calendar.current.date(byAdding: .minute, value: 5, to: time, wrappingComponents: false)!
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
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
        navigationItem.hidesBackButton = true
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
        
        self.repeatImgView.image = UIImage(named: "unchecked-checkbox") 
    }
    
    @objc func menuChange() { self.navigationController?.popViewController(animated: true) }
    
    @objc func toggleRepeat() {
        repeatReminder = !repeatReminder
        repeatImgView.image = UIImage(named:  repeatReminder == true ? "checked-checkbox": "unchecked-checkbox")
    }
    
     @objc func showWeekdaysList() {
        weekdaysView.isHidden = false
        weekdaysView.alpha = 1.0
        navigationItem.leftBarButtonItem = nil
    }
    
     @objc func doneWeekBtnAction() {
        weekdaysView.isHidden = true
        weekdaysView.alpha =  0.0
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        setValuesToWeekdaysTextField()
    }
    
    @objc  func addReminder() {
        [reminderTextField,timeTextField].forEach{
            reminderFieldsRequiredValidation($0)
        }
        
        ValidationManager.shared.requiredValidation(textView: self.noteTextView, errorLabel: self.noteErrorLabel, errorMessage: "Empty.")
        
        if ValidationManager.shared.isReminderFieldsValidated(textFieldArray: [reminderTextField,timeTextField], textView: noteTextView) {
            addNewReminder()
        }
    }
    
    func addNewReminder() {
        var removingNotificationArray:[String] = []
        for singleIdentifier in self.notificationIdentifiers {
            let lastValueOfIdentifier = (String(singleIdentifier.last!) as NSString ).integerValue
            if self.selectedWeekDaysIndexes.contains(lastValueOfIdentifier - 1 ) == false {
                removingNotificationArray.append(singleIdentifier)
            }
        }
        
        if removingNotificationArray.count > 0 {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: removingNotificationArray)
            notificationCenter.removeDeliveredNotifications(withIdentifiers: removingNotificationArray)
        }

        let content = UNMutableNotificationContent()
        content.title = "Sky-Gym"
        content.subtitle = "Reminder For \(self.workoutName)"
        content.body = "Your today's workout will start after 5 min. Note:  \(noteTextView.text!)"
        content.categoryIdentifier = "local"
        
        for singleValue in self.selectedWeekDaysIndexes {
            var reminderDateComponent = DateComponents()
            reminderDateComponent.weekday = singleValue + 1
            reminderDateComponent.hour = (reminderTime.split(separator: ":").first! as NSString).integerValue
            reminderDateComponent.minute = (reminderTime.split(separator: ":").last! as NSString).integerValue
            
            content.userInfo = [
                "workoutID": self.workoutID,
                "weekDay": singleValue + 1,
                "hour" : reminderDateComponent.hour!,
                "min" : reminderDateComponent.minute!,
                "note" : noteTextView.text!
            ]
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: reminderDateComponent, repeats: repeatReminder)
            let request = UNNotificationRequest(identifier: "\(workoutID)/\(singleValue + 1)", content: content, trigger: trigger)
            
            print(" REQUEST IS : \(request)")
            
            notificationCenter.add(request, withCompletionHandler: {
                err in
                if err == nil {
                    self.showReminderAlert(title: "Success", msg: "Reminder is added successfully.")
                }else {
                    self.showReminderAlert(title: "Error", msg: "Something went wrong , please try again.")
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
    
    func showReminderAlert(title:String,msg:String) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            if title == "Success" {
                self.navigationController?.popViewController(animated: true)
            }
        })
        
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func setValuesToWeekdaysTextField() {
        reminderTextField.text = ""
        selectedWeekDaysIndexes = selectedWeekDaysIndexes.sorted()
        var str = ""
        for singleValue in selectedWeekDaysIndexes {
            str += "\(weekDaysArray[singleValue]) "
        }
        reminderTextField.text = str
    }
    
}

extension AddReminderViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputView = timePicker
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let fiveMinEarlyReminderTime = Calendar.current.date(byAdding: .minute, value: -5, to: self.timePicker.date, wrappingComponents: false)
        reminderTime = dateFormatter.string(from: fiveMinEarlyReminderTime!)
        print("Date Format : \(reminderTime)")
        textField.text = AppManager.shared.getTimeFrom(date: self.timePicker.date)
        reminderFieldsRequiredValidation(textField)
    }
}

extension AddReminderViewController : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.noteErrorLabel, errorMessage:      "Empty.")
    }
}

extension AddReminderViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weekDaysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderWeekdayCell", for: indexPath) as! ReminderWeekdaysTableCell
        
        if self.selectedWeekDaysIndexes.contains(indexPath.row) {
            cell.checkBoxImgView.image = UIImage(named: "checked-checkbox")
        }else {
             cell.checkBoxImgView.image = UIImage(named: "unchecked-checkbox")
        }

        cell.weekdaysNameLabel.text = self.weekDaysArray[indexPath.row]
        
        return cell
    }
}

extension AddReminderViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedWeekDaysIndexes.contains(indexPath.row) {
            selectedWeekDaysIndexes.remove(at: selectedWeekDaysIndexes.firstIndex(of: indexPath.row)!)
        } else {
            selectedWeekDaysIndexes.append(indexPath.row)
        }
        
        tableView.reloadData()
    }
    
}

