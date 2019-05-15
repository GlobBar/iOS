//
//  Photo.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/1/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

enum MediaItemType: Int {
    case photo = 1
    case video = 2
}

final class MediaItem : FeedDisplayable, Storable {
    
    var identifier: Int { return id }
    
    fileprivate(set) var thumbnailURL: String = ""
    fileprivate(set) var mediaURL: String = ""
    var mediaDescription: String = ""
    
    fileprivate(set) var isHot: Bool = false
    var likesCount: Int = 0
    
    fileprivate(set) var isLikedByCurrentUser: Bool = false
    
    fileprivate(set) var type: MediaItemType!
    
    var price: Int = 0 ///in cents
    var isLocked: Bool = false
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <- map["type"]
        
        thumbnailURL <- map["thumbnail"]
        mediaURL <- map["report_media"]
        mediaDescription <- map["description"]
        
        likesCount <- map["like_cnt"]
        isHot <- map["is_hot"]
        
        isLikedByCurrentUser <- map["is_liked"]
        
        price <- map["price"]
        isLocked <- map["is_locked"]
    }
    
    func setLikeStatusOn() {
        
        likesCount += 1
        isLikedByCurrentUser = true
        
    }
}
