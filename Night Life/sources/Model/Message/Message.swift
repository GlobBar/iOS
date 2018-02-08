//
//  Message.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper
import RxDataSources

struct Message : Mappable, Storable {
    
    fileprivate(set) var id : Int = 0
    var identifier: Int { return id }
    
    var title : String = ""
    var body : String = ""
    
    var created: Date?
    
    var isRead: Bool = false
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        
        id <- map["pk"]
        
        title <- map["title"]
        body <- map["body"]
        
        created <- (map["created"], ISO8601DateTransform())
        
        isRead <- map["is_readed"]
    }
}

extension Message : IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        return id
    }
    
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
}
