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
    var eventsArray:[Event] = []
    var filteredEventArray:[Event] = []
    @IBOutlet weak var eventsNavigationBar: CustomNavigationBar!
    @IBOutlet weak var listOfEventsTable: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var customSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setEventsNavigationBar()
        self.listOfEventsTable.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.fetchEvents()
    }
    
    @IBAction func addNewEventAction(_ sender: Any) {
        performSegue(withIdentifier: "viewEventScreenSegue", sender: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewEventScreenSegue" {
            let destinationVC = segue.destination as! ViewEventScreenViewController
            destinationVC.isNewEvent = sender as! Bool
            destinationVC.eventID = (sender as! Bool) == false ? AppManager.shared.eventID : ""
        }
    }
}

extension ListOfEventsViewController {
    func setEventsNavigationBar()  {
        self.eventsNavigationBar.navigationTitleLabel.text = "Events"
        self.eventsNavigationBar.searchBtn.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
        self.setSearchBar()
        self.addClickToDismissSearchBar()
        self.customSearchBar.delegate = self
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
                    let adminID = sinleDoc["adminID"] as! String
                    self.eventsArray.append(AppManager.shared.getEvent(id: id, adminID: adminID, eventDetail: eventDetail))
                }
                self.listOfEventsTable.reloadData()
            }
        })
    }
    
    func setSearchBar()  {
               self.customSearchBar.backgroundColor = .clear
               self.customSearchBar.layer.borderColor = .none
               for s in customSearchBar.subviews[0].subviews{
                   if s is UITextField{
                       let searchTextField = s as! UITextField
                       searchTextField.clipsToBounds = true
                       searchTextField.borderStyle = .none
                       let imagView = UIImageView(image: UIImage(named: "search-2"))
                       let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                       let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 35, height: 24))
                       stackView.insertArrangedSubview(imagView, at: 0)
                       stackView.insertArrangedSubview(emptyView, at: 1)
                       searchTextField.leftViewMode = .always
                       searchTextField.leftView = stackView
                      searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Event",
                                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1),
                                                                                              NSAttributedString.Key.font:UIFont(name: "poppins", size: 18) as Any
                      ])
                   }
               }
           }
    
    @objc  func showSearchBar()  {
           if self.searchView.isHidden == true {
               self.eventsNavigationBar.isHidden = true
               self.eventsNavigationBar.alpha = 0.0
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
           self.eventsNavigationBar.isHidden = false
           self.eventsNavigationBar.alpha = 1.0
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
        cell.eventNameLabel.text =  singleEvent.eventName
        cell.eventAddressLabel.text = singleEvent.eventAddress
        cell.eventStartTime.text = singleEvent.eventStartTime
        cell.eventEndTime.text = singleEvent.eventEndTime
        cell.eventDateLabel.text = singleEvent.eventDate
        cell.eventDateLabel.layer.cornerRadius = 7.0
        cell.backgroundView = AppManager.shared.getClearBG()
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
        performSegue(withIdentifier: "viewEventScreenSegue", sender: false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteContextualAction = UIContextualAction(style: .destructive, title: "Delete", handler: {
            _,_,_ in
            FireStoreManager.shared.deleteEventBy(id: self.eventsArray[indexPath.section].eventID, completion: {
                err in
                if err != nil {
                    self.showEventAlert(title: "Error", message: "Error in deleting the event.")
                } else {
                    self.showEventAlert(title: "Success", message: "Event is deleted successfully.")
                }
            })
        })
        deleteContextualAction.backgroundColor = .red
        deleteContextualAction.image = UIImage(named: "delete")
        let configuration = UISwipeActionsConfiguration(actions: [deleteContextualAction])
        return configuration
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



