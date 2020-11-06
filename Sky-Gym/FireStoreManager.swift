//
//  FireStoreManager.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 14/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD


class FireStoreManager: NSObject {
    static let shared:FireStoreManager = FireStoreManager()
    private override init() {}
    let fireDB = Firestore.firestore()
    let fireStorageRef = Storage.storage().reference()
    

    //FOR ADMIN LOGIN
    func isAdminLogin(email:String,password:String,result:@escaping (Bool,Error?)->Void) {
        var flag:Bool = false
        fireDB.collection("Admin").getDocuments(completion: {
            (querySnapshot,err) in
            if err != nil {
                result(false,err)
            } else {
                for singleDoc in querySnapshot!.documents{
                    let adminDetail = (singleDoc.data() as NSDictionary)["adminDetail"] as! [String:Any]
                    
                    let adminEmail = adminDetail["email"] as! String
                    let adminPassword = adminDetail["password"] as! String
                    
                    if adminEmail == email && adminPassword == password {
                        AppManager.shared.adminID = singleDoc.documentID
                        AppManager.shared.gymID =  adminDetail["gymID"] as! String
                        AppManager.shared.isInitialUploaded = false
                        flag = true
                        break
                    }else {
                        flag = false
                    }
                }
                result(flag,nil)
            }
        })
    }
    
