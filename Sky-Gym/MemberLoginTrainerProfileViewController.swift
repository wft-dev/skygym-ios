//
//  MemberLoginTrainerProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 05/01/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class MemberLoginTrainerProfileViewController: UIViewController {
    
    @IBOutlet weak var memberLoginTrainerProfileCustomNavigationbarView: CustomNavigationBar!
    @IBOutlet weak var trainerDetailView: UIView!
    @IBOutlet weak var trainerProfileImg: UIImageView!
    @IBOutlet weak var trainerName: UILabel!
    @IBOutlet weak var trainerIDLabel: UILabel!
    @IBOutlet weak var trainerDateOfJoiningLabel: UILabel!
    @IBOutlet weak var trainerGenderLabel: UILabel!
    @IBOutlet weak var trainerPasswordLabel: UILabel!
    @IBOutlet weak var trainerEmailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var trainerShiftTimingsLabel: UILabel!
    @IBOutlet weak var trainerShiftDaysLabel: UILabel!
    @IBOutlet weak var trainerBackBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMemberLoginTrainerProfileCustomNavigationbar()
        self.trainerBackBtn.layer.cornerRadius = 15.0
        self.trainerBackBtn.layer.borderColor = UIColor.black.cgColor
        self.trainerBackBtn.layer.borderWidth = 0.7
        self.trainerBackBtn.clipsToBounds = true
        self.fetchTrainerDetail(id: "78010")
    }
    
    func setMemberLoginTrainerProfileCustomNavigationbar()  {
        self.memberLoginTrainerProfileCustomNavigationbarView.navigationTitleLabel.text = "Trainer"
        self.memberLoginTrainerProfileCustomNavigationbarView.searchBtn.isHidden = true
        self.memberLoginTrainerProfileCustomNavigationbarView.searchBtn.alpha = 0.0
    }
    
    
    func fetchTrainerDetail(id:String) {
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getTrainerDetailBy(id: id)
            
            switch result {
            case let .success(trainerDetail):
                self.setTrainerDetail(trainerDetail: trainerDetail!)
            case .failure(_):
                break
            }
        }
    }
    
    func setTrainerDetail(trainerDetail:TrainerDataStructure) {
        self.trainerIDLabel.text = trainerDetail.trainerID
        self.trainerDateOfJoiningLabel.text = trainerDetail.dateOfJoining
        self.trainerGenderLabel.text = trainerDetail.gender
        self.trainerPasswordLabel.text = AppManager.shared.getSecureTextFor(text: trainerDetail.password)
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
