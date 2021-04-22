//
//  GymPostFeedsPageViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 22/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class PostFeedCell: UITableViewCell {
    @IBOutlet weak var postFeedMainView: UIView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var userNameForCaptionLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var viewAllCommentBtn: UIButton!
    @IBOutlet weak var latestCommentUserNameLabel: UILabel!
    @IBOutlet weak var latestCommentLabel: UILabel!
    @IBOutlet weak var secondLatestCommentUserNameLabel: UILabel!
    @IBOutlet weak var secondLatestCommentLabel: UILabel!
    @IBOutlet weak var timeOfPostLabel: UILabel!
    
    override func awakeFromNib() {
        likeBtn.addTarget(self, action: #selector(likePostAction), for: .touchUpInside)
        dislikeBtn.addTarget(self, action: #selector(dislikePostAction), for: .touchUpInside)
    }
    
  @objc  func likePostAction() {
    likeBtn.setImage(UIImage(named: "like-fill"), for: .normal)
    }
    
    @objc  func dislikePostAction() {
        
    }
    
}


class GymPostFeedsPageViewController: UIViewController {

    @IBOutlet weak var postFeedTable: UITableView!
    
    private var menuBtn:UIButton = {
        let menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        menuBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        menuBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return menuBtn
    }()
    
    var stackView:UIStackView? = nil
    
    var commentArray:[Comment] = []
    var postsArray:[Posts] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPostsFeedNavigationBar()
        postFeedTable.separatorStyle = .none
        
        commentArray = [
            Comment(userID: "4444", userName: "Sagar",commentStr: "Nice keep it up.")
        ]
        
        postsArray = [
           Posts(userID: "64628", userNameImg: UIImage(named: "user")!, userName: "Sagar Bohat", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption: "My First post.Please like and comment.", comments: commentArray,timeForPost: "1 hour ago"),
           Posts(userID: "64628", userNameImg: UIImage(named: "user")!, userName: "Sagar Kumar", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption: "My First post.Please like and comment.", comments: commentArray,timeForPost: "2 hour ago"),
           Posts(userID: "64628", userNameImg: UIImage(named: "user")!, userName: "Sagar Bohat", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption: "My First post.Please like and comment.", comments: commentArray,timeForPost: "3 hour ago"),
           Posts(userID: "64628", userNameImg: UIImage(named: "user")!, userName: "Sagar Kumar", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption: "My First post.Please like and comment.", comments: commentArray,timeForPost: "4 hour ago")
        ]
        
    }
    
    func setPostsFeedNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Sky-Gym Posts", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 20)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        stackView =  UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
    }
    
     @objc func menuChange() {  AppManager.shared.appDelegate.swRevealVC.revealToggle(self) }

}

extension GymPostFeedsPageViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postFeedCell", for: indexPath) as! PostFeedCell
        let singlePost = postsArray[indexPath.row]
        let comment = commentArray[0]
        
        
        cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
        
        
        cell.userImg.image = singlePost.userNameImg
        cell.userNameLabel.text = singlePost.userName
        cell.postImg.image = singlePost.postImg
        cell.totalLikesLabel.text = "100 likes"
        cell.userNameForCaptionLabel.text = singlePost.userName
        cell.captionLabel.text = singlePost.caption
        cell.latestCommentUserNameLabel.text = comment.userName
        cell.latestCommentLabel.text = comment.commentStr
        cell.secondLatestCommentUserNameLabel.text = comment.userName
        cell.secondLatestCommentLabel.text = comment.commentStr
        cell.timeOfPostLabel.text = singlePost.timeForPost
        
        
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    
}

extension GymPostFeedsPageViewController:UITableViewDelegate{}
