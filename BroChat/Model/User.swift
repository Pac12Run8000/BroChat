//
//  User.swift
//  BroChat
//
//  Created by Michelle Grover on 3/28/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import Foundation

class User:NSObject, Comparable {
    
    
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
    
    static func < (lhs: User, rhs: User) -> Bool {
        if let lhsUser = lhs.username, let rhsUser = rhs.username {
            return lhsUser < rhsUser
        }
        return false
    }
}



