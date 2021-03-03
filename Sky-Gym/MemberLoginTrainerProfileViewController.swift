//
//  MemberLoginTrainerProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 05/01/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class MemberLoginTrainerProfileViewController: UIViewController {
    @IBOutlet weak var trainerDetailView: UIView!
    @IBOutlet weak var trainerProfileImg: UIImageView!
    @IBOutlet weak var trainerName: UILabel!
    @IBOutlet weak var trainerDateOfJoiningLabel: UILabel!
    @IBOutlet weak var trainerGenderLabel: UILabel!
    @IBOutlet weak var trainerEmailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var trainerShiftTimingsLabel: UILabel!
    @IBOutlet weak var trainerShiftDaysLabel: UILabel!
    @IBOutlet weak var noTrainerTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMemberLoginTrainerProfileCustomNavigationbar()
        self.getTrainerIDFromMemberById(memberID: AppManager.shared.memberID)
    }
    
    func getTrainerIDFromMemberById(memberID:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: memberID, completion: {
            (memberData,err) in
            if err == nil {
                let memberDetail = memberData?["memberDetail"] as! Dictionary<String,String>
                let trainerID = memberDetail["trainerID"]
                if trainerID != "" {
                    self.trainerDetailView.isHidden = false
                    self.trainerDetailView.alpha = 1.0
                    self.noTrainerTextLabel.isHidden = true
                    self.noTrainerTextLabel.alpha = 0.0
                    self.fetchTrainerDetail(id: trainerID!)
                }else {
                    self.noTrainerTextLabel.isHidden = false
                    self.noTrainerTextLabel.alpha = 1.0
                    self.trainerDetailView.isHidden = true
                    self.trainerDetailView.alpha = 0.0
                    SVProgressHUD.dismiss()
                }
            }
        })
    }
    
    func setMemberLoginTrainerProfileCustomNavigationbar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let title = NSAttributedString(string: "Trainer", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        let menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        menuBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        menuBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let leftBtn = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = leftBtn
    }
    
    @objc func menuChange(){
         AppManager.shared.appDelegate.swRevealVC.revealToggle(self)
     }
    
    func fetchTrainerDetail(id:String) {
        DispatchQueue.global(qos: .utility).async {
            let result = FireStoreManager.shared.getTrainerDetailBy(id: id)
            
            DispatchQueue.main.async {
                switch result {
                case let .success(trainerDetail):
                    self.setTrainerDetail(trainerDetail: trainerDetail!)
                    FireStoreManager.shared.downloadUserImg(id: id, result: {
                        (imgUrl,err) in
                        if err == nil {
                            do {
                                let imgData = try Data(contentsOf: imgUrl!)
                                self.trainerProfileImg.image = UIImage(data: imgData)
                                self.trainerProfileImg.makeRounded()
                                SVProgressHUD.dismiss()
                            } catch _ { }
                        } else {SVProgressHUD.dismiss()  }
                    })
                    
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func setTrainerDetail(trainerDetail:TrainerDataStructure) {
        self.trainerName.text = "\(trainerDetail.firstName) \(trainerDetail.lastName)"
        self.trainerDateOfJoiningLabel.text = trainerDetail.dateOfJoining
        self.trainerGenderLabel.text = trainerDetail.gender
        self.trainerEmailLabel.text = trainerDetail.email
        self.addressLabel.text = trainerDetail.address
        self.dobLabel.text = trainerDetail.dob
        self.phoneNoLabel.text = trainerDetail.phoneNo
        self.trainerShiftTimingsLabel.text = trainerDetail.shiftTimings
        self.trainerShiftDaysLabel.text = "\(self.getShiftDaysCount(days: trainerDetail.shiftDays))"
    }
    
    func getShiftDaysCount(days:String) -> Int {
        let daysArray =  days.split(separator: ",")
        return daysArray.count
    }
}
