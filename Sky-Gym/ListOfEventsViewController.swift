//
//  ListOfEventsViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 12/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SVProgressHUD

class EventCellClass: UITableViewCell {
    
    @IBOutlet weak var eventCellView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventEndTime: UILabel!
}

class ListOfEventsViewController: BaseViewController {

    @IBOutlet weak var listOfEventsTable: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var customSearchBar: UISearchBar!
    @IBOutlet weak var addEventBtn: UIButton!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    var eventsArray:[Event] = []
    var filteredEventArray:[Event] = []
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setEventsNavigationBar()
        self.listOfEventsTable.separatorStyle = .none
        self.refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Events List")
        self.refreshControl.addTarget(self, action: #selector(refreshEventList), for: .valueChanged)
        self.listOfEventsTable.refreshControl = self.refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.fetchEvents()
         self.setTrainerLayout()
    }
    
    @objc func refreshEventList(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            self.refreshControl.endRefreshing()
            self.fetchEvents()
        })
    }
    
    @IBAction func addNewEventAction(_ sender: Any) {
        let eventViewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "eventViewVC") as! ViewEventScreenViewController
        eventViewVC.isNewEvent = true
        eventViewVC.eventID =  ""
        self.navigationController?.pushViewController(eventViewVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewEventScreenSegue" {
            let destinationVC = segue.destination as! ViewEventScreenViewController
            destinationVC.isNewEvent = sender as! Bool
            destinationVC.eventID = (sender as! Bool) == false ? AppManager.shared.eventID : ""
        }
    }
    
    func setTrainerLayout() {
        switch AppManager.shared.loggedInRole {
        case .Member:
            self.hideEventBtn(hide: true)
            break
        case .Admin :
            self.hideEventBtn(hide: false)
        default:
            AppManager.shared.trainerEventPermission == true  ? hideEventBtn(hide: false) : hideEventBtn(hide: true)
            break
        }
    }
    
    func  hideEventBtn(hide:Bool)  {
        self.addEventBtn.isHidden = hide
        self.addEventBtn.alpha = hide ? 0.0 : 1.0
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
    
    @objc func deleteEvent(_ gesture:UIGestureRecognizer){
        let alertController = UIAlertController(title: "Attention", message: "Do you really want to remove this event ?", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
            SVProgressHUD.show()
            FireStoreManager.shared.deleteEventBy(id: "\(gesture.view?.tag ?? 0)", completion: {
                err in
                SVProgressHUD.dismiss()
                if err != nil {
                    self.showEventAlert(title: "Error", message: "Error in deleting the event.")
                } else {
                    self.showEventAlert(title: "Success", message: "Event is deleted successfully.")
                }
            })
        })
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            _ in
            AppManager.shared.closeSwipe(gesture: gesture)
        })
        alertController.addAction(okAlertAction)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addEventCustomSwipe(cellView:UIView,cell:EventCellClass) {
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
        trashImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteEvent(_:))))
        
        deleteView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        deleteView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        deleteView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0).isActive = true
        deleteView.bottomAnchor.constraint(greaterThanOrEqualTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
        deleteView.tag = 11
        cellView.addGestureRecognizer(leftSwipeGesture)
        cellView.addGestureRecognizer(rightSwipGesture)
        cellView.isUserInteractionEnabled = true
        cellView.backgroundColor = .white
        cellView.layer.cornerRadius = 20
        cell.layer.cornerRadius = 20
        cellView.layer.borderColor = UIColor(red: 211/255, green: 211/252, blue: 211/255, alpha: 1.0).cgColor
        cellView.layer.borderWidth = 1.0
        deleteView.superview?.sendSubviewToBack(deleteView)
    }
    
    func setEventsNavigationBar()  {
        self.setSearchBar()
        self.addClickToDismissSearchBar()
        self.customSearchBar.delegate = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
            let title = NSAttributedString(string: "Events", attributes: [
                NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
            ])
            let titleLabel = UILabel()
            titleLabel.attributedText = title
            navigationItem.titleView = titleLabel
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

    func showEventAlert(title:String,message:String)  {
           let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
           let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
               _ in
               if title == "Success" {
                self.fetchEvents()
               }
           })
           alertController.addAction(okAlertAction)
           present(alertController, animated: true, completion: nil)
       }
   
    func fetchEvents()  {
        SVProgressHUD.show()
        FireStoreManager.shared.getAllEvents(result: {
            (data,err) in
            SVProgressHUD.dismiss()
            if err != nil {
                self.viewWillAppear(true)
            } else {
                self.eventsArray.removeAll()
                for sinleDoc in data!{
                    let eventDetail = sinleDoc["eventDetail"] as! [String : Any]
                    let id = sinleDoc["id"] as! String
                    let parentID = sinleDoc["parentID"] as! String
                    self.eventsArray.append(AppManager.shared.getEvent(id: id, adminID: parentID, eventDetail: eventDetail))
                }
                self.listOfEventsTable.reloadData()
            }
        })
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
                searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Event",
                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                                                                                        NSAttributedString.Key.font:UIFont(name: "Poppins-Medium", size: 18) as Any
                ])
            }
           }
    
    @objc  func showSearchBar()  {
           if self.searchView.isHidden == true {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.navigationBar.alpha = 0.0
            self.searchBarTopConstraint.constant = -((self.navigationController!.navigationBar.frame.origin.y/4 ) )
            self.searchBarHeightConstraint.constant = 60
            self.searchView.isHidden = false
            self.searchView.alpha = 1.0
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
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1.0
        self.searchBarHeightConstraint.constant = 0
        self.searchView.isHidden = true
        self.searchView.alpha = 0.0
        self.view.endEditing(true)
       }
}

