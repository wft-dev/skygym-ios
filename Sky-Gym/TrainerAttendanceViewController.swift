//
//  TrainerAttendanceViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 09/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit

class TrainerAttendanceTableCell: UITableViewCell {
    @IBOutlet weak var attendanceImg: UIImageView!
    @IBOutlet weak var trainerAttendanceCellView: UIView!
    @IBOutlet weak var checkInTimeView: UIView!
    @IBOutlet weak var checkOutTimeView: UIView!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var checkInTimeLabel: UILabel!
    @IBOutlet weak var checkOutTimeLabel: UILabel!
}

class TrainerAttendanceViewController: BaseViewController {
    @IBOutlet weak var trainerAttendanceTable: UITableView!
    @IBOutlet weak var trainerNavigationBar: CustomNavigationBar!
    @IBOutlet weak var checkByDateBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var trainerNameLabel: UILabel!
    @IBOutlet weak var trainerAddressLabel: UILabel!
    @IBOutlet weak var attendenceStartDateLabel: UILabel!
    @IBOutlet weak var attendenceEndDateLabel: UILabel!
    var trainerAttendanceArray:[Attendence?] = []
    var trainerName:String = ""
    var trainerAddress:String = ""
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTrainerNavigationBar()
        self.checkByDateBtn.layer.cornerRadius = 18.0
        self.trainerAttendanceTable.separatorStyle = .none
        self.backBtn.layer.cornerRadius = 15.0
        setBackAction(toView: self.trainerNavigationBar)
        self.trainerNameLabel.text = self.trainerName
        self.trainerAddressLabel.text = self.trainerAddress
        self.checkByDateBtn.addTarget(self, action: #selector(trainerAttendenceFilteration), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy"

        FireStoreManager.shared.getAttendenceFrom(trainerORmember: "Trainers", id: AppManager.shared.trainerID, startDate: "\(dateFormatter.string(from: Date()))", endDate: "\(AppManager.shared.getNext7DaysDate(startDate: Date()))", s: {
            (array,_) in
            self.attendenceStartDateLabel.text = AppManager.shared.dateWithMonthNameWithNoDash(date: AppManager.shared.getDate(date: (array.first!.date)))
            self.attendenceEndDateLabel.text = AppManager.shared.dateWithMonthNameWithNoDash(date: AppManager.shared.getDate(date: (array.last!.date)))
            self.trainerAttendanceArray.removeAll()
            self.trainerAttendanceArray = array
            self.trainerAttendanceTable.reloadData()
        })
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TrainerAttendanceViewController{
    func setTrainerNavigationBar() {
        self.trainerNavigationBar.menuBtn.isHidden = true
        self.trainerNavigationBar.leftArrowBtn.isHidden = false
        self.trainerNavigationBar.leftArrowBtn.alpha = 1.0
        self.trainerNavigationBar.searchBtn.isHidden = true
        self.trainerNavigationBar.navigationTitleLabel.text = "Attendance"
    }
    
    @objc func trainerAttendenceFilteration() {
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
                 self.attendenceStartDateLabel.text = "\(dateFormatter.string(from: date))"
                 self.attendenceEndDateLabel.text = "\(AppManager.shared.getNext7DaysDate(startDate: date))"
             }
         }

         @objc func onDoneButtonClick() {
             let dateFormatter = DateFormatter()
             dateFormatter.dateFormat =  "d MMM yyyy"
             self.attendenceStartDateLabel.text = "\(dateFormatter.string(from: self.datePicker.date))"
             self.attendenceEndDateLabel.text = "\(AppManager.shared.getNext7DaysDate(startDate: self.datePicker.date))"
             self.toolBar.removeFromSuperview()
             self.datePicker.removeFromSuperview()
            self.fetchTrainerAttendenceFrom(startDate: self.attendenceStartDateLabel.text!, endDate: self.attendenceEndDateLabel.text!)
         }
         @objc func onCancelButtonClick() {
             self.toolBar.removeFromSuperview()
             self.datePicker.removeFromSuperview()
         }
    
    func fetchTrainerAttendenceFrom(startDate:String,endDate:String) {
        FireStoreManager.shared.getAttendenceFrom(trainerORmember: "Trainers", id: AppManager.shared.trainerID, startDate:startDate, endDate:endDate, s: {
            (attendenceArray,_) in
            self.trainerAttendanceArray.removeAll()
            self.trainerAttendanceArray = attendenceArray 
            self.trainerAttendanceTable.reloadData()
        })
    }
    
}

extension TrainerAttendanceViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trainerAttendanceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainerAttendanceCell", for: indexPath) as! TrainerAttendanceTableCell

        self.setAttandanceTableCellView(tableCellView: cell.trainerAttendanceCellView )
        cell.checkInTimeView.layer.cornerRadius = 12.0
        cell.checkOutTimeView.layer.cornerRadius = 12.0
        
        cell.weekdayLabel.text = AppManager.shared.getTodayWeekDay(date: self.trainerAttendanceArray[indexPath.row]!.date)

        if self.trainerAttendanceArray[indexPath.row]?.present == false {
            cell.attendanceImg.image = UIImage(named: "red")
            cell.checkInTimeLabel.text = "-"
            cell.checkOutTimeLabel.text = "-"
        } else {
             cell.attendanceImg.image = UIImage(named: "green")
            cell.checkInTimeLabel.text = self.trainerAttendanceArray[indexPath.row]?.checkIn
            cell.checkOutTimeLabel.text = self.trainerAttendanceArray[indexPath.row]?.checkOut
        }
        
        return cell
    }
}
