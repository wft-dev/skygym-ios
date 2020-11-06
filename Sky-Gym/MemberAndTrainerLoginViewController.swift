//
//  MemberAndTrainerLoginViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit

class MemberAndTrainerLoginViewController: UIViewController {
    
    
    @IBOutlet weak var gymIDTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var gymIDErrroText: UILabel?
    @IBOutlet weak var emailErrorText: UILabel?
    @IBOutlet weak var passwordErrorText: UILabel?
    @IBOutlet weak var loginBtn: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground()
        [gymIDTextField,emailTextField,passwordTextField].forEach{
                   $0?.layer.cornerRadius = 15.0
                   $0?.borderStyle = .none
                   $0?.clipsToBounds = true
                  // $0?.addTarget(self, action: #selector(errorChecker(_:)), for: .editingChanged)
                   $0?.addPaddingToTextField()
               }
        loginBtn?.layer.cornerRadius = 15.0
        loginBtn?.clipsToBounds = true
        
    }
}

extension MemberAndTrainerLoginViewController {
    func assignbackground(){
              let background = UIImage(named: "Bg_yel.png")
              var imageView : UIImageView!
              imageView = UIImageView(frame: view.bounds)
              imageView.contentMode =  UIView.ContentMode.scaleToFill
              imageView.clipsToBounds = true
              imageView.image = background
              imageView.center = view.center
              view.addSubview(imageView)
              self.view.sendSubviewToBack(imageView)
          }
}
