//
//  PointsRouter.swift
//  Night Life
//
//  Created by admin on 04.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import Alamofire


import ObjectMapper

enum PointsRouter: AuthorizedRouter {

    case getPoints
    case removePoints(points: Int)
}

extension PointsRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self{
            
        case .getPoints:
            
            return self.authorizedRequest(.get,
                                          path: "points/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .removePoints(let points):
            
            return self.authorizedRequest(.post,
                                          path: "points/",
                                          encoding: URLEncoding.default,
                                          body: ["spent_points" : points])
        }
    }
}
