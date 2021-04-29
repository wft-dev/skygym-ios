//
//  UploadPhotoViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 26/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class UploadPhotoViewController: UIViewController {
    
    @IBOutlet weak var newPostImg: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
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
        nextBtn.setAttributedTitle(NSAttributedString(string: "Share", attributes: [
            NSAttributedString.Key.foregroundColor:UIColor.black,
            NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 18)!
        ]), for: .normal)
        nextBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        nextBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        nextBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        return nextBtn
    }()
    
    var stackView:UIStackView? = nil
    var rightStackView:UIStackView? = nil
    var selecteImage:UIImage? = nil
    var userName:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setUploadPhotoNavigationBar()
        self.newPostImg.image = selecteImage
        self.captionTextView.layer.cornerRadius = 7.0
        self.captionTextView.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
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
        rightStackView?.widthAnchor.constraint(equalToConstant: 110).isActive = true

        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        navigationItem.setRightBarButton(UIBarButtonItem(customView: nextBtn), animated: true)
    }
    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func nextPostAction(){
        let alertController = UIAlertController(title: "Attention", message: "Do you want to post this ?", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.shareAction()
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func shareAction() {
        SVProgressHUD.show()
        FireStoreManager.shared.uploadNewPostFor(postID: "\(Int.random(in: 0 ..< 99999))",parentID:getParentID(),data: takeData()) { (err) in
            SVProgressHUD.dismiss()
            if err == nil {
                self.showUploadPhotAlert(title: "Success", msg: "New post is uploaded successfully.")
            }else {
                self.showUploadPhotAlert(title: "Faiure", msg: "Something went wrong, please try again.")
            }
        }
    }
    
    func showUploadPhotAlert(title:String,msg:String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if title == "Success" {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func takeData() -> Dictionary<String,Any> {
        let uploadData:[String:Any] = [
            "postImgData" : self.newPostImg.image?.jpegData(compressionQuality: 0.5),
            "isLiked" :  false,
            "isUnliked": false,
            "caption" :  self.captionTextView.text!,
            "likeCount" : 0,
            "dislikeCount":0
        ]
        return uploadData
    }
    
    private func getParentID() -> String {
        var parentID:String = ""
        switch AppManager.shared.loggedInRole {
        case .Admin:
            parentID = ""
            break
        case .Member :
            parentID = AppManager.shared.memberID
            break
        case .Trainer :
            parentID = AppManager.shared.trainerID
            break
        default:
            break
        }
        return parentID
    }

    

}
