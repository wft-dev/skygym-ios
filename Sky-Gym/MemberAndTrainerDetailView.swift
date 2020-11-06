//
//  MemberAndTrainerDetailView.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 29/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import UIKit

class MemberAndTrainerDetailView: UIView {
    
    @IBOutlet weak var memberAndTrainerDetailView: UIView!
    @IBOutlet weak var paidUserLabel: UILabel!
    @IBOutlet weak var numberOfPaidUserLabel: UILabel!
    
    override func awakeFromNib() {
            initWithNib()
        }
    
        private func initWithNib() {
            Bundle.main.loadNibNamed("MemberAndTrainerDetailView", owner: self, options: nil)
            memberAndTrainerDetailView.translatesAutoresizingMaskIntoConstraints = false
            memberAndTrainerDetailView.layer.cornerRadius = 15.0
            numberOfPaidUserLabel.layer.cornerRadius = 11.0
            numberOfPaidUserLabel.clipsToBounds = true
            memberAndTrainerDetailView.clipsToBounds = true
            memberAndTrainerDetailView.layer.borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0).cgColor
            memberAndTrainerDetailView.layer.borderWidth = 1.0 
            addSubview(memberAndTrainerDetailView)
            setupLayout()
        }
        
        private func setupLayout() {
            NSLayoutConstraint.activate(
                [
                    memberAndTrainerDetailView.topAnchor.constraint(equalTo: topAnchor),
                    memberAndTrainerDetailView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    memberAndTrainerDetailView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    memberAndTrainerDetailView.trailingAnchor.constraint(equalTo: trailingAnchor),
                ]
            )
        }
    }
