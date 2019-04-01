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
    
    var userObj:User! {
        didSet {
            
        }
    }
    
//    var restaurantObj:Restaurant! {
//        didSet {
//
//            addressLabelOutlet.text = restaurantObj.address
//            if let name = restaurantObj.name as? String {
//                nameLabelOutlet.text = name
//            }
//
//            if let formattedCurrency = takeIntAndConvertToFormattedCurrency(input: restaurantObj.average_cost_for_two!) as? String {
//                typeAndAvgCostLabelOutlet.text = "\(formattedCurrency)"
//            }
//        }
//    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        

        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.lightBlue1.cgColor
        profileImageView.layer.borderWidth = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
