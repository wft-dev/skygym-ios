//
//  MessengerManager.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 07/12/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import Foundation
import MessageUI
class MessengerManager: NSObject,MFMessageComposeViewControllerDelegate {

    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController(recipients:[String],body:String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = recipients
        messageComposeVC.body = body
        return messageComposeVC
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
       }
}
