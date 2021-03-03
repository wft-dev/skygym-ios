//
//  ListOfTrainersViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD
import MessageUI

class ListOfTrainersTableCell: UITableViewCell {
    @IBOutlet weak var trainerCellView: UIView!
    @IBOutlet weak var trainerNameLabel: UILabel!
    @IBOutlet weak var trainerLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var memberLabelView: UIView!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var dateOfJoiningLabel: UILabel!
    @IBOutlet weak var trainerPhoneNoLabel: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var attendenceBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var callLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var attendLabel: UILabel!

    var imageName:String = "Attend"
    let messenger = MessengerManager()
    var customDelegate:CustomCellSegue? = nil
    
    override func awakeFromNib() {
        callLabel.isUserInteractionEnabled = true
        callLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callAction)))
        msgLabel.isUserInteractionEnabled = true
        msgLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(messageAction)))
        attendLabel.isUserInteractionEnabled = true
        attendLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(attendenceAction)))
        callBtn.addTarget(self, action: #selector(callAction), for: .touchUpInside)
        messageBtn.addTarget(self, action: #selector(messageAction), for: .touchUpInside)
        attendenceBtn.addTarget(self, action: #selector(attendenceAction), for: .touchUpInside)
        attendenceBtn.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc func callAction()  {
        AppManager.shared.callNumber(phoneNumber: "7015810695")
    }
    
    @objc func messageAction()  {
//        print("message")
//        if messenger.canSendText() {
//            let messangerVC = messenger.configuredMessageComposeViewController(recipients: ["7015810695"], body: "testing visitor .")
//            customDelegate?.showMessage(vc: messangerVC)
//        }
        customDelegate?.applySegueToChat(id: "\(attendenceBtn.tag)", memberName: self.trainerNameLabel.text!)
      }
    
   @objc func attendenceAction()  {
    performTrainerAttandance(id: "\(attendenceBtn.tag)")
     }
    
    private func performTrainerAttandance(id:String){
        switch self.imageName {
        case "Attend":
            FireStoreManager.shared.addAttendence(trainerORmember: "Trainers", id: id, present: true, checkInA: AppManager.shared.getTimeFrom(date: Date()), checkOutA: "-")
            imageName = "AttendYlw"
            self.attendenceBtn.setImage(UIImage(named: imageName), for: .normal)
        case "AttendYlw":
            imageName = "Attend"
            self.attendenceBtn.setImage(UIImage(named: imageName), for: .normal)
            FireStoreManager.shared.updateAttendence(trainerORmember: "Trainers", id: id, checkOutA: AppManager.shared.getTimeFrom(date: Date()), completion: {
                err in
                
            })
        default:
            break
        }
    }
 
    private func showAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAlertAction)
        AppManager.shared.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

class ListOfTrainersViewController: BaseViewController {
    @IBOutlet weak var listOfTrainerTable: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var customSearchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    var listOfTrainerArray:[ListOfTrainers] = []
    var filteredListOfTrainerArray:[ListOfTrainers] = []
    var membersArray:[Dictionary<String,Any>] = []
    var userImage:UIImage? = nil
    let refreshController = UIRefreshControl()
    var senderName:String = ""
    var senderID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setListOfTrainersCompleteView()
        self.refreshController.tintColor = .black
        self.refreshController.attributedTitle = NSAttributedString(string: "Fetching Trainer List")
        self.refreshController.addTarget(self, action: #selector(refreshTrainerList), for: .valueChanged)
        self.listOfTrainerTable.refreshControl = self.refreshController
         senderID = AppManager.shared.loggedInRole == LoggedInRole.Admin ? AppManager.shared.adminID : AppManager.shared.trainerID
         senderName = AppManager.shared.loggedInRole == LoggedInRole.Admin ? AppManager.shared.adminName : AppManager.shared.trainerName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppManager.shared.trainerID = ""
        FireStoreManager.shared.getAllMembers(completion: {
            (memberData,err) in
            if err == nil {
                self.membersArray = memberData!
                self.fetcthAllTrainer()
            }
        })
        self.searchBarView.isHidden = true
    }

    
  @objc func refreshTrainerList()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            self.refreshController.endRefreshing()
            self.fetcthAllTrainer()
        })
    }
    
    @IBAction func addNewTrainerBtnAction(_ sender: Any) {
        let trainerEditVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "trainerEditVC") as! TrainerEditScreenViewController
        trainerEditVC.isNewTrainer = true
        self.navigationController?.pushViewController(trainerEditVC, animated: true)
    }
    
    @objc func trainerLeftSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x = -((gesture.view?.frame.width)!/2)
        })
    }
    
    @objc func trainerRightSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x =  0
        })
    }
    
    @objc func deleteTrainer(_ gesture:UIGestureRecognizer){
        let trainerID = "\(gesture.view!.tag)"
        let alertController = UIAlertController(title: "Attention", message: "Do you really want to remove this trainer ?", preferredStyle: .alert)
        let okActionAlert = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
            SVProgressHUD.show()
            FireStoreManager.shared.deleteUserCredentials(id: trainerID, handler: {
                (err) in
                if err == nil {
                    DispatchQueue.global(qos: .background).async {
                        let result  =  FireStoreManager.shared.deleteImgBy(id: trainerID)
                        
                        switch result {
                        case let .success(flag):
                            if flag == true {
                                FireStoreManager.shared.deleteTrainerBy(id: trainerID, completion: {
                                    (err) in
                                    SVProgressHUD.dismiss()
                                    if err != nil {
                                        self.showAlert(title: "Error", message: "Trainer is not deleted successfully.")
                                    } else {
                                        self.showAlert(title: "Success", message: "Trainer is  deleted successfully.")
                                    }
                                })
                            }
                        case .failure(_):
                            break
                        }
                    }
                }
            })
        })
        let cancelActionAlert = UIAlertAction(title: "Cancel", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
        })
        alertController.addAction(okActionAlert)
        alertController.addAction(cancelActionAlert)
        present(alertController, animated: true, completion: nil)
    }

    func addTrainerCustomSwipe(cellView:UIView,cell:ListOfTrainersTableCell,id:String) {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(trainerLeftSwipeAction(_:)))
        let rightSwipGesture = UISwipeGestureRecognizer(target: self, action: #selector(trainerRightSwipeAction(_:)))
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
        trashImgView.tag = Int(id) ?? 0
        deleteView.backgroundColor = .red
        cell.contentView.addSubview(deleteView)
        deleteView.addSubview(trashImgView)
        trashImgView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        cellView.isUserInteractionEnabled = true
        
        trashImgView.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor, constant: 0).isActive = true
        trashImgView.trailingAnchor.constraint(equalTo: deleteView.trailingAnchor, constant: -(cell.frame.width/4)).isActive = true
        trashImgView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        trashImgView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        trashImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteTrainer(_:))))
        
        deleteView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        deleteView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        deleteView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0).isActive = true
        deleteView.bottomAnchor.constraint(greaterThanOrEqualTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
        deleteView.tag = 11
        cellView.addGestureRecognizer(leftSwipeGesture)
        cellView.addGestureRecognizer(rightSwipGesture)
        deleteView.superview?.sendSubviewToBack(deleteView)
    }
    
    func fetcthAllTrainer() {
        SVProgressHUD.show()
        FireStoreManager.shared.getAllTrainers(completion: {
            (trainerData,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.showAlert(title: "Retry", message: "Error in fetching trainer's list , please try again.")
            } else {
                self.listOfTrainerArray.removeAll()
                for singleData in trainerData! {
                    if singleData.count > 0 {
                        let trainer = AppManager.shared.getTraineListInfo(trainerDetail: singleData["trainerDetail"] as! [String :Any ])
                        self.listOfTrainerArray.append(trainer)
                    }
                }
                self.listOfTrainerTable.reloadData()
            }
        })
    }
    
    func isAttendenceMarkedForTrainer(trainerID:String,cell:ListOfTrainersTableCell) {
        FireStoreManager.shared.isCheckOut(memberOrTrainer: .Trainer, memberID: trainerID, result: {
            (checkOut,err) in
            
            if err == nil{
                cell.imageName = checkOut == true ? "AttendYlw" : "Attend"
                cell.attendenceBtn.setImage(UIImage(named: cell.imageName), for: .normal)
            }
        })
    }
    
    func showAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction  = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            if title == "Success" || title == "Retry" {
                self.fetcthAllTrainer()
            }
        })
        alertController.addAction(okAlertAction)
        present(alertController, animated: true , completion: nil)
    }
    
    func getUserProfileImage(id:String,imgView :UIImageView) {
        SVProgressHUD.show()
        FireStoreManager.shared.downloadUserImg(id: id, result: {
            (imgUrl,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                imgView.image = UIImage(named: "user1")
            } else {
                do{
                  let imgData = try Data(contentsOf: imgUrl!)
                    self.userImage = UIImage(data: imgData)
                    imgView.image = self.userImage
                    imgView.makeRounded()
                    
                } catch let error as NSError { print(error) }
            }
        })
    }
    
    func setListOfTrainersCompleteView() {
        self.setListOfTrainersNavigationSet()
        self.listOfTrainerTable.separatorStyle = .none
        self.addClickToDismissSearchBar()
        self.setSearchBar()
        self.customSearchBar.delegate = self
    }
    
    func setListOfTrainersNavigationSet() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
            let title = NSAttributedString(string: "Trainer", attributes: [
                NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
            ])
            let titleLabel = UILabel()
            titleLabel.attributedText = title
            self.navigationController?.navigationBar.topItem?.titleView = titleLabel
            let menuBtn = UIButton()
            let searchBtn = UIButton()
            searchBtn.setImage(UIImage(named:"search-1"), for: .normal)
            menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
            searchBtn.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
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
    
    func setTrainerTableCellView(tableCellView:UIView)  {
        tableCellView.layer.cornerRadius = 20.0
        tableCellView.layer.borderWidth = 1.0
        tableCellView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        tableCellView.clipsToBounds = true
    }
    
    func setSearchBar()  {
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
                searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Trainers",
                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                                                                                        NSAttributedString.Key.font:UIFont(name: "Poppins-Medium", size: 18) as Any
                ])
            }
    }
    
    @objc  func showSearchBar()  {
        if self.searchBarView.isHidden == true {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.navigationBar.alpha = 0.0
            self.searchBarTopConstraint.constant = -((self.navigationController!.navigationBar.frame.origin.y/4 ) )
            self.searchBarHeightConstraint.constant = 60
            self.searchBarView.isHidden = false
            self.searchBarView.alpha = 1.0
       }
       }
    private func addClickToDismissSearchBar() {
           let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedView(_:)))
           tapRecognizer.cancelsTouchesInView = false
           self.view.isUserInteractionEnabled = true
           self.view.addGestureRecognizer(tapRecognizer)
       }

       @objc
    private func dismissPresentedView(_ sender: UITapGestureRecognizer?) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1.0
        self.searchBarHeightConstraint.constant = 0
        self.searchBarView.isHidden = true
        self.searchBarView.alpha = 0.0
        self.view.endEditing(true)
    }
}

