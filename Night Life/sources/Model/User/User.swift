//
//  User.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/5/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import ObjectMapper
import RxDataSources

struct User: UserProtocol, Storable {
    
    fileprivate(set) var id : Int = 0
    var identifier: Int { return id }
    
    var username : String = ""
    var email : String = ""
    var pictureURL : String?
    
    var followersCount: Int?
    var followingCount: Int?
    var points: Int?

    var relationType: RelationType? = nil
    
    init(id: Int) {
        self.id = id
    }
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["pk"]
        username <- map["username"]
        pictureURL <- map["profile_image"]
        
        followersCount <- map["followers_count"]
        followingCount <- map["followings_count"]
        points <- map["points_count"]
        
        relationType <- map["current_relation"]
    }
    
}

extension User : CustomStringConvertible, Hashable {
    
    var description : String {
        get {
            return "\(id) " + username
        }
    }
    
    var hashValue: Int {
        return id
    }
}

extension User : IdentifiableType {
    
    typealias Identity = Int
    
    var identity: Int {
        return id
    }
    
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

protocol UserProtocol : Mappable, Storable {
    
    static func currentUser() -> Self?
    
    static func loginWithData (_ data: AnyObject) -> Self
    
    func saveLocally() -> Void
    
    func logout()
}
