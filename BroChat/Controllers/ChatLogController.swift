//
//  ChatLogController.swift
//  BroChat
//
//  Created by Michelle Grover on 4/2/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController {
    
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var sendTextFieldOutlet: UITextField!
    @IBOutlet weak var sendView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Chat Log"
        setupSendButton()
        setupSendTextField()
        sendView.backgroundColor = UIColor.customDarkBlue
        subscribeToKeyboardNotifications()
        
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        print(sendTextFieldOutlet.text)
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