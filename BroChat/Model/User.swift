//
//  User.swift
//  BroChat
//
//  Created by Michelle Grover on 3/28/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import Foundation

class User:NSObject {
    var id:String?
    var email:String?
    var username:String?
    var profileImageUrl:String?
    
    static func convertToUserObject(dictionary:[String:AnyObject]) -> User {
        let user = User()
        user.id = dictionary["id"] as? String
        user.email = dictionary["email"] as? String
        user.username = dictionary["username"] as? String
        user.profileImageUrl = dictionary["profileImageUrl"] as? String
        return user
    }
}
