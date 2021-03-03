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
    @IBOutlet weak var activeLabelHeightConstraint: NSLayoutConstraint!
}

class PurchaseViewController: BaseViewController {

    @IBOutlet weak var purchaseTable: UITableView!
    @IBOutlet weak var noPurchaseHistoryLabel: UILabel!
    
    var purchaseArray:[PurchaseMembershipPlan] = []
    var todayDate:Date = Date()
    var memberDetail:MemberFullNameAndPhone? = nil
    var purchaseTimeStamp:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setPurchaseNavigationBar()
        self.purchaseTable.separatorStyle = .none
        self.todayDate = AppManager.shared.getStandardFormatDate(date: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.getMembershipPlans(id: AppManager.shared.memberID)
    }
    
    func setPurchaseNavigationBar() {
        let title = NSAttributedString(string: "Membership Plan", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(membershipPlanBackBtnAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,backButton])
        stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let backBtn = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc func  membershipPlanBackBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }

    func setTableCellView(tableCellView:UIView)  {
        tableCellView.layer.cornerRadius = 12.0
        tableCellView.layer.borderWidth = 1.0
        tableCellView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        tableCellView.clipsToBounds = true
        tableCellView.isUserInteractionEnabled = true
        tableCellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToMembershipDetail(_:))))
    }
    
    @objc func moveToMembershipDetail(_ gesture:UITapGestureRecognizer){
        let singleMembership = self.purchaseArray[gesture.view!.tag]
        let currentMembershipDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currentMembershipDetailVC") as! CurrentMembershipDetailViewController
        currentMembershipDetailVC.memberDetail = self.memberDetail
        currentMembershipDetailVC.purchasedMembershipID = singleMembership.membershipID
        currentMembershipDetailVC.membershipTimeStamp = singleMembership.timeStamp
        self.navigationController?.pushViewController(currentMembershipDetailVC, animated: true)
    }
    
    func getMembershipPlans(id:String)  {
        self.purchaseArray.removeAll()
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (docSnapshot,err) in
            if err != nil {
                SVProgressHUD.dismiss()
                self.retryMembershipPlansAlert()
            } else {
                SVProgressHUD.dismiss()
                self.memberDetail = AppManager.shared.getMemberNameAndPhone(memberDetail: docSnapshot?["memberDetail"] as! Dictionary<String,String>)
                let memberships = docSnapshot?["memberships"] as! Array<Dictionary<String,String>>
                if memberships.count > 0 {
                    self.noPurchaseHistoryLabel.isHidden = true
                    self.noPurchaseHistoryLabel.alpha = 0.0
                    self.purchaseTable.isHidden = false
                    self.purchaseTable.alpha = 1.0
                    for membership in memberships {
                        let singleMembership = self.getPurchaseMemberPlan(membership: membership)
                        self.purchaseArray.append(singleMembership)
                    }
                }else {
                    self.noPurchaseHistoryLabel.isHidden = false
                    self.noPurchaseHistoryLabel.alpha = 1.0
                    self.purchaseTable.isHidden = true
                    self.purchaseTable.alpha = 0.0
                }
                self.purchaseTable.reloadData()
            }
        })
    }
    
    func getPurchaseMemberPlan(membership:Dictionary<String,String>) -> PurchaseMembershipPlan {
        let purchasePlan = PurchaseMembershipPlan(membershipID: membership["membershipID"]!, membershipPlan: membership["membershipPlan"]!, expireDate: membership["endDate"]!, amount:membership["totalAmount"]! , dueAmount: membership["dueAmount"]!, paidAmount: membership["amount"]!, purchaseDate:membership["purchaseDate"]!, startDate: membership["startDate"]!, timeStamp: membership["purchaseTimeStamp"]!)
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell") as! PuchaseTableViewCell
        let singleMembership = self.purchaseArray[indexPath.row]
        cell.purchaseTableCellView.tag = indexPath.row
        self.setTableCellView(tableCellView: cell.purchaseTableCellView)
        cell.activePurchaseLabel.layer.cornerRadius = 10.0
        let endDate = AppManager.shared.getDate(date:singleMembership.expireDate)
        let startDate = AppManager.shared.getDate(date: singleMembership.startDate)
        let endDayDiff = Calendar.current.dateComponents([.day], from:todayDate , to: endDate).day!
        let startDayDiff = Calendar.current.dateComponents([.day], from:todayDate, to:startDate).day!

        cell.membershipPlanLabel.text = singleMembership.membershipPlan
        cell.membershipEndDateLabel.text = singleMembership.expireDate
        cell.amountLabel.text = singleMembership.amount
        cell.dueAmountLabel.text = singleMembership.dueAmount
        cell.paidAmountLabel.text = singleMembership.paidAmount
        cell.purchaseDateLabel.text = singleMembership.purchaseDate
        cell.selectionStyle = .none
        
        DispatchQueue.main.async {
            if endDayDiff >= 0 && startDayDiff <= 0 {
                cell.activePurchaseLabel.isHidden = false
                cell.activeLabelHeightConstraint.constant = 25
            } else {
                cell.activePurchaseLabel.isHidden = true
                cell.activeLabelHeightConstraint.constant = 0 
            }
        }
        
       return cell
    }
}
