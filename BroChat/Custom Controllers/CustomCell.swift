//
//  CustomCell.swift
//  BroChat
//
//  Created by Michelle Grover on 4/1/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
   
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var userObj:User! {
        didSet {
            nameLabel.text = userObj.username
            emailLabel.text = userObj.email
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.lightBlue1.cgColor
        profileImageView.layer.borderWidth = 3
        
        nameLabel.textColor = UIColor.customDarkBlue
        
        emailLabel.textColor = UIColor.customDarkBlue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
