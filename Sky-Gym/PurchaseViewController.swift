//
//  PurchaseViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 06/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class PuchaseTableViewCell: UITableViewCell {
    @IBOutlet weak var activePurchaseLabel: UILabel!
    @IBOutlet weak var purchaseTableCellView: UIView!
    @IBOutlet weak var membershipPlanLabel: UILabel!
    @IBOutlet weak var membershipEndDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dueAmountLabel: UILabel!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var purchaseDateLabel: UILabel!
}

class PurchaseViewController: BaseViewController {

    @IBOutlet weak var purchaseTable: UITableView!
    @IBOutlet weak var purchaseNavigationBar: CustomNavigationBar!
    
    var purchaseArray:[PurchaseMembershipPlan] = []
    var todayDate:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setPurchaseNavigationBar()
        self.purchaseTable.separatorStyle = .none
        setBackAction(toView: self.purchaseNavigationBar)
        self.todayDate = AppManager.shared.getStandardFormatDate(date: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getMembershipPlans(id: AppManager.shared.memberID)
    }
}

extension PurchaseViewController {
    func setPurchaseNavigationBar() {
        self.purchaseNavigationBar.navigationTitleLabel.text = "Membership Plan"
        self.purchaseNavigationBar.menuBtn.isHidden = true
        self.purchaseNavigationBar.leftArrowBtn.isHidden = false
        self.purchaseNavigationBar.leftArrowBtn.alpha = 1.0
        self.purchaseNavigationBar.searchBtn.isHidden = true
    }
    func setTableCellView(tableCellView:UIView)  {
        tableCellView.layer.cornerRadius = 12.0
       tableCellView.layer.borderWidth = 1.0
       tableCellView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        tableCellView.clipsToBounds = true
    }
    
    func getMembershipPlans(id:String)  {
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (docSnapshot,err) in
            if err != nil {
                self.retryMembershipPlansAlert()
            } else {
                let memberships = docSnapshot?["memberships"] as! NSArray
               
                for membership in memberships {
                    let singleMembership = self.getPurchaseMemberPlan(membership: membership as! [String:String])
                    self.purchaseArray.append(singleMembership)
                }
                self.purchaseTable.reloadData()
            }
        })
    }
    
    func getPurchaseMemberPlan(membership:[String:String]) -> PurchaseMembershipPlan {
        let purchasePlan = PurchaseMembershipPlan(membershipPlan: membership["membershipPlan"]!, expireDate: membership["endDate"]!, amount:membership["totalAmount"]! , dueAmount: membership["dueAmount"]!, paidAmount: membership["amount"]!, purchaseDate:membership["purchaseDate"]!, startDate: membership["startDate"]!)
        
        return purchasePlan
    }
    
    func retryMembershipPlansAlert() {
           let retryAlertController = UIAlertController(title: "Error", message: "Error in getting the member Detail.", preferredStyle: .alert)
           let retryAlertBtn = UIAlertAction(title: "Retry", style: .default, handler: {
               (action) in
            self.getMembershipPlans(id: AppManager.shared.memberID)
           })
           retryAlertController.addAction(retryAlertBtn)
           present(retryAlertController, animated: true, completion: nil)
       }
}

extension PurchaseViewController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.purchaseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! PuchaseTableViewCell
        let singleMembership = self.purchaseArray[indexPath.row]
        self.setTableCellView(tableCellView: cell.purchaseTableCellView)
        cell.activePurchaseLabel.layer.cornerRadius = 10.0
        let endDate = AppManager.shared.getDate(date:singleMembership.expireDate)
        let startDate = AppManager.shared.getDate(date: singleMembership.startDate)
        let endDayDiff = Calendar.current.dateComponents([.day], from:todayDate , to: endDate).day!
        let startDayDiff = Calendar.current.dateComponents([.day], from:todayDate, to:startDate).day!
  
        if endDayDiff >= 0 && startDayDiff <= 0 {
            cell.activePurchaseLabel.isHidden = false
            cell.activePurchaseLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        } else {
           cell.activePurchaseLabel.isHidden = true
           cell.activePurchaseLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        cell.membershipPlanLabel.text = singleMembership.membershipPlan
        cell.membershipEndDateLabel.text = singleMembership.expireDate
        cell.amountLabel.text = singleMembership.amount
        cell.dueAmountLabel.text = singleMembership.dueAmount
        cell.paidAmountLabel.text = singleMembership.paidAmount
        cell.purchaseDateLabel.text = singleMembership.purchaseDate
        cell.backgroundView = AppManager.shared.getClearBG()
        
       return cell
    }
}
