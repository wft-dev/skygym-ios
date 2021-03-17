//
//  GymVideosViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 17/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class GymVideoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var gymVideoCellView: UIView!
}

class GymVideosViewController: UIViewController {
    @IBOutlet weak var gymVideoCollectionView: UICollectionView!
    var videoUrlArray:[Int] = []
    var deleteVideoIndex:[Int] = []
    var isDeleteEnable :Bool = false

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
        self.videoUrlArray = [1,2,3,4,5,6]
        self.gymVideoCollectionView.dataSource = self
        self.gymVideoCollectionView.delegate = self
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
    
    @objc func addNewVideo() {
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = .photoLibrary
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
        print("delete image.")
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
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemPink
        //imageView.alpha = self.deleteImgIndex.contains(indexPath.row) ? 0.5 : 1.0
        cell.gymVideoCellView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: cell.gymVideoCellView.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: cell.gymVideoCellView.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: cell.gymVideoCellView.bottomAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: cell.gymVideoCellView.leftAnchor, constant: 0).isActive = true
        
        return cell
    }
}

extension GymVideosViewController : UICollectionViewDelegate{
    
}


extension GymVideosViewController:UICollectionViewDelegateFlowLayout{
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
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.item == self.imagesArray.count - 1 {
//            self.lastElementContentOffsets = cell.frame.origin
//        }
//    }
    
}



extension GymVideosViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImg = info[.editedImage] as? UIImage else {
            return
        }
       // self.uploadImg(img: selectedImg)
        self.dismiss(animated: true, completion: nil)
    }
}
