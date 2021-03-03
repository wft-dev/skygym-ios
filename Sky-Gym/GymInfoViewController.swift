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

    @IBOutlet weak var gymNameLabel: UILabel!
    @IBOutlet weak var gymTimingLabel: UILabel!
    @IBOutlet weak var gymDaysLabel: UILabel!
    @IBOutlet weak var gymAddressLabel: UILabel!
    @IBOutlet weak var gymOwnerNameLabel: UILabel!
    @IBOutlet weak var gymOwnerPhoneNoLabel: UILabel!
    @IBOutlet weak var gymOwnerAddressLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setGymInfoNavigationBar()
        self.fetchGymInfo(gymID: AppManager.shared.gymID)
    }
    
    func setGymInfoNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Gym Info", attributes: [
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
        self.gymTimingLabel.text = "\(gymDetail.gymOpeningTime)/\(gymDetail.gymClosingTime)"
        self.gymDaysLabel.text  = "\(gymDetail.gymDays) days"
        self.gymAddressLabel.text  = gymDetail.gymAddress
        self.gymOwnerNameLabel.text = gymDetail.gymOwnerName
        self.gymOwnerPhoneNoLabel.text = gymDetail.gymOwnerPhoneNumber
        self.gymOwnerAddressLabel.text = gymDetail.gymOwnerAddress
    }
}
