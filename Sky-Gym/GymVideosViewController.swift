//
//  GymVideosViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 17/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import AVKit
import SVProgressHUD


class GymVideoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var gymVideoCellView: UIView!
}

class GymVideosViewController: UIViewController {
    @IBOutlet weak var gymVideoCollectionView: UICollectionView!
   // @IBOutlet weak var videoSegment: UISegmentedControl!
    
    var videoUrlArray:[UIImage] = []
    var gymVideoUrlArrayStr:[String] = []
    var deleteVideoIndex:[Int] = []
    var gymVideoUrlArray:[URL] = []
    var isDeleteEnable :Bool = false
    var isImgaeAddedOrDeleted: Bool = false
    var lastElementContentOffsets:CGPoint = .zero
    var playBtnImg = UIImage(named: "play-button")
    var playVideoVC = AVPlayerViewController()
    let spinner = UIActivityIndicatorView()
    let bottomBarView = UIView()
    var bottomBarWidth:CGFloat = .zero
    var videoForRole : Role = .Admin
    var ownerId:String = ""
    var ownerName:String  = ""
    var role:String = ""
    var loggedInID:String = ""

    private let sectionInsets = UIEdgeInsets(
       top: 5.0,
       left: 5.0,
       bottom: 20.0,
       right: 5.0)
       
       private var imagePicker :UIImagePickerController = {
           return UIImagePickerController()
       }()
       
       private var leftBtn:UIButton = {
           let leftBtn = UIButton()
           leftBtn.setImage(UIImage(named: "left-arrow"), for: .normal)
           leftBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
           leftBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
           leftBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
           return leftBtn
       }()
       
       private var addBtn :UIButton = {
           let addBtn = UIButton()
           addBtn.setImage(UIImage(named:"add-image"), for: .normal)
           addBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
           addBtn.heightAnchor.constraint(equalToConstant: 18).isActive = true
           addBtn.widthAnchor.constraint(equalToConstant: 18).isActive = true
           return addBtn
       }()
       
       private var selectBtn:UIButton = {
           let selectBtn = UIButton()
           let selectTitle = NSAttributedString(string: "Select", attributes: [NSAttributedString.Key.foregroundColor:UIColor.blue])
           selectBtn.setAttributedTitle(selectTitle, for: .normal)
           selectBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
           return selectBtn
       }()
       
       private var cancelBtn:UIButton = {
           let cancelBtn = UIButton()
           let cancelTitle = NSAttributedString(string: "Cancel", attributes: [NSAttributedString.Key.foregroundColor:UIColor.blue])
           cancelBtn.setAttributedTitle(cancelTitle, for: .normal)
           cancelBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
           return cancelBtn
       }()

