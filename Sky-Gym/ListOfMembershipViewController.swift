//
//  ListOfMembershipViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 09/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class MembershipTableCell: UITableViewCell {
    @IBOutlet weak var membershipCellView: UIView!
    @IBOutlet weak var membershipPriceLabel: UILabel!
    @IBOutlet weak var membershipTitleLabel: UILabel!
    @IBOutlet weak var membershipDetailLabel: UILabel!
    }

class ListOfMembershipViewController: BaseViewController {
    
    @IBOutlet weak var membershipNavigationBar: CustomNavigationBar!
    @IBOutlet weak var membershipTable: UITableView!
    @IBOutlet weak var membershipAddBtn: UIButton!
    let refreshControl = UIRefreshControl()
    var membershipDetailArray:[Memberhisp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMembershipNavigation()
        self.setMembershipViewForMember()
        self.membershipTable.separatorStyle = .none
        self.refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Membership List")
        self.refreshControl.addTarget(self, action: #selector(refreshMembershipList), for: .valueChanged)
        self.membershipTable.refreshControl = self.refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.showAllMemberships()
    }
    
    @objc func refreshMembershipList(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.refreshControl.endRefreshing()
            self.showAllMemberships()
        })
    }
    
    @IBAction func addNewMembershipAction(_ sender: Any) {
        performSegue(withIdentifier: "addMembershipSegue", sender: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMembershipSegue"{
            let destinationVC = segue.destination as! MembershipViewScreenViewController
            destinationVC.isNewMemberhsip = sender as! Bool
        }
    }
    
    func setMembershipViewForMember() {
        if AppManager.shared.loggedInRole == LoggedInRole.Member {
            self.membershipAddBtn.isHidden = true
            self.membershipAddBtn.alpha = 0.0
        }
    }

    @objc func membershipLeftSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x = -((gesture.view?.frame.width)!/2)
        })
    }
    
    @objc func membershipRightSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x =  0
        })
    }
    
    @objc func deleteMembership(_ gesture:UIGestureRecognizer){
        let alertController = UIAlertController(title: "Attention", message: "Do you really want to remove this membership ?", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
            SVProgressHUD.show()
            FireStoreManager.shared.deleteMembershipBy(id: "\(gesture.view!.tag)", result: {
                err in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.showMembershipAlert(title: "Error", message: "Error in deleting membership.")
                } else {
                    self.showMembershipAlert(title: "Success", message: "Membership is deleted .")
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

    func addMembershipCustomSwipe(cellView:UIView,cell:MembershipTableCell) {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(membershipLeftSwipeAction(_:)))
        let rightSwipGesture = UISwipeGestureRecognizer(target: self, action: #selector(membershipRightSwipeAction(_:)))
        leftSwipeGesture.direction = .left
        rightSwipGesture.direction = .right
        let _ = cell.contentView.subviews.map({
             if  $0.tag  == 11 {
                 $0.removeFromSuperview()
             }
         })
        let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: cellView.frame.width, height: cellView.frame.height))
        let trashImgView = UIImageView(image: UIImage(named: "delete"))
        trashImgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        trashImgView.isUserInteractionEnabled = true
        trashImgView.tag = cellView.tag
        deleteView.backgroundColor = .red
        cell.contentView.addSubview(deleteView)
        deleteView.addSubview(trashImgView)
        trashImgView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        trashImgView.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor, constant: 0).isActive = true
        trashImgView.trailingAnchor.constraint(equalTo: deleteView.trailingAnchor, constant: -(cell.frame.width/4)).isActive = true
        trashImgView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        trashImgView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        trashImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteMembership(_:))))
        
        deleteView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        deleteView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        deleteView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0).isActive = true
        deleteView.bottomAnchor.constraint(greaterThanOrEqualTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
        deleteView.tag = 11 
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

    func setMembershipNavigation() {
        self.membershipNavigationBar.navigationTitleLabel.text = "Membership"
        self.membershipNavigationBar.searchBtn.isHidden = true
    }
    
    func showAllMemberships() {
        SVProgressHUD.show()
        FireStoreManager.shared.getAllMembership(result: {
            (data,err)in
            SVProgressHUD.dismiss()
            if err != nil{
                self.viewWillAppear(true)
            }else {
                self.membershipDetailArray.removeAll()
                for singleMembership in data!{
                    self.membershipDetailArray.append(AppManager.shared.getMembership(membership: singleMembership["membershipDetail"] as! [String:String], membershipID: singleMembership["id"] as! String))
                }
                self.membershipTable.reloadData()
            }
        })
    }
    
    func showMembershipAlert(title:String,message:String)  {
        let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            if title == "Success" {
                self.showAllMemberships()
            }
        })
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ListOfMembershipViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.membershipDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "membershipCell", for: indexPath) as! MembershipTableCell
        let singleMembership = self.membershipDetailArray[indexPath.section]
        self.setAttandanceTableCellView(tableCellView: cell.membershipCellView)
        cell.contentView.layer.cornerRadius = 20.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        cell.membershipPriceLabel.layer.cornerRadius = 7.0
        cell.membershipTitleLabel.text = singleMembership.title
        cell.membershipDetailLabel.text = singleMembership.detail
        cell.membershipPriceLabel.text = "Rs. \(singleMembership.amount)"
        cell.selectionStyle = .none
        cell.membershipCellView.tag = Int(singleMembership.membershipID)!
        
      //  print("LOGGED IN ROLE IS : \(AppManager.shared.LoggedInAs)")
        
        if AppManager.shared.loggedInRole != LoggedInRole.Member {
            self.addMembershipCustomSwipe(cellView: cell.membershipCellView, cell: cell)
        }
        
        return cell
    }
    }

extension ListOfMembershipViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.membershipID = self.membershipDetailArray[indexPath.section].membershipID
            self.performSegue(withIdentifier: "addMembershipSegue", sender: false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
}
