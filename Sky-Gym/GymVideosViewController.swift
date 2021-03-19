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
    @IBOutlet weak var videoSegment: UISegmentedControl!
    
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
    var  videoForRole : Role = .Admin

    private let sectionInsets = UIEdgeInsets(
       top: 5.0,
       left: 5.0,
       bottom: 20.0,
       right: 5.0)
       
       private var imagePicker :UIImagePickerController = {
           return UIImagePickerController()
       }()
       
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
           let cancelBtn = UIButton()
           let cancelTitle = NSAttributedString(string: "Delete", attributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
           cancelBtn.setAttributedTitle(cancelTitle, for: .normal)
           cancelBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
           return cancelBtn
       }()
       
       private var refreshController:UIRefreshControl = {
           let refreshControl = UIRefreshControl()
           refreshControl.attributedTitle = NSAttributedString(string: "Reloading images", attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
           return refreshControl
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGymVideoNavigationBar()
        setVideoSegment()
        self.gymVideoCollectionView.dataSource = self
        self.gymVideoCollectionView.delegate = self
        self.playVideoVC.delegate = self
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.gymVideoCollectionView.refreshControl = self.refreshController
        AppManager.shared.videoPageToken = ""
        self.downloadGymVideos(role: self.videoForRole)
    }
    
    func setVideoSegment()  {
        videoSegment.setTitle("Admin", forSegmentAt: 0)
        videoSegment.setTitle("Trainers", forSegmentAt: 1)

        if #available(iOS 13.0, *) {
            videoSegment.setBackgroundImage(UIImage(), for: .normal, barMetrics: UIBarMetrics.default)
            videoSegment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: UIBarMetrics.default)
            videoSegment.selectedSegmentTintColor = .clear
        } else {
            videoSegment.backgroundColor = .clear
            videoSegment.tintColor = .clear
        }

        videoSegment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor:UIColor.black,
            NSAttributedString.Key.font:UIFont(name: "Poppins-Medium", size: 20)!
        ], for: .normal)
        videoSegment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor:UIColor(red: 204/255, green: 204/255, blue: 0/255, alpha: 1.0),
            NSAttributedString.Key.font:UIFont(name: "Poppins-Medium", size: 20)!
        ], for: .selected)
        bottomBarWidth = videoSegment.frame.width / CGFloat(videoSegment.numberOfSegments)
        bottomBarView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 0/255, alpha: 1.0)
        view.addSubview(bottomBarView)
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBarView.topAnchor.constraint(equalTo: videoSegment.bottomAnchor, constant: 0).isActive = true
        bottomBarView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        bottomBarView.leftAnchor.constraint(equalTo: videoSegment.leftAnchor, constant: 0).isActive = true
       // bottomBarView.widthAnchor.constraint(equalToConstant: bottomBarWidth).isActive = true
        bottomBarView.widthAnchor.constraint(equalTo: videoSegment.widthAnchor, multiplier: 1 / CGFloat(videoSegment.numberOfSegments)).isActive = true

       // videoSegment.
        videoSegment.addTarget(self, action: #selector(changeVideos), for: .valueChanged)
    }
        
    func downloadGymVideos(role:Role) {
        if self.videoUrlArray.count < self.gymVideoUrlArrayStr.count ||  self.videoUrlArray.count == 0 ||  self.isImgaeAddedOrDeleted == true {
            SVProgressHUD.show()
            FireStoreManager.shared.downloadGymVideosUrls(role: self.videoForRole) { (vidUrlStr, err) in
                if err == nil  && vidUrlStr.count  > 0 {
                    self.gymVideoUrlArrayStr = vidUrlStr
                    FireStoreManager.shared.downloadGymVideo(pageToken: AppManager.shared.videoPageToken != "" ? AppManager.shared.videoPageToken : nil, role: self.videoSegment.selectedSegmentIndex == 0 ? .Admin : .Trainer) { (gymVideos) in
                        if gymVideos.count > 0 {
                            for singleGymVideo in gymVideos {
                                guard let singleVideoUrl = singleGymVideo.url else  { return }
                                if self.gymVideoUrlArray.contains(singleVideoUrl) == false {
                                    print("SINGLE VIDEO URL IS : \(singleVideoUrl)")
                                    self.gymVideoUrlArray.append(singleVideoUrl)
                                    self.videoUrlArray.append(self.createVideoThumbnail(videoUrl: singleVideoUrl)!)
                                }
                            }
                            if self.videoUrlArray.count >= self.gymVideoUrlArray.count || self.isImgaeAddedOrDeleted == true {
                                self.gymVideoCollectionView.reloadData()
                                self.isImgaeAddedOrDeleted = false
                                print("RELOADED")
                                SVProgressHUD.dismiss()
                            }
                        }else {
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
           menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
           deleteBtn.addTarget(self, action: #selector(deleteImages), for: .touchUpInside)

           let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
           let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
           stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
           
           let rightSpaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
           let rightstackView = UIStackView(arrangedSubviews: [selectBtn,rightSpaceBtn,addBtn])
           
           if AppManager.shared.loggedInRole == LoggedInRole.Admin {
               navigationItem.setRightBarButton(UIBarButtonItem(customView: rightstackView), animated: true)
           }
           navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView), animated: true)
       }
    
    @objc func changeVideos() {
        UIView.animate(withDuration: 0.3, animations: {
            print("BOTTOM WIDTH : \(self.bottomBarWidth)")
            let movement = (self.view.bounds.width / CGFloat(self.videoSegment.numberOfSegments)) * CGFloat(self.videoSegment.selectedSegmentIndex)
            print("MOVEMENT IS : \(movement)")
            self.bottomBarView.frame.origin.x = movement == 0.0 ? 40 : movement
        })
        self.videoForRole = self.videoSegment.selectedSegmentIndex == 0 ? .Admin : .Trainer
        self.videoUrlArray.removeAll()
        self.gymVideoUrlArray.removeAll()
        DispatchQueue.main.async {
        self.downloadGymVideos(role: self.videoForRole)
        }
       
    }
    
    @objc func refresh() {
        self.downloadGymVideos(role: self.videoForRole)
        self.refreshController.endRefreshing()
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
    
    @objc func menuChange() {  AppManager.shared.appDelegate.swRevealVC.revealToggle(self) }
  
    @objc func deleteImages() {
        SVProgressHUD.show()
        var deletingImgUrlsArray : [String] = []
        if self.deleteVideoIndex.count > 0 {
            for singleImgIndex in self.deleteVideoIndex {
                deletingImgUrlsArray.append(self.gymVideoUrlArrayStr[singleImgIndex])
            }
            
            FireStoreManager.shared.deleteVideos(role: self.videoForRole, urls: deletingImgUrlsArray) { (err) in
                SVProgressHUD.dismiss()
                if err == nil {
                    print("Success")
                    self.isImgaeAddedOrDeleted = true
                    self.isDeleteEnable = false
                    
                     print("deleted array count before : \(self.videoUrlArray.count)")
                    
                    self.videoUrlArray = self.videoUrlArray.enumerated().filter({ !self.deleteVideoIndex.contains($0.0) }).map { $0.1 }
                    
                    print("deleted array count  after: \(self.videoUrlArray.count)")
                    
                        self.deleteVideoIndex.removeAll()
                        self.setGymVideoNavigationBar()
                    self.downloadGymVideos(role: self.videoForRole)
              
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
        SVProgressHUD.show()
        FireStoreManager.shared.uploadGymVideo(url: videoUrl, role: self.videoSegment.selectedSegmentIndex == 0 ? .Admin : .Trainer) { (err) in
            if err == nil {
                print("VIDEO IS UPLOADED SUCCESSFULLY.")
                self.isImgaeAddedOrDeleted = true
                self.downloadGymVideos(role: self.videoForRole)
                SVProgressHUD.dismiss()
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
             self.playVideo(url:self.gymVideoUrlArray[indexPath.row])
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y >= self.lastElementContentOffsets.y/3 {
            spinner.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                self.downloadGymVideos(role: self.videoSegment.selectedSegmentIndex == 0 ? .Admin : .Trainer)
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
