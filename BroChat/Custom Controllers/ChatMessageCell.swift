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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.backgroundColor = UIColor.lightBlue1
        
        
    }
}
