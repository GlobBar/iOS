//
//  FeedDisplayable.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

class FeedDisplayable : Mappable {
    
    fileprivate(set) var id: Int = 0
    
    var postOwnerId: Int = 0
    fileprivate(set) var createdDate: Date?
    
    ///which club this report belongs to
    fileprivate(set) var clubId: Int?
    
    init(postOwner: User, createdDate: Date) {
        
        self.postOwnerId = postOwner.id
        self.createdDate = createdDate
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        
        postOwnerId <- map["owner.pk"]
        
        createdDate <- (map["created"], ISO8601DateTransform())
        id <- map["pk"]
        
        clubId <- map["place"]
    }
 
}


enum FeedDataItem {
    
    case mediaType(media: MediaItem)
    case reportType(report: Report)
    
    init?(feedItemJSON: [String: AnyObject], postOwner: User? = nil) {
        
        guard let type = feedItemJSON["type"] as? Int else {
            assert(false, "Can't create FeedDataItem without 'type' in dictionary")
            return nil
        }
        
        switch type {
        case 0:
            let mapper = Mapper<Report>()
            guard let report = mapper.map(JSON: feedItemJSON) else {
                assert(false, "Error parsing report object")
                return nil
            }
            
            if let user = postOwner { report.postOwnerId = user.id }
            
            self = .reportType(report: report)
            
        case 1, 2:
            let mapper = Mapper<MediaItem>()
            guard let media = mapper.map(JSON: feedItemJSON) else {
                assert(false, "Error parsing report object")
                return nil
            }
            
            if let user = postOwner { media.postOwnerId = user.id }
            
            self = .mediaType(media: media)
            media.saveEntity()
            
            
        default:
            fatalError("type of FeedData item \(type) is not handled")
        }
        
        
        
    }
    
}
