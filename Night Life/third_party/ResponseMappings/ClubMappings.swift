//
//  ClubMappings.swift
//  GlobBar
//
//  Created by Vlad Soroka on 1/5/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

struct ClubByIdMapping: Mappable {
    
    var club: Club!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        club <- map["place"]
    }
}

struct ClubListByIdMapping: Mappable {
    
    var clubs: [Club]!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        clubs <- map["places"]
    }
}

struct CheckingMapping: Mappable {
    
    var expired: String!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        expired <- map["expired"]
    }
}
