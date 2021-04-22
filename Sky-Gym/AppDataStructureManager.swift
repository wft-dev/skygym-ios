//
//  AppDataStructureManager.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 15/10/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Firebase
import MessageKit


enum Role:String {
    case Admin
    case Member
    case Trainer
    case Visitor
}

enum LoggedInRole:String,Codable {
    case Admin
    case Member
    case Trainer
}

struct  GymDetail {
    var gymName:String
    var gymID:String
    var gymOpeningTime:String
    var gymClosingTime:String
    var gymDays:String
    var gymAddress:String
    var gymOwnerName:String
    var gymOwnerPhoneNumber:String
    var gymOwnerAddress:String
}

struct AdminProfile {
    var gymName:String
    var gymID:String
    var gymAddress:String
    var firstName:String
    var lastName:String
    var gender:String
    var password:String
    var email:String
    var phoneNO :String
    var dob:String
    var gymOpenningTime:String
    var gymClosingTime:String
    var gymDays:String
    var gymDyasArrayIndexs:[Int]
}

//MEMBER STRUCTURE
struct MemberDetailStructure {
    var firstName:String
    var lastName:String
    var memberID:String
    var dateOfJoining:String
    var gender:String
    var password:String
    var type:String
    var trainerName:String
    var trainerID:String
    var uploadIDName:String
    var email:String
    var address:String
    var phoneNo : String
    var dob:String
}

struct MembershipDetailStructure {
    var membershipID:String
    var membershipPlan:String
    var membershipDetail:String
    var amount:String
    var startDate:String
    var endDate:String
    var totalAmount:String
    var paidAmount:String
    var discount:String
    var paymentType:String
    var dueAmount:String
    var purchaseTime:String
    var purchaseDate:String
    var membershipDuration:String
    var purchaseTimeStamp:String
}

struct ListOfMemberStr {
    var memberID:String
    var userImg:UIImage
    var userName:String
    var phoneNumber:String
    var dateOfExp:String
    var dueAmount:String
    var uploadName:String
}

struct  MemberFullNameAndPhone {
    var memberID:String
    var userName:String
    var phoneNo:String
}


struct PurchaseMembershipPlan {
    var membershipID:String
    var membershipPlan:String
    var expireDate:String
    var amount:String
    var dueAmount:String
    var paidAmount:String
    var purchaseDate:String
    var startDate:String
    var timeStamp:String
}

struct Attendence {
    var date:String
    var present:Bool
    var checkIn:String
    var checkOut:String
}
 
protocol CustomCellSegue {
    func applySegue(id:String)
    func applySegueToChat(id:String,memberName:String)
    func showMessage(vc:MFMessageComposeViewController)
}

struct TrainerDataStructure {
    var firstName:String
    var lastName:String
    var trainerID:String
    var phoneNo:String
    var email:String
    var password:String
    var address:String
    var gender:String
    var salary:String
    var uploadID:String
    var shiftDays:String
    var shiftTimings:String
    var type:String
    var dob:String
    var dateOfJoining:String
    var shiftDaysIndexArray:[Int]
}

struct TrainerPermissionStructure {
    var canAddVisitor:Bool
    var canAddMember:Bool
    var canAddEvent:Bool
}

struct ListOfTrainers {
    var trainerID:String
    var trainerName:String
    var trainerPhone:String
    var dateOfJoinging:String
    var salary:String
    var members:String
    var type:String
}

enum TrainerType:String {
    case general
    case personal
}

struct TrainerNameAndType {
    var trainerName:String
    var trainerType:String
    var trainerID:String
}

struct Memberhisp {
    var membershipID:String
    var title:String
    var amount:String
    var detail:String
    var duration:String
    var selectedIndex:String
}

struct Visitor {
    var id:String
    var firstName:String
    var lastName:String
    var email:String
    var address:String
    var dateOfJoin:String
    var dateOfVisit:String
    var noOfVisit:String
    var gender:String
    var phoneNo:String
    var trainerID:String
}

