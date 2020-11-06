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
    var menuItemArray = ["Dashboard","Member","Trainer","Membership Plan","Visitors","Profile","Events","Logout"]
     var appDelgate:AppDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

       assignbackground()
        self.menuItemTable.tableFooterView = UIView(frame: .zero)
        self.menuItemTable.separatorStyle = .none
        appDelgate = UIApplication.shared.delegate as? AppDelegate
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
               switch (indexPath.row) {
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
                AppManager.shared.performLogout()
              default:
                  break
              }

    }
}
