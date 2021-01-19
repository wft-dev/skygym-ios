//
//  ListOfMembersViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 29/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD
import MessageUI

class ListOfMembersTableCell: UITableViewCell {
    @IBOutlet weak var userImag: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var dateOfExpiry: UILabel!
    @IBOutlet weak var dueAmount: UILabel!
    @IBOutlet weak var listOfmemberTCView: UIView!
    @IBOutlet weak var renewPackageLabel: UILabel!
    @IBOutlet weak var btnsStackView: UIStackView!
    @IBOutlet weak var callImg: UIImageView?
    @IBOutlet weak var msgImg: UIImageView?
    @IBOutlet weak var attendImg: UIImageView?
    @IBOutlet weak var renewImg: UIImageView?
    @IBOutlet weak var attendenceLabel: UILabel!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var attendenceView: UIView!
    @IBOutlet weak var renewView: UIView!
    
    var customCellDelegate:CustomCellSegue?
    var imageName:String = "red"
    var attendenceAlreadyMarked:Bool = false
    let messenger = MessengerManager()

    override func awakeFromNib() {
        super.awakeFromNib()
       attachGestures()
    }
    
    func attachGestures() {
        self.btnsStackView.isUserInteractionEnabled = true
        [callView,messageView,attendenceView,renewView].forEach{
            $0?.isUserInteractionEnabled = true
        }
        callView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(call(_:))))
        messageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(msg(_:))))
        attendenceView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(attendance(_:))))
        renewView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(renewPackage(_:))))
    }

    @objc func call(_ sender: UITapGestureRecognizer) {
       callNumber(phoneNumber: "7015810695")
    }

    @objc func msg(_ sender: UITapGestureRecognizer) {
        if  messenger.canSendText() {
            customCellDelegate?.showMessage(vc: messenger.configuredMessageComposeViewController())
        }else {
            print("Error in sending message.")
        }
     }
    
    @objc func attendance(_ sender: UITapGestureRecognizer) {
        performAttandance(id:"\(btnsStackView.tag)")
    }

    @objc func renewPackage(_ sender: UITapGestureRecognizer) {
        if customCellDelegate.self != nil {
            customCellDelegate?.applySegue(id: "\(btnsStackView.tag)")
        }
     }
    
    private func callNumber(phoneNumber:String) {
         if let phoneCallURL = URL(string: "TEL://\(phoneNumber)") {
             let application:UIApplication = UIApplication.shared
             if (application.canOpenURL(phoneCallURL)) {
                 if #available(iOS 10.0, *) {
                     application.open(phoneCallURL, options: [:], completionHandler: nil)
                 } else {
                     // Fallback on earlier versions
                      application.openURL(phoneCallURL as URL)
                 }
             }
         }
     }
    
    private func performAttandance(id:String){
        switch self.imageName{
        case "red":
            if attendenceAlreadyMarked == false {
            FireStoreManager.shared.addAttendence(trainerORmember: "Members", id: id, present: true, checkInA: AppManager.shared.getTimeFrom(date: Date()), checkOutA: "-")
            }
            imageName = "green"
            self.attendImg?.image = UIImage(named: imageName)
        case "green":
            imageName = "red"
             self.attendImg?.image = UIImage(named: imageName)
            if attendenceAlreadyMarked == false{
                FireStoreManager.shared.updateAttendence(trainerORmember: "Members", id: id, checkOutA: AppManager.shared.getTimeFrom(date: Date()), completion: {
                    err in
                    self.attendenceAlreadyMarked = err == nil ? true : false
                })
            }
        default:
            break
        }
    }
}

class ListOfMembersViewController: BaseViewController {
    @IBOutlet weak var navigationView: CustomNavigationBar!
    @IBOutlet weak var searchFilterView: UIView!
    @IBOutlet weak var listOfMemberTable: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var listOfMembersMainView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var filterOptionView: UIView!
    @IBOutlet weak var filterSecondOptionView: UIView!
    @IBOutlet weak var filterThirdOptionView: UIView!
    @IBOutlet weak var filterFourthOpitonView: UIView!
    @IBOutlet weak var filterApplyBtn: UIButton!
    @IBOutlet weak var customSearchBar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var allMemberFilterBtn: UIButton!
    @IBOutlet weak var expiredMembersFilterBtn: UIButton!
    @IBOutlet weak var CheckinFilterBtn: UIButton!
    @IBOutlet weak var checkoutFilterBtn: UIButton!
        
