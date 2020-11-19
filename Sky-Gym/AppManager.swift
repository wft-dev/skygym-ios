//
//  AppManager.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 24/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class AppManager: NSObject {
    static let shared:AppManager = AppManager()
    private override init() {}
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var expiredMember:Int = 0
    
    var adminID:String {
        get {
            UserDefaults.standard.string(forKey: "adminID")!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "adminID")
        }
    }
    
    var gymID:String {
           get {
               UserDefaults.standard.string(forKey: "gymID")!
           }
           set {
               UserDefaults.standard.set(newValue, forKey: "gymID")
           }
       }

    var memberID:String {
        get {
            UserDefaults.standard.string(forKey: "memberID")!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "memberID")
        }
    }
    
    var trainerID:String {
         get {
             UserDefaults.standard.string(forKey: "trainerID")!
         }
         set {
             UserDefaults.standard.set(newValue, forKey: "trainerID")
         }
     }
    
    var trainerName:String {
            get {
                UserDefaults.standard.string(forKey: "trainerName")!
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "trainerName")
            }
        }
    
    var trainerType:String{
        get {
            UserDefaults.standard.string(forKey: "trainerType")!
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "trainerType")
        }
    }

    var membershipID:String {
         get {
             UserDefaults.standard.string(forKey: "membershipID")!
         }
         set {
             UserDefaults.standard.set(newValue, forKey: "membershipID")
         }
     }
    var visitorID:String {
        get {
            UserDefaults.standard.string(forKey: "visitorID")!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "visitorID")
        }
    }

    var eventID:String {
        get {
            UserDefaults.standard.string(forKey: "eventID")!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "eventID")
        }
    }

    var isLoggedIn:Bool {
        get{
            UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isLoggedIn")
        }
    }
    
    var isSiggnedIn:Bool {
        get{
            UserDefaults.standard.bool(forKey: "isSiggnedIn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isSiggnedIn")
        }
    }
    
    var isInitialUploaded:Bool {
          get{
              UserDefaults.standard.bool(forKey: "isInitialUploaded")
          }
          set {
              UserDefaults.standard.set(newValue, forKey: "isInitialUploaded")
          }
      }

    func isEmailValid(email:String) -> Bool {
               let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
               let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
               return emailPredicate.evaluate(with: email)
    }
    
    func isPasswordValid(text:String) -> Bool {
        if text.count > 8 {
                 return true
             }
             else {
                 return false
             }
         }
    
    func errorAlert(title:String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAlertAction)
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func performLogout()  {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            AppManager.shared.isLoggedIn = false
            AppManager.shared.appDelegate.setRoot()
            SVProgressHUD.dismiss()
        })
    }
    
    func performLogin() {
                SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            AppManager.shared.isLoggedIn = true
            AppManager.shared.appDelegate.setRoot()
            SVProgressHUD.dismiss()
        })
    }
    
    func getMemberDetailStr(memberDetail:NSDictionary) -> MemberDetailStructure {
          let member:MemberDetailStructure = MemberDetailStructure(firstName:memberDetail["firstName"] as! String,lastName: memberDetail["lastName"] as! String ,memberID: memberDetail["memberID"] as! String, dateOfJoining: memberDetail["dateOfJoining"] as! String, gender: memberDetail["gender"] as! String, password: memberDetail["password"] as! String, type: memberDetail["type"] as! String, trainerName: memberDetail["trainerName"] as! String, uploadIDName: memberDetail["uploadIDName"] as! String, email: memberDetail["email"] as! String, address: memberDetail["address"] as! String, phoneNo: memberDetail["phoneNo"] as! String, dob: memberDetail["dob"] as! String)
          
          return member
      }
      
      func getLatestMembership(membershipsArray:NSArray) -> MembershipDetailStructure{
          let lastMemberhipData = membershipsArray.lastObject as! NSDictionary
        let latestMemberhsip:MembershipDetailStructure = MembershipDetailStructure(membershipID: lastMemberhipData["membershipID"] as! String, membershipPlan: lastMemberhipData["membershipPlan"] as! String, membershipDetail: lastMemberhipData["membershipDetail"] as! String, amount: lastMemberhipData["amount"] as! String, startDate: lastMemberhipData["startDate"] as! String, endDate: lastMemberhipData["endDate"] as! String, totalAmount: lastMemberhipData["totalAmount"] as! String, discount: lastMemberhipData["discount"] as! String, paymentType:lastMemberhipData["paymentType"] as! String , dueAmount: lastMemberhipData["dueAmount"] as! String,purchaseTime: lastMemberhipData["purchaseTime"] as! String,purchaseDate: lastMemberhipData["purchaseDate"] as! String, membershipDuration: lastMemberhipData["membershipDuration"] as! String)
          return latestMemberhsip
      }
    
    func getCurrentMembership(membershipArray:NSArray) -> [MembershipDetailStructure] {
        var currentMembershipDataArray:[MembershipDetailStructure] = []
        for singleMembership in membershipArray {
            let startDate = getDate(date: (singleMembership as! NSDictionary)["startDate"] as! String)
            let endDate = getDate(date: (singleMembership as! NSDictionary)["endDate"] as! String)
            let endDayDiff = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day!
            let startDayDiff = Calendar.current.dateComponents([.day], from: Date(), to:startDate).day!
            
            if endDayDiff >= 0 && startDayDiff <= 0 {
                let currentMembershipData = singleMembership as! [String:String]
                let  currentMembership = MembershipDetailStructure(membershipID: currentMembershipData["membershipID"]!, membershipPlan: currentMembershipData["membershipPlan"]!, membershipDetail: currentMembershipData["membershipDetail"]!, amount: currentMembershipData["amount"]!, startDate: currentMembershipData["startDate"]!, endDate: currentMembershipData["endDate"]!, totalAmount: currentMembershipData["totalAmount"]!, discount: currentMembershipData["discount"]!, paymentType:currentMembershipData["paymentType"]!, dueAmount: currentMembershipData["dueAmount"]!,purchaseTime: currentMembershipData["purchaseTime"]!, purchaseDate: currentMembershipData["purchaseDate"]!, membershipDuration: currentMembershipData["membershipDuration"]!)
                currentMembershipDataArray.append(currentMembership)
            }
        }
        return currentMembershipDataArray
    }
    
    func getDate(date:String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateS = dateFormatter.date(from: date)!
        return dateS
    }
    
    func getStandardFormatDate(date:Date) -> Date {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return getDate(date: df.string(from: date))
    }

    func getTodayWeekDay(date:String)-> String{
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "EEEE"
          let weekDay = dateFormatter.string(from:getDate(date: date))
          return weekDay
    }
    
    func getAttendanceData(key:String,value:NSDictionary) -> Attendence {
        let attendence = Attendence(date: key, present: value["present"] as! Bool, checkIn: value["checkIn"] as! String, checkOut:value["checkOut"] as! String)
        return attendence
    }
  
    func getTrainerDetailS(trainerDetail:[String:String]) -> TrainerDataStructure {
        let trainer = TrainerDataStructure(firstName:trainerDetail["firstName"]!, lastName:  trainerDetail["lastName"]!, trainerID:trainerDetail["trainerID"]!, phoneNo:   trainerDetail["phoneNo"]!, email:trainerDetail["email"]!,password: trainerDetail["password"]!, address:trainerDetail["address"]!, gender:trainerDetail["gender"]!, salary:trainerDetail["salary"]!, uploadID: trainerDetail["uploadIDName"]!, shiftDays:trainerDetail["shiftDays"]!, shiftTimings: trainerDetail["shiftTimings"]!, type:trainerDetail["type"]!, dob:trainerDetail["dob"]!, dateOfJoining: trainerDetail["dateOfJoining"]!)
        
        return trainer
    }
    
    func getTrainerPermissionS(trainerPermission:[String:Bool]) -> TrainerPermissionStructure {
        let permission = TrainerPermissionStructure(canAddVisitor:trainerPermission["visitorPermission"]!, canAddMember: trainerPermission["memberPermission"]!, canAddEvent: trainerPermission["eventPermission"]!)
        
        return permission
    }
    
    func getMembership(membership:[String:String],membershipID:String) -> Memberhisp {
        let membership = Memberhisp(membershipID:membershipID,title: membership["title"]!, amount: membership["amount"]!, detail: membership["detail"]!, startDate: membership["startDate"]!, endDate: membership["endDate"]!, duration: membership["duration"]!)
        
        return membership
    }
    
    func getVisitor(visitorDetail:[String:String],id:String) -> Visitor {
        let visitor = Visitor(id: id, firstName: visitorDetail["firstName"]!, lastName: visitorDetail["lastName"]!, email: visitorDetail["email"]!, address: visitorDetail["address"]!, dateOfJoin: visitorDetail["dateOfJoin"]!, dateOfVisit: visitorDetail["dateOfVisit"]!, noOfVisit: visitorDetail["noOfVisit"]!, gender: visitorDetail["gender"]!, phoneNo: visitorDetail["phoneNo"]!)
        return visitor
    }
    
    func getAdminProfile(adminDetails:[String:String]) -> AdminProfile {
        let adminProfile = AdminProfile(gymName: adminDetails["gymName"]!, gymID: adminDetails["gymID"]!, gymAddress: adminDetails["gymAddress"]!, firstName: adminDetails["firstName"]!, lastName: adminDetails["lastName"]!, gender: adminDetails["gender"]!, password: adminDetails["password"]!, email: adminDetails["email"]!, phoneNO: adminDetails["mobileNo"]!, dob: adminDetails["dob"]!)
        
        return adminProfile
    }
    
    func getEvent(id:String,adminID:String,eventDetail:[String:Any]) -> Event {
        let event = Event( eventID: id, adminID: adminID, eventName: eventDetail["eventName"] as! String, eventDate: eventDetail["eventDate"] as! String, eventAddress: eventDetail["eventAddress"] as! String, eventStartTime: eventDetail["eventStartTime"] as! String, eventEndTime: eventDetail["eventEndTime"] as! String)
        
        return event
    }
    
    func getRole(role:Role) -> String {
        var roleStr:String  = ""
        switch role {
        case .Admin:
            roleStr = "Admin"
        case .Member:
            roleStr = "Members"
        case .Trainer :
            roleStr = "Trainers"
        case .Visitor :
            roleStr = "Visitors"
        }
        return roleStr
    }
    
    func getMembershipEndDate(startDate:Date,duration:Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: duration, to: startDate)!
        let lastEndDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
        return lastEndDate
      }

    func dateWithMonthName(date:Date) ->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd-MMM-yyyy"
       let  strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func dateWithMonthNameWithNoDash(date:Date) ->String {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat =  "dd MMM yyyy"
         let  strDate = dateFormatter.string(from: date)
          return strDate
      }
    
    func getNext7DaysDate(startDate:Date) -> String {
        let next7DaysDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy"
        let  endDate = dateFormatter.string(from: next7DaysDate)
        return endDate
    }
    
    func changeDateFormatToStandard(dateStr:String) -> String {
        let df = DateFormatter()
        df.dateFormat =  "dd MMM yyyy"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        let date = df.date(from: dateStr)!
        df.dateFormat = "d/MM/yyyy"
        let s = df.string(from: date)
        return s
    }
    
    func getDuration(startDate:Date,endDate:Date) -> Int {
        let duration = Calendar.current.dateComponents([.month], from: startDate, to: endDate).month
        return duration!
    }
    
    func performEditAction( dataFields :[UITextField:UILabel],edit:Bool) {
        
        for (textField,label) in dataFields{
            if edit == true {
                label.isHidden = true
                textField.isHidden  = false
                textField.alpha = 1.0
                label.alpha = 0.0
                textField.text = label.text
            } else {
                label.isHidden = false
                textField.isHidden = true
                textField.alpha = 0.0
                label.alpha = 1.0
            }
        }
    }
    
    func getTimeFrom(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from:date)
    }
    
    func lastDay(ofMonth m: Int, year y: Int) -> Int {
           let cal = Calendar.current
           var comps = DateComponents(calendar: cal, year: y, month: m)
           comps.setValue(m + 1, for: .month)
           comps.setValue(0, for: .day)
           let date = cal.date(from: comps)!
           return cal.component(.day, from: date)
       }

    func sameMonthSameYearAttendenceFetching(attendence:NSDictionary,year:String,month:String,startDate:String,endDate:String) -> [Attendence]{
        var  attendenceArray:[Attendence] = []
        let startD = AppManager.shared.getDate(date:startDate)
        let endD = AppManager.shared.getDate(date: endDate)
        let monthArray = (attendence["\(year)"] as! NSDictionary)["\(month)"] as! Array<NSDictionary>
        var counter = Calendar.current.component(.day, from: startD)
        let terminator = Calendar.current.component(.day, from: endD)
        for eachDay in monthArray {
            let d = eachDay 
            if  let status = d["\(counter)/\(month)/\(year)"] as? NSDictionary  {
                attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(counter)/\(month)/\(year)", value: status))
                counter += 1
                if counter > terminator {
                    break
                }
            }
        }
        return attendenceArray
    }

    func sameYearDifferenctMonthAttedenceFetching(attendence:NSDictionary,startDate:Date,endDate:Date) -> [Attendence] {
        var attendenceArray:[Attendence] = []
        let year = Calendar.current.component(.year, from: startDate)
        let startDateMonth = Calendar.current.component(.month, from: startDate)
        var counter = Calendar.current.component(.day, from: startDate)
        let monthTerminator = lastDay(ofMonth: startDateMonth, year: year)
        let terminator = Calendar.current.component(.day, from: endDate)
        let endDateMonth = Calendar.current.component(.month, from: endDate)
        let startMonthArray = (attendence["\(year)"] as! NSDictionary)["\(startDateMonth)"] as! Array<NSDictionary>
        let endMonthArray = (attendence["\(year)"] as! NSDictionary)["\(endDateMonth)"] as! Array<NSDictionary>

        for eachDay in startMonthArray {
            if  let status = eachDay["\(counter)/\(startDateMonth)/\(year)"] as? NSDictionary  {
                attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(counter)/\(startDateMonth)/\(year)", value: status))
                counter += 1
                if counter > monthTerminator {
                    counter = 1
                    break
                }
            }
        }
        
        for eachDay in endMonthArray {
            if let status = eachDay["\(counter)/\(endDateMonth)/\(year)"] as? NSDictionary {
                attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(counter)/\(endDateMonth)/\(year)", value: status))
                counter += 1
                if counter > terminator {
                    counter = 1
                    break
                }
            }
        }
        return attendenceArray
    }
    
    func differentMonthDifferentYearAttendenceFetching(attendence:NSDictionary,startDate:Date,endDate:Date) -> [Attendence]  {
        var attendenceArray:[Attendence] = []
        let startDateYear = Calendar.current.component(.year, from: startDate)
        let endDateYear = Calendar.current.component(.year, from: endDate)
        let startDateMonth = Calendar.current.component(.month, from: startDate)
        var counter = Calendar.current.component(.day, from: startDate)
        let monthTerminator = lastDay(ofMonth: startDateMonth, year: startDateYear)
        let terminator = Calendar.current.component(.day, from: endDate)
        let endDateMonth = Calendar.current.component(.month, from: endDate)
        let startYearDir = attendence["\(startDateYear)"] as! NSDictionary
        let endYearDir = attendence["\(endDateYear)"] as! NSDictionary
        let startMonthArray = startYearDir["\(startDateMonth)"] as! Array<NSDictionary>
        let endMonthArray = endYearDir["\(endDateMonth)"] as! Array<NSDictionary>
        
        for eachDay in startMonthArray {
            if  let status = eachDay["\(counter)/\(startDateMonth)/\(startDateYear)"] as? NSDictionary  {
                attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(counter)/\(startDateMonth)/\(startDateYear)", value: status))
                counter += 1
                if counter > monthTerminator {
                    counter = 1
                    break
                }
            }
        }
        
        for eachDay in endMonthArray {
            if let status = eachDay["\(counter)/\(endDateMonth)/\(endDateYear)"] as? NSDictionary {
                attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(counter)/\(endDateMonth)/\(endDateYear)", value: status))
                counter += 1
                if counter > terminator {
                    counter = 1
                    break
                }
            }
        }
        
        return attendenceArray
    }

    func getCompleteMonthAttendenceStructure() -> [String:Any] {
        var completeMonthAttendenceArray = [NSDictionary]()
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        var counter:Int = 1
        let lastDate = lastDay(ofMonth: currentMonth, year: currentYear)
        var dates = "\(counter)/\(currentMonth)/\(currentYear)"
        let status:[String:Any] = [
            "checkIn" : "",
            "checkOut": "",
            "present" : false
        ]
        while counter <= lastDate {
            completeMonthAttendenceArray.append(["\(dates)":status])
            counter += 1
            dates = "\(counter)/\(currentMonth)/\(currentYear)"
        }
        let attendence = ["\(currentYear)":["\(currentMonth)":completeMonthAttendenceArray]]
        return attendence
    }
    
    func getMonthAttendenceStructure(year:Int,month:Int,markingDate:String,checkIn:String,checkOut:String,present:Bool) -> [NSDictionary] {
        var completeMonthAttendenceArray = [NSDictionary]()
        var counter:Int = 1
        let lastDate = lastDay(ofMonth: month, year: year)
        var dates = "\(counter)/\(month)/\(year)"

        while counter <= lastDate {
            if dates == markingDate {
                let status:NSDictionary = [
                    "checkIn" : "\(checkIn)",
                    "checkOut": "\(checkOut)",
                    "present" : present
                ]
            completeMonthAttendenceArray.append(["\(dates)":status])
            } else {
                let status:NSDictionary = [
                    "checkIn" : "",
                    "checkOut": "",
                    "present" : false
                ]
            completeMonthAttendenceArray.append(["\(dates)":status])
            }
            counter += 1
            dates = "\(counter)/\(month)/\(year)"
        }
        let attendence = completeMonthAttendenceArray
        return attendence
    }
    
    func setLabel(nonEditLabels:[UILabel],defaultLabels:[UILabel],flag:Bool) {
        if flag == true {
            nonEditLabels.forEach{
                $0.isHidden = false
                $0.alpha = 1.0
                $0.textColor = UIColor.lightGray
            }
            defaultLabels.forEach{
                $0.isHidden = true
                $0.alpha = 0.0
            }
            
        } else {
            nonEditLabels.forEach{
                $0.isHidden = true
                $0.alpha = 0.0
            }
            defaultLabels.forEach{
                $0.isHidden = false
                $0.alpha = 1.0
                $0.textColor = UIColor.black
            }
        }
    }
    
    func setScrollViewContentSize(scrollView:UIScrollView)  {
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(view.frame)
        }
        scrollView.contentSize = contentRect.size
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func getClearBG() -> UIView {
        let bg = UIView()
        bg.backgroundColor = .clear
        return bg
    }
    
    func getCompleteMembershipDetail(membershipDetail:[String:String]) -> MembershipDetailStructure {
        let m = MembershipDetailStructure(membershipID: membershipDetail["membershipID"]!, membershipPlan:  membershipDetail["membershipPlan"]!, membershipDetail:  membershipDetail["membershipDetail"]!, amount:  membershipDetail["amount"]!, startDate:  membershipDetail["startDate"]!, endDate:  membershipDetail["endDate"]!, totalAmount:  membershipDetail["totalAmount"]!, discount:  membershipDetail["discount"]!, paymentType:  membershipDetail["paymentType"]!, dueAmount:  membershipDetail["dueAmount"]!, purchaseTime:  membershipDetail["purchaseTime"]!, purchaseDate:  membershipDetail["purchaseDate"]!, membershipDuration: membershipDetail["membershipDuration"]!)
        return m
    }

}


