//
//  ListOfVisitorsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 09/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setVisitorsNavigationBar()
        self.visitorsTable.separatorStyle = .none
        self.setVisitorSearchBar()
        self.customSearchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool)  {
        super.viewDidAppear(animated)
        self.fetchVisitors()
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
            SVProgressHUD.dismiss()
            if err != nil {
                self.viewWillAppear(true)
            }else {
                self.visitorsArray.removeAll()
                for visitor in visitors!{
                    self.visitorsArray.append(AppManager.shared.getVisitor(visitorDetail:visitor["visitorDetail"] as! [String:String], id: visitor["id"] as! String))
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
              self.viewDidLoad()
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
               if title == "Success" {
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
        cell.selectedBackgroundView = AppManager.shared.getClearBG()
        
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
        performSegue(withIdentifier: "visitorViewSegue", sender: false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteContextualAction = UIContextualAction(style: .destructive, title: "Delete", handler: {
            (action,view,context) in
            FireStoreManager.shared.deleteImgBy(id: self.visitorsArray[indexPath.section].id, result: {
                err in
                if err != nil {
                    self.showVisitorAlert(title: "Error", message: "Error in deleting visitor.")
                } else {
                    FireStoreManager.shared.deleteVisitorBy(id: self.visitorsArray[indexPath.section].id, completion: {
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
        deleteContextualAction.backgroundColor = .red
        deleteContextualAction.image = UIImage(named: "delete")
        let configuration = UISwipeActionsConfiguration(actions: [deleteContextualAction])
        return configuration
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
    func applySegue(id: String) {
        self.performSegue(withIdentifier: "visitorMemberSegue", sender: id)
    }

}


