//
//  BaseResponse.swift
//  Campfiire
//
//  Created by Vlad Soroka on 10/23/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import ObjectMapper

protocol ResponeProtocol : Mappable {
    
    associatedtype DataType
    
    var data: DataType? { get }
    
}


struct Response<S: Mappable> : ResponeProtocol {

    typealias DataType = S
    
    var data: S?
    
    init?(map: Map) {
        data = S(map: map)
    }
    
    mutating func mapping(map: Map) {
    }
    
}

struct ArrayResponse<S: Mappable> : ResponeProtocol {
    
    typealias DataType = [S]
    
    var data: [S]?
    
    init?(map: Map) {
        data = Mapper<S>().mapArray(JSONObject: map.JSON)
    }
    
    mutating func mapping(map: Map) {
    }
    
}

struct EmptyResponse : ResponeProtocol {
    
    typealias DataType = Void
    
    var data: Void?
    
    init?(map: Map) {
        mapping(map: map)
        data = ()
    }
    
    mutating func mapping(map: Map) {
        
    }
    
}
