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
}

struct Attendence {
    var date:String
    var present:Bool
    var checkIn:String
    var checkOut:String
}

protocol CustomCellSegue {
    func applySegue(id:String)
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



