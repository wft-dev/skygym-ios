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
    let textMessageRecipients = ["7015810695"]
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body = "Just for testing ."
        return messageComposeVC
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
       }
}
