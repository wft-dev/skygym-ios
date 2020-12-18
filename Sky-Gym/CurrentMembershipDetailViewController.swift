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
    @IBOutlet weak var deleteMembershipView: UIView!
    
    var currentMembershipID:String = ""
    var purchasedMembershipID:String = ""
    var memberDetail:MemberDetailStructure? = nil
    
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
        if purchasedMembershipID.count > 0 {
//            self.currentMembershipDetailNavigationBar.verticalMenuBtn.isHidden = true
//            self.currentMembershipDetailNavigationBar.verticalMenuBtn.alpha = 0.0
            self.getPurchasedMembershipDetail(memberID: memberDetail!.memberID, membershipID: self.purchasedMembershipID)
        }else{
            self.getCurrentMembershipDetails(id: AppManager.shared.memberID)
        }
    }
   
    private func addClickToDismiss() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedView(_:)))
        tapRecognizer.cancelsTouchesInView = false
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapRecognizer)
    }

    @objc
    private func dismissPresentedView(_ sender: Any?) {
        if self.purchasedMembershipID.count > 0 {
            self.deleteMembershipView.isHidden = true
            self.deleteMembershipView.alpha = 0.0
        }else {
            self.membershipVerticalMenuView.isHidden = true
        }
    }
    
    @IBAction func renewCurrentMembershipBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "renewMembershipSegue", sender: nil)
    }
    
    @IBAction func deleteMembershipBtnAction(_ sender: Any) {
        let deletingMembershipID = self.purchasedMembershipID.count > 0 ? self.purchasedMembershipID : self.currentMembershipID
        let deletingMemberID = self.purchasedMembershipID.count > 0 ? memberDetail?.memberID : AppManager.shared.memberID
        
        let alertController = UIAlertController(title: "Attention", message: "Do you want to delete the current membership ?", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in

            FireStoreManager.shared.deleteMembershipWith(membershipID: deletingMembershipID, memberID:deletingMemberID!, completion: {
                err in
                if err != nil {
                    self.showAlert(title: "Error", message: "Membership is not deleted.")
                } else {
                    self.showAlert(title: "Success", message: "Membership is deleted.")
                }
            })
        })
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
        
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "renewMembershipSegue" {
            let destination = segue.destination as! AddMemberViewController
            destination.renewingMembershipID = self.currentMembershipID
            destination.isRenewMembership = true
        }
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
//        if purchasedMembershipID.count > 0 {
//            self.deleteMembershipView.isHidden = false
//            self.deleteMembershipView.alpha = 1.0
//        } else {
//            self.membershipVerticalMenuView.isHidden = false
//            self.membershipVerticalMenuView.alpha = 1.0
//        }
        
        self.deleteMembershipView.isHidden = self.purchasedMembershipID.count > 0 ? false : true
        self.deleteMembershipView.alpha = self.purchasedMembershipID.count > 0 ? 1.0 : 0.0
        self.membershipVerticalMenuView.isHidden = self.purchasedMembershipID.count > 0 ? true : false
        self.membershipVerticalMenuView.alpha = self.purchasedMembershipID.count > 0 ? 0.0 : 1.0

    }
    
    func setMembershipVerticalMenu()  {
        self.membershipVerticalMenuView.tag = 7
        self.membershipVerticalMenuView.layer.shadowColor =  UIColor.darkGray.cgColor
        self.membershipVerticalMenuView.layer.shadowOpacity = 0.3
        self.membershipVerticalMenuView.layer.shadowOffset = .init(width: 10, height: 10)
        self.deleteMembershipView.layer.shadowRadius = 50
        
        self.deleteMembershipView.layer.shadowColor =  UIColor.darkGray.cgColor
        self.deleteMembershipView.layer.shadowOpacity = 0.3
        self.deleteMembershipView.layer.shadowOffset = .init(width: 10, height: 10)
        self.deleteMembershipView.layer.shadowRadius = 50
    }
    
    func getPurchasedMembershipDetail(memberID:String,membershipID:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMembershipWith(memberID: memberID, membershipID: membershipID, result: {
            (membership,err) in
            if err != nil {
                SVProgressHUD.dismiss()
                self.retryCurrentMembershipAlert()
            }else {
                SVProgressHUD.dismiss()
                self.setCurrentMembership(memberDetail: self.memberDetail!, currentMembership: membership!)
            }
        })
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
                let memberships = docSnapshot?["memberships"] as! Array<Dictionary<String,String>>
                let memberDetail = AppManager.shared.getMemberDetailStr(memberDetail: docSnapshot?["memberDetail"] as! Dictionary<String, String>)
                let membershipArray = AppManager.shared.getCurrentMembership(membershipArray: memberships)
 
                if membershipArray.count > 0  {
                    self.setCurrentMembership(memberDetail: memberDetail, currentMembership: membershipArray.first!)
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
                    self.paidStatusLabel.attributedText = NSAttributedString(string: "No Active Membership", attributes: [ NSAttributedString.Key.foregroundColor: UIColor.red ])
                    if memberships.count > 0 {
                    let latestMembership = AppManager.shared.getLatestMembership(membershipsArray: docSnapshot?["memberships"] as! Array<Dictionary<String,String>>)
                        let dateComponentDiff = AppManager.shared.getDateDifferenceComponent(startDate: AppManager.shared.getDate(date: latestMembership.endDate), endDate: AppManager.shared.getStandardFormatDate(date: Date()))
                        
                        if dateComponentDiff.year! < 0 || dateComponentDiff.month! < 0 || dateComponentDiff.day! < 0 {
                            self.membershipStartDateLabel.attributedText = NSAttributedString(string: "Ended on  \(latestMembership.endDate)", attributes: [NSAttributedString.Key.font:UIFont(name: "Poppins-Medium", size: 11)!])
                        } else{
                            self.membershipStartDateLabel.attributedText = NSAttributedString(string: "starts from \(latestMembership.startDate)", attributes: [NSAttributedString.Key.font:UIFont(name: "Poppins-Medium", size: 11)!])
                        }
                    } else {
                        self.membershipStartDateLabel.text = "--"
                    }
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
        self.currentMembershipID = currentMembership.membershipID
        self.membershipStartDateLabel.text = currentMembership.purchaseDate
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
        self.membershipPaymentDateLabel.text = currentMembership.purchaseDate
        self.paymentTimeLabel.text = currentMembership.purchaseTime
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