extension ListOfTrainersViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredListOfTrainerArray.count > 0 ? self.filteredListOfTrainerArray.count : self.listOfTrainerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainerCell", for: indexPath) as! ListOfTrainersTableCell
        let singleTrainer = self.filteredListOfTrainerArray.count > 0 ? self.filteredListOfTrainerArray[indexPath.section] : self.listOfTrainerArray[indexPath.section]
        self.setTrainerTableCellView(tableCellView: cell.trainerCellView)
        cell.layer.cornerRadius = 20.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        cell.trainerLabel.layer.cornerRadius = 6.5
        cell.memberLabelView.layer.cornerRadius = 6.5
        cell.numberOfMembersLabel.layer.cornerRadius = 5.5
        self.getUserProfileImage(id: singleTrainer.trainerID, imgView: cell.userImg)
        cell.trainerNameLabel.text = singleTrainer.trainerName
        cell.trainerPhoneNoLabel.text = singleTrainer.trainerPhone
        cell.dateOfJoiningLabel.text = singleTrainer.dateOfJoinging
        cell.trainerLabel.text = singleTrainer.type
        cell.salaryLabel.text = singleTrainer.salary
        cell.attendenceBtn.tag = Int(singleTrainer.trainerID) ?? 0
        self.addTrainerCustomSwipe(cellView: cell.trainerCellView, cell: cell,id: singleTrainer.trainerID)
        cell.selectionStyle = .none
        self.isAttendenceMarkedForTrainer(trainerID: singleTrainer.trainerID, cell: cell)
        cell.numberOfMembersLabel.text = "\(AppManager.shared.getNumberOfMemberAddedByTrainerWith(membersData: self.membersArray, trainerID: singleTrainer.trainerID))"
        cell.customDelegate = self
        
        return cell
    }
}

