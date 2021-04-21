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
    let fireDB = Firestore.firestore()
    let fireStorageRef = Storage.storage().reference()
    var batch:WriteBatch? = nil
    
    private override init() {
        batch = fireDB.batch()
    }

    func getGymInfo(gymID:String) -> Result<GymDetail,Error> {
        var result:Result<GymDetail,Error>!
        let semaphore = DispatchSemaphore(value: 0)
        
        self.fireDB.collection("Admin")
        .whereField("gymID", isEqualTo: gymID)
        .getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result = .failure(err!)
            } else {
                let detailData = querySnapshot?.documents.first?.data()
                let adminDetail = detailData!["adminDetail"] as! Dictionary<String,Any>
                let gymDetail = AppManager.shared.getGymDetail(data: adminDetail)
                result = .success(gymDetail)
                semaphore.signal()
            }
        })
        let _ = semaphore.wait(wallTimeout: .distantFuture)
        return result
    }
    
    //FOR ADMIN LOGIN
    func isAdminLogin(email:String,password:String,result:@escaping (Bool,Error?)->Void) {
    let decryptedPassword = ValidationManager.shared.encryption(text: password)
        
        self.fireDB.collection("Admin")
            .whereField("email", isEqualTo: email)
            .whereField("password", isEqualTo: decryptedPassword)
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
                        let adminData = querySnapshot!.documents.first!.data()
                        let adminDetail = adminData["adminDetail"] as! Dictionary<String,Any>
                        AppManager.shared.adminID = adminData["adminID"] as! String
                        AppManager.shared.gymID = (adminData["gymID"] as! String)
                        AppManager.shared.adminName = "\(adminDetail["firstName"]!) \(adminDetail["lastName"]!)"
                        AppManager.shared.loggedInRole = LoggedInRole.Admin
                        result(true,nil)
                    }
                } else {
                    result(false,nil)
                }
            }
        })
    }
    
    func getAdminNameBy(id:String) -> Result<String,Error> {
        var result:Result<String,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        fireDB.collection("Admin").document(id).getDocument { (docSnapshot, err) in
            if err == nil {
                let data = docSnapshot?.data()
                let adminDetail =  data!["adminDetail"] as! [String : Any]
                let adminName = "\(adminDetail["firstName"]!) \(adminDetail["lastName"]!)"
                result = .success(adminName)
                semaphores.signal()
            }
        }
        
        let _ = semaphores.wait(timeout: .distantFuture)
        return result
    }
    
    func trainerOrMemberLogin(collectionPath:String,gymID:String,email:String,password:String,result:@escaping (Bool,Error?) -> Void) {
        let encryptedPassword = AppManager.shared.encryption(plainText: password)
        self.fireDB.collection(collectionPath)
        .whereField("email", isEqualTo: email)
        .whereField("gymID", isEqualTo: gymID)
        .whereField("password", isEqualTo: encryptedPassword)
        .getDocuments(completion: {
            (querySnapshot,err) in
            
            if (querySnapshot?.documents.count)! > 0 {
                if (querySnapshot?.documents.count)! > 1 {
                    result(false,nil)
                }
                else{
                    let data = querySnapshot?.documents.first?.data()
                  
                    AppManager.shared.gymID = data?["gymID"] as! String
                    if collectionPath == "Members" {
                        AppManager.shared.adminID = ""
                        AppManager.shared.memberID = querySnapshot!.documents.first!.documentID
                        AppManager.shared.trainerID = ""
                        AppManager.shared.loggedInRole = LoggedInRole.Member
                        AppManager.shared.trainerName = ""
                        AppManager.shared.trainerType = ""
                    }else {
                        let trainerDetail = data?["trainerDetail"] as! Dictionary<String,Any>
                        AppManager.shared.trainerID = querySnapshot!.documents.first!.documentID
                        AppManager.shared.memberID = ""
                        AppManager.shared.adminID = ""
                        AppManager.shared.loggedInRole = LoggedInRole.Trainer
                        AppManager.shared.trainerName = trainerDetail["firstName"] as! String
                        AppManager.shared.trainerType = trainerDetail["type"] as! String
                    }
                    result(true,nil)
                }
            } else {
                result(false,nil)
            }
        })
    }
    
    func isMember(email:String,gymID:String) -> Result<Bool,Error> {
        var result:Result<Bool,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        self.fireDB.collection("Members")
            .whereField("email", isEqualTo: email)
            .whereField("gymID", isEqualTo: gymID)
            .getDocuments(completion: {
                (querySnapshot,err) in
                
                if err != nil {
                    result = .failure(err!)
                }
                else {
                if (querySnapshot?.documents.count)! == 1 {
                    result = .success(true)
                    } else {
                         result = .success(false)
                    }
                     semaphores.signal()
                }
            })
      _ = semaphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    func isMemberWith(id:String) -> Result<Bool,Error> {
        var result:Result<Bool,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        self.fireDB.collection("Members").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            if docSnapshot?.exists == true {
                result = .success(true)
            }else {
                result = .success(false)
            }
            semaphores.signal()
        })
        _ = semaphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    
    func setPasswordFor(role:Role,id:String,password:String,handler:@escaping (Error?) -> Void) {
        let roleStr = AppManager.shared.getRole(role: role)
        let ref = self.fireDB.collection("\(roleStr)").document("\(id)")
        let detail = role == .Member ? "memberDetail" : "trainerDetail"
      
        
        ref.getDocument(completion: {
            (document,err) in
            if err == nil {
                let detailData = document?.data()
                if detailData != nil {
                    var detailStr = detailData?["\(detail)"] as! Dictionary<String,Any>
                    detailStr.updateValue(password, forKey: "password")
                    ref.updateData([
                        "password":password,
                        "\(detail)" : detailStr
                        ], completion: {
                            (err) in
                            handler(err)
                    })
                }else {
                    let error = NSError(domain: "", code: 401, userInfo: nil)
                    handler(error)
                }
            }else {
                handler(err!)
            }
        })
    }
    

    func register(id:String,gymID:String,adminDetail:[String:Any],result:@escaping (Error?) ->Void) {
        let email = adminDetail["email"] as! String
        let password = adminDetail["password"] as! String
        addNewUserCredentials(id: id, email: email, password: password, handler: {
            (err) in
            
            if err == nil {
                self.fireDB.collection("Admin").document("/\(id)").setData([
                    "gymID":gymID,
                    "adminID": id ,
                    "email" : email,
                    "password" : password ,
                    "adminDetail" : adminDetail
                    ], completion: {
                        (err) in
                        result(err)
                })
            }
        })

    }
    
    
    func updateAdminDetail(id:String,adminDetail:[String:Any],result:@escaping (Error?)->Void) {
        let email = adminDetail["email"] as! String
        let password = adminDetail["password"] as! String
        
        updateUserCredentials(id: id, email: email, password: password, handler: {
            (err) in
            if err == nil {
                self.fireDB.collection("Admin").document("/\(id)").updateData([
                    "email" : email,
                    "password" : password,
                    "adminDetail" : adminDetail
                    ], completion: {
                        err in
                        result(err)
                })
            }
        })
    }
    
    func getAdminDetailBy(id:String,result:@escaping ([String:Any]?,Error?) ->Void) {
        fireDB.collection("/Admin").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            result(docSnapshot?.data(),err)
        })
    }

    func uploadImg(url:URL,membeID:String,imageName:String,completion:@escaping (Error?) -> Void) {
        let imgRef = fireStorageRef.child("Images/\(membeID)/\(imageName)")
        
        imgRef.putFile(from: url, metadata: nil, completion: {
            (metaData,err) in
            completion(err)
        })
    }
 

    func uploadImgForTrainer(url:URL,trainerid:String,imageName:String,completion:@escaping (Error?) -> Void) {
        let imgRef = fireStorageRef.child("Images/\(trainerid)/\(imageName)")
        
        imgRef.putFile(from: url, metadata: nil, completion: {
            (metaData,err) in
            completion(err)
        })
    }
    
    func uploadUserImg(imgData:Data,id:String,completion:@escaping (Error?) -> Void){
        let imgRef = fireStorageRef.child("Images/\(id)/userProfile.png")
        
        imgRef.putData(imgData, metadata: nil, completion: {
            (metadata,err) in
            completion(err)
        })
    }
    

    func deleteImgBy(id:String) -> Result<Bool,Error> {
        var result:Result<Bool,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        let imgRef = fireStorageRef.child("Images/\(id)")

        imgRef.listAll(completion: {
            (data,err) in
            for singleItem in data.items{
                singleItem.delete(completion: {
                    error in
                    if error != nil {
                        result = .failure(error!)
                        result = .success(false)
                    }else {
                        result = .success(true)
                    }
                    semaphores.signal()
                })
            }
        })
        
        let _ = semaphores.wait(wallTimeout: .distantFuture)
        return result
    }

    func downloadUserImg(id:String,result:@escaping (URL?,Error?) -> Void) {
    let imgRef = fireStorageRef.child("Images/\(id)/userProfile.png")

        imgRef.downloadURL(completion: {
            (imgUrl,err) in
            result(imgUrl,err)
        })
    }
    
    func downloadImgWithName(imageName:String,id:String,result:@escaping (URL?,Error?) -> Void) {
      // let imgRef = fireStorageRef.child("/Admin:\(AppManager.shared.adminID)/images/\(id)/\(imageName)")
    let imgRef = fireStorageRef.child("Images/\(id)/\(imageName)")

           imgRef.downloadURL(completion: {
               (imgUrl,err) in
               result(imgUrl,err)
           })
       }
    
    func addMember(email:String,password:String,memberDetail:[String:String],memberships:[[String:String]],memberID:String,handler:@escaping (Error?) -> Void ) {
        let year = Calendar.current.dateComponents([.year], from: Date()).year!
        let month = Calendar.current.dateComponents([.month], from: Date()).month!
        let attendence = AppManager.shared.getCompleteInitialStructure(year: year, month: month,checkIn: "", checkOut: "", present: false)
        let parentID = AppManager.shared.loggedInRole == LoggedInRole.Trainer ? AppManager.shared.trainerID : AppManager.shared.adminID
        let workoutPlans:[String] = []

        self.fireDB.collection("/Members").document("/\(memberID)").setData(
            [
                "parentID":parentID,
                "gymID":AppManager.shared.gymID,
                "email": email,
                "password":password,
                "memberDetail":memberDetail,
                "memberships":memberships,
                "attendence" :attendence,
                "timeStamp":Date().timeIntervalSince1970,
                "wokroutPlans" : workoutPlans
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
        var dataDirctionary:[[String:Any]] = []
        fireDB.collection("/Members")
        .order(by: "timeStamp", descending: false)
            .getDocuments(completion: {
            (querySnapshot,err) in
            
            if err != nil {
                completion(nil,err)
            } else {
                for singleDoc in querySnapshot!.documents{
                    let singleDocDictionary = singleDoc.data()
                    dataDirctionary.append(singleDocDictionary)
                }
                completion(dataDirctionary,nil)
            }
        })
    }
    
    func getMemberByID(id:String,completion:@escaping ([String:Any]?,Error?) -> Void) {
        var singalMember:Dictionary<String,Any> = [:]
        fireDB.collection("/Members").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                completion(nil,err)
            }else {
                if docSnapshot?.documentID == id {
                    singalMember = (docSnapshot?.data())! as Dictionary<String,Any>
                    completion(singalMember,nil)
                }
            }
        })
    }
        
    func getMembershipWithTimeStamp(memberID:String,membershipID:String,purchaseTimeStamp:String,result:@escaping (MembershipDetailStructure?,Error?) -> Void) {
        fireDB.collection("/Members").document("\(memberID)").getDocument(completion: {
            (memberDate,err) in
            if err != nil {
                result(nil,err)
            } else {
                let membershipArray = ((memberDate?.data())! as Dictionary<String,Any>)["memberships"] as! Array<Dictionary<String,Any>>
                
                for currentMembership in membershipArray {
                    let currentMembershipID = currentMembership["membershipID"] as! String
                    let timestamp = currentMembership["purchaseTimeStamp"] as! String
                    if currentMembershipID == membershipID && purchaseTimeStamp == timestamp {
                        result(AppManager.shared.getCompleteMembershipDetail(membershipDetail: currentMembership as! Dictionary<String,String>) , nil)
                    }
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
                let membershipArray = ((memberDate?.data())! as Dictionary<String,Any>)["memberships"] as! Array<Dictionary<String,Any>>
                
                for currentMembership in membershipArray {
                    let currentMembershipID = currentMembership["membershipID"] as! String
                    if currentMembershipID == membershipID{
                        result(AppManager.shared.getCompleteMembershipDetail(membershipDetail: currentMembership as! Dictionary<String,String>) , nil)
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
                    let memberDetail = (doc.data())["memberDetail"] as! Dictionary<String,String>
                    let membershipArray = (doc.data())["memberships"] as! Array<Dictionary<String,String>>
                    let latestMembership = AppManager.shared.getLatestMembership(membershipsArray: membershipArray )
                        let dateComponentDifference = AppManager.shared.getDateDifferenceComponent(startDate: AppManager.shared.getDate(date: latestMembership.endDate), endDate: Date())
                        
                        if dateComponentDifference.year! < 0 || dateComponentDifference.month! < 0 || dateComponentDifference.day! < 0  {
                            let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: latestMembership.endDate, dueAmount:latestMembership.dueAmount, uploadName: memberDetail["uploadIDName"]!)
                            memberArray.append(member)
                        }
                }
            }
            result(memberArray,nil)
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
                    let memberDetail = (doc.data())["memberDetail"] as! Dictionary<String,String>
                    let membershipArray = (doc.data())["memberships"] as! Array<Dictionary<String,String>>
                    let attendence = (doc.data())["attendence"] as! Dictionary<String,Any>
                    let monthArray = (attendence["\(currentYear)"] as! Dictionary<String,Any>)["\(currentMonth)"] as! Array<Dictionary<String,Any>>
                    
                    let filteringDay = monthArray[(day-1)]
                    let dayAttendenceArray = filteringDay["\(todayDate)"] as! Array<Dictionary<String,Any>>
                    let eachAttendence = dayAttendenceArray.last!
                    
                    let check = eachAttendence["\(checkFor)"] as! String
                    let d = checkFor == "checkIn" ? "checkOut" : "checkIn"
                    let anotherCheck = eachAttendence["\(d)"] as! String
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
    
    func updateMemberProfileDetail(id:String,memberDetail:Dictionary<String,String>) -> Result<Bool,Error> {
        var result:Result<Bool,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        let memberRef = self.fireDB.collection("Members").document("/\(id)")
        
        memberRef.getDocument(completion: {
            (docSnapshot,err) in
            
            if err == nil {
                let memberData = docSnapshot?.data()
                var memberDetailData = memberData?["memberDetail"] as! Dictionary<String,String>
                memberDetailData.updateValue(memberDetail["firstName"]!, forKey: "firstName")
                memberDetailData.updateValue(memberDetail["lastName"]!, forKey: "lastName")
                memberDetailData.updateValue(memberDetail["email"]!, forKey: "email")
                memberDetailData.updateValue(memberDetail["password"]!, forKey: "password")
                memberDetailData.updateValue(memberDetail["gender"]!, forKey: "gender")
                memberDetailData.updateValue(memberDetail["phoneNo"]!, forKey: "phoneNo")
                memberDetailData.updateValue(memberDetail["dob"]!, forKey: "dob")
                
                memberRef.updateData([
                    "memberDetail" : memberDetailData,
                    "email" : memberDetail["email"]!,
                    "password" : memberDetail["password"]!
                    ], completion: {
                        (err) in
                        if err != nil {
                            result = .failure(err!)
                            result = .success(false)
                        }else {
                            result = .success(true)
                        }
                        semaphores.signal()
                })
            }
        })
        
        let _ = semaphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    func getAttandance(trainerORmember:String,id:String,year:String,month:String,result:@escaping ([Attendence])->Void) {
        var attendenceArray:[Attendence] = []
        
        fireDB.collection("/\(trainerORmember)").document("/\(id)") .getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                print("Errror in fetching the member attandance.")
            } else {
                let attandanceDic = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! Dictionary<String, Any>
                if attandanceDic.count > 0{
                    let currentYear = attandanceDic["\(year)"] as! NSDictionary
                    let currentMonth =  currentYear["\(month)"] as! NSDictionary
                    for (key,value) in currentMonth{
                        attendenceArray.append(AppManager.shared.getAttendanceData(key: key as! String, value: value as! Dictionary<String, Any> ))
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
      //  print(ref.path)
        ref.getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                completion(err)
            } else {
                let attandanceDic = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! NSDictionary
                if let year:NSDictionary = (attandanceDic["\(currentYear)"] as? NSDictionary){
                    if  let _:Array = year["\(currentMonth)"] as? Array<NSDictionary>{
                        self.updateAttendence(trainerORmember: trainerORmember, id: id,checkOutA: checkOut, completion: {
                            err in
                            completion(err)
                        })
                    }else {
                        self.addMonth(attendenceDir: attandanceDic as! Dictionary<String, Any>, trainerORmember: trainerORmember, id: id, year: currentYear, month: currentMonth, day: day, present: present, checkIn: checkIn, checkOut: checkOut, handler: {
                            err in
                            completion(err)
                        })
                    }
                } else {
                    self.addYear(attendenceDir: attandanceDic as! Dictionary<String, Any>, trainerORmember: trainerORmember, id: id, year: currentYear, month: currentMonth, day: day, present: present, checkIn: checkIn, checkOut: checkOut, handler: {
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
                if memberID == "837064" {
                    print("data is : \(docSnapshot?.data() ?? [:])")
                }
                let attendenceDictionary = ((docSnapshot?.data())! as Dictionary<String,Any>)["attendence"] as! Dictionary<String,Any>
                let matchingDateArray = self.getArrayOfOneDayAttendence(trainerORmember: role, id: memberID, attendence: attendenceDictionary, forDate: Date())
                
                if matchingDateArray?.count ?? 0 > 0  {
                    if let singleMatchingDate = matchingDateArray?.last {
                        let present = singleMatchingDate["present"] as! Bool
                        let checkIn = singleMatchingDate["checkIn"] as! String
                        let checkOut = singleMatchingDate["checkOut"] as! String
                        
                        if  present == true && checkIn != "" && checkOut == "-"  {
                            result(true,nil)
                        }else {
                            result(false,nil)
                        }
                    }
                } else {
                   result(false,nil)
                }
            }
        })
    }
    
    
   private func getArrayOfOneDayAttendence(trainerORmember:String,id:String,attendence:Dictionary<String,Any>,forDate:Date) -> Array<Dictionary<String,Any>>? {
        let year = Calendar.current.component(.year, from: forDate)
        let month = Calendar.current.component(.month, from: forDate)
        let day = Calendar.current.component(.day, from: forDate)
    guard let currentYear = attendence["\(year)"] as? Dictionary<String,Any> else {
        self.addYear(attendenceDir: attendence, trainerORmember: trainerORmember, id: id, year: year, month: month, day: day, present: false, checkIn: "", checkOut: "", handler: { _ in })
        return nil
    }
    if let monthArray:Array<Dictionary<String,Any>> = currentYear["\(month)"] as? Array<Dictionary<String,Any>>{
            let matchingDateDir = (monthArray[day-1])["\(day)/\(month)/\(year)"] as! Array<Dictionary<String,Any>>
           return matchingDateDir
        }
    self.addMonth(attendenceDir: attendence, trainerORmember: trainerORmember, id: id, year: year, month: month, day: day, present: false, checkIn: "", checkOut: "", handler: { _ in  })
    return nil
    }
    
    func isCurrentMembership(memberOrTrainer:Role,memberID:String,result:@escaping (Bool?,Bool?,Error?) -> Void) {
        fireDB.collection("\(AppManager.shared.getRole(role: memberOrTrainer))").document("\(memberID)").getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                result(false,false,err)
            }else {
                let membershipsArray = ((docSnapshot?.data())! as Dictionary<String,Any>)["memberships"] as! Array<Dictionary<String,String>>
                if membershipsArray.count > 0 {
                    let currentMemberships = AppManager.shared.getCurrentMembership(membershipArray: membershipsArray)
                    currentMemberships.count > 0 ? result(true,true,nil) : result(false,true,nil)
                }else {
                    result(false,false,nil)
                }
            }
        })
    }
      
    private   func addMonth(attendenceDir:Dictionary<String,Any>,trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler:@escaping (Error?)->Void) {
        var attendence = attendenceDir
        var yearDir = attendenceDir["\(year)"] as! Dictionary<String,Any>
        let nextMonth = month
        let monthAttendence = AppManager.shared.getMonthAttendenceStructure(year:year,month:month,checkIn: checkIn, checkOut: checkOut, present: false)
        yearDir.updateValue(monthAttendence, forKey: "\(nextMonth)")
        attendence.updateValue(yearDir, forKey: "\(year)")
        
        fireDB.collection("\(trainerORmember)").document("\(id)").updateData([
            "attendence" : attendence
            ], completion: {
                err in
                handler(err)
        })
    }
      
  private   func addYear(attendenceDir:Dictionary<String,Any>,trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler: @escaping (Error?)->Void) {
    var attendence = attendenceDir
        let nextYear = year
        let monthAttendence = AppManager.shared.getMonthAttendenceStructure( year:year,month:month, checkIn: checkIn, checkOut: checkOut, present: present)
        let nextYearAttendence:Dictionary<String,Any> = ["\(month)":monthAttendence]
        attendence.updateValue(nextYearAttendence, forKey: "\(nextYear)")
          
        fireDB.collection("\(trainerORmember)").document("\(id)").updateData([
                "attendence" : attendence
        ], completion: {
            err in
            handler(err)
        })
      }
    
    private func markAttendence(attendenceDir:NSDictionary,trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler:@escaping (Error?) -> Void) {
        let todayDate = "\(day)/\(month)/\(year)"
        let i = (day - 1)
        
        var monthArray = (attendenceDir["\(year)"] as! NSDictionary)["\(month)"] as! Array<NSDictionary>
        let status:[String:Any] = [
            "checkIn":"\(checkIn)",
            "checkOut":"\(checkOut)",
            "present" : present
        ]
        monthArray.remove(at: i)
        monthArray.insert(["\(todayDate)":status] as NSDictionary, at:i)
        
        var allMonthDic = (attendenceDir["\(year)"] as! [String:Any])
        allMonthDic["\(month)"] = monthArray
        let attendence = ["\(year)":allMonthDic]
        
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
                let attendence = (((docSnapshot?.data())! as Dictionary<String,Any> )["attendence"]) as! Dictionary<String,Any>
                
                if yearDiff == 0 {
                    if monthDiff == 0 {
                         array = AppManager.shared.sameMonthSameYearAttendenceFetching(attendence: attendence, year:"\(Calendar.current.component(.year, from: startD))" , month: "\(Calendar.current.component(.month, from: startD))", startDate: AppManager.shared.changeDateFormatToStandard(dateStr: startDate), endDate:  AppManager.shared.changeDateFormatToStandard(dateStr: endDate))

                    } else {
                        array = AppManager.shared.sameYearDifferenctMonthAttedenceFetching(attendence: attendence, startDate: startD, endDate: endD)
                    }
                } else {
                    array = AppManager.shared.differentMonthDifferentYearAttendenceFetching(attendence: attendence, startDate: startD, endDate: endD)
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
                var membershipArray = (docRef?.data())?["memberships"] as! Array<Dictionary<String,String>>
                for singleMembership in membershipArray {
                    let startDate = AppManager.shared.getDate(date: (singleMembership )["startDate"]!)
                    let endDate = AppManager.shared.getDate(date: (singleMembership )["endDate"]!)
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
    
    
    func deleteMembershipWith(membershipID:String,memberID:String,membershipTimeStamp:String,completion:@escaping (Error?) -> Void) {  let ref = fireDB.collection("/Members").document("/\(memberID)")
        ref.getDocument(completion: {
            (docSnapshot, err) in
            
            if err == nil{
                var membershipArray = (docSnapshot?.data())?["memberships"] as! Array<Dictionary<String,String>>
                for singleMembership in membershipArray {
                    if singleMembership["membershipID"] == membershipID && singleMembership["purchaseTimeStamp"] == membershipTimeStamp {
                        membershipArray.remove(at: membershipArray.firstIndex(of: singleMembership)!)
                    }
                }
                ref.updateData([
                    "memberships":membershipArray
                    ], completion: {
                        err in
                        completion(err)
                })
            }
        })
        
    }
    
    
    func addTrainer(email:String,password:String,trainerID:String,trainerDetail:[String:Any],trainerPermission:[String:Bool],completion:@escaping (Error?)->Void) {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let attendence = AppManager.shared.getCompleteInitialStructure(year: year, month: month, checkIn: "", checkOut: "", present: false)
        let parentID = AppManager.shared.loggedInRole == LoggedInRole.Trainer ? AppManager.shared.trainerID : AppManager.shared.adminID
        fireDB.collection("/Trainers").document("\(trainerID)").setData([
            "parentID": parentID,
            "gymID":AppManager.shared.gymID,
            "email":email,
            "password":password,
            "trainerDetail":trainerDetail,
            "trainerPermission":trainerPermission,
            "attendence":attendence,
            "timeStamp":Date().timeIntervalSince1970
        ], completion: {
            err in
            completion(err)
        })
    }
    
    func updateTrainer(email:String,password:String,trainerID:String,trainerDetail:[String:Any],trainerPermission:[String:Bool],completion:@escaping (Error?)->Void) {
        fireDB.collection("/Trainers").document("\(trainerID)").updateData([
        "email":email,
        "password":password,
        "trainerDetail":trainerDetail,
        "trainerPermission":trainerPermission
        ], completion: {
            err in
            completion(err)
        })
    }
    
    func getAllTrainers(completion:@escaping ([[String:Any]]?,Error?)->Void) {
         var dataDirctionary:[[String:Any]] = [[:]]
        fireDB.collection("/Trainers")
        .order(by: "timeStamp", descending: false)
            .getDocuments(completion: {
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
                AppManager.shared.trainerID =  (data?["trainerDetail"] as! [String:Any])["trainerID"] as! String
                completion(data,nil)
            }
        })
    }
    
    func getTrainerDetailBy(id:String) -> Result<TrainerDataStructure?,Error> {
        var result:Result<TrainerDataStructure?,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        let trainerRef = fireDB.collection("Trainers").document("/\(id)")
        
        trainerRef.getDocument(completion: {
            (docSnapshot,err) in
            if err != nil{
                result = .failure(err!)
                result = .success(nil)
            } else {
                let data = docSnapshot?.data()
                let trainerDetail =  data!["trainerDetail"] as! [String : Any]
                let trainerDetailStr = AppManager.shared.getTrainerDetailS(trainerDetail: trainerDetail)
                result = .success(trainerDetailStr)
            }
            semaphores.signal()
        })

        let _ = semaphores.wait(wallTimeout: .distantFuture)
         return result
    }
    
    func getTrainerNameAndTypeBy(id:String) -> Result<[String],Error> {
        var result:Result<[String],Error>!
        let semaphores = DispatchSemaphore(value: 0)
        var trainerDetailArr:[String] = []
        fireDB.collection("Trainers").document(id).getDocument { (docSnapshot, err) in
            if err == nil {
                let data = docSnapshot?.data()
                let trainerDetail =  data!["trainerDetail"] as! [String : Any]
                let trainerName = "\(trainerDetail["firstName"]!) \(trainerDetail["lastName"]!)"
                trainerDetailArr.append(trainerName)
                trainerDetailArr.append(trainerDetail["type"] as! String)
                result = .success(trainerDetailArr)
                semaphores.signal()
            }
        }
        let _ = semaphores.wait(timeout: .distantFuture)
        return result
    }
    
    func getAllTrainerTypeAndNameBy() -> Result<Dictionary<String,TrainerNameAndType>?,Error> {
        var result:Result<Dictionary<String,TrainerNameAndType>?,Error>!
        let semaphores = DispatchSemaphore(value: 0)
         let trainerRef = fireDB.collection("Trainers")
        var dic:Dictionary<String,TrainerNameAndType> = [:]
        
        trainerRef.getDocuments(completion:{
            (querySnapshot,err) in
            if err != nil{
                result = .failure(err!)
                result = .success(nil)
            } else {
                for eachDocument in querySnapshot!.documents {
                    let data = eachDocument.data()
                    let trainerDetail =  data["trainerDetail"] as? Dictionary<String,Any>
                    let id = eachDocument.documentID
                    let trainerDetailStr = AppManager.shared.getTrainerTypeAndName(trainerDetail: trainerDetail!, id: id)
                    dic["\(id)"] = trainerDetailStr
                }
                result = .success(dic)
            }
            semaphores.signal()
        })

        let _ = semaphores.wait(wallTimeout: .distantFuture)
         return result
    }
    
    
    func getTrainerPermission(id:String) -> Result<TrainerPermissionStructure,Error> {
        let trainerRef = fireDB.collection("/Trainers").document("/\(id)")
        var result:Result<TrainerPermissionStructure,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        
        trainerRef.getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                result = .failure(err!)
            }else {
                let trainerData = docSnapshot?.data()
                let trainerPermission = trainerData!["trainerPermission"] as! Dictionary<String,Bool>
                result = .success(AppManager.shared.getTrainerPermissionS(trainerPermission: trainerPermission))
                semaphores.signal()
            }
        })
        
        let _ = semaphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    func getTrainerByCategory(category:TrainerType) -> Result<[TrainerDataStructure],Error> {
        let trainerType = category == .general ? "General" : "Personal"
        let semaphores = DispatchSemaphore(value: 0)
        var result:Result<[TrainerDataStructure],Error>!
        var trainerListArray:[TrainerDataStructure] = []
        
        fireDB.collection("Trainers").getDocuments(completion: {
            (querySnapshot,err) in
            
            if err != nil {
                result = .failure(err!)
            }else{
                for trainerDoc in querySnapshot!.documents {
                    let trainerDetail = (trainerDoc.data())["trainerDetail"] as! Dictionary<String,Any>
                    
                    if trainerType == trainerDetail["type"] as! String {
                        trainerListArray.append(AppManager.shared.getTrainerDetailS(trainerDetail: trainerDetail))
                    }
                }
                result = .success(trainerListArray)
                semaphores.signal()
            }
        })
        let _ = semaphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    
    func  updateTrainerDetailBy(id:String,trainerInfo:Dictionary<String,String>) -> Result<Bool,Error> {
        var result:Result<Bool,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        let trainerRef = fireDB.collection("/Trainers").document("/\(id)")
        
        trainerRef.getDocument(completion: {
            (DocumentSnapshot,err) in
            
            if err == nil {
                let trainerData = DocumentSnapshot?.data()
                var trainerDetail = trainerData!["trainerDetail"] as! Dictionary<String,Any>
                trainerDetail.updateValue(trainerInfo["firstName"]!, forKey: "firstName")
                trainerDetail.updateValue(trainerInfo["lastName"]!, forKey: "lastName")
                trainerDetail.updateValue(trainerInfo["email"]!, forKey: "email")
                trainerDetail.updateValue(trainerInfo["password"]!, forKey: "password")
                trainerDetail.updateValue(trainerInfo["gender"]!, forKey: "gender")
                trainerDetail.updateValue(trainerInfo["phoneNo"]!, forKey: "phoneNo")
                trainerDetail.updateValue(trainerInfo["dob"]!, forKey: "dob")
                trainerRef.updateData([
                    "trainerDetail":trainerDetail,
                    "email" : trainerInfo["email"]!,
                    "password" : trainerInfo["password"]!
                ], completion: {
                    (err) in

                    if err != nil {
                        result = .success(false)
                    }else {
                        result = .success(true)
                    }
                    semaphores.signal()
                })
            }
         })

        let _ = semaphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    func deleteTrainerBy(id:String,completion:@escaping (Error?)->Void) {
           let ref = fireDB.collection("/Trainers").document("/\(id)")
           ref.delete(completion: {
           err in
               completion(err)
           })
       }
    
    func addMembership(id:String,membershipDetail:[String:String],completion:@escaping (Error?)->Void)  {
    let parentID = AppManager.shared.loggedInRole == LoggedInRole.Trainer ? AppManager.shared.trainerID : AppManager.shared.adminID
        fireDB.collection("/Memberships").document("/\(id)").setData([
            "id":id,
            "parentID":parentID,
            "membershipDetail":membershipDetail,
            "timeStamp": Date().timeIntervalSince1970
        ], completion: {
            err in
            completion(err)
        })
    }
    
    func updateMembership(id:String,membershipDetail:[String:String],completion:@escaping (Error?)->Void)  {
        fireDB.collection("/Memberships").document("/\(id)").updateData([
            "membershipDetail" : membershipDetail
            ], completion: {
                err in
                completion(err)
        })   
    }

    func getAllMembership(result:@escaping ([[String:Any]]?,Error?)->Void) {
        var membershipArray:[[String:Any]] = []
        fireDB.collection("/Memberships")
            .order(by: "timeStamp", descending: false)
            .getDocuments(completion: {
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
        let parentID = AppManager.shared.loggedInRole == LoggedInRole.Trainer ? AppManager.shared.trainerID : AppManager.shared.adminID
        fireDB.collection("/Visitors").document("/\(id)").setData([
            "id":id,
            "parentID":parentID,
            "visitorDetail":visitorDetail,
            "timeStamp":Date().timeIntervalSince1970
            ], completion: {
                err in
                completion(err)
        })
    }
    
    func updateVisitor(id:String,visitorDetail:[String:String],completion:@escaping (Error?)->Void) {
        fireDB.collection("/Visitors").document("/\(id)").updateData([
            "visitorDetail":visitorDetail
            ], completion: {
                err in
                completion(err)
        })
    }
    
    func getAllVisitors(result:@escaping ([[String:Any]]?,Error?)->Void) {
         var visitorArray:[[String:Any]] = []
        fireDB.collection("/Visitors")
        .order(by: "timeStamp", descending: false)
            .getDocuments(completion: {
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
        let parentID = AppManager.shared.loggedInRole == LoggedInRole.Trainer ? AppManager.shared.trainerID : AppManager.shared.adminID
        fireDB.collection("/Events").document("/\(id)").setData([
            "id":id,
            "parentID":parentID,
            "eventDetail":eventDetail,
            "timeStamp":Date().timeIntervalSince1970
        ], completion: {
            (err) in
            completion(err)
        })
    }

    func updateEvent(id:String,eventDetail:[String:Any],completion:@escaping (Error?)->Void) {
        fireDB.collection("/Events").document("/\(id)").updateData([
            "eventDetail":eventDetail
            ], completion: {
                err in
                completion(err)
        })
    }
    
    func getAllEvents(result:@escaping ([[String:Any]]?,Error?)->Void) {
        var eventArray:[[String:Any]] = []
        fireDB.collection("/Events")
        .order(by: "timeStamp", descending: false)
        .getDocuments(completion: {
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
        
    func getTotalOf(role:Role) -> Result<Int,Error> {
        var result:Result<Int,Error>!
        var count:Int = 0
        let semaphore = DispatchSemaphore(value: 0)
        let role = AppManager.shared.getRole(role: role)
        fireDB.collection("/\(role)").getDocuments(completion: {
            (querySnapshot,err) in
            
            if err != nil {
                result = .failure(err!)
            } else {
                count = querySnapshot!.documents.count
            }
            result = .success(count)
            semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return result
    }
    
    func numberOfPaidMembers() -> Result<Int,Error> {
        var result:Result<Int,Error>!
        let semaphore = DispatchSemaphore(value: 0)
        var count = 0
        AppManager.shared.expiredMember = 0
        fireDB.collection("/Members").getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result = .failure(err!)
            } else {
                for doc in querySnapshot!.documents{
                    let singleData = doc.data()
                    let memberships = singleData["memberships"] as? NSArray
                    if memberships?.count ?? 0 > 0 {
                        let latestMembership = memberships?.lastObject as! [String:String]
                        let dueAmount = Int(latestMembership["dueAmount"]!)
                        let endDate  = AppManager.shared.getDate(date: latestMembership["endDate"]!)
                        let today = AppManager.shared.getStandardFormatDate(date: Date())
                        let diff = Calendar.current.dateComponents([.month,.year,.day], from: today, to: endDate)
                     
                        if dueAmount == 0  && diff.day! >= 0 && diff.month! >= 0 && diff.year! >= 0 {
                            count += 1
                        }
                        
                        if diff.day! <= 0 && diff.month! <= 0 && diff.year! <= 0 {
                            AppManager.shared.expiredMember += 1
                            print("member ship count : \(AppManager.shared.expiredMember)")
                        }
                    } else {
                        AppManager.shared.expiredMember += 1
                        print("member ship count : \(AppManager.shared.expiredMember)")
                    }
                }
                result = .success(count)
                semaphore.signal()
            }
        })
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return result
    }
    
    // NEW ATTENDENCE FUNCTIONS
    func addAttendence(trainerORmember:String,id:String,present:Bool,checkInA:String,checkOutA:String)  {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let index = (day-1)
        let currentDate = "\(day)/\(month)/\(year)"
        let ref = fireDB.collection("/\(trainerORmember)").document("\(id)")
        ref.getDocument(completion: {
            (docSnapshot,err) in
            if err != nil {
                print("Error")
            }else {
               var attandanceDic = ((docSnapshot?.data())! as Dictionary<String, Any>)["attendence"] as! Dictionary<String, Any>
                var currentYear = attandanceDic["\(year)"] as? Dictionary<String, Any>
                var currentMonth = currentYear?["\(month)"] as? Array<Any>
                let firstElement = currentMonth?[index] as? Dictionary<String,Any>
                var currentDay = firstElement?["\(currentDate)"] as! Array<Dictionary<String,Any>>
                let firstAttendence = (currentDay[0])["present"] as! Bool
                let newAttendence = [
                    "checkIn":"\(checkInA)",
                    "checkOut":"\(checkOutA)",
                    "present":present
                    ] as Dictionary<String,Any>
                
                if firstAttendence == false {
                    currentDay.remove(at: 0)
                    currentDay.insert(newAttendence, at: 0)
                }else {
                     currentDay.append(newAttendence)
                }
                currentMonth?.remove(at: index)
                currentMonth?.insert(["\(currentDate)":currentDay], at: index)
                currentYear?.updateValue(currentMonth!, forKey: "\(month)")
                attandanceDic.updateValue(currentYear!, forKey: "\(year)")
                
                ref.updateData([
                    "attendence" :attandanceDic
                    ], completion: {
                        err in
                       
                        if err != nil {
                            print("Error in updating .")
                        }
                        else {
                            print("Successfull in updating.")
                        }
                })
            }
        })
    }
    
    func updateAttendence(trainerORmember:String,id:String,checkOutA:String ,completion:@escaping (Error?)->Void)  {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let index = (day-1)
        let currentDate = "\(day)/\(currentMonth)/\(currentYear)"
        let ref = fireDB.collection("\(trainerORmember)").document("\(id)")
        
           ref.getDocument(completion: {
               (docSnapshot,err) in
               if err != nil {
                   print("Errror in fetching the member attandance.")
               } else {
                   var attandanceDic = ((docSnapshot?.data())! as Dictionary<String, Any>)["attendence"] as! Dictionary<String, Any>
                   var year = attandanceDic["\(currentYear)"] as! Dictionary<String,Any>
                   var month = year["\(currentMonth)"] as! Array<Any>
                   let firstElement = month[index] as! Dictionary<String,Any>
                   var currentDay = firstElement["\(currentDate)"] as! Array<Dictionary<String, Any>>
                   var firstTimeAttendence = currentDay.last
                   var checkOut = firstTimeAttendence?["checkOut"] as! String
                   checkOut = "\(checkOutA)"
                   firstTimeAttendence?.updateValue(checkOut, forKey: "checkOut")
                   currentDay.removeLast()
                   currentDay.append(firstTimeAttendence!)
                   month.remove(at: index)
                   month.insert(["\(currentDate)":currentDay], at: index)
                   year.updateValue(month, forKey: "\(currentMonth)")
                   attandanceDic.updateValue(year, forKey: "\(currentYear)")
                   ref.updateData([
                     "attendence" : attandanceDic
                   ], completion: {
                       err in
                       
                       if err != nil {
                           print("Error")
                       } else {
                           print("Success")
                       }
                   })
               }
           })
       }
    
    func markAttendenceFor(attendenceDir:Dictionary<String,Any>,trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler:@escaping (Error?) -> Void) {
        let ref = fireDB.collection("\(trainerORmember)").document("\(id)")
        var attandanceDic = attendenceDir
        let todayDate = "\(day)/\(month)/\(year)"
        var currentYear = attandanceDic["\(year)"] as! Dictionary<String,Any>
        var currentMonth = currentYear["\(month)"] as! Array<Dictionary<String,Any>>
        let singleTimeAttendence:Dictionary<String,Any> = ["checkIn":"\(checkIn)","checkOut":"\(checkOut)","present":present]
        let AttendenceArray:Array<Dictionary<String,Any>> = [singleTimeAttendence]
        let dayAttendence:Dictionary<String,Any> = ["\(todayDate)":AttendenceArray]
        currentMonth.append(dayAttendence)
        currentYear.updateValue(currentMonth, forKey: "\(month)")
        attandanceDic.updateValue(currentYear, forKey: "\(year)")
        
        ref.updateData([
            "attendence" : attandanceDic
            ], completion: {
                err in
                if err != nil {
                    print("Error in marking next day attendence.")
                }else {
                    print("Success in marking next day attendence.")
                }
        })
    }
    
    // USER CREDENTIALS FUNCTIONALITY
    func addNewUserCredentials(id:String,email:String,password:String,handler:@escaping (Error?) -> Void){
        self.fireDB.collection("Users").document("\(id)").setData([
            "id": id,
            "email" : email,
            "password":password
            ], completion: {
                (err) in
                handler(err)
        })
    }
    
    func isUserExists(email:String) -> Result<Bool,Error>  {
        let seamphores = DispatchSemaphore(value: 0)
        var result:Result<Bool,Error>!
        
        fireDB.collection("Users").getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result = .failure(err!)
                result = .success(false)
            }else {
                for singleDoc in querySnapshot!.documents {
                    let data = singleDoc.data() as! Dictionary<String,String>
                    let matchingEmail = data["email"]
                    
                    if email == matchingEmail {
                        result = .success(true)
                        break
                    }else {
                        result = .success(false)
                    }
                }
                seamphores.signal()
            }
        })

        let _ = seamphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    func isUserExistsWithID(email:String) -> Result<Dictionary<String,Any>?,Error>  {
        let seamphores = DispatchSemaphore(value: 0)
        var result:Result<Dictionary<String,Any>?,Error>!
        
        fireDB.collection("Users").getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result = .failure(err!)
                result = .success(nil)
            }else {
                for singleDoc in querySnapshot!.documents {
                    let data = singleDoc.data() as! Dictionary<String,String>
                    let matchingEmail = data["email"]
                    
                    if email == matchingEmail {
                        result = .success(["ID":data["id"]!,"exists":true])
                        break
                    }else {
                        result = .success(["ID":"","exists":false])
                    }
                }
                seamphores.signal()
            }
        })

        let _ = seamphores.wait(wallTimeout: .distantFuture)
        return result
    }
    
    func updateUserCredentials(id:String,email:String,password:String,handler:@escaping (Error?) -> Void){
        let userRef = fireDB.collection("Users").document("\(id)")
        
        userRef.updateData([
            "email":email,
            "password" : password
            ], completion: {
                (err) in
                handler(err)
        })
    }
    
    func deleteUserCredentials(id:String,handler:@escaping (Error?) -> Void) {
         let userRef = fireDB.collection("Users").document("\(id)")
        userRef.delete(completion: {
            (err)in
            handler(err)
        })
    }
    
    func getMessageCollection(doc:DocumentReference , handler:@escaping ([QueryDocumentSnapshot]) -> Void ) {
        doc.collection("thread")
            .order(by: "created", descending: false)
            .addSnapshotListener({
            (querySnapshot,err) in
            if err == nil {
                handler(querySnapshot!.documents)
            }
        })
    }
    
    func uploadImage(senderID:String,imgData:Data,handler:@escaping (String,Error?)->Void) {
        let imageRef = fireStorageRef.child("/ChatImages/\(senderID)/\(Date().timeIntervalSince1970)")
        
        imageRef.putData(imgData, metadata: nil, completion: {
            (_,err) in
            handler(imageRef.fullPath, err)
        })
    }
    
    func downloadImage(imgUrl:String,hadler:@escaping (Data?,Error?) -> Void) {
        let imageRef = fireStorageRef.child(imgUrl)
        imageRef.downloadURL(completion: {
            (imgUrl,err) in

            if err == nil {
                do {
                    let data = try Data(contentsOf: imgUrl!)
                    hadler(data,nil)
                } catch let error {
                    print(error)
                }
            }
        })
    }
    
    func uploadGallaryImage(imgData:Data,handler:@escaping (Error?) -> Void) {
        let imgRef = fireStorageRef.child("Gallary/\(Date().timeIntervalSince1970)")
        let metaData = StorageMetadata()
        let imgUrl = imgRef.fullPath
        metaData.contentType = "content/jpeg"
        
        uploadGallaryImgUrls(imgUrl: imgUrl, handler: {
            err in
            
            if err == nil {
                imgRef.putData(imgData, metadata: metaData, completion: {
                    (_, err) in
                    handler(err)
                })
            }
        })
    }
    
    private func uploadGallaryImgUrls(imgUrl:String,handler:@escaping (Error?) -> Void ) {
        let timeStamp = imgUrl.split(separator: "/").last!
        fireDB.collection("gallary").document("\(timeStamp)")
            .setData([
                "imgUrl":imgUrl,
                "timeStamp":timeStamp
                ], completion: {
                    (err) in
                    handler(err)
            })
    }
    
    func downloadGallaryImgUrls(handler:@escaping ([String],Error?) -> Void) {
        var imgUrls : [String] = []
        fireDB.collection("gallary")
            .order(by: "timeStamp", descending: false)
            .getDocuments(completion: {
                (querySnapshot,err) in
                
                if err == nil {
                    for singleDoc in querySnapshot!.documents {
                        let data = singleDoc.data()
                        imgUrls.append(data["imgUrl"] as! String)
                    }
                    handler(imgUrls,nil)
                }else {
                    handler([],err)
                }
            })
    }

    func downloadGallaryImg(pageToken:String? = nil,handler:@escaping (([GallaryImg]) -> Void )) {
        var imgUrls : [GallaryImg] = []
        let pageHandler :(StorageListResult,Error?) ->Void = {
            (result,err) in
            if err == nil{
                print("RESULT IS : \(result.items.count)")
                if let token = result.pageToken {
                    AppManager.shared.pageToken = token
                    print("token is : \(AppManager.shared.pageToken)")
                }
                if result.items.count > 0 {
                    for singleItem in result.items{
                        singleItem.getMetadata { (metaData, err) in
                            if err == nil {
                                let timeStamp = metaData?.timeCreated?.timeIntervalSince1970
                                //print("createdTimeStamp : \(timeStamp!) , date is : \(metaData?.timeCreated)")
                                singleItem.downloadURL { (imgURL, err) in
                                    if err == nil {
                                        imgUrls.append(GallaryImg(timeStamp: timeStamp!, url: imgURL!))
                                        if imgUrls.count == result.items.count {
                                            let imgUrlArray =  imgUrls.sorted { (firstImg, secondImg) -> Bool in
                                                return firstImg.timeStamp < secondImg.timeStamp
                                            }
                                            // print("SORTED ARRAY : \(imgUrlArray)")
                                            handler(imgUrlArray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else {
                    handler([])
                }
            }else {
                handler([])
            }
        }
        if pageToken != nil {
            fireStorageRef.child("/Gallary").list(withMaxResults: 5, pageToken:pageToken!, completion:pageHandler)
        } else {
            fireStorageRef.child("/Gallary").list(withMaxResults: 16, completion: pageHandler)
        }
    }

    func deleteGallaryImages(urls:[String],handler:@escaping (Error?) -> Void) {
       var deletingUrls = urls
        deleteGallaryImageUrl(urls: urls) { (err) in
            if err == nil {
                
                for singleUrl in deletingUrls {
                    print(" ===== ===>>>>>  \(singleUrl)")
                    self.fireStorageRef.child("\(singleUrl)").delete { (err) in
                        if err == nil {
                            print("item delete.")
                            deletingUrls.remove(at: deletingUrls.firstIndex(of: singleUrl)!)
                            if deletingUrls.count <= 0 {
                                handler(nil)
                            }
                        }else {
                            handler(err)
                        }
                    }
                }
                
            }else { handler(err) }
        }
    }
    
 private func deleteGallaryImageUrl(urls:[String],handler:@escaping (Error?) -> Void) {
        var deletingUrls = urls
        
        for singleUrl in deletingUrls {
            let docUrl = singleUrl.split(separator: "/").last!
            fireDB.collection("gallary").document("\(docUrl)").delete { (err) in
                
                if err == nil {
                    deletingUrls.remove(at: deletingUrls.firstIndex(of: singleUrl)!)
                    if deletingUrls.count <= 0 {
                        handler(err)
                    }
                }
            }
        }
    }

    func  uploadGymVideo(id:String,url:URL,role:Role,handler:@escaping(Error?) -> Void) {
        let path = role == .Admin ? "Videos/admin/\(id)/\(Date().timeIntervalSince1970)" : "Videos/trainers/\(id)/\(Date().timeIntervalSince1970)"
     let VideoRef = fireStorageRef.child(path)
     let videoUrl = VideoRef.fullPath

        uploadGallaryVideoUrls(id: id, role: role, vidUrl: videoUrl) { (err) in
            if err == nil {
                VideoRef.putFile(from:url, metadata: nil) { (_, uploadErr) in
                    if err == nil {
                        handler(uploadErr)
                    }
                }
            }
        }
    }
        
    private func uploadGallaryVideoUrls(id:String,role:Role,vidUrl:String,handler:@escaping (Error?) -> Void ) {
        let docRef = fireDB.collection("videos").document("\(id)")
        var videoUrlArray:[String] = []
        if videoUrlArray.contains(vidUrl) == false {
            videoUrlArray.append(vidUrl)
        }
        
        docRef.getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot?.exists == true {
                let data = docSnapshot?.data()
                var videoUrlArr = data!["videoUrlArray"] as! [String]
                if videoUrlArr.contains(vidUrl) == false {
                    videoUrlArr.append(vidUrl)
                    
                    docRef.updateData( [ "videoUrlArray"  : videoUrlArr ]) { (err) in
                        handler(err)
                    }
                }
            }else {
                docRef.setData([
                    "videoUrlArray":videoUrlArray,
                    "role" : role == .Admin ? "admin" : "trainer",
                    "ownerID" : id
                    ], completion: {
                        (err) in
                        handler(err)
                })
            }
        }
    }

    func downloadGymVideosUrls(id:String,handler:@escaping ([String],Error?) -> Void) {
        var imgUrls : [String] = []
        fireDB.collection("videos").document(id).getDocument(completion: {
            (docSnapshot,err) in
            
            if err == nil &&  docSnapshot?.exists == true {
                let data = docSnapshot!.data()
                imgUrls = data!["videoUrlArray"] as! [String]
                handler(imgUrls,nil)
            }else {
                handler([],err)
            }
        })
    }
    
    func downloadListOfGymVideos(handler:@escaping ([VideoDocInfo]) -> Void ) {
        var videos:[VideoDocInfo] = []
        
        fireDB.collection("/videos").getDocuments { (querySnapshot, err) in
            if err == nil  {
                let documentsCount = querySnapshot?.documents.count
                if (documentsCount)! > 0 {
                    for singleDoc in querySnapshot!.documents {
                        let video = singleDoc.data()
                        videos.append(VideoDocInfo( url: video["videoUrlArray"] as! [String], role: video["role"] as! String, ownerID: video["ownerID"] as! String))
                    }
                    if videos.count == documentsCount {
                        handler(videos)
                    }
                }
            }else { handler(videos) }
        }
    }
    
    func downloadGymVideo(id:String,pageToken:String? = nil,role:Role,handler:@escaping (([GymVideos]) -> Void )) {
        
        let path = role == .Admin ? "/Videos/admin/\(id)" : "/Videos/trainers/\(id)"
        
        var vidUrls : [GymVideos] = []
        let pageHandler :(StorageListResult,Error?) ->Void = {
            (result,err) in
            if err == nil{
                if let token = result.pageToken {
                    AppManager.shared.videoPageToken = token
                }
                if result.items.count > 0 {
                    for singleItem in result.items{
                        singleItem.getMetadata { (metaData, err) in
                            if err == nil {
                                let timeStamp = metaData?.timeCreated?.timeIntervalSince1970
                                //print("createdTimeStamp : \(timeStamp!) , date is : \(metaData?.timeCreated)")
                                singleItem.downloadURL { (vidURL, err) in
                                    if err == nil {
                                        vidUrls.append(GymVideos(timeStamp: timeStamp!, url: vidURL!))
                                        if vidUrls.count == result.items.count {
                                            let vidUrlArray =  vidUrls.sorted { (firstVid, secondVid) -> Bool in
                                                return firstVid.timeStamp < secondVid.timeStamp
                                            }
                                            // print("SORTED ARRAY : \(imgUrlArray)")
                                            handler(vidUrlArray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else {
                    handler([])
                }
            }else {
                handler([])
            }
        }
        if pageToken != nil {
            fireStorageRef.child(path).list(withMaxResults: 5, pageToken:pageToken!, completion:pageHandler)
        } else {
            fireStorageRef.child(path).list(withMaxResults: 5, completion: pageHandler)
        }
    }
    
    private func deleteVideoUrl(id:String,urls:[String],handler:@escaping (Error?) -> Void) {
        var deletingUrls = urls
        let docRef = fireDB.collection("videos").document("\(id)")
        
        for singleUrl in deletingUrls {
            docRef.getDocument { (docSnapshot, err) in
                if err == nil && docSnapshot?.exists  == true {
                    let data = docSnapshot?.data()
                    var videoUrlArray = data!["videoUrlArray"] as! [String]
                    for urlStr in deletingUrls {
                        if videoUrlArray.contains(urlStr) ==  true {
                            videoUrlArray.remove(at: videoUrlArray.firstIndex(of: urlStr)!)
                        }
                    }
                    docRef.updateData([
                        "videoUrlArray":videoUrlArray
                    ]) { (err) in
                        if err == nil {
                            print("video url deleted.")
                            deletingUrls.remove(at: deletingUrls.firstIndex(of: singleUrl)!)
                            if deletingUrls.count <= 0 {
                                handler(err)
                            }
                        }
                    }
                }
            }
        }
        

    }
    
    func deleteVideos(id:String,urls:[String],handler:@escaping (Error?) -> Void) {
        var deletingUrls = urls
        deleteVideoUrl(id: id, urls: urls) { (err) in
            if err == nil {
                print("DELETING URLS ARE : \(urls)")
                
                for singleUrl in deletingUrls {
                    print(" ===== ===>>>>>  \(singleUrl)")
                    self.fireStorageRef.child("\(singleUrl)").delete { (err) in
                        if err == nil {
                            print("item delete.")
                            deletingUrls.remove(at: deletingUrls.firstIndex(of: singleUrl)!)
                            if deletingUrls.count <= 0 {
                                handler(nil)
                            }
                        }else {
                            handler(err)
                        }
                    }
                }
            } else { handler(err) }
        }
    }
    
    func getAllMembersNameAndID() -> Result<[WorkoutMemberList],Error> {
        var result:Result<[WorkoutMemberList],Error>!
        let semaphores = DispatchSemaphore(value: 0)
        
        
        var memberArray : [WorkoutMemberList] = []
        fireDB.collection("Members")
        .order(by: "timeStamp", descending: false)
            .getDocuments { (querSnapshot, err) in
            if err == nil && (querSnapshot?.documents.count)! > 0 {
                for singleDoc in querSnapshot!.documents {
                    let data =  singleDoc.data()
                    let memberDetail = data["memberDetail"] as! [String:String]
                    let memberName = "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)"
                    let memberID = memberDetail["memberID"]!
                 
                    memberArray.append(WorkoutMemberList(memberName: memberName, memberID: memberID))
                }
                result = .success(memberArray)
                semaphores.signal()
            }
        }
        let _ = semaphores.wait(timeout: .distantFuture)
        return result
    }
    
    func getMemberNameBy(id:String) -> Result<WorkoutMemberList,Error> {
        var result:Result<WorkoutMemberList,Error>!
        let semaphores = DispatchSemaphore(value: 0)
        
        fireDB.collection("Members").document(id)
            .getDocument { (docSnapshot, err) in
                if err == nil && docSnapshot!.exists == true {
                    let data =  docSnapshot!.data()
                    let memberDetail = data?["memberDetail"] as! [String:String]
                    let memberName = "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)"
                    let memberID = memberDetail["memberID"]!
                    
                    result = .success(WorkoutMemberList(memberName: memberName, memberID: memberID))
                    semaphores.signal()
                }
        }
        let _ = semaphores.wait(timeout: .distantFuture)
        return result
    }

    func addNewWorkout(id:String,parentID:String,data:Dictionary<String,Any>,handler:@escaping (Error?) -> Void) {
        fireDB.collection("workoutPlan").document("\(id)").setData([
            "timeStamp" : Date().timeIntervalSince1970,
            "workoutID":id,
            "workoutPlan":data,
            "parentID" : parentID
        ]) { (err) in
            handler(err)
        }
    }
    
    func updateWorkoutPlan(id:String,data:Dictionary<String,Any>,handler:@escaping (Error?) -> Void) {
        fireDB.collection("workoutPlan").document("\(id)").updateData([
            "workoutPlan":data
        ]) { (err) in
            handler(err)
        }
    }
    
    func getAllWorkout(parentID:String,handler:@escaping ([WorkoutPlanList]) -> Void) {
        var workoutPlan:[WorkoutPlanList] = []
        fireDB.collection("workoutPlan")
            .order(by: "timeStamp", descending: false)
           // .whereField("parentID", isEqualTo: parentID)
            .getDocuments { (querySnapshot, err) in
                if err == nil && (querySnapshot?.documents.count)! > 0 {
                    for singleDoc in querySnapshot!.documents {
                        let workoutData = singleDoc.data()
                        workoutPlan.append(AppManager.shared.getWorkoutPlanList(data:workoutData))
                    }
                    handler(workoutPlan)
                }else {
                    handler([])
                }
        }
    }
    
    func getWorkoutByID(id:String,handler:@escaping (WorkoutPlan?) -> Void ) {
        fireDB.collection("workoutPlan").document(id)
            .getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot!.exists  == true {
                handler(AppManager.shared.getWorkoutPlan(data: docSnapshot!.data()!))
            } else {
                handler(nil)
            }
        }
    }
    
    func deleteWorkoutByID(id:String,handler:@escaping (Error?) -> Void) {
        fireDB.collection("workoutPlan").document(id).delete { (err) in
            handler(err)
        }
    }
    
    func addWorkoutPlansToMember(memberID:String,workoutID:String,handler:@escaping (Error?) -> Void) {
        let ref = fireDB.collection("Members").document(memberID)
        ref.getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot?.exists == true {
                let data  = docSnapshot!.data()
                var workoutPlans = data?["workoutPlans"] as! [String]
                if workoutPlans.contains(workoutID) == false {
                   workoutPlans.append(workoutID)
                    ref.updateData(["workoutPlans" : workoutPlans], completion: {
                        errWorkout in
                        handler(errWorkout)
                    })
                }else { handler(nil) }
            }else {
                handler(err)
            }
        }
    }
    
    func getWorkoutPlansIDsForMember(memberID:String,handler:@escaping ([String]) -> Void )  {
        let ref = fireDB.collection("Members").document(memberID)
        ref.getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot?.exists == true {
                let data = docSnapshot?.data()
                let wokroutPlans = data?["workoutPlans"] as! [String]
                handler(wokroutPlans)
            }
        }
    }
    
    func setHealthKitStatus(memberID:String,healthKitStatus:Bool,completion:@escaping (Error?) -> Void ) {
        let ref = fireDB.collection("Members").document(memberID)
        ref.updateData(["healthKitStatus":healthKitStatus]) { (err) in
            completion(err)
        }
    }
    
    func getHealthKitStatus(memberID:String,completion:@escaping (Bool) -> Void) {
        let ref = fireDB.collection("Members").document(memberID)
        ref.getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot?.exists == true {
                let data = docSnapshot?.data()
                let healthKitStatus = data!["healthKitStatus"] as! Bool
                completion(healthKitStatus)
            }
        }
    }
    
    //REMINDERS FUNCTIONALITY
    
    func addOrUpdateReminder(memberID:String,reminderID:String,reminderData:[String:Any],completion:@escaping (Error?) -> Void ) {
        let ref = fireDB.collection("Reminders").document(memberID)
        ref.getDocument { (docSnapshot, err) in
            if err == nil {
                if  docSnapshot?.exists == true  {
                    let data = docSnapshot?.data()
                    var workouts = data?["workout"] as! [String:Any]
                    workouts[reminderID] = reminderData
                    
                    ref.updateData(["workout":workouts]) { (err) in
                        completion(err)
                    }
                    
                }else {
                    let workout = [reminderID:reminderData]
                    ref.setData(["workout":workout]) { (err) in
                        completion(err)
                    }
                }
            }else {
                print("ERROR IS : \(err!)")
                completion(err)
            }
        }
    }
    
    
    func getAllReminders(memberID:String,completion:@escaping ([Reminder]) -> Void) {
        let ref = fireDB.collection("Reminders").document(memberID)
        var reminderArray:[Reminder] = []
        
        ref.getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot?.exists == true  {
                let workout = (docSnapshot?.data()?["workout"] as! Dictionary<String,Any>)
                
                workout.forEach { (key,value) in
                    let reminderValues = value as! Dictionary<String,Any>
                    
                    reminderArray.append(Reminder(reminderID: key, workoutName: reminderValues["workoutName"] as! String ,note:reminderValues["note"] as! String , weekDays: reminderValues["weekdays"] as! [Int], time: reminderValues["time"]  as! String , isRepeat: reminderValues["isRepeat"] as! Bool ))
                }
                completion(reminderArray)
                
            }else {
                completion(reminderArray)
            }
        }
    }
    
    func getReminderBy(reminderID:String,memberID:String,completion:@escaping (Reminder?) -> Void) {
        let ref = fireDB.collection("Reminders").document(memberID)
        var reminder:Reminder? = nil
        
        ref.getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot?.exists == true  {
                let workout = (docSnapshot?.data()?["workout"] as! Dictionary<String,Any>)
                
                if workout[reminderID] != nil {
                    let values = workout[reminderID] as! [String:Any]
                    reminder = Reminder(reminderID: reminderID, workoutName:values["workoutName"] as! String ,note: values["note"] as! String, weekDays: values["weekdays"] as! [Int], time: values["time"] as! String , isRepeat: values["isRepeat"] as! Bool)
                }
                completion(reminder)
            } else {
                completion(reminder)
            }
        }
    }
    
    func deleteReminderBy(reminderID:String,memberID:String,completion:@escaping (Error?) -> Void) {
        let ref = fireDB.collection("Reminders").document(memberID)
    
        ref.getDocument { (docSnapshot, err) in
            if err == nil && docSnapshot?.exists == true {
                var workout = (docSnapshot?.data()?["workout"] as! Dictionary<String,Any>)
                
                if workout[reminderID] != nil {
                    workout.remove(at: workout.index(forKey: reminderID)!)
                    
                    ref.updateData(["workout":workout]) { (err) in
                        completion(err)
                    }
                }else {
                    print("ALREADY DELETED.")
                }
            }else {
                completion(err)
            }
        }
    }
    
    
    
    
}











 
