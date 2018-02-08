//
//  AuthenticationMappings.swift
//  GlobBar
//
//  Created by Vlad Soroka on 1/5/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import Foundation

import ObjectMapper

struct AccessTokenMapping: Mappable {
    
    var token: String?
    var errorString: String?
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        token <- map["access_token"]
        errorString <- map["data"]
    }
}

struct UserMapping: Mappable {
    
    var user: User!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        user <- map["user"]
    }
}

struct EditUserMapping: Mappable {
    
    var errorReason: String?
    
    var username: String?
    var profileImage: String?
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        errorReason <- map["data"]
        
        username <- map["username"]
        profileImage <- map["profile_image"]
    }
}

struct CurrentUserMapping: Mappable {
    
    var user: [String : AnyObject]!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        user <- map["user"]
    }
}

struct FacebookInvitationMapping: Mappable {
    
    var data: String?
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

struct JSONArrayWrapper : Mappable {
    var data: [[String : AnyObject]]!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        data <- map
    }
}

