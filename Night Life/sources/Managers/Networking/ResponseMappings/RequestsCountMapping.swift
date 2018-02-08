//
//  RequestsCountMapping.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/31/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

struct RequestsCountMapping : Mappable {
    
    var count: Int = 0
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        count <- map["data"]
    }
    
}
