//
//  StepsOrHeartRateTableViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import HealthKit
import SVProgressHUD

class HealthKitCell: UITableViewCell {
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var healthKitCellMainView: UIView!
}

class StepsOrHeartRateTableViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberAddress: UILabel!
    @IBOutlet weak var checkByDateBtn: UIButton!
    @IBOutlet weak var stepsOrHeartRateTable: UITableView!
    @IBOutlet weak var previousDateBtn: UIButton!
    @IBOutlet weak var nextDateBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var noDataFoundText: UILabel!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    lazy var datePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.timeZone = .none
        datePicker.locale = .none
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    lazy var toolBar:UIToolbar? = nil
    
    var healthKitArray:[HealthStatics] =  [
    HealthStatics(value: "2323", date: "April,1 2021"),
    HealthStatics(value: "2322", date: "April,1 2021"),
    HealthStatics(value: "2321", date: "April,1 2021"),
    HealthStatics(value: "2324", date: "April,1 2021"),
    HealthStatics(value: "2326", date: "April,1 2021"),
    HealthStatics(value: "2328", date: "April,1 2021"),
    HealthStatics(value: "2399", date: "April,1 2021")
    ]
    
    var startDate:Date? = nil
    var endDate:Date? = nil
    var memberDetail:MemberDetailStructure? = nil
    var healthDataFor : HealthParameter = .steps
    
    private var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return leftBtn
    }()
    
    let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var stackView : UIStackView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthKitSetUpUI()
    }
    
    func healthKitSetUpUI()  {
        setHealthKitTableNavigationBar()
        
        stepsOrHeartRateTable.tableFooterView = UIView()
        stepsOrHeartRateTable.separatorStyle = .none
        stepsOrHeartRateTable.isScrollEnabled = false
        stepsOrHeartRateTable.dataSource  = self
        stepsOrHeartRateTable.delegate = self

        checkByDateBtn.layer.cornerRadius = 12.0
        backBtn.layer.cornerRadius = 12.0
        backBtn.addTarget(self, action: #selector(backAciton), for: .touchUpInside)
        checkByDateBtn.addTarget(self, action: #selector(checkByDateAction), for: .touchUpInside)
        previousDateBtn.addTarget(self, action: #selector(previousDateAction), for: .touchUpInside)
        nextDateBtn.addTarget(self, action: #selector(nextDateAction), for: .touchUpInside)
        
        self.imgView.layer.cornerRadius = 10.0
        self.imgView.contentMode = .scaleAspectFill
        
        self.startDate = Date()
        self.endDate = AppManager.shared.getNext7DaysDateFormat(startDate: Date())
        
        previousDateBtn.setTitle("\(AppManager.shared.dateWithMonthNameWithNoDash(date: self.startDate!))", for: .normal)
        nextDateBtn.setTitle("\(AppManager.shared.dateWithMonthNameWithNoDash(date: self.endDate!))", for: .normal)

        DispatchQueue.main.async {
            self.getMemberData(memberID: AppManager.shared.memberID)
        }
        
    }
    
    func getMemberData(memberID:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: memberID) { (data, err) in
            if err == nil {
                let memberDetail = data?["memberDetail"] as! [String:String]
                self.memberDetail = AppManager.shared.getMemberDetailStr(memberDetail: memberDetail)
                self.memberName.text = "\(self.memberDetail!.firstName) \(self.memberDetail!.lastName)"
                self.memberAddress.text = self.memberDetail!.address
                
                self.fetchHealthData(for: self.healthDataFor, startDate:self.startDate!, endDate: self.endDate!)
                
                FireStoreManager.shared.downloadUserImg(id: memberID, result: {
                    (url , err) in
                    SVProgressHUD.dismiss()
                    if err == nil {
                        let data = try! Data(contentsOf: url!)
                        self.imgView.image = UIImage(data: data)
                    }else {
                        self.imgView.image = UIImage(named: "user1")
                    }
                })
                
            }else {
                SVProgressHUD.dismiss()
            }
        }
        
    }
    
    
    func fetchHealthData(for healthParameter : HealthParameter,startDate:Date,endDate:Date) {
        print("HEALTH PARAMETER IN FETCHING DATA : \(healthParameter)")
        SVProgressHUD.show()
        self.healthKitArray.removeAll()
        
        switch healthParameter {
        case .steps:
            let steps = HKSampleType.quantityType(forIdentifier: .stepCount)!
            
            HealthKitManager.shared.getSteps(for: steps, start:startDate, end: endDate) { (arr) in
                if arr.count > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0  , execute: {
                        self.healthKitArray = arr
                        self.stepsOrHeartRateTable.isHidden = false
                        self.stepsOrHeartRateTable.alpha = 1.0
                        self.noDataFoundText.isHidden = true
                        self.noDataFoundText.alpha = 0.0
                        self.stepsOrHeartRateTable.reloadData()
                        SVProgressHUD.dismiss()
                    })
                }else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0  , execute: {
                        self.stepsOrHeartRateTable.isHidden = true
                        self.stepsOrHeartRateTable.alpha = 0.0
                        self.noDataFoundText.isHidden = false
                        self.noDataFoundText.alpha = 1.0
                        self.stepsOrHeartRateTable.reloadData()
                        SVProgressHUD.dismiss()
                    })
                }
            }
            break
        case .heartRate :
            let heartRate = HKSampleType.quantityType(forIdentifier: .heartRate)!
            
            print("START DATE IS : \(self.startDate!)")
            print("END DATE IS : \(self.endDate!)")
            
            HealthKitManager.shared.getHeartRate(for: heartRate, start: self.startDate!, end: self.endDate!) { (arr) in
                if arr.count > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
                        self.healthKitArray = arr
                        self.stepsOrHeartRateTable.isHidden = false
                        self.stepsOrHeartRateTable.alpha = 1.0
                        self.noDataFoundText.isHidden = true
                        self.noDataFoundText.alpha = 0.0
                        self.stepsOrHeartRateTable.reloadData()
                        SVProgressHUD.dismiss()
                    })
                }else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0  , execute: {
                        self.stepsOrHeartRateTable.isHidden = true
                        self.stepsOrHeartRateTable.alpha = 0.0
                        self.noDataFoundText.isHidden = false
                        self.noDataFoundText.alpha = 1.0
                        self.stepsOrHeartRateTable.reloadData()
                        SVProgressHUD.dismiss()
                    })

                }
            }
            break
        }
   
    }
    
    func setHealthKitTableNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: healthDataFor == HealthParameter.steps ? "Steps" : "Heart Rate", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        stackView = UIStackView(arrangedSubviews: [spaceBtn,leftBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        leftBtn.addTarget(self, action: #selector(backAciton), for: .touchUpInside)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        navigationItem.hidesBackButton = true
    }
    
    @objc func backAciton() { self.navigationController?.popViewController(animated: true) }
    
    @objc func checkByDateAction() {
       setPickerView()
    }
    
    @objc func previousDateAction() {
        self.startDate = AppManager.shared.getDayByAdding(value: -1, to: self.startDate!)
        self.endDate = AppManager.shared.getDayByAdding(value: -1, to: self.endDate!)
        
        previousDateBtn.setTitle("\(AppManager.shared.dateWithMonthNameWithNoDash(date: self.startDate!))", for: .normal)
        nextDateBtn.setTitle("\(AppManager.shared.dateWithMonthNameWithNoDash(date: self.endDate!))", for: .normal)
        
        fetchHealthData(for: self.healthDataFor, startDate: self.startDate!, endDate: self.endDate!)
       
       }
    
    @objc func nextDateAction() {
        self.startDate = AppManager.shared.getDayByAdding(value: 1, to: self.startDate!)
        self.endDate = AppManager.shared.getDayByAdding(value: 1, to: self.endDate!)
        
        previousDateBtn.setTitle("\(AppManager.shared.dateWithMonthNameWithNoDash(date: self.startDate!))", for: .normal)
        nextDateBtn.setTitle("\(AppManager.shared.dateWithMonthNameWithNoDash(date: self.endDate!))", for: .normal)
        
        fetchHealthData(for: self.healthDataFor, startDate: self.startDate!, endDate: self.endDate!)
       }
    
    @objc func dateChanged(_ sender: UIDatePicker?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "d MMM yyyy"
        if let date = sender?.date {
            let nextEndDate = AppManager.shared.getNext7DaysDateFormat(startDate: date)
            previousDateBtn.setTitle("\(dateFormatter.string(from: date))", for: .normal)
            nextDateBtn.setTitle("\(dateFormatter.string(from: nextEndDate))", for: .normal)
        }
    }
    
    @objc func onDoneButtonClick() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "d MMM yyyy"
        self.startDate = datePicker.date
        self.endDate = AppManager.shared.getNext7DaysDateFormat(startDate: datePicker.date)
        previousDateBtn.setTitle("\(dateFormatter.string(from: self.startDate!))", for: .normal)
        nextDateBtn.setTitle("\(dateFormatter.string(from: self.endDate!))", for: .normal)
        
        fetchHealthData(for: self.healthDataFor, startDate: self.startDate!, endDate: self.endDate!)
        
        toolBar!.removeFromSuperview()
        self.datePicker.removeFromSuperview()
    }
    
    @objc func onCancelButtonClick() {
        toolBar!.removeFromSuperview()
        datePicker.removeFromSuperview()
        self.view.endEditing(true)
    }
    
    func setPickerView() {
        datePicker.backgroundColor = UIColor.white
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 250)
        self.view.addSubview(datePicker)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 250, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar?.barStyle = .default
        toolBar?.items = [UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.onCancelButtonClick)),UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneButtonClick))]
        toolBar?.sizeToFit()
        self.view.addSubview(self.toolBar!)
    }
    
}


extension StepsOrHeartRateTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return healthKitArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "healthkitCell", for: indexPath) as! HealthKitCell

        cell.value.text = healthKitArray[indexPath.section].value
        cell.date.text = healthKitArray[indexPath.section].date

        cell.healthKitCellMainView.layer.borderColor = UIColor.lightGray.cgColor
        cell.healthKitCellMainView.layer.borderWidth = 0.5
        cell.healthKitCellMainView.layer.cornerRadius  = 15.0

        cell.selectionStyle = .none

        return cell
    }
}

extension StepsOrHeartRateTableViewController : UITableViewDelegate {
    
      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let header = UIView()
          header.backgroundColor = .clear
          return header
      }

      func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 15
      }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