extension ListOfTrainersViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.trainerID = self.listOfTrainerArray[indexPath.section].trainerID
        let trainerEditVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "trainerEditVC") as! TrainerEditScreenViewController
        trainerEditVC.isNewTrainer = false
        trainerEditVC.img = self.userImage
        self.navigationController?.pushViewController(trainerEditVC, animated: true)
    }
}

extension ListOfTrainersViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            self.filteredListOfTrainerArray.removeAll()
            for singleTrainer in self.listOfTrainerArray {
                if  singleTrainer.trainerName.lowercased().contains(searchText.lowercased()) == true  ||
                singleTrainer.trainerPhone.contains(searchText) == true{
                    self.filteredListOfTrainerArray.append(singleTrainer)
                }
            }
        } else {
            self.filteredListOfTrainerArray.removeAll()
        }
        self.listOfTrainerTable.reloadData()
    }
}

extension ListOfTrainersViewController:CustomCellSegue{
    func showMessage(vc: MFMessageComposeViewController) {}
    func applySegue(id: String) {}
    
    
    func applySegueToChat(id: String, memberName: String) {
        let currentChatUsers = ChatUsers(messageSenderID: self.senderID, messageReceiverID: id, messageSenderName: self.senderName, messageReceiverName: memberName)
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.chatUsers = currentChatUsers
        self.navigationController?.pushViewController(chatVC, animated: true)
    }

}
