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
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var viewAllCommentBtn: UIButton!
    @IBOutlet weak var latestCommentUserNameLabel: UILabel!
    @IBOutlet weak var latestCommentLabel: UILabel!
    @IBOutlet weak var secondLatestCommentUserNameLabel: UILabel!
    @IBOutlet weak var secondLatestCommentLabel: UILabel!
    @IBOutlet weak var timeOfPostLabel: UILabel!
   // @IBOutlet weak var captionHeightConstraint: NSLayoutConstraint!
    var delegate:PostFeed? = nil
}

class GymPostFeedsPageViewController: UIViewController {

    @IBOutlet weak var postFeedTable: UITableView!
    var newPostImg:UIImage? = nil
    
    private var menuBtn:UIButton = {
        let menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        menuBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        menuBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return menuBtn
    }()
    
    private var addBtn:UIButton = {
        let addBtn = UIButton()
        addBtn.setImage(UIImage(named: "add-image"), for: .normal)
        addBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        addBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return addBtn
    }()
    
    lazy private var imagePicker:UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    var stackView:UIStackView? = nil
    var commentArray:[Comment] = []
    var postsArray:[Posts] = []
    var likeArray:[Int] = []
    var dislikeArray:[Int] = []
    var captionExpand:[Int] = []
    var likeImgName = "like"
    var dislikeImgName = "dislike"
    var userName:String = ""
    var userImg:UIImage? = nil
    let semaphores = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPostsFeedNavigationBar()
        postFeedTable.shouldIgnoreScrollingAdjustment = true
        postFeedTable.separatorStyle = .none
        postFeedTable.allowsSelection = false
        postFeedTable.estimatedRowHeight = UITableView.automaticDimension
        imagePicker.delegate = self
        
        self.likeArray.removeAll()
        self.dislikeArray.removeAll()
        
//        commentArray = [
//            Comment(userID: "4444", userName: "Sagar",commentStr: "Nice keep it up.")
//        ]
//
//        let caption = "My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment.My First post.Please like and comment sagar."
//
//        postsArray = [
//           Posts(userID: "64628", userNameImg: UIImage(named: "user")!, userName: "Sagar Bohat", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption:caption, comments: commentArray,timeForPost: "1 hour ago"),
//           Posts(userID: "6545", userNameImg: UIImage(named: "user")!, userName: "Sagar Kumar", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption: "My First post.Please like and comment.", comments: commentArray,timeForPost: "2 hour ago"),
//           Posts(userID: "5545", userNameImg: UIImage(named: "user")!, userName: "Sagar Bohat", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption: "My First post.Please like and comment.", comments: commentArray,timeForPost: "3 hour ago"),
//           Posts(userID: "3221", userNameImg: UIImage(named: "user")!, userName: "Sagar Kumar", postImg: UIImage(named: "pexels")!, isLiked: true, isUnliked: false, likesCount: 1, unlikesCount: 0, caption: caption, comments: commentArray,timeForPost: "4 hour ago")
//        ]
        
