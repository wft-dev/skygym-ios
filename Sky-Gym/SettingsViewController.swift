//
//  SettingsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController {
    
    private var menuBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return leftBtn
    }()
    
    let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var stackView : UIStackView? = nil
    
    @IBOutlet weak var healthKitSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSettingsUI()
    }
    
    func setSettingsUI() {
        setSettingsNavigationBar()
        healthKitSwitch.addTarget(self, action: #selector(healthKitAction), for: .valueChanged)
    }
    
    func setSettingsNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Settings", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        navigationItem.hidesBackButton = true
    }
    
    @objc func menuChange() { AppManager.shared.appDelegate.swRevealVC.revealToggle(self) }
    
    @objc func healthKitAction() {

        if getSwitchBtnStatus() {
            //healthKitTableVC
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
                let healthKitTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "healthKitTableVC") as! StepsOrHeartRateTableViewController
                self.navigationController?.pushViewController(healthKitTableVC, animated: true)
            })
        }else {
            
        }
    }
    
    func getSwitchBtnStatus() -> Bool {
        return healthKitSwitch.isOn
    }

}
