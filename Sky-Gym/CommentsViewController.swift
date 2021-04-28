//
//  CommentsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 27/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class CommentsTableCell: UITableViewCell {
    @IBOutlet weak var commentingUserImg: UIImageView!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
}

class CommentsViewController: UIViewController {

    @IBOutlet weak var commentMainView: UIView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentsTable: UITableView!
    
    private var leftBtn:UIButton = {
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        leftBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        leftBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return leftBtn
    }()
    
    private var sendBtn:UIButton = {
        let sendBtn = UIButton()
        sendBtn.setImage(UIImage(named: "send"), for: .normal)
        sendBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        sendBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return sendBtn
    }()
    
    var stackView:UIStackView? = nil
    var rightStackView:UIStackView? = nil
    var commentArray:[Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCommentsUI()
    }
    
    func setUpCommentsUI() {
        userImgView.image = UIImage(named: "user")
        userImgView.layer.cornerRadius = userImgView.frame.height/2
        commentTextField.layer.cornerRadius = 15.0
        commentTextField.layer.backgroundColor = UIColor.white.cgColor
        commentTextField.addPaddingToTextField()
        setUploadPhotoNavigationBar()
        
        commentArray = [
            Comment(userID: "44343", userName: "Sagar", commentStr: "nice",userImg: UIImage(named: "user1"),time: "1h ago"),
            Comment(userID: "44343", userName: "Sagar", commentStr: "nice",userImg: UIImage(named: "user1"),time: "1h ago"),
            Comment(userID: "44343", userName: "Sagar", commentStr: "nice",userImg: UIImage(named: "user1"),time: "1h ago"),
            Comment(userID: "44343", userName: "Sagar", commentStr: "nice",userImg: UIImage(named: "user1"),time: "1h ago")
        ]
        
        self.commentsTable.separatorStyle = .none
        self.commentsTable.tableFooterView = UIView()
    }
    
    func setUploadPhotoNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Comments", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 20)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        leftBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        sendBtn.addTarget(self, action: #selector(nextPostAction), for: .touchUpInside)
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        stackView =  UIStackView(arrangedSubviews: [spaceBtn,leftBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        rightStackView =  UIStackView(arrangedSubviews: [spaceBtn,sendBtn])
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

extension CommentsViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableCell
        let singleComment = self.commentArray[indexPath.row]
        cell.commentingUserImg.layer.cornerRadius = cell.commentingUserImg.frame.height/2
        cell.commentingUserImg.image = singleComment.userImg
        cell.userComment.attributedText = AppManager.shared.getAttributedCaption(userName: singleComment.userName, caption: singleComment.commentStr)
        cell.timeAgoLabel.text = singleComment.time
        cell.selectionStyle = .none
        
        return cell
    }
    
}

extension CommentsViewController : UITableViewDelegate {}
