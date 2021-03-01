//
//  ChatViewController.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 25/02/21.
//  Copyright © 2021 KP iOSDev. All rights reserved.
//

import UIKit
import InputBarAccessoryView
import Firebase
import MessageKit
import SDWebImage
import SVProgressHUD
import IQKeyboardManagerSwift

class ChatViewController: MessagesViewController{
    var currentSenderUser:SenderDecription? = nil
    var chatUsers:ChatUsers? = nil
    var messages:[Message] = []
    var docRef:DocumentReference? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
       // IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatViewController.self)
        self.currentSenderUser = SenderDecription(senderId: self.chatUsers!.messageSenderID, displayName: self.chatUsers!.messageSenderName)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
      messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        self.loadChat()
        setNavigationBar()
    }

  private  func insertNewMessage(message:Message) {
        messages.append(message)
    messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    func setNavigationBar()  {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        let title = NSAttributedString(string:self.chatUsers!.messageReceiverName, attributes: [
            NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 22)!,
        ])
        let titleLabel = UILabel()
        titleLabel.attributedText = title
        self.navigationItem.titleView = titleLabel
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let spaceBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        let stackView = UIStackView(arrangedSubviews: [spaceBtn,backButton])
        stackView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let backBtn = UIBarButtonItem(customView: stackView)
        navigationItem.leftBarButtonItem = backBtn

        
        
    }
    
    @objc func backBtnAction(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
  private  func saveMessage(message:Message) {
        let msgData:[String:Any] = [
            "id":message.id,
            "content" : message.content,
            "created" : message.created,
            "senderID" : message.senderDescription.senderId,
            "senderName" : message.senderDescription.displayName,
            "imgURLStr" : message.imgURLStr
        ]
       // print("DOC REF : \(docRef)")
        docRef?.collection("thread").addDocument(data: msgData, completion: {
            (err) in
            
            if err == nil {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }else {
                print("Error in saving message.")
            }
        })
    }
    
    func loadChat(){
        let chatRef = Firestore.firestore().collection("Chats")
            .whereField("users", arrayContains: chatUsers!.messageSenderID)
        
        chatRef.getDocuments(completion: {
            (querySnapshot,err) in
            
            if err == nil {
                guard let queryCount = querySnapshot?.documents.count else {
                    return
                }
                if queryCount == 0 { self.createNewChat() }
                    
                else if queryCount >= 1 {
                    for doc in querySnapshot!.documents  {
                        let chat = Chat(dictionary: doc.data())
                        if chat!.users.contains(self.chatUsers!.messageReceiverID){
                            self.docRef = doc.reference
                            FireStoreManager.shared.getMessageCollection(doc: self.docRef!, handler: {
                                (documentArray) in
                                if documentArray.count > 0 {
                                    self.messages.removeAll()
                                    
                                    for singleDoc in documentArray {
                                        let msg = Message(dictionary: singleDoc.data())
                                        if msg?.imgURLStr == "" {
                                            self.messages.append(msg!)
                                        }else {
                                            print("image")
                                        }
                                    }
                                    
                                    if self.messages.count == documentArray.count {
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToBottom(animated: true)
                                    }
                                }
                            })
                        }
                    }
                }
                
            }
            
        })
        
    }
    
    private func createNewChat(){
        let users = [self.chatUsers!.messageSenderID,self.chatUsers!.messageReceiverID]
        let data:[String:Any] = ["users":users]
        
    Firestore.firestore().collection("Chats")
            .document("\(users.first! + users.last!)")
        .setData(data, completion: {
            (err) in
            if err == nil {
                self.loadChat()
            }
        })
        
    }
    
}

extension ChatViewController:InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let msg = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderDescription: self.currentSenderUser!, imgURLStr: "", imageMessage: nil)
        
        insertNewMessage(message: msg)
        saveMessage(message: msg)
        
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.resignFirstResponder()
    }
}

extension ChatViewController:MessagesDataSource{
    func currentSender() -> SenderType {
        return currentSenderUser!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There is no message")
            return 0
        }else {
            return messages.count
        }
    }
}

extension ChatViewController:MessagesLayoutDelegate{
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}

extension ChatViewController:MessagesDisplayDelegate{
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .gray : .black
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
         return .bubble
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            avatarView.image = UIImage(named: "member")
        }else {
            avatarView.image = UIImage(named: "user1")
        }
    }
    
}