    var listOfMemberArray:[ListOfMemberStr] = []
    var filteredMemberArray:[ListOfMemberStr] = []
    var userImg:UIImage? = nil
    var filterationLabel:String = "allMemberFilteration"
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCompleteListOfMembersView()
        self.setUpFilterView()
        self.refreshControl.addTarget(self, action: #selector(refreshMembers), for: .valueChanged)
        self.refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Member List")
        self.listOfMemberTable.refreshControl = self.refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showMembers()
    }
    
   @objc func callAction() {
        print("WORKING CALLING ACTION")
    }
    
    @objc func refreshMembers(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            self.refreshControl.endRefreshing()
            switch self.filterationLabel {
            case "allMemberFilteration":
                self.showMembers()
            case "expiredMemberFilteration":
                self.expiredMemberFilterationAction()
            case "checkInMemberFilteration":
                self.checkFilterationAction(checkFor: "checkIn")
            case "checkOutMemberFilteration":
                self.checkFilterationAction(checkFor: "checkOut")
            default:
                break
            }
        })
    }
    
    @IBAction func filterBtnAction(_ sender: Any) {
        if self.filterView.isHidden == true {
            self.showFilterView()
        }
    }
    
    @IBAction func filterCancelBtnAction(_ sender: Any) {
        self.hideFilterView()
            }
        
    @IBAction func addNewMemberBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "addMemberSegue", sender: true)
    }
    
    func hideFilterView() {
        self.filterView.isHidden = true
        self.filterView.alpha = 0.0
        self.grayView.isHidden = true
        self.grayView.alpha = 0
        self.addBtn.isHidden = false
        AppManager.shared.setStatusBarBackgroundColor(color: .white, alpha: 1.0)
    }
    func showFilterView() {
        self.filterView.isHidden = false
        self.filterView.alpha = 1.0
        self.grayView.isHidden = false
        self.grayView.alpha = 0.4
        self.grayView.backgroundColor = UIColor.darkGray
        self.addBtn.isHidden = true
        AppManager.shared.setStatusBarBackgroundColor(color: .gray, alpha: 0.4)
    }
}

extension ListOfMembersViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return  1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredMemberArray.count > 0 ? self.filteredMemberArray.count : self.listOfMemberArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "listOfMemberCell", for: indexPath) as! ListOfMembersTableCell
        cell.contentView.layer.cornerRadius = 15.0
        cell.contentView.layer.borderColor = UIColor(red: 211/255, green: 211/252, blue: 211/255, alpha: 1.0).cgColor
        cell.contentView.layer.borderWidth = 1.0
        cell.listOfmemberTCView.layer.cornerRadius = 15.0
        cell.listOfmemberTCView.layer.borderColor = UIColor(red: 211/255, green: 211/252, blue: 211/255, alpha: 1.0).cgColor
        cell.listOfmemberTCView.layer.borderWidth = 1.0
        self.adjustFontSizeForRenewPackageLabel(label: cell.renewPackageLabel)
        let singleMember = self.filteredMemberArray.count > 0 ? self.filteredMemberArray[indexPath.section] : self.listOfMemberArray[indexPath.section]
        self.getMemberProfileImage(id: singleMember.memberID, imageName:singleMember.uploadName, imgView: cell.userImag)
        cell.userImag.image = singleMember.userImg
        cell.userName.text = singleMember.userName
        cell.phoneNumber.text = singleMember.phoneNumber
        cell.dateOfExpiry.text = singleMember.dateOfExp
        cell.dueAmount.text = singleMember.dueAmount
        cell.btnsStackView.tag =  Int(singleMember.memberID)!
       // print("\(cell.btnsStackView.tag)")
        cell.customCellDelegate = self
        cell.selectionStyle = .none
        self.setCellAttendeneBtn(memberCell: cell, memberID: singleMember.memberID)
        self.setCellRenewMembershipBtn(memberCell: cell, memberID: singleMember.memberID,dueAmount: singleMember.dueAmount)
        self.addCustomSwipe(cellView: cell.listOfmemberTCView, cell: cell)

        return cell
    }

      func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 15
    }
      
      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let headerView = UIView()
          headerView.backgroundColor = UIColor.clear
          return headerView
      }
}

