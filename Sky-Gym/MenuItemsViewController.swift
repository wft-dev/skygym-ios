//
//  MenuItemsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 28/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SWRevealViewController


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
    let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var sw:SWRevealViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        self.menuItemTable.tableFooterView = UIView(frame: .zero)
        self.menuItemTable.separatorStyle = .none
        appDelgate = UIApplication.shared.delegate as? AppDelegate
        self.sw = storyBoard.instantiateViewController(withIdentifier: "swRevealVC") as? SWRevealViewController
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
            array = ["Dashboard","Member","Trainer","Membership Plan","Visitors","Profile","Events","Gallary"," Videos","Workout Plans","Logout"]
        case .Trainer :
            array = ["Dashboard","Gym Info","Home", "Member","Membership Plan","Profile","Visitors","Events", "Gallary",
                "Videos","Workout  Plan","Logout"]
            if AppManager.shared.trainerVisitorPermission == false  {
            array.remove(at: 6)
            }
            if  AppManager.shared.trainerMemberPermission == false {
                array.remove(at: 3)
            }
        case .Member :
            array = ["Home","Gym Info","Membership plans","Profile","Trainer","Events", "Gallary","Videos","Logout"]
        }
        return array
    }
    
    func menuItemMappingForAdmin(index:Int) {

        switch (index) {
        case 0:
            let dashboardVC = self.storyBoard.instantiateViewController(withIdentifier: "dashbaordVC") as! AdminDashboardViewController
           
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: dashboardVC), animated: true)
            break
        case 1:
            let listOfMemberVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfMemberVC") as! ListOfMembersViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: listOfMemberVC), animated: true)
            break
        case 2:
            let listOfTrainersVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfTrainersVC") as! ListOfTrainersViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: listOfTrainersVC), animated: true)
            break
        case 3:
            let listOfMembershipVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfMembershipVC") as! ListOfMembershipViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: listOfMembershipVC), animated: true)
            break
        case 4:
            let listOfVisitorVC = self.storyBoard.instantiateViewController(withIdentifier: "visitorVC") as! ListOfVisitorsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: listOfVisitorVC), animated: true)
            break
        case 5 :
            let adminProfileVC = self.storyBoard.instantiateViewController(withIdentifier: "profileAdminVC") as! ProfileAdminViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: adminProfileVC), animated: true)
            break
        case 6 :
            let eventVC = self.storyBoard.instantiateViewController(withIdentifier: "eventsVC") as! ListOfEventsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: eventVC), animated: true)
            break
        case 7 :
                let gallaryVC = self.storyBoard.instantiateViewController(withIdentifier: "gallaryVC") as! GallaryViewController // gymVideoVC
                self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gallaryVC), animated: true)
                break
        case 8 :
            let gymVideoVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfVideosVC") as! ListOfVideosViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gymVideoVC), animated: true)
            break
        case 9:
            let workoutVC = self.storyBoard.instantiateViewController(withIdentifier: "workoutVC") as! ListOfWorkoutViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: workoutVC), animated: true)
            break
            
        default:
            self.appDelgate?.swRevealVC.revealToggle(animated: true)
            self.logOut()
            break
        }
    }
    
    func menuItemMappingForTrainer(index:Int) {
        let memberIndex = AppManager.shared.trainerMemberPermission ? 3 : 11
        let visitorIndex = AppManager.shared.trainerVisitorPermission ? 6 : 12
        switch (index) {
        case 0:
            let dashboardVC = self.storyBoard.instantiateViewController(withIdentifier: "dashbaordVC") as! AdminDashboardViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: dashboardVC), animated: true)
            break
        case 1:
            let gymInfoVC = self.storyBoard.instantiateViewController(withIdentifier: "gymInfoVC") as! GymInfoViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gymInfoVC), animated: true)
            break
        case 2:
            let trainerEditVC = self.storyBoard.instantiateViewController(withIdentifier: "trainerEditVC") as! TrainerEditScreenViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: trainerEditVC), animated: true)
            break
        case memberIndex :
            let listOfMemberVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfMemberVC") as! ListOfMembersViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: listOfMemberVC), animated: true)
            break
        case memberIndex == 3 ? 4 : 3 :
            let listOfMembershipVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfMembershipVC") as! ListOfMembershipViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: listOfMembershipVC), animated: true)
            break
        case memberIndex == 3 ? 5 : 4 :
            let trainerProfileVC = self.storyBoard.instantiateViewController(withIdentifier: "trainerProfileVC") as! TrainerProfileViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: trainerProfileVC), animated: true)
            break
        case  memberIndex == 3 ? visitorIndex : visitorIndex == 6 ? 5 : 13 :
            let listOfVisitorVC = self.storyBoard.instantiateViewController(withIdentifier: "visitorVC") as! ListOfVisitorsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: listOfVisitorVC), animated: true)
            break
        case  memberIndex == 3 && visitorIndex == 6 ? 7 : visitorIndex == 6 || memberIndex == 3 ? 6: 5:
            let eventVC = self.storyBoard.instantiateViewController(withIdentifier: "eventsVC") as! ListOfEventsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: eventVC), animated: true)
            break
        case   memberIndex == 3 && visitorIndex == 6  ? 8 : visitorIndex == 6 || memberIndex == 3 ? 7 : 6 :
            let gallaryVC = self.storyBoard.instantiateViewController(withIdentifier: "gallaryVC") as! GallaryViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gallaryVC), animated: true)
            break
            
        case memberIndex == 3 && visitorIndex == 6 ? 9 :visitorIndex == 6 || memberIndex == 3 ? 8 : 7 :
            let gymVideoVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfVideosVC") as! ListOfVideosViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gymVideoVC), animated: true)
            break
            
        case memberIndex == 3 && visitorIndex == 6 ? 10 :visitorIndex == 6 || memberIndex == 3 ? 9 : 8 :
            let workoutVC = self.storyBoard.instantiateViewController(withIdentifier: "workoutVC") as! ListOfWorkoutViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: workoutVC), animated: true)
            break
            
        default:
            self.appDelgate?.swRevealVC.revealToggle(animated: true)
            self.logOut()
            break
        }
    }
    
    func menuItemMappingForMember(index:Int) {
        switch(index) {
        case 0 :
            let memberDetailVC = self.storyBoard.instantiateViewController(withIdentifier: "memberDetailVC") as! MemberDetailViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: memberDetailVC), animated: true)
            break
        case 1 :
            let gymInfoVC = self.storyBoard.instantiateViewController(withIdentifier: "gymInfoVC") as! GymInfoViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gymInfoVC), animated: true)
            break
        case 2:
            let membershipPlanVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfMembershipVC") as! ListOfMembershipViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: membershipPlanVC), animated: true)
            break
        case 3:
            let memberLoginProfile = self.storyBoard.instantiateViewController(withIdentifier: "memberLoginProfileVC") as! MemberLoginProfileViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: memberLoginProfile), animated: true)
            break
        case 4:
            let memberLoginTrainerProfile = self.storyBoard.instantiateViewController(withIdentifier: "memberLoginTrainerProfileVC") as! MemberLoginTrainerProfileViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: memberLoginTrainerProfile), animated: true)
            break
        case 5 :
            let eventsVC = self.storyBoard.instantiateViewController(withIdentifier: "eventsVC") as! ListOfEventsViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: eventsVC), animated: true)
            break
        case 6:
            let gallaryVC = self.storyBoard.instantiateViewController(withIdentifier: "gallaryVC") as! GallaryViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gallaryVC), animated: true)
            break
        case 7 :
            let gymVideoVC = self.storyBoard.instantiateViewController(withIdentifier: "listOfVideosVC") as! ListOfVideosViewController
            self.appDelgate?.swRevealVC.pushFrontViewController(UINavigationController(rootViewController: gymVideoVC), animated: true)
            break
        default:
            self.appDelgate?.swRevealVC.revealToggle(animated: true)
            self.logOut()
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
            break
        case .Trainer :
            self.menuItemMappingForTrainer(index: indexPath.row)
            break
        case .Member :
            self.menuItemMappingForMember(index: indexPath.row)
            break
        default:
            break
        }
    }
}
