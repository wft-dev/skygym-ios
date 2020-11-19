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
    
    var isNewEvent:Bool = false
    var eventID:String = ""
    var isEdit:Bool = false
    var forNonEditLabelArray:[UILabel]? = nil
    var defaultLabelArray:[UILabel]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewEventNavigationBar()
        self.setTextFields()
        setBackAction(toView: self.viewEventNavigationBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.forNonEditLabelArray = [self.addressForNonEditLabel,self.eventDateForNonEditLabel,self.eventEndTimeForNontEditLabel,self.eventNameForNonEditLabel,self.eventStartTimeForNonEditLabel]
        self.defaultLabelArray = [self.eventName,self.eventDate,self.address,self.eventStartTime,self.eventEndTime]
        
        if self.isNewEvent == false {
            self.fetchEventBy(id: AppManager.shared.eventID)
            AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit:  false)
            self.setHrLineView(isHidden: false, alpha: 1.0)
            self.addressNonEditLabel.isHidden = false
            self.addressTextView.isHidden = true
            self.addressTextView.alpha = 0.0
            self.addressNonEditLabel.alpha = 1.0
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, flag: true)
            self.eventUpdateBtn.isEnabled = false
            self.eventUpdateBtn.alpha = 0.4
        }else {
             AppManager.shared.performEditAction(dataFields: self.getFieldsAndLabelDic(), edit:  true)
            AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, flag: false)
            self.setHrLineView(isHidden: true, alpha: 0.0)
            self.addressNonEditLabel.isHidden = true
            self.addressTextView.isHidden = false
            self.addressTextView.alpha = 1.0
            self.addressNonEditLabel.alpha = 0.0
        }
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        self.isNewEvent ?  self.addEvent() : self.updateEvent()
    }
}

extension ViewEventScreenViewController {

    func setViewEventNavigationBar() {
        self.viewEventNavigationBar.menuBtn.isHidden = true
        self.viewEventNavigationBar.leftArrowBtn.isHidden = false
        self.viewEventNavigationBar.leftArrowBtn.alpha = 1.0
        self.viewEventNavigationBar.navigationTitleLabel.text = "Events"
        self.viewEventNavigationBar.searchBtn.isHidden = true
        
        if self.isNewEvent == false {
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
                AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, flag: true)
                self.eventUpdateBtn.isEnabled = false
                self.eventUpdateBtn.alpha = 0.4
              } else{
                  AppManager.shared.performEditAction(dataFields:self.getFieldsAndLabelDic(), edit:  true)
                  self.isEdit = true
                  self.setHrLineView(isHidden: true, alpha: 0.0)
                 self.addressTextView.isHidden = false
                 self.addressTextView.alpha = 1.0
                 self.addressNonEditLabel.isHidden = true
                 self.addressNonEditLabel.alpha = 0.0
                AppManager.shared.setLabel(nonEditLabels: self.forNonEditLabelArray!, defaultLabels: self.defaultLabelArray!, flag: false)
                self.eventUpdateBtn.isEnabled = true
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
   
        FireStoreManager.shared.addEvent(id:UUID().uuidString, eventDetail: self.setEventDetails(), completion: {
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
    

