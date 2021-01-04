//
//  MenuItemsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit


class MyMenuItemTableCell: UITableViewCell {
    
    @IBOutlet weak var menuItemLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
}

class MenuItemsViewController: UIViewController {
    @IBOutlet weak var menuItemTable: UITableView!
    var menuItemArray:[String] = []
    var appDelgate:AppDelegate? = nil
    var trainerMemberPermission:Bool = false
    var trainerEventPermission:Bool = false
    var trainerVisitorPermission:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
       assignbackground()
        self.menuItemTable.tableFooterView = UIView(frame: .zero)
        self.menuItemTable.separatorStyle = .none
        appDelgate = UIApplication.shared.delegate as? AppDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.menuItemArray = fillMenuArray(role: AppManager.shared.loggedInRole!)
        self.menuItemTable.reloadData()
    }
}

extension MenuItemsViewController {
    func assignbackground(){
              let background = UIImage(named: "Bg_yel.png")
              var imageView : UIImageView!
              imageView = UIImageView(frame: view.bounds)
              imageView.contentMode =  UIView.ContentMode.scaleToFill
              imageView.clipsToBounds = true
              imageView.image = background
              imageView.center = view.center
              view.addSubview(imageView)
              self.view.sendSubviewToBack(imageView)
          }
    
    func logOut() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure want to logout ?", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            AppManager.shared.performLogout()
        })
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func fillMenuArray(role:LoggedInRole) ->[String] {
        var array:[String] = []
        switch role {
        case .Admin:
            array = ["Dashboard","Member","Trainer","Membership Plan","Visitors","Profile","Events","Logout"]
        case .Trainer :
            array = ["Dashboard","Gym Info","Home", "Member","Membership Plan","Profile","Visitors","Events","Logout"]
            if AppManager.shared.trainerVisitorPermission == false  {
            array.remove(at: 6)
            print("Array for trainer when visitor is false is : \(array)")
            }
            if  AppManager.shared.trainerMemberPermission == false {
                array.remove(at: 3)
                print("Array for trainer when visitor is true  is : \(array)")
            }
            
        case .Member :
            array = ["Home","Gym Info","Membership plans","Profile","Trainer","Events","Logout"]
        }
        
        return array
    }
    
    func menuItemMappingForAdmin(index:Int) {
        
        switch (index) {
        case 0:
            let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashbaordVC") as! AdminDashboardViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(dashboardVC, animated: true)
            break
        case 1:
            let listOfMemberVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listOfMemberVC") as! ListOfMembersViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(listOfMemberVC, animated: true)
            break
        case 2:
            let listOfTrainersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listOfTrainersVC") as! ListOfTrainersViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(listOfTrainersVC, animated: true)
            break
        case 3:
            let listOfMembershipVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listOfMembershipVC") as! ListOfMembershipViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(listOfMembershipVC, animated: true)
            break
        case 4:
            let listOfVisitorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "visitorVC") as! ListOfVisitorsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(listOfVisitorVC, animated: true)
            break
        case 5 :
            let adminProfileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "adminProfileVC") as! AdminProfileViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(adminProfileVC, animated: true)
            break
        case 6 :
            let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "eventsVC") as! ListOfEventsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(eventVC, animated: true)
            break
        case 7 :
            self.appDelgate?.swRevealVC.revealToggle(animated: true)
            self.logOut()
        default:
            break
        }
    }
    
    
    func menuItemMappingForTrainer(index:Int) {
        let memberIndex = AppManager.shared.trainerMemberPermission ? 3 : 11
        let visitorIndex = AppManager.shared.trainerVisitorPermission ? 6 : 12
        switch (index) {
        case 0:
            let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashbaordVC") as! AdminDashboardViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(dashboardVC, animated: true)
            break
        case 1:
            let gymInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "gymInfoVC") as! GymInfoViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(gymInfoVC, animated: true)
            break
        case 2:
            let trainerEditVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "trainerEditVC") as! TrainerEditScreenViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(trainerEditVC, animated: true)
            break
        case memberIndex :
            let listOfMemberVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listOfMemberVC") as! ListOfMembersViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(listOfMemberVC, animated: true)
            break
        case memberIndex == 3 ? 4 : 3 :
            let listOfMembershipVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listOfMembershipVC") as! ListOfMembershipViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(listOfMembershipVC, animated: true)
            break
        case memberIndex == 3 ? 5 : 4 :
            let trainerProfileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "trainerProfileVC") as! TrainerProfileViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(trainerProfileVC, animated: true)
            break
        case  memberIndex == 3 ? visitorIndex : visitorIndex == 6 ? 5 : 13 :
            let listOfVisitorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "visitorVC") as! ListOfVisitorsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(listOfVisitorVC, animated: true)
            break
        case  memberIndex == 3 && visitorIndex == 6 ? 7 : visitorIndex == 6 || memberIndex == 3 ? 6: 5:
            let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "eventsVC") as! ListOfEventsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(eventVC, animated: true)
            break
        case   memberIndex == 3 && visitorIndex == 6  ? 8 : visitorIndex == 6 || memberIndex == 3 ? 7 : 6 :
            self.appDelgate?.swRevealVC.revealToggle(animated: true)
            self.logOut()
        default:
            break
        }
    }
}

extension MenuItemsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell", for: indexPath) as! MyMenuItemTableCell
        
        let singleMenuItem = self.menuItemArray[indexPath.row]
        cell.menuItemLabel.text = singleMenuItem
        if cell.menuItemLabel.text == "Logout" {
            cell.borderView.isHidden = true
        }
        else {
            cell.borderView.isHidden = false
        }
        return cell
    }
}

extension MenuItemsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch AppManager.shared.loggedInRole {
        case .Admin:
            self.menuItemMappingForAdmin(index: indexPath.row)
        case .Trainer :
            self.menuItemMappingForTrainer(index: indexPath.row)
        default:
            break
        }
    }
}
