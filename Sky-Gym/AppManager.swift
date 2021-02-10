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

    var parentID:String {
        get {
            UserDefaults.standard.string(forKey: "parentID")!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "parentID")
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

    var loggedInRole:LoggedInRole? {
        get {
            guard let role = UserDefaults.standard.value(forKey: "loggedInRole") as? String else {
                return nil
            }
            return LoggedInRole(rawValue: role)
        }
        
        set(role) {
            UserDefaults.standard.set(role?.rawValue, forKey: "loggedInRole")
        }
    }
    
    var trainerVisitorPermission:Bool {
        get{
            UserDefaults.standard.bool(forKey: "trainerVisitorPermission")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "trainerVisitorPermission")
        }
    }
   
    var trainerMemberPermission:Bool {
        get{
            UserDefaults.standard.bool(forKey: "trainerMemberPermission")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "trainerMemberPermission")
        }
    }

    var trainerEventPermission:Bool {
        get{
            UserDefaults.standard.bool(forKey: "trainerEventPermission")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "trainerEventPermission")
        }
    }
    


    func setStatusBarBackgroundColor(color: UIColor,alpha:CGFloat) {
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = color
            statusBar.alpha = alpha
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(statusBar)

        } else {
                let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
                statusBar?.backgroundColor = color
                statusBar?.alpha = alpha
            }
        }

