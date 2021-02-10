//
//  ViewEventScreenViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 12/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class ViewEventScreenViewController: BaseViewController {
    
    @IBOutlet weak var viewEventNavigationBar: CustomNavigationBar!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var eventStartTimeTextField: UITextField!
    @IBOutlet weak var eventEndTimeTextField: UITextField!
    @IBOutlet weak var eventUpdateBtn: UIButton!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventNameNonEditLabel: UILabel!
    @IBOutlet weak var eventNameHrLineView: UIView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventDateNonEditLabel: UILabel!
    @IBOutlet weak var eventDateHrLineView: UIView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressNonEditLabel: UILabel!
    @IBOutlet weak var addressHrLineView: UIView!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventStartTimeNonEditLabel: UILabel!
    @IBOutlet weak var eventEndTime: UILabel!
    @IBOutlet weak var eventEndTimeNonEditLabel: UILabel!
    @IBOutlet weak var eventHrLineView: UIView!
    @IBOutlet weak var eventNameForNonEditLabel: UILabel!
    @IBOutlet weak var eventDateForNonEditLabel: UILabel!
    @IBOutlet weak var addressForNonEditLabel: UILabel!
    @IBOutlet weak var eventStartTimeForNonEditLabel: UILabel!
    @IBOutlet weak var eventEndTimeForNontEditLabel: UILabel!
    @IBOutlet weak var eventNameErrorTextLabel: UILabel!
    @IBOutlet weak var eventDateErrorTextLabel: UILabel!
    @IBOutlet weak var eventAddressErrorTextLabel: UILabel!
    @IBOutlet weak var eventStarTimeErrorTextLabel: UILabel!
    @IBOutlet weak var eventEndTimeErrorTextLabel: UILabel!
    
    var isNewEvent:Bool = false
    var eventID:String = ""
    var isEdit:Bool = false
    var forNonEditLabelArray:[UILabel]? = nil
    var defaultLabelArray:[UILabel]? = nil
    var errorLabelArray:[UILabel]? = nil
    var textFieldsArray:[UITextField]? = nil
    var datePicker = UIDatePicker()
    var timePicker = UIDatePicker()
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    var selectedTime:String = ""
    var selectedDate:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewEventNavigationBar()
        self.setTextFields()
        setBackAction(toView: self.viewEventNavigationBar)
        self.eventUpdateBtn.isHidden = true
         }
    
    @objc func checkValidation(_ textField:UITextField) {
        self.allFieldsRequiredValidation(textField: textField, duplicateError: nil)
   //     validation.updateBtnValidator(updateBtn: self.eventUpdateBtn, textFieldArray: self.textFieldsArray!, textView: self.addressTextView, phoneNumberTextField: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initialEventSetup()
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        self.eventValidation()
        if ValidationManager.shared.isEventFieldsValidated(textFieldArray: self.textFieldsArray!, textView: self.addressTextView) == true {
            self.isNewEvent ?  self.addEvent() : self.updateEvent()
        }
    }
    
    func eventValidation()  {
        for textField in self.textFieldsArray! {
            self.allFieldsRequiredValidation(textField: textField, duplicateError: nil)
        }
        ValidationManager.shared.requiredValidation(textView: self.addressTextView, errorLabel: self.eventAddressErrorTextLabel, errorMessage: "Event address require.")
    }

    func initialEventSetup() {
        self.forNonEditLabelArray = [self.addressForNonEditLabel,self.eventDateForNonEditLabel,self.eventEndTimeForNontEditLabel,self.eventNameForNonEditLabel,self.eventStartTimeForNonEditLabel]
        self.defaultLabelArray = [self.eventName,self.eventDate,self.address,self.eventStartTime,self.eventEndTime]
        
        self.errorLabelArray = [self.eventNameErrorTextLabel,self.eventDateErrorTextLabel,self.eventAddressErrorTextLabel,self.eventStarTimeErrorTextLabel,self.eventEndTimeErrorTextLabel]
        
        self.textFieldsArray = [self.eventNameTextField,self.eventDateTextField,self.eventStartTimeTextField,self.eventEndTimeTextField]
        
        if self.isNewEvent == false {
            self.fetchEventBy(id: AppManager.shared.eventID)
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit:  false)
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.addressNonEditLabel.isHidden = false
            self.addressTextView.isHidden = true
            self.addressTextView.alpha = 0.0
            self.addressNonEditLabel.alpha = 1.0
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!,errorLabels:self.errorLabelArray!, flag: true)
                self.eventUpdateBtn.isHidden = true
            self.eventUpdateBtn.setTitle("U P D A T E", for: .normal)
        }else {
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit:  true)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!,errorLabels:self.errorLabelArray!, flag: false)
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.addressNonEditLabel.isHidden = true
            self.addressTextView.isHidden = false
            self.addressTextView.alpha = 1.0
            self.addressNonEditLabel.alpha = 0.0
            self.eventUpdateBtn.isHidden = false
            self.eventUpdateBtn.alpha = 1.0
            self.eventUpdateBtn.setTitle("A D D", for: .normal)
        }
        
        self.timePicker.datePickerMode = .time
        self.datePicker.datePickerMode = .date
        toolBar.barStyle = .default
        let cancelToolBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let okToolBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTextField))
        toolBar.items = [cancelToolBarItem,space,okToolBarItem]
        toolBar.sizeToFit()
    }
    
    @objc func cancelTextField()  {
        self.view.endEditing(true)
        }
     
     @objc func doneTextField()  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        self.selectedTime = dateFormatter.string(from: timePicker.date)
        dateFormatter.dateFormat = "dd-MMM-YYYY"
        self.selectedDate = dateFormatter.string(from:datePicker.date )
        self.view.endEditing(true)
      }
    
    func allFieldsRequiredValidation(textField:UITextField,duplicateError:String?)  {
        switch textField.tag {
        case 1:
            ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.eventNameErrorTextLabel, errorMessage: "Event name required.")
        case 2:
         ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.eventDateErrorTextLabel, errorMessage: "Event date required.")
        case 3:
        ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.eventStarTimeErrorTextLabel, errorMessage: "Event start time required.")
        case 4:
          ValidationManager.shared.requiredValidation(textField: textField, errorLabel: self.eventEndTimeErrorTextLabel, errorMessage: (duplicateError != nil ? duplicateError : "Event end time required.")! )
        default:
            break
        }
    }
    
    func setViewEventNavigationBar() {
        self.viewEventNavigationBar.menuBtn.isHidden = true
        self.viewEventNavigationBar.leftArrowBtn.isHidden = false
        self.viewEventNavigationBar.leftArrowBtn.alpha = 1.0
        self.viewEventNavigationBar.navigationTitleLabel.text = "Events"
        self.viewEventNavigationBar.searchBtn.isHidden = true
        
        switch AppManager.shared.loggedInRole {
        case .Trainer:
           let flag = AppManager.shared.trainerEventPermission == false || self.isNewEvent == true ? true : false
           self.hideEditBtn(hide: flag)
            break
        case .Admin :
            self.hideEditBtn(hide: self.isNewEvent)
        default:
            break
        }
    }
    
    func hideEditBtn(hide:Bool) {
        if hide == true {
            self.viewEventNavigationBar.editBtn.isHidden = true
            self.viewEventNavigationBar.editBtn.alpha = 0.0
        }else {
            self.viewEventNavigationBar.editBtn.isHidden = false
            self.viewEventNavigationBar.editBtn.alpha = 1.0
            self.viewEventNavigationBar.editBtn.addTarget(self, action: #selector(editEvent), for: .touchUpInside)
        }
    }
    
    @objc func editEvent() {
             if self.isEdit == true {
                  AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  false)
                 self.isEdit = false
                 self.setHrLineView(isHidden: false, alpha: 1.0)
                 self.addressTextView.isHidden = true
                 self.addressTextView.alpha = 0.0
                 self.addressNonEditLabel.isHidden = false
                 self.addressNonEditLabel.alpha = 1.0
                AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!,errorLabels:self.errorLabelArray!,flag: true)
                self.eventUpdateBtn.isHidden = true
              } else{
                  AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
                 self.isEdit = true
                 self.setHrLineView(isHidden: true, alpha: 0.0)
                 self.addressTextView.isHidden = false
                 self.addressTextView.alpha = 1.0
                 self.addressNonEditLabel.isHidden = true
                 self.addressNonEditLabel.alpha = 0.0
                AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels:
                    self.defaultLabelArray!,errorLabels:self.errorLabelArray!, flag: false)
                self.eventUpdateBtn.isHidden = false
                self.eventUpdateBtn.alpha = 1.0
              }
         }

    func getFieldsAndLabelDic() -> [UITextField:UILabel] {
        let dir = [
            self.eventNameTextField! : self.eventNameNonEditLabel!,
            self.eventDateTextField! : self.eventDateNonEditLabel!,
            self.eventStartTimeTextField! : self.eventStartTimeNonEditLabel!,
            self.eventEndTimeTextField! : self.eventEndTimeNonEditLabel!
        ]
        return dir
    }
          
    func setHrLineView(isHidden:Bool,alpha:CGFloat) {
        [self.eventNameHrLineView,self.eventHrLineView,self.addressHrLineView,self.eventDateHrLineView].forEach{
            $0?.isHidden = isHidden
            $0?.alpha = alpha
        }
    }
    
    func setTextFields() {
        [self.eventNameTextField,self.eventDateTextField,self.eventStartTimeTextField,self.eventEndTimeTextField ].forEach{
            self.addPaddingToTextField(textField: $0!)
            $0?.layer.cornerRadius = 7.0
            $0?.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
            $0?.clipsToBounds = true
            $0?.addTarget(self, action: #selector(checkValidation(_:)), for: .editingChanged)
        }
        self.addressTextView.addPaddingToTextView(top: 0, right: 10, bottom: 0, left: 10)
        self.addressTextView.layer.cornerRadius = 7.0
        self.addressTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        self.addressTextView.clipsToBounds = true
        
        self.eventUpdateBtn.layer.cornerRadius = 15.0
        self.eventUpdateBtn.layer.borderColor = UIColor.black.cgColor
        self.eventUpdateBtn.layer.borderWidth = 0.7
        self.eventUpdateBtn.clipsToBounds = true
    }
        
    func addPaddingToTextField(textField:UITextField) {
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black
    }
    
    func setEventDetails() -> [String:Any] {
        let event = [
            "eventName":self.eventNameTextField.text!,
            "eventDate":self.eventDateTextField.text!,
            "eventAddress":self.addressTextView.text!,
            "eventStartTime":self.eventStartTimeTextField.text!,
            "eventEndTime": self.eventEndTimeTextField.text!
            ] as [String : Any]
        return event
    }
    
    func addEvent() {
        SVProgressHUD.show()
   
        FireStoreManager.shared.addEvent(id:"\(Int.random(in: 1..<1000000))", eventDetail: self.setEventDetails(), completion: {
            err in
            SVProgressHUD.dismiss()
            if err != nil {
                self.showEventAlert(title: "Error", message: "Error in adding event.")
            }else {
                self.showEventAlert(title: "Success", message: "Event is added successfully.")
            }
        })
    }
    
    func updateEvent() {
        FireStoreManager.shared.addEvent(id:eventID , eventDetail: self.setEventDetails(), completion: {
            err in
            SVProgressHUD.dismiss()
            if err != nil {
                self.showEventAlert(title: "Error", message: "Error in updating event.")
            }else {
                self.showEventAlert(title: "Success", message: "Event is updated successfully.")
            }
        })
    }
    
    func fetchEventBy(id:String) {
        FireStoreManager.shared.getEventBy(id: id, result: {
            (data,err)in
            
            if err != nil {
                self.showEventAlert(title: "Error", message: "Error in fetching the selected event details.")
            }else {
                let eventData = data?["eventDetail"] as! [String:Any]
                self.setEventFields(event: AppManager.shared.getEvent(id:AppManager.shared.eventID,adminID: AppManager.shared.adminID,eventDetail: eventData))
            }
        })
    }
    
    func showEventAlert(title:String,message:String) {
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
    
    func setEventFields(event:Event) {
        self.eventNameNonEditLabel.text = event.eventName
        self.eventDateNonEditLabel.text = event.eventDate
        self.addressNonEditLabel.text = event.eventAddress
        self.eventStartTimeNonEditLabel.text = event.eventStartTime
        self.eventEndTimeNonEditLabel.text = event.eventEndTime

        self.eventNameTextField.text = event.eventName
        self.eventDateTextField.text = event.eventDate
        self.addressTextView.text = event.eventAddress
        self.eventStartTimeTextField.text = event.eventStartTime
        self.eventEndTimeTextField.text = event.eventEndTime
    }
    }
    
extension ViewEventScreenViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 3:
            textField.inputView = self.timePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "h:mm a"
                self.timePicker.date = df.date(from: textField.text!)!
            }

        case 4:
            textField.inputView = self.timePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "h:mm a"
                self.timePicker.date = df.date(from: textField.text!)!
            }
        case 2 :
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.toolBar
            if textField.text!.count > 0  {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                self.datePicker.date = df.date(from: textField.text!)!
            }
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField.tag == 3 || textField.tag == 4 {
            return false
        } else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var duplicateError:String? = nil
        if self.selectedTime.count > 1 {
            switch textField.tag {
            case 2 :
                self.eventDateTextField.text = self.selectedDate
                self.selectedTime = ""
                
            case 3:
                self.eventStartTimeTextField.text = self.selectedTime
                self.selectedTime = ""
                
            case 4:
                if ValidationManager.shared.isDuplicate(text1: self.eventStartTimeTextField.text!, text2: self.selectedTime) == false{
                    self.eventEndTimeTextField.text = self.selectedTime
                    self.selectedTime = ""
                } else {
                    self.eventEndTimeTextField.text = ""
                    duplicateError = "Start time and end time can not be same."
                     self.selectedTime = ""
                }
                
            default:
                break
            }
        }

        self.allFieldsRequiredValidation(textField: textField, duplicateError: duplicateError)
         ValidationManager.shared.updateBtnValidator(updateBtn: self.eventUpdateBtn, textFieldArray: self.textFieldsArray!, textView: self.addressTextView, phoneNumberTextField: nil,email: nil,password: nil)
    }
}

extension ViewEventScreenViewController:UITextViewDelegate{

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.eventAddressErrorTextLabel, errorMessage: "Event address required.")
       ValidationManager.shared.updateBtnValidator(updateBtn: self.eventUpdateBtn, textFieldArray: self.textFieldsArray!, textView: self.addressTextView, phoneNumberTextField: nil,email: nil,password: nil)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        ValidationManager.shared.requiredValidation(textView: textView, errorLabel: self.eventAddressErrorTextLabel, errorMessage: "Event address required.")
    }
    
}
