//
//  Messages.swift
//  BroChat
//
//  Created by Michelle Grover on 4/4/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var fromId:String?
    var toId:String?
    var text:String?
    var timestamp:NSNumber?
    
    
    
    static func returnMessageObject(dictionary:[String:AnyObject]) -> Message {
        let message = Message()
        message.fromId = dictionary["fromId"] as? String
        message.toId = dictionary["toId"] as? String
        message.text = dictionary["text"] as? String
        message.timestamp = dictionary["timestamp"] as? NSNumber
        return message
    }
    
}


