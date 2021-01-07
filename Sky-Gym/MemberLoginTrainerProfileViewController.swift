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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMemberLoginTrainerProfileCustomNavigationbar()
    }

    func setMemberLoginTrainerProfileCustomNavigationbar()  {
        self.memberLoginTrainerProfileCustomNavigationbarView.navigationTitleLabel.text = "Trainer"
        self.memberLoginTrainerProfileCustomNavigationbarView.searchBtn.isHidden = true
        self.memberLoginTrainerProfileCustomNavigationbarView.searchBtn.alpha = 0.0
    }

}
