//
//  ListOfVisitorsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 09/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD
import MessageUI

class VisitorTableCell: UITableViewCell {
    @IBOutlet weak var visitorCellView: UIView!
    @IBOutlet weak var memberBtn: UIButton!
    @IBOutlet weak var visitorNameLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var numberOfvisits: UILabel!
    @IBOutlet weak var trainerNameLabel: UILabel!
    @IBOutlet weak var dateOfJoinLabel: UILabel!
    @IBOutlet weak var dateOfVisitLabel: UILabel!
    @IBOutlet weak var trainerTypeLabel: UILabel!
    @IBOutlet weak var visitorProfileImg: UIImageView!
    var delegate:CustomCellSegue? = nil
    

    override func awakeFromNib() {
        memberBtn.addTarget(self, action: #selector(becomeMember), for: .touchUpInside)
    }
    
     @objc private func  becomeMember() {
        delegate?.applySegue(id: "\(memberBtn.tag)")
    }
}

class ListOfVisitorsViewController: BaseViewController {
    var visitorsArray:[Visitor] = []
    var filteredVisitorArray:[Visitor] = []

    @IBOutlet weak var visitorsTable: UITableView!
    @IBOutlet weak var listOfVisitorsNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchbarView: UIView!
    @IBOutlet weak var customSearchBar: UISearchBar!
    var visitorProfileImage:UIImage? = nil
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setVisitorsNavigationBar()
        self.visitorsTable.separatorStyle = .none
        self.setVisitorSearchBar()
        self.customSearchBar.delegate = self
        self.refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Visitor List")
        self.refreshControl.addTarget(self, action: #selector(refreshVisitorList), for: .valueChanged)
         self.fetchVisitors()
        self.visitorsTable.refreshControl = self.refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool)  {
        super.viewDidAppear(animated)
        self.fetchVisitors()
    }
    
    @objc func refreshVisitorList(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            self.refreshControl.endRefreshing()
             self.fetchVisitors()
        })
    }
    
    @IBAction func addNewVisitorAction(_ sender: Any) {
        performSegue(withIdentifier: "visitorViewSegue", sender: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "visitorViewSegue" {
            let destinationVC = segue.destination as! ViewVisitorScreenViewController
            destinationVC.isNewVisitor = sender as! Bool
        }
        if segue.identifier == "visitorMemberSegue" {
            let destinationVC = segue.destination as! AddMemberViewController
            destinationVC.isNewMember = true
            destinationVC.visitorID = sender as! String
            destinationVC.visitorProfileImgData = self.visitorProfileImage?.pngData()
        }
    }
}

extension ListOfVisitorsViewController {

