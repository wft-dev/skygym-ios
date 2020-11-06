//
//  AdminDashboardViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class AdminDashboardViewController: BaseViewController {
    
    @IBOutlet weak var totalMemberView: UIView!
    @IBOutlet weak var totalMemberLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var totalVisitorsLabel: UILabel!
    @IBOutlet weak var numberOfVisitorsLabel: UILabel!
    @IBOutlet weak var paidMemberView: MemberAndTrainerDetailView!
    @IBOutlet weak var expiredMemberView: MemberAndTrainerDetailView!
    @IBOutlet weak var trainerDetailView: MemberAndTrainerDetailView!
    @IBOutlet weak var cutomMenuView: CustomNavigationBar!
    
    let lightGrayColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.paidMemberView.paidUserLabel.text = "Paid member"
        self.expiredMemberView.paidUserLabel.text = "Expired member"
        self.trainerDetailView.paidUserLabel.text = "Trainers"
        cutomMenuView.searchBtn.isHidden = true
        cutomMenuView.navigationTitleLabel.text = "Dashboard"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.totalMemberView.layer.borderWidth = 1.0
        self.totalMemberView.layer.cornerRadius = 15.0
        self.totalMemberView.layer.borderColor = self.lightGrayColor.cgColor
        adjustFonts()
        self.setDashboardValues()
//        FireStoreManager.shared.getAttendenceFrom(trainerORmember: "Members", id: "12400688", startDate: <#T##String#>, endDate: <#T##String#>, result: <#T##([Attendence]) -> Void#>)
        
        FireStoreManager.shared.dummyAttendence()
        
    }
    
    func adjustFonts()  {
        adjustFontSizeFor(label: self.numberOfMembersLabel, initialSize: 40, increasingScaleBy: 4, withBold: true)
        adjustFontSizeFor(label: self.numberOfVisitorsLabel, initialSize: 40, increasingScaleBy: 4, withBold: true)
        adjustFontSizeFor(label: self.totalMemberLabel, initialSize: 12, increasingScaleBy: 2, withBold: true)
        adjustFontSizeFor(label: self.totalVisitorsLabel, initialSize: 12, increasingScaleBy: 2, withBold: true)
        
        adjustFontSizeFor(label: self.paidMemberView.paidUserLabel, initialSize: 12, increasingScaleBy: 2, withBold: true)
        adjustFontSizeFor(label: self.paidMemberView.numberOfPaidUserLabel, initialSize: 18, increasingScaleBy: 2, withBold: true)
        adjustFontSizeFor(label: self.expiredMemberView.paidUserLabel, initialSize: 12, increasingScaleBy: 2, withBold: true)
        adjustFontSizeFor(label: self.expiredMemberView.numberOfPaidUserLabel, initialSize: 18, increasingScaleBy: 2, withBold: true)
        adjustFontSizeFor(label: self.trainerDetailView.paidUserLabel, initialSize: 12, increasingScaleBy: 2, withBold: true)
        adjustFontSizeFor(label: self.trainerDetailView.numberOfPaidUserLabel, initialSize: 18, increasingScaleBy: 2, withBold: true)
    }
    
    func setDashboardValues()  {
        SVProgressHUD.show()
        FireStoreManager.shared.getTotalOf(role: .Trainer, adminID: AppManager.shared.adminID, result: {
            (trainerCount,_)  in
            self.trainerDetailView.numberOfPaidUserLabel.text = trainerCount < 10 ? "0\(trainerCount)" : "\(trainerCount)"
            
            FireStoreManager.shared.getTotalOf(role: .Member, adminID: AppManager.shared.adminID, result: {
                (memberCount,_) in
                self.numberOfMembersLabel.text = memberCount < 10 ? "0\(memberCount)" : "\(memberCount)"
                
                FireStoreManager.shared.getTotalOf(role: .Visitor, adminID: AppManager.shared.adminID, result: {
                    (visitorCount,_) in
                    SVProgressHUD.dismiss()
                    self.numberOfVisitorsLabel.text = visitorCount < 10 ? "0\(visitorCount)" : "\(visitorCount)"
                    
                    FireStoreManager.shared.numberOfPaidMembers(adminID: AppManager.shared.adminID, result: {
                        (paidMemberCount,err) in
                        
                        if err != nil {
                            print("Errror")
                        } else{
                            self.paidMemberView.numberOfPaidUserLabel.text = paidMemberCount < 10 ?  "0\(paidMemberCount)" : "\(paidMemberCount)"
                            self.expiredMemberView.numberOfPaidUserLabel.text = AppManager.shared.expiredMember < 10 ? "0\(AppManager.shared.expiredMember)" : "\(AppManager.shared.expiredMember)"
                        }
                    })
                    
                })
                
            })
        })
    }
    
}


extension UIImageView {

    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius =  10.00
        self.clipsToBounds = true
    }
}






 
 




