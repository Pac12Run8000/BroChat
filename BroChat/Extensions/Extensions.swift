//
//  Extensions.swift
//  BroChat
//
//  Created by Michelle Grover on 3/22/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    static let customDarkBlue = UIColor.colorFromHex("204E5F")
    static let lightPinkish = UIColor.colorFromHex("FFC6A8")
    static let darkPinkish = UIColor.colorFromHex("FF8984")
    static let lightBlue2 = UIColor.colorFromHex("B7D7D8")
    static let lightBlue1 = UIColor.colorFromHex("EDF7F5")
    
    static func colorFromHex(_ hex:String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (hexString.hasPrefix("#")) {
            hexString.remove(at: hexString.startIndex)
        }
        
        if (hexString.count != 6) {
            return UIColor.black
        }
        
        var rgb:UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: 1.0)
        
    }
    
    
    
}



