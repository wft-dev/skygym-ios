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
    var trainerAttendanceArray:[Attendence] = []
    var trainerName:String = ""
    var trainerAddress:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTrainerNavigationBar()
        self.checkByDateBtn.layer.cornerRadius = 18.0
        self.trainerAttendanceTable.separatorStyle = .none
        self.backBtn.layer.cornerRadius = 15.0
        setBackAction(toView: self.trainerNavigationBar)
        self.trainerNameLabel.text = self.trainerName
        self.trainerAddressLabel.text = self.trainerAddress
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        FireStoreManager.shared.getAttandance(trainerORmember:"Trainers",id: AppManager.shared.trainerID,year:"\(currentYear)",month:"\(currentMonth)",result: {
                  array in
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
        
        cell.weekdayLabel.text = AppManager.shared.getTodayWeekDay(date: self.trainerAttendanceArray[indexPath.row].date)
        cell.checkInTimeLabel.text = self.trainerAttendanceArray[indexPath.row].checkIn
        cell.checkOutTimeLabel.text = self.trainerAttendanceArray[indexPath.row].checkOut
        
        if self.trainerAttendanceArray[indexPath.row].present == false {
            cell.attendanceImg.image = UIImage(named: "red")
            cell.checkInTimeLabel.text = "-"
            cell.checkOutTimeLabel.text = "-"
        }
        return cell
    }
}
