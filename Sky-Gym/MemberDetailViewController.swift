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
    
    @IBOutlet weak var memberImg: UIImageView?
    @IBOutlet weak var memberName: UILabel?
    @IBOutlet weak var memberPhoneNumber: UILabel?
    @IBOutlet weak var memberDateOfJoin: UILabel!
    @IBOutlet weak var paidTextLabel: UILabel?
    @IBOutlet weak var upaidTextLabel: UILabel?
    @IBOutlet weak var memberDetailTable: UITableView!
    @IBOutlet weak var viewForMemberDetail: UIView!
    @IBOutlet weak var callLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    
    var name:String = ""
    var address:String = ""
    var memberDetailOptionArrary:[String] = []
    let messenger = MessengerManager()
    var receiverID:String = ""
    var receiverName:String = ""
    var senderID:String = ""
    var senderName:String = ""
    
    override func viewDidLoad() {
       super.viewDidLoad()
       
        self.callLabel.isUserInteractionEnabled = true
        self.msgLabel.isUserInteractionEnabled = true

        self.callLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callAction)))
        self.msgLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(msgAction)))
        
        if AppManager.shared.loggedInRole == LoggedInRole.Member {
        memberDetailOptionArrary = ["Current membership details","Purchase","Attendence",""]
        }else {
          memberDetailOptionArrary = ["Add new Membership","Current membership details","Purchase","Attendence",""]
        }
        
        [self.paidTextLabel,self.upaidTextLabel].forEach{
            $0?.layer.cornerRadius = 7.0
            $0?.clipsToBounds = true
        }
        self.memberDetailTable.separatorStyle  = .none
        self.memberDetailTable.isScrollEnabled = false
        self.memberImg?.makeRounded()
        self.memberImg?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMemberDetail)))
        self.memberImg?.isUserInteractionEnabled =  true
        self.viewForMemberDetail.isUserInteractionEnabled = true
        self.viewForMemberDetail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMemberDetail)))
        self.setCustomMemberDetailNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.show()
        self.showMemberWithID(id:AppManager.shared.memberID)
        self.memberDetailTable.reloadData()
    }
    
    func setCustomMemberDetailNavigation()  {
        let s = AppManager.shared.loggedInRole == LoggedInRole.Member ? "Home" : "Member Detail"
        let title = NSAttributedString(string: s, attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        
        if  AppManager.shared.loggedInRole == LoggedInRole.Member {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            
            let menuBtn = UIButton()
            menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
            menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
            menuBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            menuBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
            menuBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
            let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
            stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            let leftBtn = UIBarButtonItem(customView: stackView)
            navigationItem.leftBarButtonItem = leftBtn
            
        }else {
            let backButton = UIButton()
            backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
            backButton.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
            backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
            backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
            let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            let stackView = UIStackView(arrangedSubviews: [spaceBtn,backButton])
            stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            let backBtn = UIBarButtonItem(customView: stackView)
            navigationItem.leftBarButtonItem = backBtn
        }
    }
    
    @objc func menuChange(){
          AppManager.shared.appDelegate.swRevealVC.revealToggle(self)
      }
    
    @objc func backBtnAction(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func callAction(){
        AppManager.shared.callNumber(phoneNumber: "7015810695")
    }
    @objc func msgAction(){
        //print("message working.")
//        if messenger.canSendText() {
//           let messageVC =  messenger.configuredMessageComposeViewController(recipients: ["7015810695"], body: "This is for testing member detail.")
//            present(messageVC, animated: true, completion: nil)
//        }
        
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.chatUsers = ChatUsers(messageSenderID: self.senderID, messageReceiverID: self.receiverID, messageSenderName: self.senderName, messageReceiverName: self.receiverName)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }

    @objc func showMemberDetail(){
        let memberDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "memberVC") as! MemberViewController
        memberDetailVC.img = self.memberImg?.image
        self.navigationController?.pushViewController(memberDetailVC, animated: true)
    }
    
    @IBAction func callBtnAction(_ sender: Any) {
        self.callAction()
    }
    
    @IBAction func msgBtnAction(_ sender: Any) {
        self.msgAction()
    }
    
}