//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//        statusBar.backgroundColor = color
//        statusBar.alpha = alpha
  //  }
    

    func isEmailValid(email:String) -> Bool {
//               let emailFormat = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"

      let emailFormat =   "^(?=.{1,64}@)[A-Za-z0-9_-]+(\\.[A-Za-z0-9_-]+)*@" + "[^-][A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$"

               let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
               return emailPredicate.evaluate(with: email)
    }
    
    func isPasswordValid(text:String) -> Bool {
        if text.count >= 8 {
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
         AppManager.shared.isLoggedIn = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            AppManager.shared.appDelegate.setRoot()
            SVProgressHUD.dismiss()
        })
    }
    
    func performLogin() {
    SVProgressHUD.show()
         AppManager.shared.isLoggedIn = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            AppManager.shared.appDelegate.setRoot()
            SVProgressHUD.dismiss()
        })
    }
    
    func getMemberDetailStr(memberDetail:Dictionary<String,String>) -> MemberDetailStructure {
       let decryptedPassword = AppManager.shared.decryption(cipherText: memberDetail["password"]!)
        let member:MemberDetailStructure = MemberDetailStructure(firstName:memberDetail["firstName"]!,lastName: memberDetail["lastName"]! ,memberID: memberDetail["memberID"]!, dateOfJoining: memberDetail["dateOfJoining"]!, gender: memberDetail["gender"]!, password: decryptedPassword, type: memberDetail["type"]!, trainerName: memberDetail["trainerName"]!, trainerID: memberDetail["trainerID"]!, uploadIDName: memberDetail["uploadIDName"]!, email: memberDetail["email"]!, address: memberDetail["address"]!, phoneNo: memberDetail["phoneNo"]!, dob: memberDetail["dob"]!)
          
          return member
      }
    
    func getMemberNameAndPhone(memberDetail:Dictionary<String,String>) -> MemberFullNameAndPhone {
        let fullName = "\(memberDetail["firstName"] ?? "" ) \(memberDetail["lastName"] ?? "")"
        let member = MemberFullNameAndPhone(memberID: memberDetail["memberID"] ?? "", userName: fullName , phoneNo: memberDetail["phoneNo"] ?? "" )
        return member
    }
    
    func getListOfMembersDetailStr(memberDetail:Dictionary<String,String>,membershipArray:Array<Dictionary<String,String>>) -> ListOfMemberStr {
        let userName = "\(memberDetail["firstName"] ?? "") \(memberDetail["lastName"] ?? "")"
        var membership:MembershipDetailStructure? = nil
        
        let currentMembership =
            self.getCurrentMembership(membershipArray:membershipArray )
        
        if currentMembership.count > 0 {
            membership = currentMembership.first
        }else {
            membership =  membershipArray.count > 0 ? self.getLatestMembership(membershipsArray:  membershipArray) :
                MembershipDetailStructure(membershipID:memberDetail["memberID"] ?? "", membershipPlan: "--", membershipDetail: "--", amount:"0", startDate: "--", endDate: "--", totalAmount: "0", paidAmount: "0", discount: "0", paymentType: "--", dueAmount: "0", purchaseTime: "--", purchaseDate: "--", membershipDuration: "0")
        }
        
        let member = ListOfMemberStr(memberID: memberDetail["memberID"] ?? "", userImg: UIImage(named: "user1")!, userName: userName, phoneNumber: memberDetail["phoneNo"] ?? "" , dateOfExp: membership?.endDate ?? "", dueAmount: membership?.dueAmount ?? "--" , uploadName: memberDetail["uploadIDName"] ?? "" )
        
        return member
    }
    
      
    func getLatestMembership(membershipsArray:Array<Dictionary<String,String>>) -> MembershipDetailStructure{
        let lastMemberhipData = membershipsArray.last!
        let latestMemberhsip:MembershipDetailStructure = MembershipDetailStructure(membershipID: lastMemberhipData["membershipID"]!, membershipPlan: lastMemberhipData["membershipPlan"]!, membershipDetail: lastMemberhipData["membershipDetail"]!, amount: lastMemberhipData["amount"]!, startDate: lastMemberhipData["startDate"]!, endDate: lastMemberhipData["endDate"]!, totalAmount: lastMemberhipData["totalAmount"]!, paidAmount: lastMemberhipData["paidAmount"]!, discount: lastMemberhipData["discount"]!, paymentType:lastMemberhipData["paymentType"]!, dueAmount: lastMemberhipData["dueAmount"]!,purchaseTime: lastMemberhipData["purchaseTime"]!,purchaseDate: lastMemberhipData["purchaseDate"]!, membershipDuration: lastMemberhipData["membershipDuration"]!)
        return latestMemberhsip
    }
    
    func getCurrentMembership(membershipArray:Array<Dictionary<String,String>>) -> [MembershipDetailStructure] {
        var currentMembershipDataArray:[MembershipDetailStructure] = []
        for singleMembership in membershipArray {
            let startDate = getDate(date: (singleMembership)["startDate"]!)
            let endDate = getDate(date: (singleMembership )["endDate"]!)
            let endDayDiff = Calendar.current.dateComponents([.day], from: AppManager.shared.getStandardFormatDate(date: Date()), to: endDate).day!
            let startDayDiff = Calendar.current.dateComponents([.day], from: AppManager.shared.getStandardFormatDate(date: Date()), to:startDate).day!
            
            if endDayDiff >= 0 && startDayDiff <= 0 {
                let currentMembershipData = singleMembership 
                let  currentMembership = MembershipDetailStructure(membershipID: currentMembershipData["membershipID"]!, membershipPlan: currentMembershipData["membershipPlan"]!, membershipDetail: currentMembershipData["membershipDetail"]!, amount: currentMembershipData["amount"]!, startDate: currentMembershipData["startDate"]!, endDate: currentMembershipData["endDate"]!, totalAmount: currentMembershipData["totalAmount"]!, paidAmount: currentMembershipData["paidAmount"]!, discount: currentMembershipData["discount"]!, paymentType:currentMembershipData["paymentType"]!, dueAmount: currentMembershipData["dueAmount"]!,purchaseTime: currentMembershipData["purchaseTime"]!, purchaseDate: currentMembershipData["purchaseDate"]!, membershipDuration: currentMembershipData["membershipDuration"]!)
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
    
    func getAttendanceData(key:String,value:Dictionary<String,Any>) -> Attendence {
        let attendence = Attendence(date: key, present: value["present"] as! Bool, checkIn: value["checkIn"] as! String, checkOut:value["checkOut"] as! String)
        return attendence
    }
  
    func getTrainerDetailS(trainerDetail:[String:Any]) -> TrainerDataStructure {
        let selectedWeekDaysArray = trainerDetail["selectedWeekDaysIndexArray"]
        let password = AppManager.shared.decryption(cipherText: trainerDetail["password"] as! String)
        
        let trainer = TrainerDataStructure(firstName:trainerDetail["firstName"] as! String, lastName:  trainerDetail["lastName"] as! String, trainerID:trainerDetail["trainerID"] as! String, phoneNo:   trainerDetail["phoneNo"] as! String, email:trainerDetail["email"] as! String,password: password, address:trainerDetail["address"] as! String, gender:trainerDetail["gender"] as! String, salary:trainerDetail["salary"] as! String, uploadID: trainerDetail["uploadIDName"] as! String, shiftDays:trainerDetail["shiftDays"] as! String, shiftTimings: trainerDetail["shiftTimings"] as! String, type:trainerDetail["type"] as! String, dob:trainerDetail["dob"] as! String, dateOfJoining: trainerDetail["dateOfJoining"] as! String, shiftDaysIndexArray:selectedWeekDaysArray as! [Int])
        
        return trainer
    }
    
    func getTraineListInfo(trainerDetail:[String:Any]) -> ListOfTrainers {
        let trainerName = "\(trainerDetail["firstName"] as! String) \(trainerDetail["lastName"] as! String) "
        
        let trainer = ListOfTrainers(trainerID: trainerDetail["trainerID"] as! String, trainerName: trainerName , trainerPhone: trainerDetail["phoneNo"] as! String, dateOfJoinging: trainerDetail["dateOfJoining"]  as! String, salary: trainerDetail["salary"] as! String, members: "", type: trainerDetail["type"] as! String)
        
        return trainer
    }
    
    
    func getTrainerPermissionS(trainerPermission:[String:Bool]) -> TrainerPermissionStructure {
        let permission = TrainerPermissionStructure(canAddVisitor:trainerPermission["visitorPermission"]!, canAddMember: trainerPermission["memberPermission"]!, canAddEvent: trainerPermission["eventPermission"]!)
        return permission
    }
    
    func getMembership(membership:[String:String],membershipID:String) -> Memberhisp {
        let membership = Memberhisp(membershipID:membershipID,title: membership["title"]!, amount: membership["amount"]!, detail: membership["detail"]!, duration: membership["duration"]!, selectedIndex: membership["selectedIndex"]!)
        return membership
    }
    
    func getVisitor(visitorDetail:[String:String],id:String) -> Visitor {
        let visitor = Visitor(id: id, firstName: visitorDetail["firstName"]!, lastName: visitorDetail["lastName"]!, email: visitorDetail["email"]!, address: visitorDetail["address"]!, dateOfJoin: visitorDetail["dateOfJoin"]!, dateOfVisit: visitorDetail["dateOfVisit"]!, noOfVisit: visitorDetail["noOfVisit"]!, gender: visitorDetail["gender"]!, phoneNo: visitorDetail["phoneNo"]!,trainerID: visitorDetail["trainerID"] ?? "")
        return visitor
    }
    
    func getListOfVisitor(visitorDetail:Dictionary<String,String>,id:String) -> ListOfVisitor {
        let visitorName = "\(visitorDetail["firstName"] ?? "" ) \(visitorDetail["lastName"] ?? "")"
        let trainerID = visitorDetail["trainerID"] ?? ""
        let visitor = ListOfVisitor(visitorID: id, visitorName: visitorName, mobileNumber: visitorDetail["phoneNo"] ?? "", dateOfVisit: visitorDetail["dateOfVisit"] ?? "", dateOfJoining: visitorDetail["dateOfJoin"] ?? "", trainerName: "", trainerType: "", noOfVisit: visitorDetail["noOfVisit"] ?? "", trainerID: trainerID ?? "" )
        return visitor
    }
    
    func getTrainerTypeAndName(trainerDetail:Dictionary<String,Any>,id:String) -> TrainerNameAndType {
        let trainerName = "\(trainerDetail["firstName"] as! String) \(trainerDetail["lastName"] as! String)"
        let trainer = TrainerNameAndType(trainerName: trainerName, trainerType: trainerDetail["type"] as! String , trainerID: id)
        return trainer
    }

    func getAdminProfile(adminDetails:[String:Any]) -> AdminProfile {
    let adminProfile = AdminProfile(gymName: adminDetails["gymName"] as! String, gymID: adminDetails["gymID"] as! String, gymAddress: adminDetails["gymAddress"] as! String, firstName: adminDetails["firstName"] as! String, lastName: adminDetails["lastName"] as! String, gender: adminDetails["gender"] as! String, password:adminDetails["password"] as! String, email: adminDetails["email"] as! String, phoneNO: adminDetails["mobileNo"] as! String, dob: adminDetails["dob"] as! String,gymOpenningTime: adminDetails["gymOpenningTime"] as! String,gymClosingTime: adminDetails["gymClosingTime"] as! String,gymDays: adminDetails["gymDays"] as! String, gymDyasArrayIndexs: adminDetails["gymDaysArrayIndexs"] as! [Int])
        
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
         return endDate
    }
    
    func dateWithMonthName(date:Date) ->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd-MMM-yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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
    
    func getPrevious7DaysDate(startDate:Date) -> String {
        let next7DaysDate = Calendar.current.date(byAdding: .day, value: -6, to: startDate)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy"
        let  endDate = dateFormatter.string(from: next7DaysDate)
        return endDate
    }
    
    
    func getPreviousDayDate(startDate:Date) -> String {
        let previousDayDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy"
        let  endDate = dateFormatter.string(from: previousDayDate)
        return endDate
    }
    
    func getNextDayDate(startDate:Date) -> String {
        let nextDayDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "dd MMM yyyy"
        let  endDate = dateFormatter.string(from: nextDayDate)
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
    
    func getTime(date:Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "hh:mma"
        return df.string(from: date)
    }
    
    func lastDay(ofMonth m: Int, year y: Int) -> Int {
           let cal = Calendar.current
           var comps = DateComponents(calendar: cal, year: y, month: m)
           comps.setValue(m + 1, for: .month)
           comps.setValue(0, for: .day)
           let date = cal.date(from: comps)!
           return cal.component(.day, from: date)
       }

    func sameMonthSameYearAttendenceFetching(attendence:Dictionary<String,Any>,year:String,month:String,startDate:String,endDate:String) -> [Attendence]{
        var  attendenceArray:[Attendence] = []
        var i = 0
        let startD = AppManager.shared.getDate(date:startDate)
        let endD = AppManager.shared.getDate(date: endDate)
        if let monthArray = (attendence["\(year)"] as? Dictionary<String,Any>)?["\(month)"] as? Array<Dictionary<String,Any>> {
            let counter = Calendar.current.component(.day, from: startD)
            let terminator = Calendar.current.component(.day, from: endD)
            
            while i <= terminator {
                if i >= counter && i <= terminator {
                    let dateStr = "\(i)/\(month)/\(year)"
                    let eachDay = monthArray[(i-1)]
                    let day = eachDay["\(dateStr)"] as! Array<Dictionary<String,Any>>
                    for eachEntry in day {
                        attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(i)/\(month)/\(year)", value: eachEntry ))
                    }
                }
            i += 1
            }
            return attendenceArray
        }
        return []
    }
    
    func sameYearDifferenctMonthAttedenceFetching(attendence:Dictionary<String,Any>,startDate:Date,endDate:Date) -> [Attendence] {
        var attendenceArray:[Attendence] = []
        var i = 0
        let year = Calendar.current.component(.year, from: startDate)
        let startDateMonth = Calendar.current.component(.month, from: startDate)
        let counter = Calendar.current.component(.day, from: startDate)
        let monthTerminator = lastDay(ofMonth: startDateMonth, year: year)
        let terminator = Calendar.current.component(.day, from: endDate)
        let endDateMonth = Calendar.current.component(.month, from: endDate)
        guard  let startMonthArray:Array<Dictionary<String,Any>> = (attendence["\(year)"] as? Dictionary<String,Any>)?["\(startDateMonth)"] as? Array<Dictionary<String,Any>> else {
           // return []
            guard let _:Array<Dictionary<String,Any>> = (attendence["\(year)"] as? Dictionary<String,Any>)?["\(endDateMonth)"] as? Array<Dictionary<String,Any>> else {
                return []
            }
            let df = DateFormatter()
            df.dateFormat = "dd-MM-yyyy"
            let endDateStr = "1/\(endDateMonth)/\(year)"
            attendenceArray = sameMonthSameYearAttendenceFetching(attendence: attendence, year: "\(year)", month: "\(endDateMonth)", startDate: endDateStr, endDate: "\(terminator)/\(endDateMonth)/\(year)")
            return attendenceArray
        }
        
        guard let endMonthArray:Array<Dictionary<String,Any>> = (attendence["\(year)"] as? Dictionary<String,Any>)?["\(endDateMonth)"] as? Array<Dictionary<String,Any>> else {
            let df = DateFormatter()
            df.dateFormat = "dd-MM-yyyy"
            let starDateStr = df.string(from: startDate)
            attendenceArray = sameMonthSameYearAttendenceFetching(attendence: attendence, year: "\(year)", month: "\(startDateMonth)", startDate: starDateStr, endDate: "\(monthTerminator)/\(startDateMonth)/\(year)") 
            return attendenceArray
        }
        
        if startMonthArray.count > 0 {
            while i <= monthTerminator {
                if i >= counter && i <= monthTerminator {
                    let dateStr = "\(i)/\(startDateMonth)/\(year)"
                    let eachDay = startMonthArray[i-1]
                    let day = eachDay["\(dateStr)"] as! Array<Dictionary<String,Any>>
                    for eachEntry in day {
                        attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(i)/\(startDateMonth)/\(year)", value: eachEntry ))
                    }
                }
                i += 1
            }
        }
        
        if endMonthArray.count > 0 {
            i = 1
            while i <= terminator {
                if i >= 1 && i <= monthTerminator {
                    let dateStr = "\(i)/\(endDateMonth)/\(year)"
                    let eachDay = endMonthArray[i-1]
                    let day = eachDay["\(dateStr)"] as! Array<Dictionary<String,Any>>
                    for eachEntry in day {
                        attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(i)/\(endDateMonth)/\(year)", value: eachEntry ))
                    }
                }
                i += 1
            }
        }
        return attendenceArray
    }
    
    func differentMonthDifferentYearAttendenceFetching(attendence:Dictionary<String,Any>,startDate:Date,endDate:Date) -> [Attendence]  {
        var attendenceArray:[Attendence] = []
        let startDateYear = Calendar.current.component(.year, from: startDate)
        let endDateYear = Calendar.current.component(.year, from: endDate)
        let startDateMonth = Calendar.current.component(.month, from: startDate)
        let counter = Calendar.current.component(.day, from: startDate)
        let monthTerminator = lastDay(ofMonth: startDateMonth, year: startDateYear)
        let terminator = Calendar.current.component(.day, from: endDate)
        let endDateMonth = Calendar.current.component(.month, from: endDate)
        let startYearDir = attendence["\(startDateYear)"] as! Dictionary<String,Any>
        guard  let endYearDir = attendence["\(endDateYear)"] as? Dictionary<String,Any> else {
            return []
        }
        let startMonthArray = startYearDir["\(startDateMonth)"] as! Array<Dictionary<String,Any>>
        guard let endMonthArray = endYearDir["\(endDateMonth)"] as? Array<Dictionary<String,Any>> else {
            return []
        }
        var i = 0

        if startMonthArray.count > 0 {
                  while i <= monthTerminator {
                      if i >= counter && i <= monthTerminator {
                          let dateStr = "\(i)/\(startDateMonth)/\(startDateYear)"
                          let eachDay = startMonthArray[i-1]
                          let day = eachDay["\(dateStr)"] as! Array<Dictionary<String,Any>>
                          for eachEntry in day {
                              attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(i)/\(startDateMonth)/\(startDateYear)", value: eachEntry ))
                          }
                      }
                      i += 1
                  }
              }
              
              if endMonthArray.count > 0 {
                  i = 1
                  while i <= terminator {
                      if i >= 1 && i <= monthTerminator {
                          let dateStr = "\(i)/\(endDateMonth)/\(endDateYear)"
                          let eachDay = endMonthArray[i-1]
                          let day = eachDay["\(dateStr)"] as! Array<Dictionary<String,Any>>
                          for eachEntry in day {
                              attendenceArray.append(AppManager.shared.getAttendanceData(key: "\(i)/\(endDateMonth)/\(endDateYear)", value: eachEntry ))
                          }
                      }
                      i += 1
                  }
              }

        return attendenceArray
    }

    func getMonthAttendenceStructure(year:Int,month:Int,checkIn:String,checkOut:String,present:Bool) -> Array<Dictionary<String,Any>>{
        var counter = 1
        let lastDate = lastDay(ofMonth: month, year: year)
        var dates = "\(counter)/\(month)/\(year)"
        var monthArray:Array<Dictionary<String,Any>> = []
        let firstAttendence:Dictionary<String,Any> = ["checkIn":checkIn,
                                                      "checkOut":checkOut,
                                                      "present":present
                                                     ]
        var dayArray:Array<Dictionary<String,Any>> = []
        dayArray.append(firstAttendence)

        while counter <= lastDate {
            monthArray.append(["\(dates)":dayArray])
            counter += 1
            dates = "\(counter)/\(month)/\(year)"
        }
        return monthArray
    }
    
    func getCompleteInitialStructure(year:Int,month:Int,checkIn:String,checkOut:String,present:Bool)  -> Dictionary<String,Any> {
        var completeMonthAttendenceArray: Dictionary<String,Any> = [:]
        var monthArray:Array<Dictionary<String,Any>> = []
        var counter = 1
        let lastDate = lastDay(ofMonth: month, year: year)
        var dates = "\(counter)/\(month)/\(year)"
        let firstAttendence:Dictionary<String,Any> = ["checkIn":checkIn,
                                                      "checkOut":checkOut,
                                                      "present":present
        ]
        var dayArray:Array<Dictionary<String,Any>> = []
        dayArray.append(firstAttendence)
        while counter <= lastDate {
            monthArray.append(["\(dates)":dayArray])
            counter += 1
            dates = "\(counter)/\(month)/\(year)"
        }
        let monthArrayDictionary:Dictionary<String,Any> = ["\(month)":monthArray]
        completeMonthAttendenceArray = ["\(year)":monthArrayDictionary]
        return completeMonthAttendenceArray
    }

    func setLabel(nonEditLabels:[UILabel],defaultLabels:[UILabel],errorLabels:[UILabel]?,flag:Bool) {
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
            if errorLabels != nil {
                errorLabels!.forEach{
                    $0.isHidden = true
                    $0.alpha = 0.0
                }
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
            if errorLabels != nil {
                errorLabels!.forEach{
                    $0.isHidden = false
                    $0.alpha = 1.0
                    $0.textColor = UIColor.red
                }
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
        let m = MembershipDetailStructure(membershipID: membershipDetail["membershipID"]!, membershipPlan:  membershipDetail["membershipPlan"]!, membershipDetail:  membershipDetail["membershipDetail"]!, amount:  membershipDetail["amount"]!, startDate:  membershipDetail["startDate"]!, endDate:  membershipDetail["endDate"]!, totalAmount:  membershipDetail["totalAmount"]!, paidAmount: membershipDetail["paidAmount"]!, discount:  membershipDetail["discount"]!, paymentType:  membershipDetail["paymentType"]!, dueAmount:  membershipDetail["dueAmount"]!, purchaseTime:  membershipDetail["purchaseTime"]!, purchaseDate:  membershipDetail["purchaseDate"]!, membershipDuration: membershipDetail["membershipDuration"]!)
        return m
    }
    

    
    func getDateDifferenceComponent(startDate:Date, endDate:Date) -> DateComponents {
        let diff = Calendar.current.dateComponents([.year,.month,.day], from: endDate, to: startDate)
        return diff
    }
    
    func getPreviousMembership(membershipArray:Array<Dictionary<String,String>>) -> MembershipDetailStructure {
        
        let lastMemberhipData = membershipArray.last!
        let latestMemberhsip:MembershipDetailStructure = MembershipDetailStructure(membershipID: lastMemberhipData["membershipID"]!, membershipPlan: lastMemberhipData["membershipPlan"]!, membershipDetail: lastMemberhipData["membershipDetail"]!, amount: lastMemberhipData["amount"]!, startDate: lastMemberhipData["startDate"]!, endDate: lastMemberhipData["endDate"]!, totalAmount: lastMemberhipData["totalAmount"]!, paidAmount: lastMemberhipData["paidAmount"]!, discount: lastMemberhipData["discount"]!, paymentType:lastMemberhipData["paymentType"]! , dueAmount: lastMemberhipData["dueAmount"]!,purchaseTime: lastMemberhipData["purchaseTime"]!,purchaseDate: lastMemberhipData["purchaseDate"]!, membershipDuration: lastMemberhipData["membershipDuration"]!)
        return latestMemberhsip
    }
    
    func closeSwipe(gesture:UIGestureRecognizer)  {
        UIView.animate(withDuration: 0.2, animations: {
            gesture.view?.superview?.superview?.subviews.last!.frame.origin.x =  0
        })
    }
    
    func getSecureTextFor(text:String) -> String {
     return String(text.map { _ in return "•" })
    }
    
    func hidePasswordTextField(hide:Bool,passwordTextField:UITextField,passwordLabel:UILabel) {
        passwordTextField.isHidden = hide
        passwordTextField.alpha = hide == true ? 0.0 : 1.0
        passwordLabel.isHidden = !hide
        passwordLabel.alpha = hide == true ? 1.0 : 0.0
    }
    
    func getGymDetail(data:Dictionary<String,Any>) -> GymDetail {
        
        let gymInfo:[Int] = data["gymDaysArrayIndexs"] as! [Int]
        let gymDetail = GymDetail(gymName: data["gymName"] as! String, gymID: data["gymID"] as! String, gymOpeningTime:  data["gymOpenningTime"] as! String, gymClosingTime: data["gymClosingTime"] as! String,gymDays:"\(gymInfo.count)" , gymAddress: data["gymAddress"] as! String, gymOwnerName: data["firstName"] as! String, gymOwnerPhoneNumber: data["mobileNo"] as! String, gymOwnerAddress: data["gymAddress"] as! String)
        
        return gymDetail
    }
    
    
    func getNumberOfMemberAddedByTrainerWith(membersData:[Dictionary<String,Any>],trainerID:String) ->
        Result<Int,Error> {
        let semaphores = DispatchSemaphore(value: 0)
        var result:Result<Int,Error>!
        var counter:Int = 0
            
            for member in membersData {
                let parentID = member["parentID"] as! String
                if parentID == trainerID {
                    counter += 1
                }
            }
            result = .success(counter)
            semaphores.signal()
            
            let _ = semaphores.wait(wallTimeout: .distantFuture)
            return result
    }
    
    
    func getSelectedWeekdays(selectedArray:[Int],defaultArray:[String]) -> [String] {
        var array:[String] = []
        if selectedArray.count > 0 {
            for i in selectedArray {
                array.append(defaultArray[i])
            }
        }
        return array
    }
    
    func encryption(plainText:String) -> String {
        return ValidationManager.shared.encryption(text: plainText)
    }
    
    func decryption(cipherText:String) -> String {
        return ValidationManager.shared.decryption(hash: cipherText)
    }
    
//    func keyboardWillShow(keyboardHeight:CGFloat?,constraintContentHeight:NSLayoutConstraint,activeTextField:UITextField?,scrollView:UIScrollView,lastOffset:CGPoint?) {
//        var constraintHeight = constraintContentHeight
//
//        if keyboardHeight != nil {
//            return
//        }
//        UIView.animate(withDuration: 0.3, animations: {
//            constraintHeight.constant += keyboardHeight!
//        })
//
//        let distanceToBottom = scrollView.frame.size.height - (activeTextField?.frame.origin.y)! - (activeTextField?.frame.size.height)!
//
//        let collapseSpace = keyboardHeight! - distanceToBottom
//        if collapseSpace < 0 {
//            return
//        }
//
//        UIView.animate(withDuration: 0.3, animations: {
//            scrollView.contentOffset = CGPoint(x: lastOffset!.x, y: collapseSpace + 20)
//        })
//    }
    
//    func keyboardWillHide(keyboardHeight:CGFloat?,constraintContentHeight:NSLayoutConstraint,scrollView:UIScrollView,lastOffset:CGPoint?)  {
//        var keyboardHeight:CGFloat? = keyboardHeight
//        
//        UIView.animate(withDuration: 0.3) {
//            constraintContentHeight.constant -= keyboardHeight!
//            scrollView.contentOffset = lastOffset!
//        }
//        keyboardHeight = nil
//    }

}


