//
//  CkubListRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

enum ClubListRouter : AuthorizedRouter {
    
    case inCity(city: City?, location: CLLocation?)
    case inCityNew(city: City?, location: CLLocation?)
    
    case liked
    case nearest(location: CLLocation)
    
}

extension ClubListRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self {
            
        case .inCity(let city, let location):
            
            var body: [String: Any] = [
                "latitude" : location?.coordinate.latitude ?? 0,
                "longitude" : location?.coordinate.longitude ?? 0
            ]
            
            if let c = city {
                body["filter_city"] = c.id
            }
            
            return self.authorizedRequest(.get,
                path: "places/",
                encoding: URLEncoding.default,
                body: body)
        
        case .inCityNew(let city, let location):
            
            var body: [String: Any] = [
                "latitude" : location?.coordinate.latitude ?? 0,
                "longitude" : location?.coordinate.longitude ?? 0
            ]
            
            if let c = city {
                body["city_id"] = c.id
            }
            
            return self.authorizedRequest(.get,
                                          path: "places/test/",
                                          encoding: URLEncoding.default,
                                          body: body)
            
        case .liked:
            
            return self.authorizedRequest(.get,
                path: "places/saved/",
                encoding: URLEncoding.default,
                body: [:])
            
        case .nearest(let location):
            
            return self.authorizedRequest(.get,
                                          path: "places/nearest/",
                                          encoding: URLEncoding.default,
                                          body: [
                                            "latitude" : location.coordinate.latitude,
                                            "longitude" : location.coordinate.longitude
                ])
            
            
        }
    }
    
}