extension ListOfMembersViewController : UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.memberID = self.listOfMemberArray[indexPath.section].memberID
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "memberDetailSegue", sender:nil)
        }
    }
}

extension ListOfMembersViewController{
    
    @objc func deleteMember(_ gesture:UIGestureRecognizer) {
        let alertController = UIAlertController(title: "Attention", message: "Do you want to remove this member.", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
            SVProgressHUD.show()
            let id = "\(gesture.view?.tag ?? 0 )"
            FireStoreManager.shared.deleteUserCredentials(id: id, handler: {
                (err) in
                
                DispatchQueue.global(qos: .background).async {
                    let result = FireStoreManager.shared.deleteImgBy(id:id )
                    
                    switch result {
                    case  .failure(_):
                        self.alertBox(title: "Error", message: "Member is not deleted,Please try again.")
                    case let .success(flag) :
                        if flag == true {
                            FireStoreManager.shared.deleteMemberBy(id:id, completion: {
                                err in
                                SVProgressHUD.dismiss()
                                if err != nil {
                                    self.alertBox(title: "Error", message: "Member is not deleted,Please try again.")
                                } else {
                                    self.alertBox(title: "Success", message: "Member is deleted successfully.")
                                }
                            })
                        }
                    }
                }
            })
        })
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
        })

        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addCustomSwipe(cellView:UIView,cell:ListOfMembersTableCell) {
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeAction(_:)))
        let rightSwipGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeAction(_:)))
        leftSwipeGesture.direction = .left
        rightSwipGesture.direction = .right
       let _ = cell.contentView.subviews.map({
            if  $0.tag  == 11 {
                $0.removeFromSuperview()
            }
        })
         let deleteView = UIView()
        deleteView.frame = CGRect(x: 0, y: 0, width: cellView.frame.width, height: cellView.frame.height)
        let trashImgView = UIImageView(image: UIImage(named: "delete"))
        trashImgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        trashImgView.isUserInteractionEnabled = true
        trashImgView.tag = cell.btnsStackView.tag
        deleteView.backgroundColor = .red
        cell.contentView.addSubview(deleteView)
        deleteView.addSubview(trashImgView)
        trashImgView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        trashImgView.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor, constant: 0).isActive = true
        trashImgView.trailingAnchor.constraint(equalTo: deleteView.trailingAnchor, constant: -(cell.frame.width/3)).isActive = true
        trashImgView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        trashImgView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        trashImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteMember(_:))))

        deleteView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        deleteView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        deleteView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0).isActive = true
        deleteView.bottomAnchor.constraint(greaterThanOrEqualTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
        
        cellView.addGestureRecognizer(leftSwipeGesture)
        cellView.addGestureRecognizer(rightSwipGesture)
        cellView.isUserInteractionEnabled = true
        deleteView.tag = 11
        cell.contentView.backgroundColor = .white
        cell.layer.cornerRadius = 20
        cellView.layer.cornerRadius = 20
        cellView.layer.borderColor = UIColor(red: 211/255, green: 211/252, blue: 211/255, alpha: 1.0).cgColor
        cellView.layer.borderWidth = 1.0
        deleteView.superview?.sendSubviewToBack(deleteView)
    }
    
    @objc func rightSwipeAction (_ gesture:UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x =  0
        })
    }
    
    @objc func leftSwipeAction (_ gesture:UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x = -((gesture.view?.frame.width)!/2)
        })
    }
    
    func allMemberFilterAction() {
        self.showMembers()
    }
    
    func expiredMemberFilterationAction(){
      FireStoreManager.shared.expiredMemberFilterAction(result: {
        (array,err) in
        if err == nil {
            self.listOfMemberArray.removeAll()
            self.listOfMemberArray = array!
            self.listOfMemberTable.reloadData()
        }
      })
    }

    func checkFilterationAction(checkFor:String) {
        FireStoreManager.shared.checkFilterAction(checkFor:checkFor, result: {
            (array,err) in
            if err == nil {
                self.listOfMemberArray.removeAll()
                self.listOfMemberArray = array ?? []
                self.listOfMemberTable.reloadData()
            }
        })
    }

    func getMemberProfileImage(id:String,imageName:String,imgView :UIImageView) {
         SVProgressHUD.show()
        FireStoreManager.shared.downloadUserImg(id: id, result: {
            (imgUrl,err) in
            SVProgressHUD.dismiss()
            if err != nil {
               
            } else {
                do{
                    let imgData = try Data(contentsOf: imgUrl!)
                    self.userImg = UIImage(data: imgData)
                    imgView.image = self.userImg
                    imgView.makeRounded()
                } catch let error as NSError { print(error) }
            }
        })
     }

   func adjustFontSizeForRenewPackageLabel(label:UILabel) {
                let deviceType = UIDevice.current.deviceType
                switch deviceType {
                 
                case .iPhone4_4S:
                    label.font = UIFont.boldSystemFont(ofSize: 5.5)
                 
                case .iPhones_5_5s_5c_SE:
                    label.font = UIFont.boldSystemFont(ofSize: 5.5)
                 
                case .iPhones_6_6s_7_8:
            label.font = UIFont.systemFont(ofSize: 7)
                 
                case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                  label.font = UIFont.systemFont(ofSize: 7)
                 
                case .iPhoneX:
                  label.font = UIFont.systemFont(ofSize: 7)
                 
                default:
                  label.font = UIFont.systemFont(ofSize: 7)
                }
            }
    
    func setSearchBar()  {
            self.customSearchBar.backgroundColor = .clear
            self.customSearchBar.layer.borderColor = .none
            if  let searchTextField = self.customSearchBar.value(forKey: "searchField") as? UITextField {
                    searchTextField.clipsToBounds = true
                    searchTextField.borderStyle = .none
                    let imagView = UIImageView(image: UIImage(named: "search-2"))
                    let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 25, height: searchTextField.frame.height))
                    stackView.translatesAutoresizingMaskIntoConstraints = false
                    stackView.widthAnchor.constraint(equalToConstant: 25).isActive = true
                    stackView.heightAnchor.constraint(equalToConstant: 25).isActive = true
                    stackView.alignment = .center
                    stackView.insertArrangedSubview(imagView, at: 0)
                    stackView.insertArrangedSubview(emptyView, at: 1)
                    searchTextField.leftViewMode = .always
                    searchTextField.leftView = stackView
                    searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Members",
                                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                                                                                           NSAttributedString.Key.font:UIFont(name: "Poppins-Medium", size: 18)!
                   ])
                }
        }
    
    func showMembers() {
        self.view.isUserInteractionEnabled = false
        var membership:MembershipDetailStructure? = nil
        SVProgressHUD.show()
        
        FireStoreManager.shared.getAllMembers(completion: {
            (dataDirctionary,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.alertBox(title: "Retry", message: "Error in fetching member's list, please try again.")
            }else{
                self.listOfMemberArray.removeAll()
                for singleData in dataDirctionary! {
                    if singleData.count > 0 {
                        
                        let memberDetail = AppManager.shared.getMemberDetailStr(memberDetail: singleData["memberDetail"] as! Dictionary<String, String>)
                        let membershipArray = singleData["memberships"] as! Array<Dictionary<String,String>>
                        let currentMembership =
                            AppManager.shared.getCurrentMembership(membershipArray:membershipArray )
                        
                        if currentMembership.count > 0 {
                            membership = currentMembership.first
                        }else {
                            membership =  membershipArray.count > 0 ? AppManager.shared.getLatestMembership(membershipsArray:  membershipArray) :
                                MembershipDetailStructure(membershipID: memberDetail.memberID, membershipPlan: "--", membershipDetail: "--", amount:"0", startDate: "--", endDate: "--", totalAmount: "0", paidAmount: "0", discount: "0", paymentType: "--", dueAmount: "0", purchaseTime: "--", purchaseDate: "--", membershipDuration: "0")
                        }
                        let member = ListOfMemberStr(memberID: memberDetail.memberID, userImg: UIImage(named: "user1")!, userName: "\(memberDetail.firstName) \(memberDetail.lastName)", phoneNumber: memberDetail.phoneNo, dateOfExp:membership!.endDate , dueAmount: membership!.dueAmount, uploadName: memberDetail.uploadIDName)
                            self.listOfMemberArray.append(member)
                    }
                }
                self.listOfMemberTable.reloadData()
                self.view.isUserInteractionEnabled = true
            }
        })
    }
    
    func setCompleteListOfMembersView() {
        navigationView.navigationTitleLabel.text = "Member"
        self.searchFilterView.layer.cornerRadius = 16.0
        self.listOfMemberTable.separatorStyle  = .none
        self.filterView.layer.cornerRadius = 15.0
        [self.filterOptionView,self.filterSecondOptionView,self.filterThirdOptionView,self.filterFourthOpitonView].forEach{
            $0!.layer.cornerRadius = 15.0
            $0!.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).cgColor
            $0!.layer.borderWidth = 1.0
            $0!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(enableSelectionWithFilterView(_:))))
        }
        self.filterApplyBtn.layer.cornerRadius = 15.0
        self.filterApplyBtn.clipsToBounds = true
        self.navigationView.searchBtn.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
        self.setSearchBar()
        addClickToDismissSearchBar()
        self.customSearchBar.delegate = self
    }
    
    @objc func enableSelectionWithFilterView(_ gesture:UITapGestureRecognizer){
        switch gesture.view?.tag {
        case 1:
            self.allMemberFilter()
        case 2:
            self.expiredMembersFilter()
        case 3:
            self.checkInFilter()
        case 4:
            self.checkoutFilter()
        default:
            break
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
        self.navigationView.isHidden = false
        self.navigationView.alpha = 1.0
        self.searchBarView.isHidden = true
        self.searchBarView.alpha = 0.0
        self.view.endEditing(true)
    }

    @objc  func showSearchBar()  {
        if self.searchBarView.isHidden == true {
            self.navigationView.isHidden = true
            self.navigationView.alpha = 0.0
            self.searchBarView.isHidden = false
            self.searchBarView.alpha = 1.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMemberSegue"{
            let destinationVC = segue.destination as! AddMemberViewController
            destinationVC.isNewMember = sender as! Bool
            destinationVC.isRenewMembership = !(sender as! Bool)
        }
    }
    
    func setUpFilterView()  {
        [self.allMemberFilterBtn,self.expiredMembersFilterBtn,self.CheckinFilterBtn,self.checkoutFilterBtn].forEach{
            $0.setImage(UIImage(named: "non_selecte"), for: .normal)
        }
        self.allMemberFilterBtn.addTarget(self, action: #selector(allMemberFilter), for: .touchUpInside)
        self.expiredMembersFilterBtn.addTarget(self, action: #selector(expiredMembersFilter), for: .touchUpInside)
        self.CheckinFilterBtn.addTarget(self, action: #selector(checkInFilter), for: .touchUpInside)
        self.checkoutFilterBtn.addTarget(self, action: #selector(checkoutFilter), for: .touchUpInside)
        self.filterApplyBtn.addTarget(self, action: #selector(doFilteration), for: .touchUpInside)
    }
    
   @objc func allMemberFilter() {
    self.allMemberFilterBtn.setImage(UIImage(named: "selelecte"), for: .normal)
     [self.expiredMembersFilterBtn,self.CheckinFilterBtn,self.checkoutFilterBtn].forEach{
              $0.setImage(UIImage(named: "non_selecte"), for: .normal)
          }
    }
    
    @objc func expiredMembersFilter() {
          self.expiredMembersFilterBtn.setImage(UIImage(named: "selelecte"), for: .normal)
           [self.allMemberFilterBtn,self.CheckinFilterBtn,self.checkoutFilterBtn].forEach{
                    $0.setImage(UIImage(named: "non_selecte"), for: .normal)
                }
       }
    
    @objc func checkInFilter() {
          self.CheckinFilterBtn.setImage(UIImage(named: "selelecte"), for: .normal)
           [self.allMemberFilterBtn,self.expiredMembersFilterBtn,self.checkoutFilterBtn].forEach{
                    $0.setImage(UIImage(named: "non_selecte"), for: .normal)
                }
       }
    
    @objc func checkoutFilter() {
         self.checkoutFilterBtn.setImage(UIImage(named: "selelecte"), for: .normal)
                  [self.allMemberFilterBtn,self.expiredMembersFilterBtn,self.CheckinFilterBtn].forEach{
                           $0.setImage(UIImage(named: "non_selecte"), for: .normal)
                       }
    }
    
    @objc func doFilteration() {
        self.hideFilterView()
        self.filteration()
       }
    
    func filteration() {
        [self.allMemberFilterBtn,self.expiredMembersFilterBtn,self.CheckinFilterBtn,self.checkoutFilterBtn].forEach{
            if $0?.currentImage == UIImage(named: "selelecte"){
                switch $0?.tag {
                case 1:
                    self.allMemberFilterAction()
                    self.filterationLabel = "allMemberFilteration"
                case 2:
                    self.expiredMemberFilterationAction()
                    self.filterationLabel = "expiredMemberFilteration"
                case 3:
                    self.checkFilterationAction(checkFor: "checkIn")
                    self.filterationLabel = "checkInMemberFilteration"
                case 4:
                    self.checkFilterationAction(checkFor: "checkOut")
                    self.filterationLabel = "checkOutMemberFilteration"
                default:
                    break
                }
            }
        }
    }
    
    func alertBox(title:String,message:String) {
          let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
          let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
          _ in
            
            if title == "Success" || title == "Retry" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
                     self.showMembers()
                })
            }
          })
        alertController.addAction(okAlertAction)
        present(alertController, animated: true, completion: nil)
      }
    
    
    func setCellAttendeneBtn(memberCell:ListOfMembersTableCell,memberID:String)  {
        FireStoreManager.shared.isCheckOut(memberOrTrainer: .Member, memberID: memberID, result: {
            (checkOut,err) in
            
            if err == nil{
                memberCell.imageName = checkOut == true ? "green" : "red"
                memberCell.attendImg?.image = UIImage(named: memberCell.imageName)
            }
        })
    }
    
    func setCellRenewMembershipBtn(memberCell:ListOfMembersTableCell,memberID:String,dueAmount:String)  {
        FireStoreManager.shared.isCurrentMembership(memberOrTrainer: .Member, memberID: memberID, result: {
            (flag,membershipExists,err) in
            
            if err == nil {
                memberCell.attendImg?.isUserInteractionEnabled = flag!
                memberCell.attendImg?.alpha = flag == true ? 1.0 : 0.4
                memberCell.attendenceLabel.alpha = flag == true ? 1.0 : 0.4
                memberCell.dueAmount.text =  flag == true ? dueAmount :"0"
              //  memberCell.dateOfExpiry.text = flag == true ? dateOfExpiry : "--"
                memberCell.renewImg?.isUserInteractionEnabled = membershipExists!
                memberCell.renewImg?.alpha = membershipExists == true ? 1.0 : 0.4
                memberCell.renewPackageLabel.alpha = membershipExists == true ? 1.0 : 0.4
            }
        })
    }
}

extension ListOfMembersViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
                         self.filteredMemberArray.removeAll()
                         for singleMember in listOfMemberArray{
                             if singleMember.userName.lowercased().contains(searchText.lowercased()) == true  ||
                                singleMember.phoneNumber.contains(searchText) == true {
                                 self.filteredMemberArray.append(singleMember)
                                 self.listOfMemberTable.reloadData()
                             }
                         }
          } else {
            self.filteredMemberArray.removeAll()
            self.listOfMemberTable.reloadData()
        }
    }
}

extension ListOfMembersViewController:CustomCellSegue{
    func showMessage(vc: MFMessageComposeViewController) {
        present(vc, animated: true, completion: nil)
    }

    func applySegue(id: String) {
           AppManager.shared.memberID = id
        performSegue(withIdentifier: "addMemberSegue", sender: false)
    }
}

//extension UIView {
//    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
//    }
//}
