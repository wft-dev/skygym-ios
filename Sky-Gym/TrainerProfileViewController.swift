//
//  TrainerProfileViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/12/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit

class TrainerProfileViewController: BaseViewController {
    
    @IBOutlet weak var trainerProfileCustomNavigationView: CustomNavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground()
        self.trainerProfileCustomNavigationView.navigationTitleLabel.text = "Profile"
        self.trainerProfileCustomNavigationView.searchBtn.isHidden = true
        self.trainerProfileCustomNavigationView.searchBtn.alpha = 0.0
    }


}
