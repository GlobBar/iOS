//
//  Club.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper
import RxDataSources

import CoreLocation

struct Club : Mappable, Storable {
    
    fileprivate(set) var id: Int = 0
    var identifier: Int { return id }
    
    var name: String = ""

    var adress: String = ""
    var description: String = ""

    var logoImageURL : String = ""
    var coverPhotoURL: String = ""

    var latitude : String = ""
    var longtitude : String = ""
    
    var location: CLLocation {
        guard let lat = Double(latitude),
              let long = Double(longtitude) else {
                assert(false, "Error retreiving location. Check club with id=\(id)")
                return CLLocation()
        }
        
        return CLLocation(latitude: lat, longitude: long)
    }
    
    var clubDescriptors: ClubDescriptors = ClubDescriptors()
    
    var likesCount: Int = 0
    var checkinsCount: Int = 0
    var placeId: Int = 0
    
    ///these are descriptors rathaer than actual User. 
    ///Query UserStorage to retreive actual values
    var lastCheckedInUsers : [User] = []
    
    ///thanks to backend responce structure each of the clubs have
    ///these checkin related fields that are really of no use as part of our club value
    fileprivate var myCheckin: Bool = false
    fileprivate var dueDate: Date = Date(timeIntervalSince1970: 0)
    
    var isLikedByCurrentUser: Bool = false
    
    init(id: Int) {
        self.id = id
    }
    
    init?(map: Map) {
        mapping(map: map)
        
        ///updating checkin status of current user
        if myCheckin { CheckinContext.registerCheckinInClub(self, dueDate: dueDate) }
            
    }
    
    mutating func mapping(map: Map) {
        id <- map["pk"]
        name <- map["title"]
        adress <- map["address"]
        description <- map["description"]
        latitude <- map["latitude"]
        longtitude <- map["longitude"]
        
        logoImageURL <- map["place_logo"]
        coverPhotoURL <- map["place_image"]
        
        clubDescriptors.openingHours <- map["opening_hours"]
        clubDescriptors.musicType <- map["music_type"]
        clubDescriptors.ageGroup <- map["age_group"]
        
        likesCount <- map["like_cnt"]
        checkinsCount <- map["checkin_cnt"]
        
        lastCheckedInUsers <- map["last_users"]
        
        placeId <- map["city_pk"]
        
        myCheckin <- map ["my_check_in.is_my"]
        dueDate <- (map["my_check_in.expired"], ISO8601DateTransform())
        
        isLikedByCurrentUser <- map["is_liked"]
    }
    
}

extension Club {
    
    mutating func checkInUser() {
        
        let user = User.currentUser()!
        var set: Set<User> = Set(self.lastCheckedInUsers)
        set.insert(user)
        
        if set.count != self.lastCheckedInUsers.count {
            self.checkinsCount+=1
        }
        
        self.lastCheckedInUsers = Array(set)
    }
    
    mutating func switchLikeStatus() {
        
        if self.isLikedByCurrentUser {
            self.isLikedByCurrentUser = false
            self.likesCount -= 1
        }
        else {
            self.isLikedByCurrentUser = true
            self.likesCount += 1
        }

    }
    
}

extension Club : IdentifiableType, Equatable {
    
    typealias Identity = String
    
    var identity: String {
        return "\(id)"
    }
    
}

// equatable, this is needed to detect changes
func == (lhs: Club, rhs: Club) -> Bool {
    return lhs.id == rhs.id
}

extension Club : GlobBarMapAnnotation {
    var coordinate: CLLocationCoordinate2D { return location.coordinate }
    
    var annotationTitle: String? { return name }
    var annotationSubtitle: String? { return nil }
    
}
