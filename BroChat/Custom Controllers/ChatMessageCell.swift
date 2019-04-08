//
//  ChatMessageCell.swift
//  BroChat
//
//  Created by Michelle Grover on 4/6/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
   
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.backgroundColor = UIColor.lightBlue1
        
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.customDarkBlue.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }
}
