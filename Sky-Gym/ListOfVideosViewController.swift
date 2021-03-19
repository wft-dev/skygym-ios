//
//  ListOfVideosViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 19/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class ListOfVideosCell: UITableViewCell {
    @IBOutlet weak var listOfVideosCellMainView: UIView!
    @IBOutlet weak var videoImg: UIImageView!
    @IBOutlet weak var videoOwnerNameTitle: UILabel!
    @IBOutlet weak var videoOwnerRoleTitle: UILabel!
}

class ListOfVideosViewController: UIViewController {
    
    private var menuBtn:UIButton = {
        let menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        menuBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        menuBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return menuBtn
    }()

    @IBOutlet weak var listOfVideosTable: UITableView!
    var listOfVideoArray:[VideoList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listOfVideosTable.delegate = self
        listOfVideosTable.dataSource = self
        setListOfVideoNavigationBar()
        listOfVideoArray = [
            VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: "Sagar", ownerRole: "Admin"),
            VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: "Trainer 1", ownerRole: "Trainer"),
            VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: "Trainer 2", ownerRole: "Trainer"),
            VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: "Trainer 3", ownerRole: "Trainer"),
            VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: "Trainer 4", ownerRole: "Trainer"),
            VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: "Trainer 5", ownerRole: "Trainer"),
            VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: "Trainer 6", ownerRole: "Trainer"),
        ]
    }
    
    
       func setListOfVideoNavigationBar()  {
           self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
           self.navigationController?.navigationBar.shadowImage = UIImage()
           self.navigationController?.navigationBar.isTranslucent = true
           let title = NSAttributedString(string: "List of Videos", attributes: [
               NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
           ])
           let titleLabel = UILabel()
           titleLabel.attributedText = title
           navigationItem.titleView = titleLabel
    
//           addBtn.addTarget(self, action: #selector(addNewVideo), for: .touchUpInside)
//           selectBtn.addTarget(self, action: #selector(selectDeleteVideo), for: .touchUpInside)
//           cancelBtn.addTarget(self, action: #selector(cancelSelection), for: .touchUpInside)
            menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
//           deleteBtn.addTarget(self, action: #selector(deleteImages), for: .touchUpInside)
//
           let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
           let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
           stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
//
//           let rightSpaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
//           let rightstackView = UIStackView(arrangedSubviews: [selectBtn,rightSpaceBtn,addBtn])
           
//           if AppManager.shared.loggedInRole == LoggedInRole.Admin {
//               navigationItem.setRightBarButton(UIBarButtonItem(customView: rightstackView), animated: true)
//           }
           navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView), animated: true)
       }
    
     @objc func menuChange() {  AppManager.shared.appDelegate.swRevealVC.revealToggle(self) }
    
}


extension ListOfVideosViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfVideoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listOfVideosCell", for: indexPath) as! ListOfVideosCell
        
        let singleVideo = self.listOfVideoArray[indexPath.row]
        
        cell.videoImg.image = singleVideo.videoImgae
        cell.videoOwnerNameTitle.text = "\(singleVideo.ownerName)"
        cell.videoOwnerRoleTitle.text = "\(singleVideo.ownerRole)"
        
        return cell
    }
    
    
}


extension ListOfVideosViewController : UITableViewDelegate {
    
}
