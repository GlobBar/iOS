//
//  RelationshipManager.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/31/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import Foundation

import Alamofire
import RxSwift

enum RelationshipManager {}
extension RelationshipManager {
    
    static func followersRequestCount() -> Observable<Int> {
        
        return Alamofire.request(RelationRouter.requestCount)
                .rx_Response(Response<RequestsCountMapping>.self)
                .map { $0.count }
        
    }
    
}