    @objc func visitorLeftSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x = -((gesture.view?.frame.width)!/2)
        })

    }
    
    @objc func visitorRightSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x =  0
        })
    }
    
    @objc func deleteVisitor(_ gesture:UIGestureRecognizer){
        let alertController = UIAlertController(title: "Attention", message: "Do you really want to remove this visitor ?", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "Ok", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
            SVProgressHUD.show()
            FireStoreManager.shared.deleteImgBy(id: "\(gesture.view?.tag ?? 0)", result: {
                err in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.showVisitorAlert(title: "Error", message: "Error in deleting visitor.")
                } else {
                    FireStoreManager.shared.deleteVisitorBy(id:"\(gesture.view?.tag ?? 0)", completion: {
                        err in
                        if err != nil {
                            self.showVisitorAlert(title: "Error", message: "Error in deleting visitor.")
                        }else {
                            self.showVisitorAlert(title: "Success", message: "Visitor is deleted successfully.")
                        }
                    })
                }
            })
        })
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
        })
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }

    func addVisitorCustomSwipe(cellView:UIView,cell:VisitorTableCell) {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(visitorLeftSwipeAction(_:)))
        let rightSwipGesture = UISwipeGestureRecognizer(target: self, action: #selector(visitorRightSwipeAction(_:)))
        leftSwipeGesture.direction = .left
        rightSwipGesture.direction = .right
        let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: cellView.frame.height))
        let trashImgView = UIImageView(image: UIImage(named: "delete"))
        trashImgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        trashImgView.isUserInteractionEnabled = true
        trashImgView.tag = cellView.tag
        
        deleteView.addSubview(trashImgView)
        trashImgView.translatesAutoresizingMaskIntoConstraints = false
        trashImgView.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor, constant: 0).isActive = true
        trashImgView.trailingAnchor.constraint(equalTo: deleteView.trailingAnchor, constant: -(cell.frame.width/2)).isActive = true
        trashImgView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        trashImgView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        trashImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteVisitor(_:))))
        
        deleteView.heightAnchor.constraint(equalToConstant: cell.frame.height).isActive = true
        deleteView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        deleteView.translatesAutoresizingMaskIntoConstraints = true
        deleteView.backgroundColor = .red
        cell.contentView.addSubview(deleteView)
        
        cellView.addGestureRecognizer(leftSwipeGesture)
        cellView.addGestureRecognizer(rightSwipGesture)
        cellView.isUserInteractionEnabled = true
        cellView.backgroundColor = .white
        cellView.layer.cornerRadius = 20
        cell.layer.cornerRadius = 20
        cellView.layer.borderColor = UIColor(red: 211/255, green: 211/252, blue: 211/255, alpha: 1.0).cgColor
        cellView.layer.borderWidth = 1.0
        
        deleteView.superview?.sendSubviewToBack(deleteView)
    }

    func setVisitorsNavigationBar() {
        self.listOfVisitorsNavigationBar.navigationTitleLabel.text = "Visitor"
        self.listOfVisitorsNavigationBar.searchBtn.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
        self.addClickToDismissSearchBar()
    }
    
    func setVisitorSearchBar()  {
        self.customSearchBar.backgroundColor = .clear
        self.customSearchBar.layer.borderColor = .none
        if  let searchTextField = self.customSearchBar.value(forKey: "searchField") as? UITextField {
                searchTextField.clipsToBounds = true
                searchTextField.borderStyle = .none
                let imagView = UIImageView(image: UIImage(named: "search-2"))
                let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    emptyView.backgroundColor = .red
                let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 40, height: searchTextField.frame.height))
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.widthAnchor.constraint(equalToConstant: 25).isActive = true
                stackView.heightAnchor.constraint(equalToConstant: 25).isActive = true
                stackView.alignment = .center
                stackView.insertArrangedSubview(imagView, at: 0)
                stackView.insertArrangedSubview(emptyView, at: 1)
                searchTextField.leftViewMode = .always
                searchTextField.leftView = stackView
                searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Visitors",
                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                                                                                        NSAttributedString.Key.font:UIFont(name: "poppins", size: 18) as Any
                ])
            }
    }
    
    @objc  func showSearchBar()  {
           if self.searchbarView.isHidden == true {
               self.listOfVisitorsNavigationBar.isHidden = true
               self.listOfVisitorsNavigationBar.alpha = 0.0
               self.searchbarView.isHidden = false
               self.searchbarView.alpha = 1.0
           }
       }
    
    private func addClickToDismissSearchBar() {
           let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedView(_:)))
           tapRecognizer.cancelsTouchesInView = false
           self.view.isUserInteractionEnabled = true
           self.view.addGestureRecognizer(tapRecognizer)
       }

       @objc
       private func dismissPresentedView(_ sender: Any?) {
           self.listOfVisitorsNavigationBar.isHidden = false
           self.listOfVisitorsNavigationBar.alpha = 1.0
           self.searchbarView.isHidden = true
           self.searchbarView.alpha = 0.0
           self.view.endEditing(true)
       }
    
    func fetchVisitors() {
        SVProgressHUD.show()
        FireStoreManager.shared.getAllVisitors(result: {
            (visitors,err)in
            
            if err != nil {
                self.showVisitorAlert(title: "Retry", message: "Some error in fetching visitor list , Please retry again.")
                
            }else {
                self.visitorsArray.removeAll()
                for visitor in visitors!{
                let visitorData = AppManager.shared.getVisitor(visitorDetail:visitor["visitorDetail"] as! [String:String], id: visitor["id"] as! String)
                    self.visitorsArray.append(visitorData)
                }
                self.visitorsTable.reloadData()
            }
        })
    }
    
    func getVisitorProfileImage(id:String,imgView :UIImageView) {
          SVProgressHUD.show()
          FireStoreManager.shared.downloadUserImg(id: id, result: {
              (imgUrl,err) in
              SVProgressHUD.dismiss()
              if err != nil {
            //  self.viewDidLoad()
              } else {
                  do{
                    let imgData = try Data(contentsOf: imgUrl!)
                    self.visitorProfileImage = UIImage(data: imgData)
                    imgView.image = self.visitorProfileImage
                    imgView.makeRounded()
                  } catch let error as NSError { print(error) }
              }
          })
      }
    
    func adjustFontSizeForVisitorLabel(label:UILabel) {
                  let deviceType = UIDevice.current.deviceType
                  switch deviceType {
                   
                  case .iPhone4_4S:
                    label.font = UIFont.boldSystemFont(ofSize: 6)
                   
                  case .iPhones_5_5s_5c_SE:
                    label.font = UIFont.boldSystemFont(ofSize: 6)
                   
                  case .iPhones_6_6s_7_8:
              label.font = UIFont.systemFont(ofSize: 8)
                   
                  case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                    label.font = UIFont.systemFont(ofSize: 8)
                   
                  case .iPhoneX:
                    label.font = UIFont.systemFont(ofSize: 8)
                   
                  default:
                    label.font = UIFont.systemFont(ofSize: 8)
                  }
              }
    
    func showVisitorAlert(title:String,message:String)  {
           let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
           let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
               _ in
               if title == "Success" || title == "Retry" {
                self.fetchVisitors()
            }
           })
           alertController.addAction(okAlertAction)
           present(alertController, animated: true, completion: nil)
       }
    
}

