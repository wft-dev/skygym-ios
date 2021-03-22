//
//  ListOfVideosViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 19/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    
    private var addBtn :UIButton = {
        let addBtn = UIButton()
        addBtn.setImage(UIImage(named:"add-image"), for: .normal)
        addBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        addBtn.heightAnchor.constraint(equalToConstant: 18).isActive = true
        addBtn.widthAnchor.constraint(equalToConstant: 18).isActive = true
        return addBtn
    }()
    
    private var imagePicker :UIImagePickerController = {
        return UIImagePickerController()
    }()
    
    var isImgaeAddedOrDeleted:Bool = false

    @IBOutlet weak var listOfVideosTable: UITableView!
    var listOfVideoArray:[VideoList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listOfVideosTable.delegate = self
        listOfVideosTable.dataSource = self
        setListOfVideoNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchVideos()
    }
    
    func fetchVideos()  {
        FireStoreManager.shared.downloadListOfGymVideos { (arr) in
            if arr.count > 0 {
                for sinleVid in arr {
                    switch sinleVid.role {
                    case "admin":
                        DispatchQueue.global(qos: .background).async {
                            let result = FireStoreManager.shared.getAdminNameBy(id: sinleVid.ownerID)
                            DispatchQueue.main.async {
                                switch result {
                                case let  .success(admin):
                                    self.listOfVideoArray.append(VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: admin, ownerRole: "Admin", ownerID: sinleVid.ownerID))
                                    if self.listOfVideoArray.count == arr.count {
                                        self.listOfVideosTable.reloadData()
                                    }
                                    break
                                case .failure(_):
                                    break
                                }
                            }
                        }
                        break
                    case "trainer" :
                        DispatchQueue.global(qos: .background).async {
                            let result = FireStoreManager.shared.getTrainerNameAndTypeBy(id: sinleVid.ownerID)
                            DispatchQueue.main.async {
                                switch result {
                                case let  .success(trainer):
                                    self.listOfVideoArray.append(VideoList(videoImgae: UIImage(named: "video-gallery")!, ownerName: trainer.first!, ownerRole: "Trainer (Type : \(trainer.last!))", ownerID: sinleVid.ownerID))
                                    if self.listOfVideoArray.count == arr.count {
                                        self.listOfVideosTable.reloadData()
                                    }
                                    break
                                case .failure(_):
                                    break
                                }
                            }
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
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
        addBtn.addTarget(self, action: #selector(addNewVideo), for: .touchUpInside)
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView), animated: true)
        navigationItem.setRightBarButton(UIBarButtonItem(customView: addBtn), animated: true)
    }
    
    func uploadGymVideo(videoUrl:URL) {
        let id = AppManager.shared.loggedInRole == LoggedInRole.Admin ? AppManager.shared.adminID : AppManager.shared.trainerID
        let role:Role = AppManager.shared.loggedInRole == LoggedInRole.Admin ? .Admin : .Trainer
        SVProgressHUD.show()
        FireStoreManager.shared.uploadGymVideo(id: id , url: videoUrl, role: role) { (err) in
            if err == nil {
                print("VIDEO IS UPLOADED SUCCESSFULLY.")
                self.isImgaeAddedOrDeleted = true
                self.fetchVideos()
                SVProgressHUD.dismiss()
            }else {
                SVProgressHUD.dismiss()
                print("VIDEO IS NOT UPLOADED  SUCCESSFULLY.")
            }
        }
    }
    
     @objc func menuChange() {  AppManager.shared.appDelegate.swRevealVC.revealToggle(self) }
    
    @objc func addNewVideo() {
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
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
        cell.selectionStyle = .none
        
        return cell
    }
    
}


extension ListOfVideosViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gymVideoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "gymVideoVC") as! GymVideosViewController
        gymVideoVC.ownerId = self.listOfVideoArray[indexPath.row].ownerID
        gymVideoVC.ownerName = self.listOfVideoArray[indexPath.row].ownerName
        gymVideoVC.role = self.listOfVideoArray[indexPath.row].ownerRole
        self.navigationController?.pushViewController(gymVideoVC, animated: true)
    }
    
}


extension ListOfVideosViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedVideoUrl = info[.mediaURL] as? URL else {
            print("ERROR IN FETCHING VIDEO URL.")
            return
        }
        self.uploadGymVideo(videoUrl: selectedVideoUrl)
        self.dismiss(animated: true, completion: nil)
    }
}
