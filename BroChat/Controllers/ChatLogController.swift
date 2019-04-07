//
//  ChatLogController.swift
//  BroChat
//
//  Created by Michelle Grover on 4/2/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatLogController: UIViewController {
    
    
    var messages = [Message]()
    
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var sendTextFieldOutlet: UITextField!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user:User? {
        didSet {
            if let username = user?.username {
                navigationItem.title = "\(username)"
                observeMessages()
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSendButton()
        setupSendTextField()
        sendView.backgroundColor = UIColor.customDarkBlue
        subscribeToKeyboardNotifications()
        setCollectionViewDelegateDataSource()
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        sendMessageData()
    }
    
    
    
    deinit {
        unsubscribeToKeyboardNotifications()
    }
    
    
    

}

// MARK:- UI and Layout functionality
extension ChatLogController {
    
    
    private func setupSendTextField() {
        
        sendTextFieldOutlet.delegate = self
        
        sendTextFieldOutlet.layer.masksToBounds = true
        sendTextFieldOutlet.layer.borderWidth = 3
        sendTextFieldOutlet.layer.borderColor = UIColor.lightBlue2.cgColor
        sendTextFieldOutlet.layer.cornerRadius = 8
        sendTextFieldOutlet.placeholder = "send new message ..."
        sendTextFieldOutlet.tintColor = UIColor.darkPinkish
    }
    
    private func setupSendButton() {
        
        let attributedString = NSAttributedString(string: "Send", attributes: [NSAttributedString.Key.backgroundColor:UIColor.white, NSAttributedString.Key.foregroundColor:UIColor.customDarkBlue])
        sendButtonOutlet.setAttributedTitle(attributedString, for: .normal)
        sendButtonOutlet.layer.backgroundColor = UIColor.white.cgColor
        sendButtonOutlet.layer.borderWidth = 2
        sendButtonOutlet.layer.borderColor = UIColor.lightBlue2.cgColor
        sendButtonOutlet.layer.cornerRadius = 8
        sendButtonOutlet.layer.masksToBounds = true
    }
    
    
}

extension ChatLogController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendTextFieldOutlet.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessageData()
        return true
    }
}

extension ChatLogController {
    
    private func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc private func keyboardWillShow(_ notification:Notification) {
        if (sendTextFieldOutlet.isEditing) {
            view.frame.origin.y = 0 - getkeyboardHeight(notification)
            
        }
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        if (sendTextFieldOutlet.isEditing) {
            view.frame.origin.y = 0
        }
    }
    
    private func getkeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func unsubscribeToKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
}


// MARK:- Firebase functionality
extension ChatLogController {
    
    private func sendMessageData() {
        guard let sendText = sendTextFieldOutlet.text, !sendText.isEmpty, sendText != "" else {
            print("There is no text")
            return
        }
        
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("There is no fromId")
            return
        }
        
        guard let timestamp = Int(Date().timeIntervalSince1970) as? NSNumber else {
            print("There is no timestamp")
            return
        }
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        guard let toId = user?.id else {
            print("There is a problem getting the toId")
            return
        }
        let values = ["text": sendText, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]

        childRef.updateChildValues(values) { (error, ref) in
            if (error != nil) {
                print("There was an error!!")
                return
            }
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId)
            
            guard let messageId = childRef.key, let value = [messageId:1] as? [String:Int] else {
                print("There was an error getting the values")
                return
            }
            
            userMessageRef.updateChildValues(value)
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessageRef.updateChildValues(value)
        }
        sendTextFieldOutlet.text = ""
        
        
    }
    
    
    private func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error occurred getting uid")
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            //            print(snapshot)
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observe(.value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    print("Error creating dictionary")
                    return
                }
                
                var message = Message()
                message = Message.returnMessageObject(dictionary: dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
}
// MARK:- CollectionViewDelegate and functionality
extension ChatLogController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? ChatMessageCell
        cell?.textView.text = message.text
        
        return cell!
    }
    
    
    private func setCollectionViewDelegateDataSource() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK:- CollectionViewFlowLayout
extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}