struct ListOfVisitor {
    var visitorID:String
    var visitorName:String
    var mobileNumber:String
    var dateOfVisit:String
    var dateOfJoining:String
    var trainerName:String
    var trainerType:String
    var noOfVisit:String
    var trainerID:String
}

struct Event {
    var eventID:String
    var adminID:String
    var eventName:String
    var eventDate:String
    var eventAddress:String
    var eventStartTime:String
    var eventEndTime:String
}


// CHAT SYSTEM STRUCTURE

struct Chat {
    var users:[String]
    
    var dic:[String:Any] {
        return ["users":users]
    }
}

extension Chat {
    init?(dictionary:[String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {
            return nil
        }
        self.init(users: chatUsers)
    }
}

struct Message {
    var id :String
    var content : String
    var created:Timestamp
    var senderDescription:SenderDecription
    var imgURLStr :String
    var imageMessage:ImageMessage?
    var dictionary:[String:Any] {
        return [
            "id":id,
            "created":created,
            "content":content,
            "senderID":senderDescription.senderId,
            "senderName":senderDescription.displayName,
            "imgURLStr":imgURLStr
        ]
    }
}

extension Message {
    init?(dictionary:[String:Any]) {
        guard let id = dictionary["id"] as? String,
        let content = dictionary["content"] as? String ,
        let created = dictionary["created"] as? Timestamp,
        let senderID = dictionary["senderID"] as? String,
        let senderName = dictionary["senderName"] as? String,
        let imgUrlStr = dictionary["imgURLStr"] as? String
            else {
            return nil
        }
        self.init(id: id, content: content, created: created, senderDescription: SenderDecription(senderId: senderID, displayName: senderName), imgURLStr: imgUrlStr, imageMessage: nil)
    }

}

// Structure for sending image as message
struct ImageMessage:MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image:UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}

//Sender type structre
struct SenderDecription:SenderType {
    var senderId: String
    var displayName: String
}


extension Message : MessageType {
    var sender: SenderType {
        return senderDescription
    }
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return created.dateValue()
    }
    
    var kind: MessageKind {
        if self.imgURLStr == "" {
            return .text(content)
        }else {
            return .photo(imageMessage ?? ImageMessage(image: UIImage(named: "default-image")!))
        }
    }

}

// Chat usesr

struct  ChatUsers {
    var messageSenderID :String
    var messageReceiverID :String
    var messageSenderName:String
    var messageReceiverName:String
}


// PAYMENT RESULT ENUM
enum PaymentResult {
  case success
  case failure(Error)
}

struct GallaryImg {
    var timeStamp:TimeInterval
    var url:URL
}

struct GymVideos {
    var timeStamp:TimeInterval
    var url:URL?
}

struct VideoDocInfo {
    var url:[String]
    var role:String
    var ownerID:String
}

struct VideoList {
    var videoImgae:UIImage
    var ownerName:String
    var ownerRole:String
    var ownerID:String
}

struct WorkoutPlanList {
    var workoutID:String
    var workoutPlan:String
    var numberOfSets:String
    var numberOfReps:String
    var weight:String
}

struct WorkoutPlan {
    var workoutID:String
    var workoutPlan:String
    var workoutDescription:String
    var sets:String
    var reps:String
    var weight:String
    var members:[String]
    var memberIndex : [Int]
}

struct WorkoutMemberList {
    var memberName:String
    var memberID:String
}


struct HealthStatics {
    var value:String
    var date:String
}

enum HealthParameter {
    case steps
    case heartRate
}

struct Reminder {
    var reminderID:String
    var workoutName:String
    var note:String
    var weekDays:[Int]
    var time:String
    var isRepeat:Bool
}


struct Posts {
    var userID:String
    var userNameImg:UIImage
    var userName:String
    var postImg:UIImage
    var isLiked:Bool
    var isUnliked:Bool
    var likesCount:Int
    var unlikesCount:Int
    var caption:String
    var comments:[Comment]
    var timeForPost:String
}


struct Comment {
    var userID:String
    var userName:String
    var commentStr:String
}

