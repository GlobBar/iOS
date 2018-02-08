//
//  ClubFeedDataProvider.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/2/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxDataSources
import Alamofire


import ObjectMapper

struct ClubFeedDataProvider {
    
    let club: Club
    let filter: FeedFilter
    
    init(club: Club, filter: FeedFilter) {
        self.club = club
        self.filter = filter
    }
    
}

extension ClubFeedDataProvider : FeedDataProvider {
    
    func loadBatch(_ batch: Batch) -> Observable<[FeedDataItem]> {
        
        let rout = FeedDisplayableRouter.feedOfClub(club: club, filter: filter, batch: batch)
        
        return Alamofire.request(rout)
            .rx_Response(Response<CityReportsMapping>.self)
            .map { response -> [FeedDataItem] in
                
                ///FIXME: parsing response into seperate entities must be encapsulated
                guard let clubsJSON = response.reports else {
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

extension FeedDataItem : IdentifiableType, RawRepresentable, Equatable {
    typealias Identity = String
    
    var identity: String {
        return self.rawValue
    }
    
    typealias RawValue = String
    init?(rawValue: RawValue) {
        return nil
    }
    
    var rawValue: RawValue {
        switch self {
        case .mediaType(let media):
            return "media \(media.id)"
        case .reportType(let report):
            return "report \(report.id)"
        }
    }
}

// equatable, this is needed to detect changes
func == (lhs: FeedDataItem, rhs: FeedDataItem) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

