//
//  CurrentMembershipDetailViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 06/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class CurrentMembershipDetailViewController: BaseViewController {
    
    @IBOutlet weak var currentMembershipDetailNavigationBar: CustomNavigationBar!
    @IBOutlet weak var paidStatusView: UIView!
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var membershipDateView: UIView!
    @IBOutlet weak var DiscountView: UIView!
    @IBOutlet weak var paymentHistoryView: UIView!
    @IBOutlet weak var membershipVerticalMenuView: UIView!
    @IBOutlet weak var paidStatusLabel: UILabel!
    @IBOutlet weak var membershipStartDateLabel: UILabel!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var membershipPlanLabel: UILabel!
    @IBOutlet weak var membershipEndDateLabel: UILabel!
    @IBOutlet weak var membershipDetailLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var dueAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var membershipPaymentDateLabel: UILabel!
    @IBOutlet weak var paymentTimeLabel: UILabel!
    @IBOutlet weak var paymentType: UILabel!
    @IBOutlet weak var paymentAmountLabel: UILabel!
    @IBOutlet weak var memberhsipStartDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCurrentMembershipDetailNavigationBar()
        [self.paidStatusView,self.memberView,self.membershipDateView,self.DiscountView,self.paymentHistoryView].forEach{
            $0?.layer.cornerRadius = 12.0
            $0?.layer.borderWidth = 1.0
            $0?.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
            $0?.clipsToBounds = true
        }
        setMembershipVerticalMenu()
     addClickToDismiss()
    setBackAction(toView: self.currentMembershipDetailNavigationBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCurrentMembershipDetails(id: AppManager.shared.memberID)
    }
   
    private func addClickToDismiss() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedView(_:)))
        tapRecognizer.cancelsTouchesInView = false
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapRecognizer)
    }

    @objc
    private func dismissPresentedView(_ sender: Any?) {
        self.membershipVerticalMenuView.isHidden = true
    }
    
    @IBAction func renewCurrentMembershipBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "renewMembershipSegue", sender: nil)
    }
    
    @IBAction func deleteMembershipBtnAction(_ sender: Any) {
        FireStoreManager.shared.deleteMembership(memberID: AppManager.shared.memberID, completion: {
            err in
            if err != nil {
                self.showAlert(title: "Error", message: "Current membership is not deleted.")
            } else {
                self.showAlert(title: "Success", message: "Current membership is deleted.")
            }
        })
    }
}

extension CurrentMembershipDetailViewController {
    
