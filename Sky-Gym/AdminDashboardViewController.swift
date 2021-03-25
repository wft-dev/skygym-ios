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
    
    let lightGrayColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    var nav:UINavigationBar? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nav = self.navigationController?.navigationBar
        setCustomNavigation(textForTitle: "Dashboard")
        SVProgressHUD.show()
        self.assignbackground()
        self.paidMemberView.paidUserLabel.text = "Paid member"
        self.expiredMemberView.paidUserLabel.text = "Expired member"
        if  AppManager.shared.loggedInRole == LoggedInRole.Trainer {
            self.trainerDetailView.isHidden = true
            self.trainerDetailView.alpha = 0.0
            self.trainerDetailView.paidUserLabel.text = ""
        }else {
            self.trainerDetailView.isHidden = false
            self.trainerDetailView.alpha = 1.0
            self.trainerDetailView.paidUserLabel.text = "Trainers"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            self.setDashboardValues()
        })   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.totalMemberView.layer.borderWidth = 1.0
        self.totalMemberView.layer.cornerRadius = 15.0
        self.totalMemberView.layer.borderColor = self.lightGrayColor.cgColor
        adjustFonts()
         
        if AppManager.shared.loggedInRole == LoggedInRole.Trainer {
            DispatchQueue.global(qos: .utility).async {
                let result = FireStoreManager.shared.getTrainerPermission(id: AppManager.shared.trainerID)
                switch result {
                case .failure(_):
                    print("Error")
                case let .success(trainerPermission) :
                    AppManager.shared.trainerMemberPermission = trainerPermission.canAddMember
                    AppManager.shared.trainerEventPermission = trainerPermission.canAddEvent
                    AppManager.shared.trainerVisitorPermission = trainerPermission.canAddVisitor
                }
            }
        }
    }
    
      func setCustomNavigation(textForTitle:String)  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 10, width: (self.navigationController?.navigationBar.bounds.width)!, height: (self.navigationController?.navigationBar.bounds.height)! + 40 )
        let title = NSAttributedString(string: textForTitle, attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        self.navigationController?.navigationBar.topItem?.titleView = titleLabel
        let menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    @objc func menuChange(){
        AppManager.shared.appDelegate.swRevealVC.revealToggle(self)
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
        
        self.getTotalNumberOf(role: .Member)
        self.getTotalNumberOf(role: .Visitor)
        if AppManager.shared.loggedInRole ==  LoggedInRole.Admin  {
            self.getTotalNumberOf(role: .Trainer)
        }
        self.getNumberOfPaidMembers()
        SVProgressHUD.dismiss()
    }
    
    
    func getTotalNumberOf(role:Role){
        var v = 0
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getTotalOf(role: role)
            
            DispatchQueue.main.async {
                switch result {
                case let .success(count):
                    v = count
                case .failure(_):
                    v = 0
                }
                switch role {
                case .Member:
                    self.numberOfMembersLabel.text = "\(v)"
                case .Trainer:
                    self.trainerDetailView.numberOfPaidUserLabel.text = "\(v)"
                case .Visitor:
                    self.numberOfVisitorsLabel.text = "\(v)"
                default:
                    break
                }
            }
        }
    }
    
    func getNumberOfPaidMembers() {
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.numberOfPaidMembers()
            DispatchQueue.main.async {
                switch result {
                case let .success(count):
                    self.paidMemberView.numberOfPaidUserLabel.text = "\(count)"
                case .failure(_):
                    self.paidMemberView.numberOfPaidUserLabel.text = "0"
                }
                self.expiredMemberView.numberOfPaidUserLabel.text = "\(AppManager.shared.expiredMember)"
            }
        }
    }
}

extension UIImageView {

    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius =  10.00
        self.clipsToBounds = true
    }
}






 
 




