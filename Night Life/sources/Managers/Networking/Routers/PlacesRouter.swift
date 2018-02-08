//
//  PlacesRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/23/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

enum PlacesRouter : AuthorizedRouter {
    
    /**
     * returns list of cities sorted from closest to furthest based on Location
     */
    case cities(baseLocation: CLLocation)
    
    case details(club: Club)
    case chekin(club: Club, broadcast: Bool)
    
    case like(club: Club)
    case unLike(club: Club)

}

extension PlacesRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self{
            
        case .cities(let baseLocation):
            
            return self.authorizedRequest(.get,
                path: "cities/",
                encoding: URLEncoding.default,
                body: [
                    "latitude" : baseLocation.coordinate.latitude,
                    "longitude" : baseLocation.coordinate.longitude
                ])
            
        case .details(let club):

            return self.authorizedRequest(.get,
                path: "places/\(club.id)/",
                encoding: URLEncoding.default,
                body: [:])
            
        case .chekin(let club, let broadcast):
            
            return self.authorizedRequest(.post,
                path: "places/checkin/",
                encoding: URLEncoding.default,
                body: [
                    "place_pk" : club.id,
                    "is_hidden" : broadcast ? "true" : "false"
                ])
            
        case .like(let club):
            
            return self.authorizedRequest(.post,
                path: "places/like/",
                encoding: URLEncoding.default,
                body: ["place_pk" : club.id])
            
        case .unLike(let club):
            
            return self.authorizedRequest(.post,
                path: "places/like/",
                encoding: URLEncoding.default,
                body: [
                    "place_pk" : club.id,
                    "remove_like" : "true"
                ])
            
        }
        
    }
    
}
