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
    var imgUrlsArray:[String] = []
    private let sectionInsets = UIEdgeInsets(
    top: 35.0,
    left: 20.0,
    bottom: 35.0,
    right: 20.0)
    
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

    let spinner = UIActivityIndicatorView()
    var lastElementContentOffsets:CGPoint = CGPoint(x: 0, y: 0)
    var isDeleteEnable:Bool = false
    var deleteImgIndex:[Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setGallaryNavigationBar()
        gallaryCollectionView.delegate = self
        gallaryCollectionView.dataSource = self
        imagePicker.delegate = self
        gallaryCollectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MyFooterView")
        (gallaryCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).footerReferenceSize = CGSize(width: gallaryCollectionView.bounds.width, height: 50)
        AppManager.shared.pageToken = ""
        self.downloadImg()
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
 
        addBtn.addTarget(self, action: #selector(addNewImage), for: .touchUpInside)
        selectBtn.addTarget(self, action: #selector(selectDeleteImg), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelSelection), for: .touchUpInside)
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteImages), for: .touchUpInside)

        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let rightSpaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        let rightstackView = UIStackView(arrangedSubviews: [selectBtn,rightSpaceBtn,addBtn])
        
        navigationItem.setRightBarButton(UIBarButtonItem(customView: rightstackView), animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView), animated: true)
    }
    
    @objc func menuChange(){
        AppManager.shared.appDelegate.swRevealVC.revealToggle(self)
    }
    
    @objc func deleteImages(){
        SVProgressHUD.show()
        var deletingImgUrlsArray : [String] = []
        if self.deleteImgIndex.count > 0 {
            for singleImgIndex in self.deleteImgIndex {
                deletingImgUrlsArray.append(self.imgUrlsArray[singleImgIndex])
            }
            
            FireStoreManager.shared.deleteGallaryImages(urls: deletingImgUrlsArray) { (err) in
                SVProgressHUD.dismiss()
                if err == nil {
                    print("Success")
                    AppManager.shared.pageToken = ""
                    self.imagesArray.removeAll()
                    self.imgUrlsArray.removeAll()
                    self.downloadImg()
                }else {
                    print("\(err!)")
                    print("Try again ")
                }
            }
        }
    }
    
    @objc func selectDeleteImg(){
        self.isDeleteEnable = true
        DispatchQueue.main.async {
            self.navigationItem.titleView = nil
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView: self.deleteBtn), animated: true)
            self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: self.cancelBtn), animated: true)
        }
    }
    
    @objc func cancelSelection() {
        self.deleteImgIndex.removeAll()
        self.gallaryCollectionView.reloadData()
        DispatchQueue.main.async {
            self.setGallaryNavigationBar()
        }
    }
    
    @objc func addNewImage(){
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func showEnlargeImageAt(index:Int){
        let enlargeImageView = UIImageView(image: self.imagesArray[index] )
        enlargeImageView.contentMode = .scaleAspectFit
        let enlargeView = UIView()
        
        enlargeView.frame = self.view.frame
        enlargeImageView.frame = enlargeView.frame
        enlargeView.backgroundColor = .black
        enlargeView.addSubview(enlargeImageView)
        
        enlargeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissEnlargeView)))
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubview(enlargeView)
    }
    
    @objc func dismissEnlargeView(_ gesture:UITapGestureRecognizer){
        self.navigationController?.isNavigationBarHidden = false
        gesture.view?.removeFromSuperview()
    }

    @objc func performDelete(index:Int){
        if self.deleteImgIndex.contains(index) {
            print("remove from delete")
            self.deleteImgIndex.remove(at: self.deleteImgIndex.firstIndex(of: index)!)
        }else {
            print("add to delete")
            self.deleteImgIndex.append(index)
        }
        print("SELECTED ARRAY : \(self.deleteImgIndex)")
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
        FireStoreManager.shared.downloadGallaryImgUrls { (imgUrlsStr, err) in
            if err == nil && imgUrlsStr.count > 0  {
                self.imgUrlsArray = imgUrlsStr
                print("IMG URLS : \(self.imgUrlsArray)")
                FireStoreManager.shared.downloadGallaryImg(pageToken: AppManager.shared.pageToken != "" ? AppManager.shared.pageToken : nil ) { (urlArray) in
                    if urlArray.count > 0 {
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
                    }
                    SVProgressHUD.dismiss()
                }
            }else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
}

extension GallaryViewController :UICollectionViewDelegate , UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y >= self.lastElementContentOffsets.y/3 {
            spinner.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                self.downloadImg()
                self.spinner.stopAnimating()
            })
        } else {
            print("Scrolling offset : \(scrollView.contentOffset.y)")
            print("element offset : \(self.lastElementContentOffsets.y/2)")
            print(" Not scrolling. ")
        }
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

        cell.layer.cornerRadius = 10.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.7
  
        let imageView = UIImageView(image: imagesArray[indexPath.row])
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = self.deleteImgIndex.contains(indexPath.row) ? 0.5 : 1.0
        cell.gallaryView.backgroundColor = .black
        cell.gallaryView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: cell.gallaryView.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: cell.gallaryView.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: cell.gallaryView.bottomAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: cell.gallaryView.leftAnchor, constant: 0).isActive = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isDeleteEnable == false {
             self.showEnlargeImageAt(index: indexPath.row)
        }else {
            self.performDelete(index:indexPath.row)
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }
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
        if indexPath.item == self.imagesArray.count - 1 {
            self.lastElementContentOffsets = cell.frame.origin
        }
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
