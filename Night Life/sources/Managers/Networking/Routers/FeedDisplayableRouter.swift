//
//  FeedDisplayableRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/26/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

enum FeedDisplayableRouter: AuthorizedRouter {
    
    case createReportForClub(report: Report, club: Club)
    
    case uploadPhoto
    case uploadVideo
    
    case feedOfClub(club: Club, filter: FeedFilter, batch: Batch)
    case feedOfCity(city: City, filter: FeedFilter, batch: Batch)
    
    case likeMedia(media: MediaItem)
 
    case updateMediaDescription
    
    case deleteMedia(media: MediaItem)
    
    case unlock(media: MediaItem)
}

extension FeedDisplayableRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self {
        
        case .createReportForClub(let report, let club):
            
            var reportJSON = Mapper().toJSON(report)
            reportJSON["place"] = club.id
            
            let request = self.authorizedRequest(.post,
                path: "report/",
                encoding: JSONEncoding.default,
                body: reportJSON
            )
            
            return request
            
        case .feedOfClub(let club, let filter, let batch):

            return self.authorizedRequest(.get,
                path: "places/\(club.id)/",
                encoding: URLEncoding.default,
                body: [
                    "limit_from" : batch.offset,
                    "limit_count" : batch.limit,
                    "period_filter" : filter.serverString()
                ])
        
        case .feedOfCity(let city, let filter, let batch):
            
            return self.authorizedRequest(.get,
                path: "city_reports/",
                encoding: URLEncoding.default,
                body: [
                    "filter_city" : city.id,
                    "limit_from" : batch.offset,
                    "limit_count" : batch.limit,
                    "period_filter" : filter.serverString()
                ])
            
        case .likeMedia(let media):
            
            return self.authorizedRequest(.post,
                                          path: "report/image/like/",
                                          encoding: URLEncoding.default,
                                          body: ["report_pk" : media.id])
            
        case .uploadVideo:
            
            return self.authorizedRequest(.post,
                                          path: "report/videos/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .uploadPhoto:
            
            return self.authorizedRequest(.post,
                                          path: "report/files/",
                                          encoding: URLEncoding.default,
                                          body:[:])
            
        case .updateMediaDescription:
            
            return self.authorizedRequest(.put,
                                          path: "report/files/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .deleteMedia(let media):
            
            return self.authorizedRequest(.delete,
                                          path: "report/",
                                          encoding: URLEncoding.default,
                                          body: [ "report_pk" : media.id ])
            
        case .unlock(let media):
            
            return self.authorizedRequest(.post,
                                          path: "users/media/donate/",
                                          encoding: URLEncoding.default,
                                          body: [ "report_pk" : media.id,
                                                  "amount": media.price ])
            
            
        }
        
    }
    
}
