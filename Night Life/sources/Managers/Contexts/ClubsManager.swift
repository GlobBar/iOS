//
//  ClubsManager.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxSwift

import ObjectMapper

class ClubsManager {
    
    static func clubForId(_ key: Int, forceRefresh: Bool = false) -> Observable<Club> {
        
        if let club = Club.entityByIdentifier(key), forceRefresh != true {
            return Observable.just(club)
        }
        
        return Alamofire.request(PlacesRouter.details(club: Club(id: key)))
            .rx_Response(Response<ClubByIdMapping>.self)
            .map { resp in
                let club: Club = resp.club
                
                club.lastCheckedInUsers.forEach { user in
                    if User.entityByIdentifier(user.id) == nil {
                        user.saveEntity()
                    }
                }
                club.saveEntity()
                
                return club
            }
        
    }
    
    static func clubListFromRouter(_ router: ClubListRouter) -> Observable<[Club]> {
        
        return Alamofire.request(router)
            .rx_Response(Response<ClubListByIdMapping>.self)
            .map { resp in
                
                let places: [Club] = resp.clubs
                
                places.forEach { club in
                    club.saveEntity()
                    
                    club.lastCheckedInUsers.forEach { user in
                        if User.entityByIdentifier(user.id) == nil {
                            user.saveEntity()
                        }
                    }
                    
                }
                
                return places
            }
    }
    
}
