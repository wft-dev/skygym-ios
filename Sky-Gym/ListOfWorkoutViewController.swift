//
//  ListOfWorkoutViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 23/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit


class ListOfWorkoutTableCell: UITableViewCell {
    @IBOutlet weak var workoutPlanName: UILabel!
    @IBOutlet weak var numberOfSets: UILabel!
    @IBOutlet weak var numberOfReps: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var workoutMainView: UIView!
}

class ListOfWorkoutViewController: UIViewController {

    @IBOutlet weak var workoutPlanListTable: UITableView!
    
    private var menuBtn:UIButton = {
        let menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "icons8-menu-24"), for: .normal)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        menuBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        menuBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return menuBtn
    }()

    var workoutPlanListArray :[WorkoutPlanList] = []
    
    var addWorkoutVC:AddNewWorkoutViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setListOfWorkoutNavigationBar()
        workoutPlanListTable.dataSource = self
        workoutPlanListTable.delegate = self
        workoutPlanListTable.separatorStyle = .none
        addWorkoutVC = self.storyboard?.instantiateViewController(withIdentifier: "addWorkoutVC") as? AddNewWorkoutViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllWorkoutPlans()
    }
    
    
    @IBAction func addNewWorkout(_ sender: Any) {
        addWorkoutVC?.isNewWorkout = true
        self.navigationController?.pushViewController(addWorkoutVC!, animated: true)
    }
    
    func getAllWorkoutPlans()  {
        FireStoreManager.shared.getAllWorkout { (arr) in
            self.workoutPlanListArray = arr
            self.workoutPlanListTable.reloadData()
        }
    }
    
    func setListOfWorkoutNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let title = NSAttributedString(string: "Workout Plans", attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        navigationItem.titleView = titleLabel
        menuBtn.addTarget(self, action: #selector(menuChange), for: .touchUpInside)
        
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,menuBtn])
        stackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: stackView), animated: true)
    }
    
     @objc func menuChange() {  AppManager.shared.appDelegate.swRevealVC.revealToggle(self) }
    
}


extension ListOfWorkoutViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workoutPlanListArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! ListOfWorkoutTableCell
        
        let singleWorkout = workoutPlanListArray[indexPath.row]
        
        cell.workoutMainView.layer.cornerRadius = 12.0
        cell.workoutMainView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        cell.workoutMainView.layer.borderWidth = 1.0
        
        cell.workoutPlanName.text = singleWorkout.workoutPlan
        cell.numberOfSets.text = "\(singleWorkout.numberOfSets)"
        cell.numberOfReps.text = "\(singleWorkout.numberOfReps)"
        cell.weight.text = "\(singleWorkout.weight) K.G."
        
        cell.selectionStyle = .none
        
        return cell
        
    }

      func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 5
    }
      
      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let headerView = UIView()
          headerView.backgroundColor = UIColor.clear
          return headerView
      }
}

extension ListOfWorkoutViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //addWorkoutVC
        addWorkoutVC?.isNewWorkout = false
        addWorkoutVC?.workoutID = self.workoutPlanListArray[indexPath.row].workoutID
        self.navigationController?.pushViewController(addWorkoutVC!, animated: true)
    }
    
}
