//
//  ChatLogController.swift
//  BroChat
//
//  Created by Michelle Grover on 4/2/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class ChatLogController: UIViewController {
    
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var sendTextFieldOutlet: UITextField!
    @IBOutlet weak var sendView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Chat Log Controller"
        setupSendButton()
        setupSendTextField()
        sendView.backgroundColor = UIColor.customDarkBlue
        
    }
    

    

}

// MARK:- UI and Layout functionality
extension ChatLogController {
    
    
    private func setupSendTextField() {
        sendTextFieldOutlet.layer.masksToBounds = true
        sendTextFieldOutlet.layer.borderWidth = 3
        sendTextFieldOutlet.layer.borderColor = UIColor.lightBlue2.cgColor
        sendTextFieldOutlet.layer.cornerRadius = 8
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