extension MemberDetailViewController{
    func showMemberWithID(id:String) {
        SVProgressHUD.show()
        FireStoreManager.shared.getMemberByID(id: id, completion: {
            (singleMemberData,err) in
            if err != nil {
                SVProgressHUD.dismiss()
                self.retryAlert()
            } else {
                
                let memberships = singleMemberData?["memberships"] as! Array<Dictionary<String,String>>
                let memberDetail = singleMemberData?["memberDetail"] as! [String:String]
                self.memberName?.text = String(describing:"\(memberDetail["firstName"] ?? "") \(memberDetail["lastName"] ?? "")")

                if AppManager.shared.loggedInRole == LoggedInRole.Member {
                    self.receiverID = AppManager.shared.getParentID(data: singleMemberData!)
                    self.receiverName = "Admin"
                    self.senderID = AppManager.shared.memberID
                    self.senderName = self.memberName!.text!
                }else {
                    self.receiverID = AppManager.shared.memberID
                    self.receiverName = self.memberName!.text!
                    self.senderID = AppManager.shared.loggedInRole == LoggedInRole.Admin ? AppManager.shared.adminID : AppManager.shared.trainerID
                    self.senderName = AppManager.shared.loggedInRole == LoggedInRole.Admin ? AppManager.shared.adminName : AppManager.shared.trainerName

                }
                
                self.name = "\(memberDetail["firstName"] ?? "" ) \(memberDetail["lastName"] ?? "" )"
                self.address = memberDetail["address"]!
                self.memberPhoneNumber?.text = memberDetail["phoneNo"]
                let lastMembership = memberships.count > 0 ? AppManager.shared.getLatestMembership(membershipsArray: memberships) : MembershipDetailStructure(membershipID: "__", membershipPlan: "__", membershipDetail: "--", amount: "--", startDate: "--", endDate: "--", totalAmount: "--", paidAmount: "--", discount: "--", paymentType: "--", dueAmount: "--", purchaseTime: "--", purchaseDate: "--", membershipDuration: "--", purchaseTimeStamp: "")
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
}

extension MemberDetailViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberDetailOptionArrary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberDetailCell", for: indexPath) as! MemberDetailTableViewCell
        cell.detailName.text = self.memberDetailOptionArrary[indexPath.row]
        //cell.sele
        
        if cell.detailName.text == "" {
            cell.detailBtn.isHidden = true
        }
        return cell
    }
}

extension MemberDetailViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case AppManager.shared.loggedInRole == LoggedInRole.Member ? 11 : 0 :
            let addNewMemberShipVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addMemberVC") as! AddMemberViewController
            addNewMemberShipVC.isNewMember = false
            self.navigationController?.pushViewController(addNewMemberShipVC, animated: true)
            
        case AppManager.shared.loggedInRole == LoggedInRole.Member ? 0 : 1 :
            let currentMembershipVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currentMembershipDetailVC") as! CurrentMembershipDetailViewController
            self.navigationController?.pushViewController(currentMembershipVC, animated: true)
            
        case AppManager.shared.loggedInRole == LoggedInRole.Member ? 1 : 2 :
            let purchaseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "purchaseVC") as! PurchaseViewController
            self.navigationController?.pushViewController(purchaseVC, animated: true)
            
        case AppManager.shared.loggedInRole == LoggedInRole.Member ? 2 : 3  :
            let attendenceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "memberAttendanceVC") as! MemberAttandanceViewController
            attendenceVC.memberName = self.name
            attendenceVC.memberAddress = self.address
            attendenceVC.memberUserImgData = self.memberImg?.image?.pngData()
            self.navigationController?.pushViewController(attendenceVC, animated: true)
            
        default:
            break
        }
    }
}
