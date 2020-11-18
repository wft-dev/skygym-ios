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
    @IBOutlet weak var membershipStartDate: UILabel!
    @IBOutlet weak var membershipEndDate: UILabel!
    }

class ListOfMembershipViewController: BaseViewController {
    
    var membershipDetailArray:[Memberhisp] = []
    @IBOutlet weak var membershipNavigationBar: CustomNavigationBar!
    @IBOutlet weak var membershipTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMembershipNavigation()
        self.membershipTable.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showAllMemberships()
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
}

extension ListOfMembershipViewController {
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
        cell.membershipPriceLabel.layer.cornerRadius = 7.0
        cell.membershipTitleLabel.text = singleMembership.title
        cell.membershipDetailLabel.text = singleMembership.detail
        cell.membershipPriceLabel.text = singleMembership.amount
        cell.membershipStartDate.text = singleMembership.startDate
        cell.membershipEndDate.text = singleMembership.endDate
        cell.selectedBackgroundView = AppManager.shared.getClearBG()
            
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {
            (_,_,_) in
            FireStoreManager.shared.deleteMembershipBy(id: self.membershipDetailArray[indexPath.section].membershipID, result: {
                err in
                if err != nil {
                    self.showMembershipAlert(title: "Error", message: "Error in deleting membership.")
                } else {
                    self.showMembershipAlert(title: "Success", message: "Membership is deleted .")
                }
            })
        })
       
      
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(named: "delete")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
