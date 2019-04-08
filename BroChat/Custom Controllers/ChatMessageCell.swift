//
//  ChatMessageCell.swift
//  BroChat
//
//  Created by Michelle Grover on 4/6/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChatMessageCell: UICollectionViewCell {
   
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var messageObj:Message! {
        didSet {
            textView.text = messageObj.text
            
            
            if messageObj.fromId == Auth.auth().currentUser?.uid {
                textView.backgroundColor = UIColor.lightBlue1
                leadingConstraint.constant = 120
                trailingConstraint.constant = 5
            } else {
                textView.backgroundColor = UIColor.lightPinkish
                leadingConstraint.constant = 5
                trailingConstraint.constant = 120
            }
        }
    }
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.white
        textView.backgroundColor = UIColor.lightBlue1
        
        textView.layer.cornerRadius = 14
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.lightBlue2.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }
}