extension ListOfVisitorsViewController :UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.visitorsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "visitorCell", for: indexPath) as! VisitorTableCell
        let singleVisitor = self.visitorsArray[indexPath.section]
        self.setAttandanceTableCellView(tableCellView: cell.visitorCellView)
        cell.contentView.layer.cornerRadius = 20.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        cell.memberBtn.layer.cornerRadius = 7.0
        cell.visitorNameLabel.text = "\(singleVisitor.firstName) \(singleVisitor.lastName)"
        cell.phoneNoLabel.text = singleVisitor.phoneNo
        cell.numberOfvisits.text = "visitor: \(singleVisitor.noOfVisit)"
        cell.dateOfJoinLabel.text = singleVisitor.dateOfJoin
        cell.dateOfVisitLabel.text = singleVisitor.dateOfVisit
        self.getVisitorProfileImage(id: singleVisitor.id, imgView: cell.visitorProfileImg)
        if AppManager.shared.adminID == "" {
            cell.trainerNameLabel.text = AppManager.shared.trainerID.count > 0 ? "\(AppManager.shared.trainerName)" : "  --"
            cell.trainerTypeLabel.text = AppManager.shared.trainerID.count > 0 ? "\(AppManager.shared.trainerType)" : "  --"
        } else {
            cell.trainerNameLabel.text = "  --"
            cell.trainerTypeLabel.text = "  --"
        }
        
        cell.delegate = self
        self.adjustFontSizeForVisitorLabel(label: cell.dateOfJoinLabel)
        self.adjustFontSizeForVisitorLabel(label: cell.dateOfVisitLabel)
        self.adjustFontSizeForVisitorLabel(label:cell.trainerNameLabel)
        self.adjustFontSizeForVisitorLabel(label: cell.trainerTypeLabel)
        cell.memberBtn.tag = Int(singleVisitor.id)!
        cell.selectionStyle = .none
        cell.visitorCellView.tag = Int(singleVisitor.id)!
        self.addVisitorCustomSwipe(cellView: cell.visitorCellView, cell: cell)
        
        return cell
    }
}

extension ListOfVisitorsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.visitorID = self.visitorsArray[indexPath.section].id
        print("visitor id : \(AppManager.shared.visitorID)")
        performSegue(withIdentifier: "visitorViewSegue", sender: false)
    }
}

extension ListOfVisitorsViewController:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.filteredVisitorArray.removeAll()
            for singleVisitor in self.visitorsArray {
                let fullName = "\(singleVisitor.firstName) \(singleVisitor.lastName)"
                if  fullName.lowercased().contains(searchText.lowercased()) || singleVisitor.phoneNo.contains(searchText){
                    self.filteredVisitorArray.append(singleVisitor)
                    self.visitorsTable.reloadData()
                }
            }
        } else {
            self.filteredVisitorArray.removeAll()
            self.visitorsTable.reloadData()
        }
    }
    
}

extension ListOfVisitorsViewController:CustomCellSegue{
    func showMessage(vc: MFMessageComposeViewController) {
        print("")
    }
    
    
    func applySegue(id: String) {
        self.performSegue(withIdentifier: "visitorMemberSegue", sender: id)
    }

}


