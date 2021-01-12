//
//  GymInfoViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/12/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class GymInfoViewController: UIViewController {
    
    @IBOutlet weak var gymInfoCutomNavigationBar: CustomNavigationBar!
    @IBOutlet weak var gymNameLabel: UILabel!
    @IBOutlet weak var gymTimingLabel: UILabel!
    @IBOutlet weak var gymDaysLabel: UILabel!
    @IBOutlet weak var gymAddressLabel: UILabel!
    @IBOutlet weak var gymOwnerNameLabel: UILabel!
    @IBOutlet weak var gymOwnerPhoneNoLabel: UILabel!
    @IBOutlet weak var gymOwnerAddressLabel: UILabel!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gymInfoCutomNavigationBar.navigationTitleLabel.text = "Gym info"
        self.gymInfoCutomNavigationBar.searchBtn.isHidden = true
        self.gymInfoCutomNavigationBar.searchBtn.alpha = 0.0
        self.fetchGymInfo(gymID: AppManager.shared.gymID)
    }
    

    func fetchGymInfo(gymID:String) {
        SVProgressHUD.show()
        DispatchQueue.global(qos: .background).async {
            let gymDetail = FireStoreManager.shared.getGymInfo(gymID: gymID)
            
            DispatchQueue.main.async {
                switch gymDetail {
                case let .failure(err):
                    print("Error in finding the gym info \(err)")
                case let .success(gymInfo) :
                    SVProgressHUD.dismiss()
                    self.setGymInfo(gymDetail: gymInfo)
                }
            }
        }
    }
    
    func setGymInfo(gymDetail:GymDetail) {
        self.gymNameLabel.text = gymDetail.gymName
       // self.gymIDLabel.text = gymDetail.gymID
        self.gymTimingLabel.text = "\(gymDetail.gymOpeningTime)/\(gymDetail.gymClosingTime)"
        self.gymDaysLabel.text  = "\(gymDetail.gymDays) days"
        self.gymAddressLabel.text  = gymDetail.gymAddress
        self.gymOwnerNameLabel.text = gymDetail.gymOwnerName
        self.gymOwnerPhoneNoLabel.text = gymDetail.gymOwnerPhoneNumber
        self.gymOwnerAddressLabel.text = gymDetail.gymOwnerAddress
    }
}