    func showAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            if title == "Success" {
                self.dismiss(animated: true, completion: nil)
            }
        })
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion:nil)
    }
    
    func setCurrentMembershipDetailNavigationBar()  {
        self.currentMembershipDetailNavigationBar.navigationTitleLabel.attributedText = NSAttributedString(string: "Membership detail", attributes: [NSAttributedString.Key.font : UIFont(name: "poppins", size: 20)!])
        self.currentMembershipDetailNavigationBar.menuBtn.isHidden = true
        self.currentMembershipDetailNavigationBar.leftArrowBtn.isHidden = false
        self.currentMembershipDetailNavigationBar.leftArrowBtn.alpha = 1.0
        self.currentMembershipDetailNavigationBar.searchBtn.isHidden = true
        self.currentMembershipDetailNavigationBar.verticalMenuBtn.isHidden = false
        self.currentMembershipDetailNavigationBar.verticalMenuBtn.alpha = 1.0
        self.currentMembershipDetailNavigationBar.verticalMenuBtn.addTarget(self, action: #selector(showMembershipOption), for: .touchUpInside)
    }
    
    @objc func showMembershipOption() {
        self.membershipVerticalMenuView.isHidden = false
        self.membershipVerticalMenuView.alpha = 1.0
    }
    
    func setMembershipVerticalMenu()  {
        self.membershipVerticalMenuView.tag = 7
        self.membershipVerticalMenuView.layer.shadowColor =  UIColor.darkGray.cgColor
        self.membershipVerticalMenuView.layer.shadowOpacity = 0.3
        self.membershipVerticalMenuView.layer.shadowOffset = .init(width: 10, height: 10)
        self.membershipVerticalMenuView.layer.shadowRadius = 50
    }
    
    func getCurrentMembershipDetails(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (docSnapshot,err) in
            if err != nil {
                SVProgressHUD.dismiss()
                self.retryCurrentMembershipAlert()
            } else {
                SVProgressHUD.dismiss()
                let memberDetail = AppManager.shared.getMemberDetailStr(memberDetail: docSnapshot?["memberDetail"] as! NSDictionary )
                let membershipArray = AppManager.shared.getCurrentMembership(membershipArray: docSnapshot?["memberships"] as! NSArray)
                
                if membershipArray.count > 0 {
                    self.setCurrentMembership(memberDetail: memberDetail, currentMembership: membershipArray.last!)
                    [self.memberView,self.membershipDateView,self.DiscountView,self.paymentHistoryView].forEach{
                        $0?.isHidden = false
                        $0?.alpha = 1.0
                    }
                    self.currentMembershipDetailNavigationBar.verticalMenuBtn.isHidden = false
                    self.currentMembershipDetailNavigationBar.verticalMenuBtn.alpha = 1.0
                } else {
                    SVProgressHUD.show()
                    [self.memberView,self.membershipDateView,self.DiscountView,self.paymentHistoryView].forEach{
                        $0?.isHidden = true
                        $0?.alpha = 0.0
                    }
                    self.paidStatusLabel.attributedText = NSAttributedString(string: "No Membership", attributes: [ NSAttributedString.Key.foregroundColor: UIColor.red ])
                    self.membershipStartDateLabel.text = "--"
                    self.currentMembershipDetailNavigationBar.verticalMenuBtn.isHidden = true
                    self.currentMembershipDetailNavigationBar.verticalMenuBtn.alpha = 0.0
                    SVProgressHUD.dismiss()
                }
            }
        })
    }
    
    func setCurrentMembership(memberDetail:MemberDetailStructure,currentMembership:MembershipDetailStructure) {
        let dueAmount = Int(currentMembership.dueAmount)
        
        if dueAmount! > 0 {
            self.paidStatusLabel.attributedText = NSAttributedString(string: "Unpaid", attributes: [ NSAttributedString.Key.foregroundColor: UIColor.red ])
        }
        else {
            self.paidStatusLabel.attributedText = NSAttributedString(string: "Paid", attributes: [ NSAttributedString.Key.foregroundColor: UIColor.green ])
        }
        self.membershipStartDateLabel.text = currentMembership.startDate
        self.membershipEndDateLabel.text = currentMembership.endDate
        self.memberhsipStartDate.text = currentMembership.startDate
        self.memberNameLabel.text = "\(memberDetail.firstName) \(memberDetail.lastName)"
        self.mobileNumberLabel.text = memberDetail.phoneNo
        self.membershipPlanLabel.text = currentMembership.membershipPlan
        self.membershipEndDateLabel.text = currentMembership.endDate
        self.membershipDetailLabel.text = currentMembership.membershipDetail.count > 0 ? "YES" : "NO"
        self.discountLabel.text = currentMembership.discount
        self.amountLabel.text = currentMembership.amount
        self.totalAmountLabel.text = currentMembership.totalAmount
        self.dueAmountLabel.text = currentMembership.dueAmount
        self.paymentTypeLabel.text = currentMembership.paymentType
        self.membershipPaymentDateLabel.text = currentMembership.startDate
        self.paymentTimeLabel.text = currentMembership.puchaseTime
        self.paymentType.text = currentMembership.paymentType
        self.paymentAmountLabel.text = currentMembership.amount
    }
    
    func retryCurrentMembershipAlert() {
         let retryAlertController = UIAlertController(title: "Error", message: "Error in getting the member Detail.", preferredStyle: .alert)
         let retryAlertBtn = UIAlertAction(title: "Retry", style: .default, handler: {
             (action) in
            self.getCurrentMembershipDetails(id: AppManager.shared.memberID)
         })
         retryAlertController.addAction(retryAlertBtn)
         present(retryAlertController, animated: true, completion: nil)
     }
   
}
