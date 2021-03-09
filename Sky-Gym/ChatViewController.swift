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
    var imageMessage:[Message] = []
    var docRef:DocumentReference? = nil
    var imageData:Data? = nil
    var imageIndexArray:[Int] = []
    var imgUrlStrArray:[String] = []
    var isChatExists:Bool = false
    private lazy var imagePicker :UIImagePickerController = {
       return UIImagePickerController()
    }()
    
    let blackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = false
        self.currentSenderUser = SenderDecription(senderId: self.chatUsers!.messageSenderID, displayName: self.chatUsers!.messageSenderName)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        self.imagePicker.delegate = self
        setChatFieldView()
        self.loadChat()
        setNavigationBar()
        blackView.backgroundColor = .black
    }
    
    func enlargeImage(imageView:UIImageView) {
        let enlargeImageView =  UIImageView(image: imageView.image)
        enlargeImageView.frame = UIScreen.main.bounds
        enlargeImageView.backgroundColor = .black
        enlargeImageView.contentMode = .scaleAspectFit
        enlargeImageView.isUserInteractionEnabled = true
        enlargeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissEnlargedImage(_:))))
        self.navigationController?.isNavigationBarHidden = true
        blackView.frame = messageInputBar.frame
        self.messageInputBar.addSubview(self.blackView)
        self.view.addSubview(enlargeImageView)
    }
    
    @objc func dismissEnlargedImage(_ gesture:UITapGestureRecognizer){
        self.navigationController?.isNavigationBarHidden = false
        self.blackView.removeFromSuperview()
        gesture.view?.removeFromSuperview()
    }
    
    func setChatFieldView() {
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.7
        messageInputBar.inputTextView.layer.cornerRadius = 15.0
        messageInputBar.sendButton.backgroundColor = UIColor(red: 105/255, green: 142/255, blue: 184/255, alpha: 1.0)
        messageInputBar.sendButton.layer.cornerRadius = 10.0
        messageInputBar.sendButton.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 0)
        let b = InputBarButtonItem(frame: CGRect(x: 5, y: 4, width: 25, height: 25))
        b.setImage(UIImage(named:"upload-image"), for: .normal)
        b.addTarget(self, action: #selector(uploadImg), for: .touchUpInside)
        let v = UIView(frame: b.frame)
        v.addSubview(b)
        messageInputBar.inputTextView.addSubview(v)
    }
    
    @objc func uploadImg(){
        self.imagePicker.allowsEditing = true
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }

  private  func insertNewMessage(message:Message) {
        messages.append(message)
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    func loadImages() {
        SVProgressHUD.show()
        if self.imageMessage.count > 0 {
            for (index,singleMessage) in self.imageMessage.enumerated(){
                FireStoreManager.shared.downloadImage(imgUrl: singleMessage.imgURLStr, hadler: {
                    (imggData,err) in
                    
                    let i = self.imageIndexArray[index]
                    self.messages.remove(at: i)
                    self.messages.insert(Message(id: UUID().uuidString, content: singleMessage.content, created: Timestamp(), senderDescription: singleMessage.senderDescription, imgURLStr: singleMessage.imgURLStr, imageMessage: ImageMessage(image: UIImage(data: imggData!)!)), at: i)
                    
                    if index ==  self.imageMessage.count - 1 {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom(animated: true)
                            SVProgressHUD.dismiss()
                    }
                })
            }
        }else {
            SVProgressHUD.dismiss()
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
        self.navigationController?.popViewController(animated: true)
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
        docRef?.collection("thread").addDocument(data: msgData, completion: {
            (err) in
            
            if err == nil {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            }else {
                print("Error in saving message.")
            }
        })
    }
    
    func loadChat(){
        SVProgressHUD.show()
        let chatRef = Firestore.firestore().collection("Chats")
            .whereField("users",arrayContains:self.chatUsers!.messageSenderID)
        
        chatRef.getDocuments(completion: {
            (querySnapshot,err) in
            
            if err == nil {
                guard let queryCount = querySnapshot?.documents.count else {
                    SVProgressHUD.dismiss()
                    return
                }
                if queryCount == 0 { self.createNewChat() }
                    
                else if queryCount >= 1 {
                    for doc in querySnapshot!.documents  {
                       let chat = Chat(dictionary: doc.data())
                        if chat!.users.contains(self.chatUsers!.messageReceiverID){
                            self.isChatExists = true
                            self.docRef = doc.reference
                            FireStoreManager.shared.getMessageCollection(doc: self.docRef!, handler: {
                                (documentArray) in
                                if documentArray.count > 0 {
                                    self.messages.removeAll()
                                    
                                    for (index,singleDoc) in documentArray.enumerated() {
                                        let msg = Message(dictionary: singleDoc.data())
                                        if msg?.imgURLStr == "" {
                                            self.messages.append(msg!)
                                        }else {
                                            self.imageMessage.append(msg!)
                                            self.imageIndexArray.append(index)
                                            let m = Message(id: msg!.id, content:msg!.content, created: Timestamp(), senderDescription:msg!.senderDescription, imgURLStr: msg!.imgURLStr, imageMessage: msg!.imageMessage)
                                            self.messages.append(m)
                                        }
                                    }
                                    if self.messages.count == documentArray.count {
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToBottom(animated: true)
                                        self.loadImages()
                                    }
                                    SVProgressHUD.dismiss()
                                }else {
                                    SVProgressHUD.dismiss()
                                }
                            })
                        }
                    }
                    if self.isChatExists == false {
                        self.createNewChat()
                    }
                }
            }
        })
    }
    
    private func createNewChat(){
        SVProgressHUD.show()
        let users = [self.chatUsers!.messageSenderID,self.chatUsers!.messageReceiverID]
        let data:[String:Any] = ["users":users]
        
    Firestore.firestore().collection("Chats")
            .document("\(users.first! + users.last!)")
        .setData(data, completion: {
            (err) in
            if err == nil {
                self.loadChat()
                SVProgressHUD.dismiss()
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
        return isFromCurrentSender(message: message) ? .gray : .yellow
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

extension ChatViewController:MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        let subV = cell.subviews.first!.subviews
        for sub in subV {
            if sub.isKind(of: UIImageView.self) && sub.subviews.count > 0  {
                self.enlargeImage(imageView: sub.subviews.first as! UIImageView)
               // print("image view are : \(sub.subviews)")
            }
        }
    }
}

extension ChatViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image:UIImage = info[.editedImage] as? UIImage{
            SVProgressHUD.show()
            self.imageData = image.jpegData(compressionQuality: 0.5)
            FireStoreManager.shared.uploadImage(senderID: currentSenderUser!.senderId, imgData: self.imageData!, handler: {
                (imgUrlStr,err) in
                if err == nil {
                    let message = Message(id: UUID().uuidString, content: "", created: Timestamp(), senderDescription: self.currentSenderUser!, imgURLStr: imgUrlStr, imageMessage: nil)
                    self.insertNewMessage(message: message)
                    self.saveMessage(message: message)
                    SVProgressHUD.dismiss()
                }
            })
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


