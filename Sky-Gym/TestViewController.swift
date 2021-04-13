//
//  TestViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 13/04/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainTable: UITableView!
    
    var arr = [
        "1","2","3","4","5","6","7","8","9","10","11","12",
         "11","12","13","14","15","16","17","18","19","20","21","22"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTable.dataSource = self
        self.mainTable.isScrollEnabled  = false 
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mainTable.rowHeight = 66
    }
}


extension TestViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        
        cell.textLabel?.text = arr[indexPath.row]
        
         return cell
    
    }
    
    
}

