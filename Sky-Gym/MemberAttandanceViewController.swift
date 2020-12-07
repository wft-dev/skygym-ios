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
    @IBOutlet weak var memberAttandanceNavigationBar: CustomNavigationBar!
    @IBOutlet weak var checkByDateBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberAddressLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var attandanceArray:[Attendence] = []
    var memberName:String = ""
    var memberAddress:String = ""
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMemberAttandanceNavigation()
        self.checkByDateBtn.layer.cornerRadius =  15.0
        self.backBtn.layer.cornerRadius = 15.0
        self.memberAttandanceTable.separatorStyle = .none
        self.memberAttandanceTable.isScrollEnabled = false
        setBackAction(toView: self.memberAttandanceNavigationBar)
        self.memberNameLabel.text = self.memberName
        self.memberAddressLabel.text = self.memberAddress
        self.checkByDateBtn.addTarget(self, action: #selector(checkByDateAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy"
        
        FireStoreManager.shared.getAttendenceFrom(trainerORmember: "Members", id: AppManager.shared.memberID, startDate: "\(dateFormatter.string(from: Date()))", endDate: "\(AppManager.shared.getNext7DaysDate(startDate: Date()))"
            , result: {
                array in
                // self.attandanceArray.removeAll()
                if array != nil {
                    self.attandanceArray = array!
                    self.startDateLabel.text = AppManager.shared.dateWithMonthNameWithNoDash(date: AppManager.shared.getDate(date: (array?.first!.date)!))
                    self.endDateLabel.text = AppManager.shared.dateWithMonthNameWithNoDash(date: AppManager.shared.getDate(date: (array?.last!.date)!))
                    self.memberAttandanceTable.reloadData()
                    self.memberAttandanceTable.alpha = 1.0
                } else {
                    print("ATTENDENCE NOT FOUND.")
                }
        })
    }
}

extension MemberAttandanceViewController {
    func setMemberAttandanceNavigation()  {
        memberAttandanceNavigationBar.menuBtn.isHidden = true
        memberAttandanceNavigationBar.leftArrowBtn.isHidden = false
        memberAttandanceNavigationBar.leftArrowBtn.alpha = 1.0
        memberAttandanceNavigationBar.navigationTitleLabel.text = "Attendance"
        memberAttandanceNavigationBar.searchBtn.isHidden = true
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
        FireStoreManager.shared.getAttendenceFrom(trainerORmember: "Members", id: AppManager.shared.memberID, startDate:startDate, endDate:endDate, result: {
            (attendenceArray) in
            self.attandanceArray.removeAll()
            self.attandanceArray = attendenceArray ?? []
            self.memberAttandanceTable.reloadData()
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
        cell.weekdayNameLabel.text = AppManager.shared.getTodayWeekDay(date: singleAttendenceStatus.date)

        if singleAttendenceStatus.present == false {
            cell.attandanceImg.image = UIImage(named: "red")
            cell.checkOutTime.text = "-"
            cell.checkInTime.text = "-"
        } else {
            cell.attandanceImg.image = UIImage(named: "green")
            cell.checkInTime.text = singleAttendenceStatus.checkIn
            cell.checkOutTime.text = singleAttendenceStatus.checkOut
        }
        return cell
    }
}
