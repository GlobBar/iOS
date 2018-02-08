//
//  City.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/14/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

struct City : Mappable {
    
    fileprivate(set) var id: Int = 0
    fileprivate(set) var name: String = ""

    
    init?(map: Map) {
        mapping(map: map)
    }
     
    mutating func mapping(map: Map) {
        id <- map["pk"]
        name <- map["title"]
    }
    
}

extension City: Equatable {
}

func ==(lhs: City, rhs: City) -> Bool {
    return lhs.id == rhs.id
}
