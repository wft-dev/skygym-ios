//
//  GymInfoViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/12/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit

class GymInfoViewController: UIViewController {
    
    @IBOutlet weak var gymInfoCutomNavigationBar: CustomNavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gymInfoCutomNavigationBar.navigationTitleLabel.text = "Gym info"
        self.gymInfoCutomNavigationBar.searchBtn.isHidden = true
        self.gymInfoCutomNavigationBar.searchBtn.alpha = 0.0

        // Do any additional setup after loading the view.
    }
    

}
