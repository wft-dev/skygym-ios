//
//  FireStoreManager.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 14/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD


class FireStoreManager: NSObject {
    static let shared:FireStoreManager = FireStoreManager()
    private override init() {}
    let fireDB = Firestore.firestore()
    let fireStorageRef = Storage.storage().reference()
   // let authRef = Auth.auth()

//    private  func updateCredential(previousEmail:String,previousPassword:String,updatedEmail:String,updatedPassword:String,completion:@escaping (Error?) -> Void ) {
//
//        let previousCredential = EmailAuthProvider.credential(withEmail: previousEmail, password: previousPassword)
//        authRef.currentUser?.reauthenticate(with: previousCredential, completion: {
//            (authResult,err) in
//
//            if err != nil {
//                completion(err)
//            } else {
//                if previousEmail != updatedEmail {
//                    self.authRef.currentUser?.updateEmail(to: updatedEmail, completion: {
//                        (err) in
//                        completion(err)
//                    })
//                }
//              else  if previousPassword != updatedPassword {
//                    self.authRef.currentUser?.updatePassword(to: updatedPassword, completion: {
//                        (err) in
//                        completion(err)
//                    })
//                }
//                else {
//                    completion(nil)
//                }
//            }
//        })
//    }
    
    //FOR ADMIN LOGIN
    func isAdminLogin(email:String,password:String,result:@escaping (Bool,Error?)->Void) {
            
        self.fireDB.collection("Admin")
            .whereField("email", isEqualTo: email)
            .whereField("password", isEqualTo: password)
            .getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result(false,err)
            }else{
                
                if (querySnapshot?.documents.count)! > 0 {
                    if (querySnapshot?.documents.count)! > 1 {
                        result(false,nil)
                    }
                    else{
                        let adminData = querySnapshot?.documents.first?.data()
                        AppManager.shared.adminID = adminData?["adminID"] as! String
                        AppManager.shared.gymID = (adminData?["adminDetail"] as! [String:String])["gymID"]!
                        result(true,nil)
                    }
                } else {
                    result(false,nil)
                }
            }
        })
    }
    
    func register(id:String,adminDetail:[String:Any],result:@escaping (Error?) ->Void) {
        
        self.fireDB.collection("Admin").document("/\(id)").setData([
            "adminID": id ,
            "email" : adminDetail["email"] as! String,
            "password" : adminDetail["password"] as! String,
            "adminDetail" : adminDetail
            ], completion: {
                (err) in
                result(err)
        })
    }
    
    
    func updateAdminDetail(id:String,adminDetail:[String:Any],result:@escaping (Error?)->Void) {
        self.fireDB.collection("Admin").document("/\(id)").updateData([
            "email" : adminDetail["email"] as! String,
            "password" : adminDetail["password"] as! String,
            "adminDetail" : adminDetail
            ], completion: {
                err in
                result(err)
        })
    }
    
    func getAdminDetailBy(id:String,result:@escaping ([String:Any]?,Error?) ->Void) {
        fireDB.collection("/Admin").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            result(docSnapshot?.data(),err)
        })
    }

    func uploadImg(url:URL,membeID:String,imageName:String,completion:@escaping (Error?) -> Void) {
        let imgRef = fireStorageRef.child("/Admin:\(AppManager.shared.adminID)/images/\(membeID)/\(imageName)")
        
        imgRef.putFile(from: url, metadata: nil, completion: {
            (metaData,err) in
            completion(err)
        })
    }

    func uploadImgForTrainer(url:URL,trainerid:String,imageName:String,completion:@escaping (Error?) -> Void) {
        let imgRef = fireStorageRef.child("/Admin:\(AppManager.shared.adminID)/images/\(trainerid)/\(imageName)")
        
        imgRef.putFile(from: url, metadata: nil, completion: {
            (metaData,err) in
            completion(err)
        })
    }
    
    func uploadUserImg(imgData:Data,id:String,completion:@escaping (Error?) -> Void){
        let imgRef = fireStorageRef.child("/Admin:\(AppManager.shared.adminID)/images/\(id)/userProfile.png")
        
        imgRef.putData(imgData, metadata: nil, completion: {
            (metadata,err) in
            completion(err)
        })
    }
    
    func deleteImgBy(id:String,result:@escaping (Error?)->Void) {
        let imgRef = fireStorageRef.child("/Admin:\(AppManager.shared.adminID)/images/\(id)")
        
        imgRef.listAll(completion: {
            (data,err) in
            for singleItem in data.items{
                singleItem.delete(completion: {
                    error in
                    result(error)
                })
            }
        })
    }
    
    func downloadUserImg(id:String,result:@escaping (URL?,Error?) -> Void) {
    let imgRef = fireStorageRef.child("/Admin:\(AppManager.shared.adminID)/images/\(id)/userProfile.png")

        imgRef.downloadURL(completion: {
            (imgUrl,err) in
            result(imgUrl,err)
        })
    }
    
    func downloadImgWithName(imageName:String,id:String,result:@escaping (URL?,Error?) -> Void) {
       let imgRef = fireStorageRef.child("/Admin:\(AppManager.shared.adminID)/images/\(id)/\(imageName)")

           imgRef.downloadURL(completion: {
               (imgUrl,err) in
               result(imgUrl,err)
           })
       }
    
    func addMember(email:String,password:String,memberDetail:[String:String],memberships:[[String:String]],memberID:String,handler:@escaping (Error?) -> Void ) {
        let attendence = AppManager.shared.getCompleteMonthAttendenceStructure()
        
        self.fireDB.collection("/Members").document("/\(memberID)").setData(
            [
                "adminID":AppManager.shared.adminID,
                "gymID":AppManager.shared.gymID,
                "email": email,
                "password":password,
                "memberDetail":memberDetail,
                "memberships":memberships,
                "attendence" :attendence
            ] , completion: {
                err in
                handler(err)
        })
    }
    
    func addNewMembeship(memberID:String,membership:[String:String], completion:@escaping (Error?) -> Void) {
         let memberhipRef = fireDB.collection("/Members").document("\(memberID)")
        
         memberhipRef.getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
               completion(err)
            } else {
                let membersipArray = ((docSnapshot?.data())! as NSDictionary)["memberships"] as! NSArray
                let latestMemershipArray =  membersipArray.adding(membership) as NSArray
                memberhipRef.updateData(["memberships":latestMemershipArray], completion: {
                    err in
                    completion(err)
                             })
            }
        })
    }
    
    func getAllMembers(completion:@escaping ([[String:Any]]?,Error?)->Void) {
        var dataDirctionary:[[String:Any]] = [[:]]
        fireDB.collection("/Members").whereField("adminID", isEqualTo: AppManager.shared.adminID)  .getDocuments(completion: {
            (querySnapshot,err) in
            
            if err != nil {
                completion(nil,err)
            } else {
                for singleDoc in querySnapshot!.documents{
                    let singleDocDictionary = singleDoc.data()
                    dataDirctionary.append(singleDocDictionary)
                    //print(dataDirctionary.count)
                }
                completion(dataDirctionary,nil)
            }
        })
    }
    
    func getMemberByID(id:String,completion:@escaping ([String:Any]?,Error?) -> Void) {
        var singalMember:[String:Any] = [:]
        fireDB.collection("/Members").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                completion(nil,err)
            }else {
                if docSnapshot?.documentID == id {
                    singalMember = (docSnapshot?.data())! as [String : Any]
                    completion(singalMember,nil)
                }
            }
        })
    }
    
    func getMembershipWith(memberID:String,membershipID:String,result:@escaping (MembershipDetailStructure?,Error?) -> Void) {
        fireDB.collection("/Members").document("\(memberID)").getDocument(completion: {
            (memberDate,err) in
            if err != nil {
                result(nil,err)
            } else {
                let membershipArray = ((memberDate?.data())! as NSDictionary)["memberships"] as! Array<NSDictionary>
                
                for currentMembership in membershipArray {
                    let currentMembershipID = currentMembership["membershipID"] as! String
                    if currentMembershipID == membershipID {
                        result(AppManager.shared.getCompleteMembershipDetail(membershipDetail: currentMembership as! [String:String]) , nil)
 
                    }
                }
            }
        })
    }
    
    
    func expiredMemberFilterAction(result:@escaping ([ListOfMemberStr]?,Error?) -> Void) {
        var memberArray:[ListOfMemberStr] =  []
        fireDB.collection("/Members").getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result(nil,err)
            }else {
                for doc in querySnapshot!.documents {
                    let memberDetail = (doc.data())["memberDetail"] as! [String:String]
                    let membershipArray = (doc.data())["memberships"] as! NSArray
                  //  let currentMembership = AppManager.shared.getCurrentMembership(membershipArray: membershipArray)
                    let latestMembership = AppManager.shared.getLatestMembership(membershipsArray: membershipArray as NSArray)
                    
                //    for singleCurrentMembership in latestMembership {
//                        let expiredDate = AppManager.shared.getDate(date: singleCurrentMembership.endDate)
//                        let df = DateFormatter()
//                        df.dateFormat = "dd-MMM-yyyy"
//                        let startDate = AppManager.shared.getDate(date: df.string(from: Date()))
//                        //let dayDiff = calculateDaysBetweenTwoDates(start: Date(), end: expiredDate)
//                        let difference = Calendar.current.dateComponents([.year,.month,.day], from: startDate, to: expiredDate)

                        let dateComponentDifference = AppManager.shared.getDateDifferenceComponent(startDate: AppManager.shared.getDate(date: latestMembership.endDate), endDate: Date())
                        
                        if dateComponentDifference.year! < 0 || dateComponentDifference.month! < 0 || dateComponentDifference.day! < 0  {
                            let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: latestMembership.endDate, dueAmount:latestMembership.dueAmount, uploadName: memberDetail["uploadIDName"]!)
                            memberArray.append(member)
                        }
               //     }
                }
            }
            result(memberArray,nil)
        })
    }
    
    func checkInFilterAction(result:@escaping ([ListOfMemberStr]?,Error?) -> Void) {
        var checkInArray:[ListOfMemberStr] = []
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let todayDate = "\(day)/\(currentMonth)/\(currentYear)"
        fireDB.collection("/Members").getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result(nil,err)
            }else {
                for doc in querySnapshot!.documents {
                    let memberDetail = (doc.data())["memberDetail"] as! [String:String]
                    let membershipArray = (doc.data())["memberships"] as! NSArray
                    let attendence = (doc.data())["attendence"] as! [String:Any]
                    let day = ((attendence["\(currentYear)"] as! NSDictionary)["\(currentMonth)"] as! NSDictionary)["\(todayDate)"] as! NSDictionary
                    let checkIn = day["checkIn"] as! String
                    let currentMembership = AppManager.shared.getCurrentMembership(membershipArray: membershipArray)
                    
                    if checkIn != "" {
                        let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: currentMembership.last!.endDate, dueAmount:currentMembership.last!.dueAmount, uploadName: memberDetail["uploadIDName"]!)
                        checkInArray.append(member)
                    } else {
                        print("COMES OUT OF CHECK IN FILTER : \(memberDetail["firstName"]!)")
                    }
                    
                }
                result(checkInArray,nil)
            }
        })
    }

    func checkFilterAction(checkFor:String,result:@escaping ([ListOfMemberStr]?,Error?) -> Void) {
        var checkArray:[ListOfMemberStr] = []
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let todayDate = "\(day)/\(currentMonth)/\(currentYear)"
        fireDB.collection("/Members").getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result(nil,err)
            }else {
                for doc in querySnapshot!.documents {
                    let memberDetail = (doc.data())["memberDetail"] as! [String:String]
                    let membershipArray = (doc.data())["memberships"] as! NSArray
                    let attendence = (doc.data())["attendence"] as! [String:Any]
                    let monthArray = (attendence["\(currentYear)"] as! NSDictionary)["\(currentMonth)"] as! Array<NSDictionary>
//
//                    guard  let day:NSDictionary = ((attendence["\(currentYear)"] as! NSDictionary)["\(currentMonth)"] as? NSDictionary)!["\(todayDate)"] as? NSDictionary else {
//                        break
//                    }
                    for eachDay in monthArray {
                        let d = eachDay as! NSDictionary
                        if  let status = d["\(todayDate)"] as? NSDictionary  {
                            let check = status["\(checkFor)"] as! String
                            let d = checkFor == "checkIn" ? "checkOut" : "checkIn"
                            let anotherCheck = status["\(d)"] as! String
                            let currentMembership = AppManager.shared.getCurrentMembership(membershipArray: membershipArray)
                            
                            switch checkFor {
                            case "checkIn":
                                if check != "" && check != "-"  && anotherCheck == "-" {
                                    let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: currentMembership.count > 0 ? currentMembership.first!.endDate : "--", dueAmount: currentMembership.count > 0 ? currentMembership.first!.dueAmount : "--", uploadName: memberDetail["uploadIDName"]!)
                                    checkArray.append(member)
                                }
                            case "checkOut" :
                                if check != "" && check != "-"  && anotherCheck != "" && anotherCheck != "-"  {
                                    let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: currentMembership.count > 0 ? currentMembership.first!.endDate : "--", dueAmount: currentMembership.count > 0 ? currentMembership.first!.dueAmount : "--", uploadName: memberDetail["uploadIDName"]!)
                                    checkArray.append(member)
                                }
                            default:
                                break
                            }
                        }
                    }
                }
                result(checkArray,nil)
            }
        })
    }
    
    func updateMemberDetails(id:String,memberDetail:[String:String],handler:@escaping (Error?) -> Void ) {
        
        self.fireDB.collection("Members").document("/\(id)").updateData([
            "memberDetail":memberDetail,
            "email": memberDetail["email"]!,
            "password":memberDetail["password"]!,
            ], completion: {
                (err) in
                handler(err)
        })
    }
    
    func getAttandance(trainerORmember:String,id:String,year:String,month:String,result:@escaping ([Attendence])->Void) {
        var attendenceArray:[Attendence] = []
        
        fireDB.collection("/\(trainerORmember)").document("/\(id)") .getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                print("Errror in fetching the member attandance.")
            } else {
                let attandanceDic = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! NSDictionary
                if attandanceDic.count > 0{
                    let currentYear = attandanceDic["\(year)"] as! NSDictionary
                    let currentMonth =  currentYear["\(month)"] as! NSDictionary
                    for (key,value) in currentMonth{
                        attendenceArray.append(AppManager.shared.getAttendanceData(key: key as! String, value: value as! NSDictionary))
                    }
                }
            }
            result(attendenceArray)
        })
    }
    
    func uploadAttandance(trainerORmember:String,id:String,present:Bool,checkIn:String,checkOut:String ,completion:@escaping (Error?)->Void )  {
       // var attendenceMarked:Bool = false
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        
        let ref = fireDB.collection("/\(trainerORmember)").document("/\(id)")
        print(ref.path)
        ref.getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                completion(err)
            } else {
                let attandanceDic = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! NSDictionary
                if let year:NSDictionary = (attandanceDic["\(currentYear)"] as? NSDictionary){
                    if  let _:Array = year["\(currentMonth)"] as? Array<NSDictionary>{
                        self.markAttendence(attendenceDir: attandanceDic, trainerORmember: trainerORmember, id: id, year: currentYear, month: currentMonth, day: day, present: present, checkIn: checkIn, checkOut: checkOut, handler: {
                            err in
                            completion(err)
                        })
                    }else {
                        self.addMonth(attendenceDir: attandanceDic, trainerORmember: trainerORmember, id: id, year: currentYear, month: currentMonth, day: day, present: present, checkIn: checkIn, checkOut: checkOut, handler: {
                            err in
                            completion(err)
                        })
                    }
                } else {
                    self.addYear(attendenceDir: attandanceDic, trainerORmember: trainerORmember, id: id, year: currentYear, month: currentMonth, day: day, present: present, checkIn: checkIn, checkOut: checkOut, handler: {
                        err in
                        completion(err)
                    })
                }
            }
        })
    }
    
    func isCheckOut(memberOrTrainer:Role,memberID:String,result:@escaping (Bool?,Error?) -> Void) {
        let role = AppManager.shared.getRole(role: memberOrTrainer)
        fireDB.collection(role).document("\(memberID)").getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                result(false,err)
            }else {
                let attendenceDictionary = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! NSDictionary
                let matchingDateDir = AppManager.shared.getSingleDateDetail(trainerORmember:role,id: memberID, attendence: attendenceDictionary, forDate: Date())
                
                if matchingDateDir != nil {
                    let matchingDate = AppManager.shared.getAttendanceData(key: "\(matchingDateDir?.allKeys.first as! String)", value: matchingDateDir?.value(forKey: "\(matchingDateDir?.allKeys.first as! String)") as! NSDictionary )
                    
                    if  matchingDate.present == true && matchingDate.checkIn != "" && matchingDate.checkOut == "-"  {
                        result(true,nil)
                    }else {
                        result(false,nil)
                    }
                } else {
                   result(false,nil)
                }
            }
        })
    }
    
    func isCurrentMembership(memberOrTrainer:Role,memberID:String,result:@escaping (Bool?,Error?) -> Void) {
        fireDB.collection("\(AppManager.shared.getRole(role: memberOrTrainer))").document("\(memberID)").getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                result(false,err)
            }else {
                let membershipsArray = ((docSnapshot?.data())! as NSDictionary)["memberships"] as! NSArray
                let currentMemberships = AppManager.shared.getCurrentMembership(membershipArray: membershipsArray)
                currentMemberships.count > 0 ? result(true,nil) : result(false,nil)
            }
        })
    }
      
 private   func addMonth(attendenceDir:NSDictionary,trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler:@escaping (Error?)->Void) {
            
        let yearDir = attendenceDir["\(year)"] as! NSDictionary
        let nextMonth = month
        let monthAttendence = AppManager.shared.getMonthAttendenceStructure(year: year, month: nextMonth, markingDate: "\(day)/\(nextMonth)/\(year)", checkIn: checkIn, checkOut: checkOut, present: true)
        yearDir.setValue(monthAttendence, forKey: "\(nextMonth)")
        attendenceDir.setValue(yearDir, forKey: "\(year)")

        fireDB.collection("\(trainerORmember)").document("\(id)").updateData([
           "attendence" : attendenceDir
        ], completion: {
            err in
            handler(err)
        })
      }
      
  private   func addYear(attendenceDir:NSDictionary,trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler: @escaping (Error?)->Void) {
        let nextYear = year
        let monthAttendence = AppManager.shared.getMonthAttendenceStructure(year: nextYear, month: 1, markingDate:  "\(day)/\(month)/\(nextYear)", checkIn: checkIn, checkOut: checkOut, present: present)
        let monthArray = ["\(month)":monthAttendence]
        attendenceDir.setValue(monthArray, forKey: "\(nextYear)")
          
        fireDB.collection("\(trainerORmember)").document("\(id)").updateData([
                "attendence" : attendenceDir
        ], completion: {
            err in
            handler(err)
        })
      }
    
    private func markAttendence(attendenceDir:NSDictionary,trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler:@escaping (Error?) -> Void ) {
        let todayDate = "\(day)/\(month)/\(year)"
        let i = (day - 1)
        
        var monthArray = (attendenceDir["\(year)"] as! NSDictionary)["\(month)"] as! Array<NSDictionary>
        let status:[String:Any] = [
            "checkIn":"\(checkIn)",
            "checkOut":"\(checkOut)",
            "present" : present
        ]
        monthArray.remove(at: i)
        monthArray.insert(["\(todayDate)":status] as NSDictionary, at:i )
        
         var allMonthDic = (attendenceDir["\(year)"] as! [String:Any])
         allMonthDic["\(month)"] = monthArray
         let attendence = ["\(year)":allMonthDic]
        
       // let attendence = ["\(year)":["\(month)":monthArray]]
        let ref = fireDB.collection("/\(trainerORmember)").document("/\(id)")
        ref.updateData([
            "attendence": attendence
            ], completion: {
                err in
                handler(err)
        })
    }
    
    func uploadCheckOutTime(trainerORmember:String,id:String,checkOut:String,completion:@escaping (Error?)->Void) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let todayDate = "\(day)/\(currentMonth)/\(currentYear)"
        
        fireDB.collection("/\(trainerORmember)").document("/\(id)").getDocument(completion: {
            (docRef,err) in
            
            if err == nil {
                let member = docRef?.data()!
                let attendence = member?["attendence"] as! [String:Any]
                if  var monthArray:Array = (attendence["\(currentYear)"] as! NSDictionary)["\(currentMonth)"] as? Array<NSDictionary>{
                    let attendenceDay = monthArray[(day - 1)]
                    let values = attendenceDay["\(todayDate)"] as! [String:Any]
                    let status:[String:Any] = [
                        "checkIn" : "\(values["checkIn"] as! String)",
                        "checkOut": "\(checkOut)",
                        "present" :  values["present"] as! Bool
                    ]
                    monthArray.remove(at: (day - 1))
                   monthArray.insert(["\(todayDate)":status] as NSDictionary, at:(day - 1))
                    var allMonthDic = (attendence["\(currentYear)"] as! [String:Any])
                    allMonthDic["\(currentMonth)"] = monthArray
                   // let attendence = ["\(currentYear)":["\(currentMonth)":monthArray]]
                    let attendence = ["\(currentYear)":allMonthDic]
                    
                    let ref = self.fireDB.collection("/\(trainerORmember)").document("/\(id)")
                    ref.updateData([
                        "attendence":attendence
                        ], completion: {
                            err in
                            completion(err)
                    })
                }
            }
        })
    }
    
    func getAttendenceFrom(trainerORmember:String,id:String,startDate:String,endDate:String,s: @escaping ([Attendence],Bool) -> Void) {
        var array:[Attendence] = []
        let startD = AppManager.shared.getDate(date: startDate)
        let endD = AppManager.shared.getDate(date: endDate)
        let yearDiff = Calendar.current.component(.year, from: startD) - Calendar.current.component(.year, from: endD)
        let monthDiff = Calendar.current.component(.month, from: startD) - Calendar.current.component(.month, from: endD)

        fireDB.collection("/\(trainerORmember)").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            
            if err == nil {
                let attendence = (((docSnapshot?.data())! as NSDictionary )["attendence"]) as! NSDictionary
                
                if yearDiff == 0 {
                    if monthDiff == 0 {
                         array = AppManager.shared.sameMonthSameYearAttendenceFetching(attendence: attendence, year:"\(Calendar.current.component(.year, from: startD))" , month: "\(Calendar.current.component(.month, from: startD))", startDate: AppManager.shared.changeDateFormatToStandard(dateStr: startDate), endDate:  AppManager.shared.changeDateFormatToStandard(dateStr: endDate))

                       // result(a,true)
                    } else {
                        array = AppManager.shared.sameYearDifferenctMonthAttedenceFetching(attendence: attendence, startDate: startD, endDate: endD)
                     //   result(a, true)
                    }
                } else {
                    array = AppManager.shared.differentMonthDifferentYearAttendenceFetching(attendence: attendence, startDate: startD, endDate: endD)
                    //result(a, true)
                }
                s(array,true)
            }
        })
    }

    func deleteMemberBy(id:String,completion:@escaping (Error?)->Void) {
        
        let ref = fireDB.collection("/Members").document("/\(id)")
        ref.delete(completion: {
        err in
            completion(err)
        })
    }
    
    func deleteMembership(memberID:String,completion:@escaping (Error?) -> Void) {
        let ref = fireDB.collection("/Members").document("/\(memberID)")
        ref.getDocument(completion: {
            (docRef,err) in
            
            if err == nil {
                var membershipArray = (docRef?.data())?["memberships"] as! Array<NSDictionary>
                for singleMembership in membershipArray {
                    let startDate = AppManager.shared.getDate(date: (singleMembership )["startDate"] as! String)
                    let endDate = AppManager.shared.getDate(date: (singleMembership )["endDate"] as! String)
                    let endDayDiff = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day!
                    let startDayDiff = Calendar.current.dateComponents([.day], from: Date(), to:startDate).day!
                    if endDayDiff >= 0 && startDayDiff <= 0 {
                    membershipArray.remove(at: membershipArray.firstIndex(of: singleMembership)!)
                        ref.updateData([
                            "memberships":membershipArray
                            ], completion: {
                                err in
                                completion(err)
                        })
                    }
                }
            }
        })
    }
    
    func addTrainer(email:String,password:String,trainerID:String,trainerDetail:[String:String],trainerPermission:[String:Bool],completion:@escaping (Error?)->Void) {
       // let attendence = [String:[String:[String:Bool]]]()
        let attendence = AppManager.shared.getCompleteMonthAttendenceStructure()
        fireDB.collection("/Trainers").document("\(trainerID)").setData([
            "adminID":AppManager.shared.adminID,
            "gymID":AppManager.shared.gymID,
            "email":email,
            "password":password,
            "trainerDetail":trainerDetail,
            "trainerPermission":trainerPermission,
            "attendence":attendence
        ], completion: {
            err in
            completion(err)
        })
    }
    
    func getAllTrainers(completion:@escaping ([[String:Any]]?,Error?)->Void) {
         var dataDirctionary:[[String:Any]] = [[:]]
        fireDB.collection("/Trainers").whereField("adminID", isEqualTo: AppManager.shared.adminID) .getDocuments(completion: {
            (querSnapshot,err) in
            if err != nil {
                completion(nil,err)
            } else {
                for singleDoc in querSnapshot!.documents{
                    let singleDocDictionary = singleDoc.data()
                    dataDirctionary.append(singleDocDictionary)
                }
                completion(dataDirctionary,nil)
            }
        })
    }
    
    func getTrainerBy(id:String,completion:@escaping ([String:Any]?,Error?)->Void) {
        let trainerRef = fireDB.collection("/Trainers").document("/\(id)")
        
        trainerRef.getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                completion(nil,err)
            } else {
                
                let data = docSnapshot?.data()
                AppManager.shared.trainerID =  (data?["trainerDetail"] as! [String:String])["trainerID"]!
                completion(data,nil)
            }
        })
    }
    
    func deleteTrainerBy(id:String,completion:@escaping (Error?)->Void) {
           let ref = fireDB.collection("/Trainers").document("/\(id)")
           ref.delete(completion: {
           err in
               completion(err)
           })
       }
    
    func addMembership(id:String,membershipDetail:[String:String],completion:@escaping (Error?)->Void)  {
        fireDB.collection("/Memberships").document("/\(id)").setData([
            "id":id,
            "adminID":AppManager.shared.adminID,
            "membershipDetail":membershipDetail
        ], completion: {
            err in
            completion(err)
        })
    }

    func getAllMembership(result:@escaping ([[String:Any]]?,Error?)->Void) {
        var membershipArray:[[String:Any]] = []
        fireDB.collection("/Memberships").whereField("adminID", isEqualTo: AppManager.shared.adminID)   .getDocuments(completion: {
            (querySnapshot,err) in
            
            if err != nil {
                result(nil,err)
            } else {
                for singleDoc in querySnapshot!.documents{
                    membershipArray.append(singleDoc.data())
                }
                result(membershipArray,nil)
            }
        })
    }
    
    func getMembershipBy(id:String,result:@escaping (Memberhisp?,Error?) -> Void) {
        fireDB.collection("/Memberships").document("\(id)").getDocument(completion: {
            (membershipData,err) in
            if err != nil {
                result(nil,err)
            }else {
                let membershipDetail = ((membershipData?.data())! as NSDictionary)["membershipDetail"] as! [String:String]
                
                let membership = AppManager.shared.getMembership(membership: membershipDetail, membershipID: ((membershipData?.data())! as NSDictionary)["id"] as! String)
                
                result(membership,nil)
                
            }
        })
    }
    
    func updateMembershipBy(memberID:String,membershipID:String,membershipDetail:[String:String],result:@escaping (Error?) -> Void) {
        fireDB.collection("/Members").document("\(memberID)").getDocument(completion: {
            (memberDate,err) in
            if err != nil {
                result(err)
            } else {
                var membershipArray = ((memberDate?.data())! as NSDictionary)["memberships"] as! Array<NSDictionary>
                
                for currentMembership in membershipArray {
                    let currentMembershipID = currentMembership["membershipID"] as! String
                    if currentMembershipID == membershipID {
                        let i:Int = membershipArray.firstIndex(of: currentMembership)!
                        membershipArray.remove(at: i)
                        membershipArray.insert(membershipDetail as NSDictionary, at: i)
                        self.fireDB.collection("/Members").document("\(memberID)").updateData([
                            "memberships" : membershipArray
                        ], completion: {
                            err in
                            result (err)
                        })
                    }
                }
            }
        })
    }
    
    func deleteMembershipBy(id:String,result:@escaping (Error?)->Void) {
        let docRef = fireDB.collection("/Memberships").document("/\(id)")
        
        docRef.delete(completion: {
            err in
            result(err)
        })
    }

    func addVisitor(id:String,visitorDetail:[String:String],completion:@escaping (Error?)->Void) {
        fireDB.collection("/Visitors").document("/\(id)").setData([
            "id":id,
            "adminID":AppManager.shared.adminID,
            "visitorDetail":visitorDetail
            ], completion: {
                err in
                completion(err)
        })
    }
    
    func getAllVisitors(result:@escaping ([[String:Any]]?,Error?)->Void) {
         var visitorArray:[[String:Any]] = []
        fireDB.collection("/Visitors").whereField("adminID", isEqualTo: AppManager.shared.adminID)  .getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result(nil,err)
            } else{
                for singleDoc in querySnapshot!.documents{
                    visitorArray.append(singleDoc.data())
                }
                result(visitorArray,nil)
            }
        })
    }
    
    func getVisitorBy(id:String,result:@escaping ([String:Any]?,Error?)->Void) {
        fireDB.collection("/Visitors").document("/\(id)").getDocument(completion: {
            (docSnapshot,err)in
            
            if err != nil {
                result(nil,err)
            }else {
                result(docSnapshot?.data(),nil)
            }
        })
    }
    
     func deleteVisitorBy(id:String,completion:@escaping (Error?)->Void) {
            let ref = fireDB.collection("/Visitors").document("/\(id)")
            ref.delete(completion: {
            err in
                completion(err)
            })
        }
     
    func addEvent(id:String,eventDetail:[String:Any],completion:@escaping (Error?)->Void) {
        fireDB.collection("/Events").document("/\(id)").setData([
            "id":id,
            "adminID":AppManager.shared.adminID,
            "eventDetail":eventDetail
        ], completion: {
            (err) in
            completion(err)
        })
    }
   
    func getAllEvents(result:@escaping ([[String:Any]]?,Error?)->Void) {
        var eventArray:[[String:Any]] = []
        fireDB.collection("/Events").whereField("adminID", isEqualTo: AppManager.shared.adminID)  .getDocuments(completion: {
            (querySnapshot,err)in
            if err != nil {
                result(nil,err)
            } else {
                for doc in querySnapshot!.documents{
                    eventArray.append(doc.data())
                }
                result(eventArray, nil)
            }
        })
    }
    
    func getEventBy(id:String,result:@escaping ([String:Any]?,Error?) -> Void) {
        fireDB.collection("/Events").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            
            if err != nil {
                result(nil,err)
            }else {
                result(docSnapshot?.data(),nil)
            }
        })
    }
    
    func deleteEventBy(id:String,completion:@escaping (Error?)->Void) {
        let ref = fireDB.collection("/Events").document("/\(id)")
        ref.delete(completion: {
        err in
            completion(err)
        })
    }
        
    func getTotalOf(role:Role,adminID:String,result:@escaping (Int,Error?)->Void) {
        var count:Int = 0
        let role = AppManager.shared.getRole(role: role)
        fireDB.collection("/\(role)").whereField("adminID", isEqualTo: adminID).getDocuments(completion: {
            (querySnapshot,err) in
            
            if err != nil {
              result(0,err)
            } else {
                count = querySnapshot!.documents.count
            }
            result(count,nil)
        })
    }
    
    func numberOfPaidMembers(adminID:String,result:@escaping (Int,Error?) -> Void) {
        var count = 0
        fireDB.collection("/Members").whereField("adminID", isEqualTo: adminID).getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result(0,err)
            } else {
                for doc in querySnapshot!.documents{
                    let singleData = doc.data()
                    let memberships = singleData["memberships"] as! NSArray
                    if memberships.count > 0 {
                        let latestMembership = memberships.lastObject as! [String:String]
                        let dueAmount = Int(latestMembership["dueAmount"]!)
                        let endDate  = AppManager.shared.getDate(date: latestMembership["endDate"]!)
                        
                        if dueAmount == 0 {
                            count += 1
                        }
                        let dayDiff = Calendar.current.compare(endDate, to: Date(), toGranularity: .day).rawValue
                        let monthDiff = Calendar.current.compare(endDate, to: Date(), toGranularity: .month).rawValue
                        let yearDiff = Calendar.current.compare(endDate
                            , to:Date(), toGranularity: .year).rawValue
                        
                        if dayDiff < 0 && monthDiff < 0 && yearDiff < 0 {
                            AppManager.shared.expiredMember += 1
                        }
                    }
                }
                result(count,nil)
            }
        })
    }
    

    func dummyAttendence() {
        fireDB.collection("/Members").document("129078391").getDocument(completion: {
            (docRef,error) in

         //   let attendence = ((docRef?.data())! as NSDictionary)["attendence"] as! NSDictionary
           // var monthArray = (attendence["2020"] as! NSDictionary)["11"] as! Array<NSDictionary>
           // print("ARRAY IS :\((monthArray.first!)["1/11/2020"] as! NSDictionary)")
           // print(monthArray)

            // let s =  AppManager.shared.sameMonthSameYearAttendenceFetching(attendence: attendence as NSDictionary, year: "2020", month: "11", startDate: "6 Nov 2020", endDate: "13 Nov 2020")
            //print("FINALL RESULT ATTENDENCE: \(s)")

//            let element = monthArray[9]
//            let ab =  element["10/11/2020"] as! NSDictionary
//
//            ab.setValue("10:00 AM", forKey: "checkIn")
//            ab.setValue("11:00 AM ", forKey: "checkOut")
//            ab.setValue(true, forKey: "present")
//
//            monthArray.remove(at: 9)
//            monthArray.insert(["10/11/2020":ab] as NSDictionary, at:9 )
//            let day = ["2020":["11":monthArray]]
//            print(day)

//            self.markFirstAttendence(attendenceDir: attendence, trainerORmember: "Members", id: "129078391", year: 2020, month: 11, day: 10, present: true, checkIn: "1:00 PM", checkOut: "", handler: {
//                _ in
//
//            })
            
//            self.addMonth(attendenceDir: attendence, trainerORmember: "Members", id: "129078391", year: 2020, month: 11, day: 2, present: true, checkIn: "2:00 PM", checkOut: "4:00 PM", handler: {
//                _ in
//
//            })
//
//            self.addYear(attendenceDir: attendence, trainerORmember: "Members", id: "129078391", year: 2020, month: 1, day: 1, present: true, checkIn: "9:00 AM", checkOut: "10:00 AM", handler: {
//                _ in
//            })
            
   
        })
    }

}
    




 
