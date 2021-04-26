//
//  UploadPhotoViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 26/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class UploadPhotoViewController: UIViewController {
    private var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return leftBtn
    }()
    
    private var nextBtn:UIButton = {
        let nextBtn = UIButton()
        nextBtn.setTitle("next", for: .normal)
        nextBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        nextBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        nextBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return nextBtn
    }()
    
    var stackView:UIStackView? = nil
    var rightStackView:UIStackView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setUploadPhotoNavigationBar()
    }
    
    func setUploadPhotoNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "New Post", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 20)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        leftBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextPostAction), for: .touchUpInside)
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        stackView =  UIStackView(arrangedSubviews: [spaceBtn,leftBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        rightStackView =  UIStackView(arrangedSubviews: [spaceBtn,nextBtn])
        rightStackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true

        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        
        navigationItem.setRightBarButton(UIBarButtonItem(customView: rightStackView!), animated: true)
    }
    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func nextPostAction(){
        self.navigationController?.popViewController(animated: true)
    }

}
