//
//  CityFeedDataProvider.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxDataSources
import Alamofire


import ObjectMapper

struct CityFeedDataProvider {
    
    let city: City
    let filter: FeedFilter
    
    init(city: City, filter: FeedFilter) {
        self.city = city
        self.filter = filter
    }
    
}

extension CityFeedDataProvider : FeedDataProvider {
    
    func loadBatch(_ batch: Batch) -> Observable<[FeedDataItem]> {
        
        let rout = FeedDisplayableRouter.feedOfCity(city: city, filter: filter, batch: batch)
        
        return Alamofire.request(rout)
            .rx_Response(Response<CityReportsMapping>.self)
            .map { response -> [FeedDataItem] in
                
                ///FIXME: parsing response into seperate entities must be encapsulated
                guard let clubsJSON = response.reports else {
                    print("Error retreiving reports for city id \(self.city.id)")
                    return []
                }
                
                let users = Mapper<User>().mapArray(JSONArray: clubsJSON.map ({ $0["owner"] as! [String : AnyObject] }))
                
                users.forEach { user in
                    ///FIXME: get away from heruistic on merging entities
                    if user != User.currentUser() {
                        user.saveEntity()
                    }
                }
                
                return clubsJSON.map { FeedDataItem(feedItemJSON: $0)! }
        }
        
        
        
    }
    
}
