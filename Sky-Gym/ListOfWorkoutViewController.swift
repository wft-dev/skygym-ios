//
//  ListOfWorkoutViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 23/03/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD


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
        SVProgressHUD.show()
        FireStoreManager.shared.getAllWorkout { (arr) in
            self.workoutPlanListArray = arr
            self.workoutPlanListTable.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    
    func addWorkoutPlanCustomSwipe(cellView:UIView,cell:ListOfWorkoutTableCell) {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(eventLeftSwipeAction(_:)))
        let rightSwipGesture = UISwipeGestureRecognizer(target: self, action: #selector(eventRightSwipeAction(_:)))
        leftSwipeGesture.direction = .left
        rightSwipGesture.direction = .right
        let _ = cell.contentView.subviews.map({
             if  $0.tag  == 11 {
                 $0.removeFromSuperview()
             }
         })
        let deleteView = UIView(frame: CGRect(x: 0, y: 0, width: cellView.frame.width, height:cellView.frame.height))

        let trashImgView = UIImageView(image: UIImage(named: "delete"))
        trashImgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        trashImgView.isUserInteractionEnabled = true
        trashImgView.tag = cellView.tag
        
        deleteView.backgroundColor = .red
        cell.contentView.addSubview(deleteView)
        deleteView.addSubview(trashImgView)
        trashImgView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        
        trashImgView.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor, constant: 0).isActive = true
        trashImgView.trailingAnchor.constraint(equalTo: deleteView.trailingAnchor, constant: -(cell.frame.width/4)).isActive = true
        trashImgView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        trashImgView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        trashImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteWorkout(_:))))
        
        deleteView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        deleteView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        deleteView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0).isActive = true
        deleteView.bottomAnchor.constraint(greaterThanOrEqualTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
        deleteView.tag = 11
        cellView.addGestureRecognizer(leftSwipeGesture)
        cellView.addGestureRecognizer(rightSwipGesture)
        cellView.isUserInteractionEnabled = true
        cellView.backgroundColor = .white
        //cellView.layer.cornerRadius = 20
        cell.layer.cornerRadius = 20
        cell.layer.borderColor = UIColor(red: 211/255, green: 211/252, blue: 211/255, alpha: 1.0).cgColor
        cell.layer.borderWidth = 1.0
        deleteView.superview?.sendSubviewToBack(deleteView)
    }
    
    
    @objc func eventLeftSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x = -((gesture.view?.frame.width)!/2)
        })
    }
    
    @objc func eventRightSwipeAction(_ gesture:UIGestureRecognizer){
        UIView.animate(withDuration: 0.4, animations: {
            gesture.view?.frame.origin.x =  0
        })
    }
    
    
    @objc func deleteWorkout(_ gesture:UIGestureRecognizer){
        SVProgressHUD.show()
        let id = "\(gesture.view!.tag)"
        
        FireStoreManager.shared.deleteWorkoutByID(id: id) { (err) in
            if err == nil {
                print("SUCCESS")
                self.getAllWorkoutPlans()
                SVProgressHUD.dismiss()
            }
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
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutPlanListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! ListOfWorkoutTableCell
        
        let singleWorkout = workoutPlanListArray[indexPath.section]
        
        cell.workoutMainView.layer.cornerRadius = 12.0
        cell.workoutMainView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        cell.workoutMainView.layer.borderWidth = 1.0
        
        cell.workoutPlanName.text = singleWorkout.workoutPlan
        cell.numberOfSets.text = "\(singleWorkout.numberOfSets)"
        cell.numberOfReps.text = "\(singleWorkout.numberOfReps)"
        cell.weight.text = "\(singleWorkout.weight) K.G."
        cell.workoutMainView.tag = Int(singleWorkout.workoutID)!
        
        cell.selectionStyle = .none
        addWorkoutPlanCustomSwipe(cellView: cell.workoutMainView, cell: cell)
        
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

extension ListOfWorkoutViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //addWorkoutVC
        addWorkoutVC?.isNewWorkout = false
        addWorkoutVC?.workoutID = self.workoutPlanListArray[indexPath.section].workoutID
        self.navigationController?.pushViewController(addWorkoutVC!, animated: true)
    }
    
}
