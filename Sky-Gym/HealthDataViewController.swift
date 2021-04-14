//
//  HealthDataViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 14/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit


class HealthDataCell: UITableViewCell {
    @IBOutlet weak var healthDataLabel: UILabel!
    @IBOutlet weak var healthDataCellView: UIView!
}


class HealthDataViewController: UIViewController {

    @IBOutlet weak var healthDataTable: UITableView!
    
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
    
    var healthDataArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHealhDataUI()
        }
    
    func setUpHealhDataUI() {
        healthDataArray = ["Steps","Heart Rate"]
        self.navigationItem.hidesBackButton = true
        healthDataTable.separatorStyle  = .none
        setHealthDataNavigationBar()
    }
    
    func setHealthDataNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Health Data", attributes: [
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
    
}


extension HealthDataViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return healthDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "healthDataCell", for: indexPath) as! HealthDataCell
        
        cell.healthDataCellView.layer.cornerRadius = 15.0
        cell.healthDataCellView.layer.borderColor = UIColor.lightGray.cgColor
        cell.healthDataCellView.layer.borderWidth = 1.0
        
        cell.selectionStyle = .none
        
        cell.healthDataLabel.text = self.healthDataArray[indexPath.section]
        
        return cell
        
    }
    
}


extension HealthDataViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stepsOrHeartRateVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "healthKitTableVC") as! StepsOrHeartRateTableViewController
        
        if self.healthDataArray[indexPath.section] == "Steps" {
            stepsOrHeartRateVC.healthDataFor = .steps
        }else {
            stepsOrHeartRateVC.healthDataFor = .heartRate
        }
        self.navigationController?.pushViewController(stepsOrHeartRateVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    
}
