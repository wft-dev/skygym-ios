//
//  CustomAnnotation.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 19/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import Foundation
import UIKit


class CustomAnnotation: UIView {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var gymAddress: UILabel!
    
    
    override func awakeFromNib() {
          // setupLayout()
        }
    

    private func setupLayout() {
//
//          Bundle.main.loadNibNamed("CustomAnnotation", owner: self, options: nil)
//        addSubview(mainView)
//        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                mainView.topAnchor.constraint(equalTo: topAnchor),
                mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
                mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    
}