extension ListOfEventsViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredEventArray.count > 0 ?  self.filteredEventArray.count : self.eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath) as! EventCellClass
        let singleEvent = self.filteredEventArray.count > 0 ? self.filteredEventArray[indexPath.section] : self.eventsArray[indexPath.section]
        
        self.setAttandanceTableCellView(tableCellView:cell.eventCellView )
        cell.contentView.layer.cornerRadius = 20.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1).cgColor
        cell.eventNameLabel.text =  singleEvent.eventName
        cell.eventAddressLabel.text = singleEvent.eventAddress
        cell.eventStartTime.text = singleEvent.eventStartTime
        cell.eventEndTime.text = singleEvent.eventEndTime
        cell.eventDateLabel.text = singleEvent.eventDate
        cell.eventDateLabel.layer.cornerRadius = 7.0
        cell.selectionStyle = .none
        cell.eventCellView.tag = Int(singleEvent.eventID)!
        
        switch AppManager.shared.loggedInRole {
        case .Admin:
            self.addEventCustomSwipe(cellView: cell.eventCellView, cell: cell)
        case .Trainer:
            if AppManager.shared.trainerEventPermission {
               self.addEventCustomSwipe(cellView: cell.eventCellView, cell: cell)
            }
        default:
            break
        }
        return cell
    }
}

extension ListOfEventsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hearder = UIView()
        hearder.backgroundColor = .clear
        return hearder
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.eventID = self.eventsArray[indexPath.section].eventID
        let eventViewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "eventViewVC") as! ViewEventScreenViewController
        eventViewVC.isNewEvent = false
        eventViewVC.eventID =  AppManager.shared.eventID
        self.navigationController?.pushViewController(eventViewVC, animated: true)
    }
}

extension ListOfEventsViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.filteredEventArray.removeAll()
            for singleEvent in self.eventsArray {
                if  singleEvent.eventName.lowercased().contains(searchText.lowercased()) ||
                    singleEvent.eventAddress.lowercased().contains(searchText.lowercased()){
                    self.filteredEventArray.append(singleEvent)
                    self.listOfEventsTable.reloadData()
                }
            }
        } else {
            self.filteredEventArray.removeAll()
            self.listOfEventsTable.reloadData()
        }
    }
}



