//
//  StepsOrHeartRateTableViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class HealthKitCell: UITableViewCell {
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var date: UILabel!
}

struct HealthKitStr {
    var value:String
    var date:String
}

class StepsOrHeartRateTableViewController: UIViewController {
    
//    @IBOutlet weak var imgView: UIImageView!
//    @IBOutlet weak var memberName: UILabel!
//    @IBOutlet weak var memberAddress: UILabel!
//    @IBOutlet weak var checkByDateBtn: UIButton!
    @IBOutlet weak var stepsOrHeartRateTable: UITableView!
//    @IBOutlet weak var previousDateBtn: UIButton!
//    @IBOutlet weak var nextDateBtn: UIButton!
    
    
    var healthKitArray:[HealthKitStr] =  [
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    HealthKitStr(value: "2323", date: "April,1 2021"),
    ]
    
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
        
        self.stepsOrHeartRateTable.tableFooterView = UIView()
        self.stepsOrHeartRateTable.separatorStyle = .none
        self.stepsOrHeartRateTable.isScrollEnabled = false

        self.stepsOrHeartRateTable.dataSource  = self
        self.stepsOrHeartRateTable.delegate = self
        
        // healthKitSetUpUI()
    }
    
//    func healthKitSetUpUI()  {
//        self.stepsOrHeartRateTable.dataSource  = self
//        self.stepsOrHeartRateTable.delegate = self
//        self.checkByDateBtn.layer.cornerRadius = 15.0
//
//        self.imgView.image = UIImage(named: "user1")
//        self.memberName.text = "Member 2"
//        self.memberAddress.text = "SCO 265-240-230, sector 22D, Chandigarh, India"
//        setHealthKitTableNavigationBar()
//    }
    
    func setHealthKitTableNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Steps", attributes: [
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


extension StepsOrHeartRateTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return healthKitArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "healthkitCell", for: indexPath) as! HealthKitCell

        cell.value.text = healthKitArray[indexPath.row].value
        cell.date.text = healthKitArray[indexPath.row].date

        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.cornerRadius  = 15.0

        cell.selectionStyle = .none

        return cell
    }

}

extension StepsOrHeartRateTableViewController : UITableViewDelegate {

      func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 15
    }

      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let headerView = UIView()
          headerView.backgroundColor = UIColor.clear
          return headerView
      }

}
