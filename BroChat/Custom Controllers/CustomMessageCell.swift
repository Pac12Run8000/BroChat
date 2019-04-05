//
//  CustomMessageCell.swift
//  BroChat
//
//  Created by Michelle Grover on 4/4/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var CustomImageView: UIImageView!
    @IBOutlet weak var messageLabelOutlet: UILabel!
    
    var userObj:User! {
        didSet {
            userLabel.text = userObj.username
            if let profileImageUrl = userObj.profileImageUrl, let url = URL(string: profileImageUrl) {
                ImageService.downloadAndCacheImage(withUrl: url) { (succees, image, error) in
                    self.CustomImageView.image = image
                }
            }
        }
    }
    
    var messageObj:Message! {
        didSet {
            messageLabelOutlet.text = messageObj.text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
       
        CustomImageView.image = UIImage(named: "addImage-3")
        CustomImageView.layer.cornerRadius = CustomImageView.frame.height / 2
        CustomImageView.layer.masksToBounds = true
        CustomImageView.layer.borderWidth = 3
        CustomImageView.layer.borderColor = UIColor.lightBlue2.cgColor
        CustomImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