       private var deleteBtn:UIButton = {
           let deleteBtn = UIButton()
           let deleteTitle = NSAttributedString(string: "Delete", attributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
           deleteBtn.setAttributedTitle(deleteTitle, for: .normal)
           deleteBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
           return deleteBtn
       }()
       
       private var refreshController:UIRefreshControl = {
           let refreshControl = UIRefreshControl()
           refreshControl.attributedTitle = NSAttributedString(string: "Reloading images", attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
           return refreshControl
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loggedInID = AppManager.shared.loggedInRole == LoggedInRole.Admin ? AppManager.shared.adminID : AppManager.shared.trainerID
        setGymVideoNavigationBar()
        self.gymVideoCollectionView.dataSource = self
        self.gymVideoCollectionView.delegate = self
        self.playVideoVC.delegate = self
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.gymVideoCollectionView.refreshControl = self.refreshController
        AppManager.shared.videoPageToken = ""
        self.videoForRole = self.role == "Admin" ? .Admin : .Trainer
        self.downloadGymVideos(role: self.videoForRole, id:self.ownerId)
    }
    
    func downloadGymVideos(role:Role,id:String) {
        if self.videoUrlArray.count < self.gymVideoUrlArrayStr.count ||  self.videoUrlArray.count == 0 ||  self.isImgaeAddedOrDeleted == true || self.refreshController.isRefreshing == true {
            SVProgressHUD.show()
            FireStoreManager.shared.downloadGymVideosUrls(id:self.ownerId) { (vidUrlStr, err) in
                if err == nil  && vidUrlStr.count  > 0 {
                    self.gymVideoUrlArrayStr = vidUrlStr
                    FireStoreManager.shared.downloadGymVideo(id: id, pageToken: AppManager.shared.videoPageToken != "" ? AppManager.shared.videoPageToken : nil, role:self.videoForRole) { (gymVideos) in
                        if gymVideos.count > 0 {
                            for singleGymVideo in gymVideos {
                                guard let singleVideoUrl = singleGymVideo.url else  { return }
                                if self.gymVideoUrlArray.contains(singleVideoUrl) == false {
                                    self.gymVideoUrlArray.append(singleVideoUrl)
                                    let image = self.createVideoThumbnail(videoUrl: singleVideoUrl)
                                    if image != nil {
                                        self.videoUrlArray.append(image!)
                                    }
                                }
                            }
                            if self.videoUrlArray.count >= self.gymVideoUrlArray.count || self.isImgaeAddedOrDeleted == true || self.refreshController.isRefreshing == true {
                                self.gymVideoCollectionView.reloadData()
                                self.isImgaeAddedOrDeleted = false
                                self.refreshController.endRefreshing()
                                SVProgressHUD.dismiss()
                            }
                        } else {
                            SVProgressHUD.dismiss()
                        }
                    }
                } else {
                    self.videoUrlArray.removeAll()
                    self.gymVideoCollectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func setGymVideoNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Videos", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        
        addBtn.addTarget(self, action: #selector(addNewVideo), for: .touchUpInside)
        selectBtn.addTarget(self, action: #selector(selectDeleteVideo), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelSelection), for: .touchUpInside)
        leftBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteImages), for: .touchUpInside)
        
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,leftBtn])
        stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let rightSpaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        let rightstackView = UIStackView(arrangedSubviews: [selectBtn,rightSpaceBtn,addBtn])
     
        if AppManager.shared.loggedInRole == LoggedInRole.Admin {
            self.addBtn.isEnabled = self.ownerId == self.loggedInID ? true : false
            self.addBtn.isHidden = self.ownerId == self.loggedInID ? false : true
            self.addBtn.alpha = self.ownerId == self.loggedInID ? 1.0 : 0.0
            navigationItem.setRightBarButton(UIBarButtonItem(customView: rightstackView), animated: true)
        } else {
            if self.ownerId == self.loggedInID {
                navigationItem.setRightBarButton(UIBarButtonItem(customView: rightstackView), animated: true)
            }
        }
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView), animated: true)
    }
    
    @objc func refresh() {
        self.downloadGymVideos(role: self.videoForRole, id: self.ownerId)
    }
    
    @objc func addNewVideo() {
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func selectDeleteVideo() {
        self.isDeleteEnable = true
        DispatchQueue.main.async {
            self.navigationItem.titleView = nil
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView: self.deleteBtn), animated: true)
            self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: self.cancelBtn), animated: true)
            self.deleteBtn.isEnabled = false
            self.deleteBtn.alpha = 0.4
        }
    }
    
    @objc func cancelSelection() {
        self.isDeleteEnable = false
        self.deleteVideoIndex.removeAll()
        self.gymVideoCollectionView.reloadData()
        DispatchQueue.main.async {
            self.setGymVideoNavigationBar()
        }
    }
    
    @objc func backAction() {  self.navigationController?.popViewController(animated: true) }
  
    @objc func deleteImages() {
        SVProgressHUD.show()
        var deletingImgUrlsArray : [String] = []
        if self.deleteVideoIndex.count > 0 {
            for singleImgIndex in self.deleteVideoIndex {
                deletingImgUrlsArray.append(self.gymVideoUrlArrayStr[singleImgIndex])
            }
            
            FireStoreManager.shared.deleteVideos(id: self.ownerId , urls: deletingImgUrlsArray) { (err) in
                SVProgressHUD.dismiss()
                if err == nil {
                    print("Success")
                    self.isImgaeAddedOrDeleted = true
                    self.isDeleteEnable = false
                    self.videoUrlArray = self.videoUrlArray.enumerated().filter({ !self.deleteVideoIndex.contains($0.0) }).map { $0.1 }
                    self.gymVideoUrlArray = self.gymVideoUrlArray.enumerated().filter({ !self.deleteVideoIndex.contains($0.0) }).map { $0.1 }
                    
                    print("VIDEO ARRAY : \(self.videoUrlArray)")
                    self.deleteVideoIndex.removeAll()
                    self.setGymVideoNavigationBar()
                    DispatchQueue.main.async {
                      self.downloadGymVideos(role: self.videoForRole, id: self.ownerId)
                    }
                }else {
                    print("\(err!)")
                    print("Try again")
                }
            }
        }
    }
    
    func addVideoForDelete(index:Int)  {
        if self.deleteVideoIndex.contains(index) {
            self.deleteVideoIndex.remove(at: self.deleteVideoIndex.firstIndex(of: index)!)
        }else {
            self.deleteVideoIndex.append(index)
        }
        let deleteCount = self.deleteVideoIndex.count
        self.deleteBtn.isEnabled = deleteCount > 0 ? true : false
        self.deleteBtn.alpha = deleteCount > 0 ? 1.0 : 0.4
    }
    
    func uploadVideo(videoUrl:URL) {
        let id = AppManager.shared.loggedInRole == LoggedInRole.Admin ? AppManager.shared.adminID : AppManager.shared.trainerID
        let role:Role = AppManager.shared.loggedInRole == LoggedInRole.Admin ? .Admin : .Trainer
        SVProgressHUD.show()
        FireStoreManager.shared.uploadGymVideo(id: id , url: videoUrl, role: role) { (err) in
            if err == nil {
                print("VIDEO IS UPLOADED SUCCESSFULLY.")
                self.isImgaeAddedOrDeleted = true
                self.downloadGymVideos(role: self.videoForRole, id: self.ownerId)
            }else {
                SVProgressHUD.dismiss()
                print("VIDEO IS NOT UPLOADED  SUCCESSFULLY.")
            }
        }
    }
    
    func createVideoThumbnail(videoUrl:URL) -> UIImage? {
        let videoAsset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        imageGenerator.appliesPreferredTrackTransform = false
        
        do{
            let cgImg = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImg)
        }catch {
            print("ERROR IN CONVERTING THUMBNAIL IMAGE.")
            return nil
        }
    }
    
    func playVideo(url:URL)  {
        print("ARRAY COUNT URL ARRAY : \(self.gymVideoUrlArray.count)")
        print(" VIDEO CONTAIN :  \(self.gymVideoUrlArray.contains(url))")
        let player = AVPlayer(url: url)
        self.playVideoVC.player = player
        self.navigationController?.pushViewController(self.playVideoVC, animated: true)
    }
    
  }


