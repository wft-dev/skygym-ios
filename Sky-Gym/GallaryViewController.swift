//
//  GallaryViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class GallaryCollectionCell: UICollectionViewCell {
    @IBOutlet weak var gallaryView: UIView!
}

class FooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class GallaryViewController: UIViewController {

    @IBOutlet weak var gallaryCollectionView: UICollectionView!
    var imagesArray:[UIImage?] = []
    private let sectionInsets = UIEdgeInsets(
    top: 35.0,
    left: 20.0,
    bottom: 35.0,
    right: 20.0)
    
    private var imagePicker :UIImagePickerController = {
        return UIImagePickerController()
        
    }()
    
    var limit = 5
    let spinner = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setGallaryNavigationBar()
        gallaryCollectionView.delegate = self
        gallaryCollectionView.dataSource = self
        imagePicker.delegate = self
        gallaryCollectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MyFooterView")
        (gallaryCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).footerReferenceSize = CGSize(width: gallaryCollectionView.bounds.width, height: 50)
        print("ARRAY COUTN : \(self.imagesArray.count)")
        AppManager.shared.pageToken = ""
        self.downloadImg()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    func setGallaryNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Gallary", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        let menuBtn = UIButton()
        let searchBtn = UIButton()
        searchBtn.setImage(UIImage(named:"add-image"), for: .normal)
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        searchBtn.addTarget(self, action: #selector(addNewImage), for: .touchUpInside)
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        searchBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        searchBtn.heightAnchor.constraint(equalToConstant: 18).isActive = true
        searchBtn.widthAnchor.constraint(equalToConstant: 18).isActive = true
        menuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        let rightspaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let rightstackView = UIStackView(arrangedSubviews: [searchBtn,rightspaceBtn])
        rightstackView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: stackView)
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: rightstackView)
    }
    
    @objc func menuChange(){
        AppManager.shared.appDelegate.swRevealVC.revealToggle(self)
    }
    
    
    @objc func refresh(){
        self.downloadImg()
       // refreshController.endRefreshing()
    }
    
    @objc func addNewImage(){
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadImg(img:UIImage) {
        SVProgressHUD.show()
        let imgData = img.jpegData(compressionQuality: 0.5)
        FireStoreManager.shared.uploadGallaryImage(imgData: imgData!, handler: {
            err in
            SVProgressHUD.dismiss()
            if err == nil {
               // self.gallaryCollectionView.reloadData()
                self.downloadImg()
                print("Success")
            }else {
                print("Failure")
            }
        })
    }
    
    func  downloadImg() {
        SVProgressHUD.show()
        //self.imagesArray.removeAll()
        print("PAGE TOKEN : \(AppManager.shared.pageToken)")
        FireStoreManager.shared.downloadGallaryImg(pageToken: AppManager.shared.pageToken != "" ? AppManager.shared.pageToken : nil ) { (urlArray) in
            for singleUrl in urlArray {
                do {
                    let imgData = try Data(contentsOf: singleUrl)
                    self.imagesArray.append(UIImage(data: imgData))
                }catch {
                    print("Error in fetching images.")
                }
                
                if self.imagesArray.count >= urlArray.count {
                    self.gallaryCollectionView.reloadData()
                }
            }
            SVProgressHUD.dismiss()
        }
    }
}

extension GallaryViewController :UICollectionViewDelegate , UIScrollViewDelegate {
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
            spinner.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                self.downloadImg()
                self.spinner.stopAnimating()
            })
    
    }
}

extension GallaryViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gallaryPhotoCell", for: indexPath) as! GallaryCollectionCell
        
         let _ = cell.gallaryView.subviews.map {
            if $0.isKind(of: UIImageView.self) {
                $0.removeFromSuperview()
            }
        }

        cell.layer.cornerRadius = 15.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.7
  
        let imageView = UIImageView(image: imagesArray[indexPath.row])
        imageView.contentMode = .scaleAspectFit
        cell.gallaryView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: cell.gallaryView.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: cell.gallaryView.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: cell.gallaryView.bottomAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: cell.gallaryView.leftAnchor, constant: 0).isActive = true
        
        return cell
    }
}

extension GallaryViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
     return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyFooterView", for: indexPath)
            footer.addSubview(spinner)
            spinner.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
}


extension GallaryViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImg = info[.editedImage] as? UIImage else {
            return
        }
        self.uploadImg(img: selectedImg)
        self.dismiss(animated: true, completion: nil)
    }
}
