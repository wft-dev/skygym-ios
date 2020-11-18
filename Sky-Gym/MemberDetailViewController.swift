//
//  MemberDetailViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 05/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class MemberDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var detailName: UILabel!
    @IBOutlet weak var detailBtn: UIButton!
}

class MemberDetailViewController: BaseViewController {
    var memberDetailOptionArrary = ["Add new Membership","Current membership details","Purchase","Attendence",""]
    @IBOutlet weak var memberImg: UIImageView?
    @IBOutlet weak var memberName: UILabel?
    @IBOutlet weak var memberPhoneNumber: UILabel?
    @IBOutlet weak var memberDateOfJoin: UILabel!
    @IBOutlet weak var memberDetailsNavigationBar: CustomNavigationBar!
    @IBOutlet weak var paidTextLabel: UILabel?
    @IBOutlet weak var upaidTextLabel: UILabel?
    @IBOutlet weak var memberDetailTable: UITableView!
    var name:String = ""
    var address:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMemberDetailNavigationBar()
        [self.paidTextLabel,self.upaidTextLabel].forEach{
            $0?.layer.cornerRadius = 7.0
            $0?.clipsToBounds = true
        }
        self.memberDetailTable.separatorStyle  = .none
        self.memberDetailTable.isScrollEnabled = false
        setBackAction(toView: self.memberDetailsNavigationBar)
        self.memberImg?.makeRounded()
        self.memberImg?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMemberDetail)))
        self.memberImg?.isUserInteractionEnabled =  true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.show()
        self.showMemberWithID(id:AppManager.shared.memberID)
        self.memberDetailTable.reloadData()
        FireStoreManager.shared.downloadUserImg(id: AppManager.shared.memberID, result: {
            (url,err) in
            SVProgressHUD.dismiss()
            do {
                if url != nil {
                    let imgData = try  Data(contentsOf: url!)
                    self.memberImg?.image = UIImage(data: imgData)
                }
            } catch let err as NSError { print(err) }
        })
    }

    @objc func showMemberDetail(){
        performSegue(withIdentifier: "memberProfileSegue", sender: nil)
    }
}

extension MemberDetailViewController{
    func setMemberDetailNavigationBar()  {
        self.memberDetailsNavigationBar.menuBtn.isHidden = true
        self.memberDetailsNavigationBar.leftArrowBtn.isHidden = false
        self.memberDetailsNavigationBar.leftArrowBtn.alpha = 1.0
        self.memberDetailsNavigationBar.navigationTitleLabel.text = "Member detail"
        self.memberDetailsNavigationBar.searchBtn.isHidden = true
    }
    
    func showMemberWithID(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (singleMemberData,err) in
            if err != nil {
                SVProgressHUD.dismiss()
                self.retryAlert()
            } else {
                SVProgressHUD.dismiss()
                let memberships = singleMemberData?["memberships"] as! NSArray
                let memberDetail = singleMemberData?["memberDetail"] as! [String:String]
                self.memberName?.text = String(describing:"\(memberDetail["firstName"] ?? "") \(memberDetail["lastName"] ?? "")")
                self.name = "\(memberDetail["firstName"] ?? "" ) \(memberDetail["lastName"] ?? "" )"
                self.address = memberDetail["address"]!
                self.memberPhoneNumber?.text = memberDetail["phoneNo"]
                let lastMembership = memberships.count > 0 ? AppManager.shared.getLatestMembership(membershipsArray: memberships) : MembershipDetailStructure(membershipPlan: "__", membershipDetail: "--", amount: "--", startDate: "--", endDate: "--", totalAmount: "--", discount: "--", paymentType: "--", dueAmount: "--", puchaseTime: "--", purchaseDate: "--")
                
                self.memberDateOfJoin.text = memberDetail["dateOfJoining"]
                if lastMembership.dueAmount == "--"{
                    self.paidTextLabel?.isHidden = true
                    self.paidTextLabel?.alpha = 0
                    self.upaidTextLabel?.isHidden = true
                    self.upaidTextLabel?.alpha = 0.0
                } else {
                    let dueAmount =  Int(lastMembership.dueAmount)
                    if dueAmount! > 0 {
                        self.paidTextLabel?.isHidden = true
                        self.paidTextLabel?.alpha = 0
                        self.upaidTextLabel?.isHidden = false
                        self.upaidTextLabel?.alpha = 1.0
                    } else {
                        self.paidTextLabel?.isHidden = false
                        self.paidTextLabel?.alpha = 1.0
                        self.upaidTextLabel?.isHidden = true
                        self.upaidTextLabel?.alpha = 0.0
                    }
                }
            }
        })
    }
    
    func retryAlert() {
        let retryAlertController = UIAlertController(title: "Error", message: "Error in getting the member Detail.", preferredStyle: .alert)
        let retryAlertBtn = UIAlertAction(title: "Retry", style: .default, handler: {
            (action) in
            self.viewDidLoad()
        })
        retryAlertController.addAction(retryAlertBtn)
        present(retryAlertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewMembershipSegue" {
            let destinationVC = segue.destination as! AddMemberViewController
            destinationVC.isNewMember = sender as! Bool
        }
        
        if segue.identifier == "attendanceDetailSegue" {
            let destinationVC = segue.destination as! MemberAttandanceViewController
            destinationVC.memberName = self.name
            destinationVC.memberAddress = self.address
        }
         
        if segue.identifier == "memberProfileSegue" {
            let destinationVC = segue.destination as! MemberViewController
            destinationVC.img = self.memberImg?.image
        }
    }
}

extension MemberDetailViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberDetailOptionArrary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberDetailCell", for: indexPath) as! MemberDetailTableViewCell
        cell.detailName.text = self.memberDetailOptionArrary[indexPath.row]
        
        if cell.detailName.text == "" {
            cell.detailBtn.isHidden = true
        }
        return cell
    }
}


extension MemberDetailViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "addNewMembershipSegue", sender: false)
        case 1:
            performSegue(withIdentifier: "currentMembershipDetailSegue", sender: nil)
        case 2:
            performSegue(withIdentifier: "purchaseDetailSegue", sender: nil)
        case 3 :
            performSegue(withIdentifier: "attendanceDetailSegue", sender: nil)
        default:
            break
        }
    }
}
