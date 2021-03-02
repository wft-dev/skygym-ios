//
//  MemberAttandanceViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 07/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class AttandanceTableCell: UITableViewCell {
    
    @IBOutlet weak var tableCellView: UIView!
    @IBOutlet weak var checkInTimeView: UIView!
    @IBOutlet weak var checkoutTimeView: UIView!
    @IBOutlet weak var weekdayNameLabel: UILabel!
    @IBOutlet weak var checkInTime: UILabel!
    @IBOutlet weak var checkOutTime: UILabel!
    @IBOutlet weak var attandanceImg: UIImageView!
}

class MemberAttandanceViewController: BaseViewController {
    
    @IBOutlet weak var memberAttandanceTable: UITableView!
   // @IBOutlet weak var memberAttandanceNavigationBar: CustomNavigationBar!
    @IBOutlet weak var checkByDateBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberAddressLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var attendenceTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var memberUserImg: UIImageView!
    @IBOutlet weak var noAttendenceHistoryLabel: UILabel!
    
    var attandanceArray:[Attendence?] = []
    var memberName:String = ""
    var memberAddress:String = ""
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    var attendenceTableHeight:CGFloat = 0
    var memberUserImgData:Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMemberAttandanceNavigation()
        self.checkByDateBtn.layer.cornerRadius =  15.0
        self.backBtn.layer.cornerRadius = 15.0
        self.memberAttandanceTable.separatorStyle = .none
        self.memberAttandanceTable.isScrollEnabled = false
        //setBackAction(toView: self.memberAttandanceNavigationBar)
        self.memberNameLabel.text = self.memberName
        self.memberAddressLabel.text = self.memberAddress
        self.checkByDateBtn.addTarget(self, action: #selector(checkByDateAction), for: .touchUpInside)
        self.startDateLabel.isUserInteractionEnabled = true
        self.endDateLabel.isUserInteractionEnabled = true
        self.startDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previousWeekAttendence)))
        self.endDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextWeekAttendence)))
        if memberUserImgData != nil {
            self.memberUserImg.image = UIImage(data: self.memberUserImgData!)
            self.memberUserImg.makeRounded()
        }
        self.backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        memberAttandanceTable.rowHeight = 66;
        memberAttandanceTable.estimatedRowHeight = 66;
        super.viewWillAppear(animated)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy"
        
        SVProgressHUD.show()
        FireStoreManager.shared.getAttendenceFrom(trainerORmember: "Members", id: AppManager.shared.memberID, startDate: "\(dateFormatter.string(from: Date()))", endDate: "\(AppManager.shared.getNext7DaysDate(startDate: Date()))"
            , s: {
               (array,flag)  in
                SVProgressHUD.dismiss()
                if array.count < 1 {
                    self.memberAttandanceTable.isHidden = true
                    self.memberAttandanceTable.alpha = 0.0
                    self.noAttendenceHistoryLabel.isHidden = false
                    self.noAttendenceHistoryLabel.alpha = 1.0
                    self.backBtn.isHidden = true
                    self.backBtn.alpha = 0.0
                } else {
                    self.memberAttandanceTable.isHidden = false
                    self.memberAttandanceTable.alpha = 1.0
                    self.noAttendenceHistoryLabel.isHidden = true
                    self.noAttendenceHistoryLabel.alpha = 0.0
                    self.backBtn.isHidden = false
                    self.backBtn.alpha = 1.0
                    self.attandanceArray = array
                    self.attendenceTableHeight = CGFloat((self.attandanceArray.count * 66))
                    self.startDateLabel.text = AppManager.shared.dateWithMonthNameWithNoDash(date: AppManager.shared.getDate(date: (array.first?.date)!))
                    self.endDateLabel.text = AppManager.shared.dateWithMonthNameWithNoDash(date: AppManager.shared.getDate(date: (array.last?.date)!))
                    self.memberAttandanceTable.alpha = 1.0
                    DispatchQueue.main.async {
                        self.attendenceTableHeightConstraint.constant = self.attendenceTableHeight
                        self.memberAttandanceTable.reloadData()
                    }
                }
        })
    }
   
    @IBAction func previousWeekAttendenceAction(_ sender: Any) {
        self.previousWeekAttendence()
    }

    @IBAction func forwardWeekAttendenceAction(_ sender: Any) {
        self.nextWeekAttendence()
    }
    @objc  func backBtnAction() {
        dismiss(animated: true, completion: nil)
    }

 @objc  func nextWeekAttendence() {
    let nextStartDateStr = AppManager.shared.getNextDayDate(startDate: AppManager.shared.getDate(date: self.startDateLabel.text!))
    let nextEndDateStr = AppManager.shared.getNextDayDate(startDate: AppManager.shared.getDate(date: self.endDateLabel.text!))
        self.fetchAttendenceFrom(startDate: nextStartDateStr, endDate: nextEndDateStr)
        self.startDateLabel.text = nextStartDateStr
        self.endDateLabel.text = nextEndDateStr
    }
    
  @objc  func previousWeekAttendence() {
    let previousStartDate = AppManager.shared.getPreviousDayDate(startDate: AppManager.shared.getDate(date: self.startDateLabel.text!))
    let previousEndDate = AppManager.shared.getPreviousDayDate(startDate: AppManager.shared.getDate(date: self.endDateLabel.text!))
        
        self.fetchAttendenceFrom(startDate: previousStartDate, endDate:previousEndDate)
        self.startDateLabel.text = previousStartDate
        self.endDateLabel.text = previousEndDate
    }

    func setMemberAttandanceNavigation()  {
//        memberAttandanceNavigationBar.menuBtn.isHidden = true
//        memberAttandanceNavigationBar.leftArrowBtn.isHidden = false
//        memberAttandanceNavigationBar.leftArrowBtn.alpha = 1.0
//        memberAttandanceNavigationBar.navigationTitleLabel.text = "Attendance"
//        memberAttandanceNavigationBar.searchBtn.isHidden = true
        
        let title = NSAttributedString(string: "Attendence", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(memberAttendenceBackBtnAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,backButton])
        stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let backBtn = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc func  memberAttendenceBackBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc  func checkByDateAction() {
        datePicker = UIDatePicker.init()
        datePicker.backgroundColor = UIColor.white
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 250)
        self.view.addSubview(datePicker)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.onCancelButtonClick)),UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneButtonClick))]
        toolBar.sizeToFit()
        self.view.addSubview(toolBar)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "d MMM yyyy"
        if let date = sender?.date {
            self.startDateLabel.text = "\(dateFormatter.string(from: date))"
            self.endDateLabel.text = "\(AppManager.shared.getNext7DaysDate(startDate: date))"
        }
    }

    @objc func onDoneButtonClick() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "d MMM yyyy"
        self.startDateLabel.text = "\(dateFormatter.string(from: self.datePicker.date))"
        self.endDateLabel.text = "\(AppManager.shared.getNext7DaysDate(startDate: self.datePicker.date))"
        self.toolBar.removeFromSuperview()
        self.datePicker.removeFromSuperview()
        fetchAttendenceFrom(startDate: self.startDateLabel.text!, endDate: self.endDateLabel.text!)
    }
    
    @objc func onCancelButtonClick() {
        self.toolBar.removeFromSuperview()
        self.datePicker.removeFromSuperview()
    }
    
    func fetchAttendenceFrom(startDate:String,endDate:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getAttendenceFrom(trainerORmember: "Members", id: AppManager.shared.memberID, startDate:startDate, endDate:endDate, s: {
            (attendenceArray,_)  in
            
            self.attandanceArray.removeAll()
            if attendenceArray.count > 0 {
                self.attandanceArray = attendenceArray
                self.attendenceTableHeight = CGFloat((self.attandanceArray.count * 66))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
                     SVProgressHUD.dismiss()
                    self.attendenceTableHeightConstraint.constant = self.attendenceTableHeight
                    self.memberAttandanceTable.reloadData()
                })
                self.memberAttandanceTable.isHidden = false
                self.memberAttandanceTable.alpha = 1.0
                self.noAttendenceHistoryLabel.isHidden = true
                self.noAttendenceHistoryLabel.alpha = 0.0
                self.backBtn.isHidden = false
                self.backBtn.alpha = 1.0
            } else {
                SVProgressHUD.dismiss()
                self.memberAttandanceTable.isHidden = true
                self.memberAttandanceTable.alpha = 0.0
                self.noAttendenceHistoryLabel.isHidden = false
                self.noAttendenceHistoryLabel.alpha = 1.0
                self.backBtn.isHidden = true
                self.backBtn.alpha = 0.0
            }
        })
    }
}

extension MemberAttandanceViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attandanceArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendanceCell", for: indexPath) as! AttandanceTableCell
        let singleAttendenceStatus = self.attandanceArray[indexPath.row]
        self.setAttandanceTableCellView(tableCellView: cell.tableCellView)
        cell.checkInTimeView.layer.cornerRadius = 12.0
        cell.checkoutTimeView.layer.cornerRadius = 12.0
        cell.selectionStyle = .none
        cell.weekdayNameLabel.text = AppManager.shared.getTodayWeekDay(date: singleAttendenceStatus?.date ?? "")

        if singleAttendenceStatus?.present == false {
            cell.attandanceImg.image = UIImage(named: "red")
            cell.checkOutTime.text = "-"
            cell.checkInTime.text = "-"
        } else {
            cell.attandanceImg.image = UIImage(named: "green")
            cell.checkInTime.text = singleAttendenceStatus?.checkIn
            cell.checkOutTime.text = singleAttendenceStatus?.checkOut
        }
        return cell
    }
}
