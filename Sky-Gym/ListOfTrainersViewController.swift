//
//  ListOfTrainersViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 08/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

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
        print("call")
    }
    
    @objc func messageAction()  {
          print("message")
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
                let s = err == nil ? "Successfull" : "false"
                print("Attendence \(s)")
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
    @IBOutlet weak var listOfTrainersNavigationBar: CustomNavigationBar!
    @IBOutlet weak var listOfTrainerTable: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var customSearchBar: UISearchBar!
    var listOfTrainerArray:[ListOfTrainers] = []
    var filteredListOfTrainerArray:[ListOfTrainers] = []
    var membersArray:[Dictionary<String,Any>] = []
    var userImage:UIImage? = nil
    let refreshController = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setListOfTrainersCompleteView()
        self.refreshController.tintColor = .black
        self.refreshController.attributedTitle = NSAttributedString(string: "Fetching Trainer List")
        self.refreshController.addTarget(self, action: #selector(refreshTrainerList), for: .valueChanged)
        self.listOfTrainerTable.refreshControl = self.refreshController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppManager.shared.trainerID = ""
        FireStoreManager.shared.getAllMembers(completion: {
            (memberData,err) in
            if err == nil {
                self.membersArray = memberData!
                self.fetcthAllTrainer()
            }
        })
    }
    
  @objc func refreshTrainerList()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            self.refreshController.endRefreshing()
            self.fetcthAllTrainer()
        })
    }
    
    @IBAction func addNewTrainerBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "visitorDetailSegue", sender:true)
    }
}

extension ListOfTrainersViewController {
    
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
        cellView.backgroundColor = .white
        cell.contentView.backgroundColor = .white
        cellView.layer.cornerRadius = 20
        cellView.layer.cornerRadius = 15.0
        cellView.layer.borderColor = UIColor(red: 211/255, green: 211/252, blue: 211/255, alpha: 1.0).cgColor
        cellView.layer.borderWidth = 1.0
        
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
                        let trainerDetail = AppManager.shared.getTrainerDetailS(trainerDetail: singleData["trainerDetail"] as! [String : Any] )
                        let trainer = ListOfTrainers(trainerID: trainerDetail.trainerID, trainerName: "\(trainerDetail.firstName) \(trainerDetail.lastName)", trainerPhone: trainerDetail.phoneNo, dateOfJoinging: trainerDetail.dateOfJoining, salary: trainerDetail.salary, members:"0", type: trainerDetail.type)
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
    
    func setNumberOFMembers(trainerID:String,cell:ListOfTrainersTableCell) {
        DispatchQueue.global(qos: .background).async {
            let result = AppManager.shared.getNumberOfMemberAddedByTrainerWith(membersData: self.membersArray, trainerID: trainerID)
            DispatchQueue.main.async {
                switch result {
                    
                case let .success(count):
                    cell.numberOfMembersLabel.text = "\(count)"
                case .failure(_):
                    cell.numberOfMembersLabel.text = "0"
                }
            }
        }
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
        self.listOfTrainersNavigationBar.menuBtn.isHidden = false
       // self.listOfTrainersNavigationBar.leftArrowBtn.isHidden = false
        self.listOfTrainersNavigationBar.navigationTitleLabel.text = "Trainer"
        self.listOfTrainersNavigationBar.searchBtn.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
    }
    
    func setTrainerTableCellView(tableCellView:UIView)  {
        tableCellView.layer.cornerRadius = 20.0
        tableCellView.layer.borderWidth = 1.0
        tableCellView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor

        tableCellView.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "visitorDetailSegue" {
            let destinationVC = segue.destination as! TrainerEditScreenViewController
            destinationVC.isNewTrainer = sender as! Bool
            destinationVC.img = self.userImage
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
               self.listOfTrainersNavigationBar.isHidden = true
               self.listOfTrainersNavigationBar.alpha = 0.0
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
           self.listOfTrainersNavigationBar.isHidden = false
           self.listOfTrainersNavigationBar.alpha = 1.0
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
        cell.numberOfMembersLabel.text = singleTrainer.members
        cell.attendenceBtn.tag = Int(singleTrainer.trainerID)!
        self.addTrainerCustomSwipe(cellView: cell.trainerCellView, cell: cell,id: singleTrainer.trainerID)
        cell.selectionStyle = .none
        self.isAttendenceMarkedForTrainer(trainerID: singleTrainer.trainerID, cell: cell)
        self.setNumberOFMembers(trainerID: singleTrainer.trainerID, cell: cell)
        
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
        performSegue(withIdentifier: "visitorDetailSegue", sender: false)
    }
}

extension ListOfTrainersViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.filteredListOfTrainerArray.removeAll()
            for singleTrainer in self.listOfTrainerArray {
                if  singleTrainer.trainerName.lowercased().contains(searchText.lowercased()){
                    self.filteredListOfTrainerArray.append(singleTrainer)
                    self.listOfTrainerTable.reloadData()
                }
            }
        } else {
            self.filteredListOfTrainerArray.removeAll()
            self.listOfTrainerTable.reloadData()
        }
    }
}
