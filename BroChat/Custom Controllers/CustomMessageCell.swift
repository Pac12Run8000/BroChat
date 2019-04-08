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
    @IBOutlet weak var timestampLabel: UILabel!
    
    var userObj:User? {
        didSet {
            userLabel.text = userObj!.username
            if let profileImageUrl = userObj!.profileImageUrl, let url = URL(string: profileImageUrl) {
                ImageService.downloadAndCacheImage(withUrl: url) { (succees, image, error) in
                    self.CustomImageView.image = image
                }
            }
        }
    }
    
   
    
    var messageObj:Message? {
        didSet {
            
            messageLabelOutlet.text = messageObj!.text
            
            if let seconds = messageObj?.timestamp?.doubleValue ,let timestampDate = NSDate(timeIntervalSince1970: seconds) as? NSDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timestampLabel.text = dateFormatter.string(from: timestampDate as Date)
                
            }
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        userLabel.layer.borderWidth = 2
//        timestampLabel.layer.borderWidth = 2
//        timestampLabel.font = UIFont(name: "Arial", size: 12)
        timestampLabel.textColor = UIColor.customDarkBlue
       
        CustomImageView.image = UIImage(named: "addImage-3")
        CustomImageView.layer.cornerRadius = CustomImageView.frame.height / 2
        CustomImageView.layer.masksToBounds = true
        CustomImageView.layer.borderWidth = 3
        CustomImageView.layer.borderColor = UIColor.lightBlue2.cgColor
        CustomImageView.contentMode = .scaleAspectFill
        backgroundColor = UIColor.lightBlue1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
