//
//  SettingsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD



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
       
        FireStoreManager.shared.getHealthKitStatus(memberID: AppManager.shared.memberID) { (status) in
            self.healthKitSwitch.setOn(status, animated: true)
        }
        
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
            HealthKitManager.shared.healthKitRequestAuthorization(completion: {
                (flag) in
                if flag == true {
                    DispatchQueue.main.async {
                        self.healthKitAlert(title: "Enabled", msg: "Welcome,Health kit is enabled. Check health data in Home menu",status: true)
                    }
                }else {
                     self.healthKitAlert(title: "Error", msg: "Something went wrong, try again.",status: false)
                    print("FAILED.")
                }
            })
            
        }else {
            self.healthKitAlert(title: "Disabled", msg: "Health kit is disabled.",status: false)
        }
    
    }
    
    func getSwitchBtnStatus() -> Bool {
        return healthKitSwitch.isOn
    }
    
    func healthKitAlert(title:String,msg:String,status:Bool)  {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
        _ in
            SVProgressHUD.show()
            
            FireStoreManager.shared.setHealthKitStatus(memberID: AppManager.shared.memberID, healthKitStatus: status) { (err) in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.healthKitSwitch.setOn(false, animated: true)
                    self.healthKitAlert(title: "Error", msg: "Something went wrong, please try again.")
                }
                
            }
        })
        
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func healthKitAlert(title:String,msg:String)  {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    

}





