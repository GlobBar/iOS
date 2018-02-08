//
//  ReportMappings.swift
//  GlobBar
//
//  Created by Vlad Soroka on 1/5/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

struct LastReportsMapping: Mappable {
    
    var reports: [[String : AnyObject]]!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        reports <- map["last_reports"]
    }
}

struct CityReportsMapping: Mappable {
    
    var reports: [[String : AnyObject]]!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        reports <- map["reports"]
    }
}

struct CitiesMapping: Mappable {
    
    var cities: [City]!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        cities <- map["cities"]
    }
}