        self.fetchPosts()
    }
    
    func fetchPosts() {
        self.postsArray.removeAll()
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.fetchPost()
            DispatchQueue.main.async {
                switch result {
                case let .success(postsDetailsArray):
                    postsDetailsArray.forEach { (singlePost) in
                        //self.postsArray.append(self.getCompleteSinglePost(data: singlePost))
                        self.getCompleteSinglePost(data: singlePost)
                    }
                    self.reload(tableView: self.postFeedTable)
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func getCompleteSinglePost(data:[String:Any]) {
        let postData = data["postDetails"] as! [String:Any]
        self.fetchUserDetail(id: data["parentID"] as! String)
    }
    
   private func fetchUserDetail(id:String) {
        DispatchQueue.global(qos: .default).async {
            let result = FireStoreManager.shared.isMemberWith(id: id)
            DispatchQueue.main.async {
                switch result {
                case let .success(flag):
                    self.fetchUserInfo(flag: flag, id: id)
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func fetchUserInfo(flag:Bool,id:String) {
        if flag == true  {
            self.getMemberName(memberID: id)
        } else {
            self.getTrainerName(trainerID: id)
        }
        self.getUserImg(imgUrl: "Images/\(id)/userProfile.png")
    }
   
    private func getMemberName(memberID:String) {
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getMemberNameBy(id: memberID)
            
            DispatchQueue.main.async {
                switch result {
                case let  .success(member):
                    self.userName = member.memberName
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func getTrainerName(trainerID:String) {
        DispatchQueue.global(qos: .background).async {
            let result = FireStoreManager.shared.getTrainerNameAndTypeBy(id: trainerID)
            
            DispatchQueue.main.async {
                switch result {
                case let  .success(trainer):
                    self.userName = trainer.first!
                    break
                case .failure(_):
                    break
                }
            }
            
        }
    }
    
    private func getUserImg(imgUrl:String) {
        DispatchQueue.global(qos: .background).async {
          let result =  FireStoreManager.shared.downloadImage(imgUrl: imgUrl)
            DispatchQueue.main.async {
                switch result {
                case let .success(url):
                    do {
                        let imgData = try Data(contentsOf: url)
                        self.userImg = UIImage(data: imgData)
                    } catch let err { print("Error is : \(err)") }
                    break
                case .failure(_):
                    break
                }
            }
        }
        
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
        addBtn.addTarget(self, action: #selector(addPostAction), for: .touchUpInside)
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        stackView =  UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView!), animated: true)
        navigationItem.setRightBarButton(UIBarButtonItem(customView: addBtn), animated: true)
    }
    
     @objc func menuChange() {  AppManager.shared.appDelegate.swRevealVC.revealToggle(self) }
    
     @objc func addPostAction() {
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }

    @objc  func likePostAction(_ sender:UIButton) {
        if self.likeArray.contains(sender.tag) {
            self.likeArray.remove(at: self.likeArray.firstIndex(of: sender.tag)!)
        }else {
            if self.dislikeArray.contains(sender.tag) {
                self.dislikeArray.remove(at: self.dislikeArray.firstIndex(of: sender.tag)!)
            }
            self.likeArray.append(sender.tag)
        }
         self.reload(tableView: postFeedTable)
    }
    
    @objc  func dislikePostAction(_ sender:UIButton) {
        if self.dislikeArray.contains(sender.tag) {
            self.dislikeArray.remove(at: self.dislikeArray.firstIndex(of: sender.tag)!)
        }else {
            if self.likeArray.contains(sender.tag) {
                self.likeArray.remove(at: self.likeArray.firstIndex(of: sender.tag)!)
            }
            self.dislikeArray.append(sender.tag)
        }
        self.reload(tableView: postFeedTable)
    }
    
    @objc func showFullCaption(_ sender:UIButton) {
        if captionExpand.contains(sender.tag) == false {
             captionExpand.append(sender.tag)
             self.reload(tableView: postFeedTable)
        }
    }
    
    @objc func viewAllCommentAction(_ sender:UIButton) {
        let commentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "commentsVC") as! CommentsViewController
        commentsVC.userImg = self.userImg
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func reload(tableView: UITableView) {
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
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
        cell.captionLabel.attributedText = AppManager.shared.getAttributedCaption(userName: singlePost.userName, caption: singlePost.caption)
        cell.latestCommentUserNameLabel.text = comment.userName
        cell.latestCommentLabel.text = comment.commentStr
        cell.secondLatestCommentUserNameLabel.text = comment.userName
        cell.secondLatestCommentLabel.text = comment.commentStr
        cell.timeOfPostLabel.text = singlePost.timeForPost
        
        cell.moreBtn.tag = indexPath.row
        cell.likeBtn.tag = indexPath.row
        cell.dislikeBtn.tag = indexPath.row
        
        likeImgName = self.likeArray.contains(indexPath.row) ? "like-fill" : "like"
        dislikeImgName = self.dislikeArray.contains(indexPath.row) ? "dislike-fill" : "dislike"
        cell.captionLabel.numberOfLines = self.captionExpand.contains(indexPath.row) ? 0 : 3
        
        cell.likeBtn.setImage(UIImage(named:likeImgName ), for: .normal)
        cell.dislikeBtn.setImage(UIImage(named: dislikeImgName), for: .normal)

        cell.likeBtn.addTarget(self, action: #selector(likePostAction(_ :)), for: .touchUpInside)
        cell.dislikeBtn.addTarget(self, action: #selector(dislikePostAction(_ :)), for: .touchUpInside)
        cell.viewAllCommentBtn.addTarget(self, action: #selector(viewAllCommentAction(_ :)), for: .touchUpInside)
        
        if captionExpand.contains(indexPath.row) {
            cell.moreBtn.removeTarget(self, action: #selector(showFullCaption(_ :)), for: .touchUpInside)
            cell.moreBtn.isHidden = true
            cell.moreBtn.isUserInteractionEnabled = false
            cell.moreBtn.alpha = 0.0
        }else {
            cell.moreBtn.addTarget(self, action: #selector(showFullCaption(_ :)), for: .touchUpInside)
            cell.moreBtn.isHidden = false
            cell.moreBtn.isUserInteractionEnabled = true
            cell.moreBtn.alpha = 1.0
        }
        
        cell.isUserInteractionEnabled = true
       
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
}

extension GymPostFeedsPageViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}

extension GymPostFeedsPageViewController:PostFeed {
    
    func reloadFeedTable() {
        self.postFeedTable.reloadData()
    }
    
}

extension GymPostFeedsPageViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image:UIImage = info[.editedImage] as? UIImage {
            self.newPostImg  = image
        }
        dismiss(animated: true) {
            let uploadPhotoVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "uploadPhotoVC") as! UploadPhotoViewController
            uploadPhotoVc.selecteImage = self.newPostImg
            self.navigationController?.pushViewController(uploadPhotoVc, animated: true)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
