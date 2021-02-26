//
//  CustomNavigationBar.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import UIKit
import SWRevealViewController

class CustomNavigationBar: UIView {
    
    @IBOutlet var navigationBarView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var leftArrowBtn: UIButton!
    @IBOutlet weak var verticalMenuBtn: UIButton!
    
    @IBOutlet weak var editBtn: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
           initWithNib()
       }
       
       private func initWithNib() {
           Bundle.main.loadNibNamed("CustomNavigationBar", owner: self, options: nil)
           navigationBarView.translatesAutoresizingMaskIntoConstraints = false
           addSubview(navigationBarView)
           setupLayout()
        setMenuBtnAction()
       }
      
       private func setupLayout() {
           NSLayoutConstraint.activate(
               [
                   navigationBarView.topAnchor.constraint(equalTo: topAnchor),
                   navigationBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
                   navigationBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
                   navigationBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
               ]
           )
       }
    
    
    func setMenuBtnAction() {
        self.menuBtn.addTarget(self, action: #selector(menuToggle), for: .touchUpInside)
       }
       @objc func menuToggle(){
        appDelegate.swRevealVC.revealToggle(animated: true)
       // appDelegate.swRevealVC.panGestureRecognizer()
       }
  
}
