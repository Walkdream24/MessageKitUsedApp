//
//  ViewController.swift
//  messagekitsample
//
//  Created by tatsumi kentaro on 2018/03/20.
//  Copyright © 2018年 tatsumi kentaro. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
class ViewController: MessagesViewController {
    var db: Firestore!
    var realtimedb: DatabaseReference!
    var messagesList: [MessageModel] = []
    var sender:Sender!
    var sender1:Sender!
    let avator = Avatar(image: UIImage(named:"Steve-Jobs.jpeg"), initials: "SJ")
    var contentsArray = [String:Any]()
    var uid1:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        realtimedb = Database.database().reference()
        if let uid = Auth.auth().currentUser?.uid{
            uid1 = uid
            db.collection("users").document(uid).getDocument(completion: { (snap, error) in
                if let error = error {
                    print(error.localizedDescription)
                }else{
                    let data = snap?.data()
                    self.sender = Sender(id: uid, displayName: data!["name"] as! String)
                    self.realtimedb.ref.child("message").observe(.value) { (snap) in
                        self.messagesList = [MessageModel]()
                        for item in snap.children{
                            let child = item as! DataSnapshot
                            let dic = child.value as! NSDictionary
                            let attributedText = NSAttributedString(string: dic["text"] as! String, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                            self.sender1 = Sender(id: dic["senderID"] as! String, displayName: dic["senderName"] as! String )
                            let message = MessageModel(attributedText: attributedText, sender: self.sender1, messageId: UUID().uuidString, date: Date())
                            self.messagesList.append(message)
                        }
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            })
        }

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
//表示内容系
extension ViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return sender
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter
            }()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}
//レイアウト系
extension ViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: avator)
    }
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }
}
//打ち込んだ文字をどうにかする系
extension ViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                
                let imageMessage = MessageModel(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messagesList.append(imageMessage)
                messagesCollectionView.insertSections([messagesList.count - 1])
                
            } else if let text = component as? String {
                print(text)
                contentsArray = ["text":text,"senderID": uid1,"senderName":self.sender.displayName]
                realtimedb.ref.child("message").childByAutoId().setValue(contentsArray)
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                
                let message = MessageModel(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messagesList.append(message)
                messagesCollectionView.insertSections([messagesList.count - 1])
            }
            
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
}