    func register(id:String,adminDetail:[String:Any],result:@escaping (Error?) ->Void) {
        fireDB.collection("Admin").document("/\(id)").setData([
        "adminDetail":adminDetail
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
    
    func addMember(email:String,password:String,memberDetail:[String:String],memberships:[[String:String]],memberID:String,handler:@escaping (Error?) -> Void ) {
        let attendence = AppManager.shared.getCompleteMonthAttendenceStructure()
        fireDB.collection("/Members").document("/\(memberID)").setData(
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
                    let currentMembership = AppManager.shared.getCurrentMembership(membershipArray: membershipArray)
                    
                    for singleCurrentMembership in currentMembership {
                        let expiredDate = AppManager.shared.getDate(date: singleCurrentMembership.endDate)
                        let startDate = AppManager.shared.getDate(date: "01-Dec-2020")
                        //let dayDiff = calculateDaysBetweenTwoDates(start: Date(), end: expiredDate)
                        let difference = Calendar.current.dateComponents([.year,.month,.day], from: startDate, to: expiredDate)
                        
                        if difference.day! < 0 {
                            let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: singleCurrentMembership.endDate, dueAmount:singleCurrentMembership.dueAmount)
                            memberArray.append(member)
                        }
                    }
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
                        let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: currentMembership.last!.endDate, dueAmount:currentMembership.last!.dueAmount)
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

                    guard  let day:NSDictionary = ((attendence["\(currentYear)"] as! NSDictionary)["\(currentMonth)"] as? NSDictionary)!["\(todayDate)"] as? NSDictionary else {
                        break
                    }
                        if day.count > 0  {
                            let check = day["\(checkFor)"] as! String
                            let currentMembership = AppManager.shared.getCurrentMembership(membershipArray: membershipArray)
                            
                            if check != "" {
                                let member = ListOfMemberStr(memberID: memberDetail["memberID"]!, userImg: UIImage(named: "user1")!, userName: "\(memberDetail["firstName"]!) \(memberDetail["lastName"]!)", phoneNumber: memberDetail["phoneNo"]!, dateOfExp: currentMembership.last!.endDate, dueAmount:currentMembership.last!.dueAmount)
                                checkArray.append(member)
                            } else {
                            }
                        }
                }
                result(checkArray,nil)
            }
        })
    }

    func updateMemberDetails(id:String,memberDetail:[String:String],handler:@escaping (Error?) -> Void ) {
        fireDB.collection("/Members").document("/\(id)")
        .updateData([
            "email": memberDetail["email"]!,
            "password":memberDetail["password"]!,
            "memberDetail":memberDetail
        ], completion: {
            err in
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
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let todayDate = "\(day)/\(currentMonth)/\(currentYear)"
        let status:[String:Any] = [
                       "checkIn" : "\(checkIn)",
                       "checkOut": "\(checkOut)",
                       "present" : present
                   ]

        let ref = fireDB.collection("/\(trainerORmember)").document("/\(id)")
        print(ref.path)
              ref.getDocument(completion: {
                  (docSnapshot,err) in
                  if err != nil {
                     completion(err)
                  } else {
                    let attandanceDic = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! NSDictionary
                    
                    if attandanceDic.count < 1 {
                        self.markFirstAttendence(trainerORmember:trainerORmember,id:id,year: currentYear,month:currentMonth,day: day, present: present,checkIn:checkIn,checkOut: checkOut,handler: {
                            err in
                            completion(err)
                        })
                    } else {
                        guard let year = attandanceDic["\(currentYear)"] as? NSDictionary  else {
                            self.addYear(trainerORmember:trainerORmember,id: id, year:currentYear, month: currentMonth, day: day, present: present,checkIn: checkIn,checkOut: checkOut, handler: {
                                err in
                                completion(err)
                            })
                            return
                        }
                        guard let month =  year["\(currentMonth)"] as? NSDictionary else {
                            self.addMonth(trainerORmember:trainerORmember,id: id,year:currentYear,month:currentMonth,day:day, present: present,checkIn: checkIn,checkOut:checkOut, handler: {
                                err in
                                completion(err)
                            })
                            return
                        }
                        month.setValue(status, forKey: todayDate )
                        ref.updateData([
                            "attendence" :attandanceDic
                            ], completion: {
                                err in
                              completion(err)
                        })
                    }
                }
              })
      }
      
    private func addMonth(trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler:@escaping (Error?)->Void) {
        let status:[String:Any] = [
            "checkIn" : "\(checkIn)",
            "checkOut": "\(checkOut)",
            "present" : present
                   ]
           let ref =  fireDB.collection("/\(trainerORmember)").document("/\(id)")
          ref.getDocument(completion: {
              (docSnapshot,err) in
              if err != nil {
                  print("Error in getting the document for  adding new month.")
              } else {
                  let attandanceDir = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! NSDictionary
                  let currentYear = attandanceDir["\(year)"] as! NSDictionary
                let newMonth = ["\(day)/\(month)/\(year)":status]
                currentYear.setValue(newMonth, forKey: "\(month)")
                  ref.updateData([
                      "attendence":attandanceDir
                      ], completion: {
                          (err) in
                        handler(err)
                  })
              }
          })
      }
      
    private func addYear(trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler: @escaping (Error?)->Void) {
        let status:[String:Any] = [
            "checkIn" : "\(checkIn)",
            "checkOut": "\(checkOut)",
            "present" : present
            ]
        
      let ref =  fireDB.collection("/\(trainerORmember)").document("/\(id)")
          ref.getDocument(completion: {
              (docSnapshot,err) in
              if err != nil {
                   print("Error in getting the document for  adding new Year.")
              } else {
                let attandanceDir = ((docSnapshot?.data())! as NSDictionary)["attendence"] as! NSDictionary
                let attendence = ["\(month)":["\(day)/\(month)/\(year)":status]]
                  attandanceDir.setValue(attendence, forKey: "\(year)")
                
                  ref.updateData([
                      "attendence":attandanceDir
                  ], completion: {
                      err in
                     handler(err)
                  })
              }
          })
      }
    
    private func markFirstAttendence(trainerORmember:String,id:String,year:Int,month:Int,day:Int,present:Bool,checkIn:String,checkOut:String,handler:@escaping (Error?) -> Void ) {
        
        let status:[String:Any] = [
            "checkIn" : "\(checkIn)",
            "checkOut": "\(checkOut)",
            "present" : present
        ]
        
        let currentDate = "\(day)/\(month)/\(year)"
        let attendence = ["\(year)":["\(month)":["\(currentDate)":status]]]
        let ref = fireDB.collection("/\(trainerORmember)").document("/\(id)")
        ref.updateData([
            "attendence":attendence
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
                let day = ((attendence["\(currentYear)"] as! [String:Any])["\(currentMonth)"] as! [String:Any])["\(todayDate)"] as! [String:Any]
                let present = day["present"] as! Bool
                let checkIn = day["checkIn"] as! String
                let status:[String:Any] = [
                    "checkIn" : "\(checkIn)",
                    "checkOut": "\(checkOut)",
                    "present" : present
                ]
                let updatedAttendence = ["\(currentYear)":["\(currentMonth)":["\(todayDate)":status]]]
                let ref = self.fireDB.collection("/\(trainerORmember)").document("/\(id)")
                ref.updateData([
                    "attendence":updatedAttendence
                    ], completion: {
                        err in
                        completion(err)
                })
            }
        })
    }
    
    func getAttendenceFrom(trainerORmember:String,id:String,startDate:String,endDate:String,result:@escaping ([Attendence]) -> Void) {
        let startD = AppManager.shared.getDate(date: startDate)
        let endD = AppManager.shared.getDate(date: endDate)
        let diff = Calendar.current.dateComponents([.year,.month], from: startD, to: endD)

        fireDB.collection("/\(trainerORmember)").document("/\(id)").getDocument(completion: {
            (docSnapshot,err) in
            
            if err == nil {
                let attendence = (((docSnapshot?.data())! as NSDictionary )["attendence"]) as! NSDictionary
                
                if diff.year == 0 {
                    if diff.month == 0 {
                        let a = AppManager.shared.sameMonthSameYearAttendenceFetching(attendence: attendence, year:"\(Calendar.current.component(.year, from: startD))" , month: "\(Calendar.current.component(.month, from: startD))", startDate: AppManager.shared.changeDateFormatToStandard(dateStr: startDate), endDate:  AppManager.shared.changeDateFormatToStandard(dateStr: endDate))
                        result(a)
                    } else {
                        let a = AppManager.shared.sameYearDifferenctMonthAttedenceFetching(attendence: attendence, startDate: startD, endDate: startD)
                        result(a)
                    }
                } else {
                    //DIFFERENT MONTH AND YEAR RETRIVAL
                }
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
        let attendence = [String:[String:[String:Bool]]]()
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
                    //print(dataDirctionary.count)
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
    
    func getMembershipBy(id:String,result:@escaping ([String:Any]?,Error?)->Void) {
        fireDB.collection("/Memberships").document("/\(id)").getDocument(completion: {
            (docSnapshot,err)in
            
            if err != nil {
                result(nil,err)
            }else {
                let data = docSnapshot?.data()
                result(data,nil)
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
        fireDB.collection("/Members").document("261826315").getDocument(completion: {
            (docRef,error) in
            
            let attendence = (docRef?.data() as! NSDictionary)["attendence"] as! [String:Any]
//            let monthArray = (attendence["2020"] as! NSDictionary)["11"] as! NSArray
//            var counter = Calendar.current.component(.day, from: Date())
//        //    print("ARRAY IS :\((monthArray.first as! NSDictionary)["1/11/2020"] as! NSDictionary)")
            
          let s =  AppManager.shared.sameMonthSameYearAttendenceFetching(attendence: attendence as NSDictionary, year: "2020", month: "11", startDate: "6 Nov 2020", endDate: "13 Nov 2020")
            
            print("FINALL RESULT ATTENDENCE: \(s)")
        })
    }
}
    
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
    
}



 