extension GymVideosViewController  : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoUrlArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gymVideoCell", for: indexPath) as! GymVideoCollectionCell
        
        let _ = cell.gymVideoCellView.subviews.map {
            if $0.isKind(of: UIImageView.self) {
                $0.removeFromSuperview()
            }
        }
        
        let imageView = UIImageView(image: self.videoUrlArray[indexPath.row])
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = self.deleteVideoIndex.contains(indexPath.row) ? 0.5 : 1.0
        let playBtnImgView = UIImageView(image: self.playBtnImg)
        playBtnImgView.contentMode = .center
        imageView.addSubview(playBtnImgView)
        cell.gymVideoCellView.addSubview(imageView)

        playBtnImgView.translatesAutoresizingMaskIntoConstraints = false
        playBtnImgView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 0).isActive = true
        playBtnImgView.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: 0).isActive = true
        playBtnImgView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0).isActive = true
        playBtnImgView.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 0).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: cell.gymVideoCellView.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: cell.gymVideoCellView.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: cell.gymVideoCellView.bottomAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: cell.gymVideoCellView.leftAnchor, constant: 0).isActive = true
        
        return cell
    }
}

extension GymVideosViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isDeleteEnable {
            self.addVideoForDelete(index: indexPath.row)
            self.gymVideoCollectionView.reloadData()
        }else {
            print("INDEX IS : \(indexPath.row), URL : \(self.gymVideoUrlArray[indexPath.row]) ")
             self.playVideo(url:self.gymVideoUrlArray[indexPath.row])
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y >= self.lastElementContentOffsets.y/3 {
            spinner.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                self.downloadGymVideos(role: .Admin, id: self.ownerId)
                self.spinner.stopAnimating()
            })
        } else {
            print(" Not scrolling. ")
        }
    }
    
}

extension GymVideosViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize  = (view.frame.width-20)/3
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
     return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionFooter {
//            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyFooterView", for: indexPath)
//            footer.addSubview(spinner)
//            spinner.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
//            return footer
//        }
//        return UICollectionReusableView()
//    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.videoUrlArray.count - 1 {
            self.lastElementContentOffsets = cell.frame.origin
        }
    }
    
}

extension GymVideosViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedVideoUrl = info[.mediaURL] as? URL else {
            print("ERROR IN FETCHING VIDEO URL.")
            return
        }
        self.uploadVideo(videoUrl: selectedVideoUrl)
        self.dismiss(animated: true, completion: nil)
    }
}


extension GymVideosViewController : AVPlayerViewControllerDelegate {
    
}
