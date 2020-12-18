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
    var memberDetail:MemberDetailStructure? = nil
    
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
        self.purchaseArray.removeAll()
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (docSnapshot,err) in
            if err != nil {
                self.retryMembershipPlansAlert()
            } else {
                self.memberDetail = AppManager.shared.getMemberDetailStr(memberDetail: docSnapshot?["memberDetail"] as! Dictionary<String,String>)
                let memberships = docSnapshot?["memberships"] as! Array<Dictionary<String,String>>
                for membership in memberships {
                    let singleMembership = self.getPurchaseMemberPlan(membership: membership)
                    self.purchaseArray.append(singleMembership)
                }
                self.purchaseTable.reloadData()
            }
        })
    }
    
    func getPurchaseMemberPlan(membership:Dictionary<String,String>) -> PurchaseMembershipPlan {
        let purchasePlan = PurchaseMembershipPlan(membershipID: membership["membershipID"]!, membershipPlan: membership["membershipPlan"]!, expireDate: membership["endDate"]!, amount:membership["totalAmount"]! , dueAmount: membership["dueAmount"]!, paidAmount: membership["amount"]!, purchaseDate:membership["purchaseDate"]!, startDate: membership["startDate"]!)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "membershipDetailSegue" {
            let destinationVC = segue.destination as! CurrentMembershipDetailViewController
            destinationVC.memberDetail = self.memberDetail
            destinationVC.purchasedMembershipID = sender as! String
        }
    }
    
    
}

extension PurchaseViewController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.purchaseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell") as! PuchaseTableViewCell
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
        
       return cell
    }
}


extension PurchaseViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let singleMembership = self.purchaseArray[indexPath.row]
        performSegue(withIdentifier: "membershipDetailSegue", sender: singleMembership.membershipID)
    }
}
