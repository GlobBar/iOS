//
//  Report.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

class Report : FeedDisplayable {
    
    fileprivate(set) var partyOnStatus: PartyStatus?
    fileprivate(set) var fullness: Fullness?
    fileprivate(set) var musicType: Music?
    fileprivate(set) var genderRatio: GenderRatio?
    fileprivate(set) var coverCharge: CoverCharge?
    fileprivate(set) var queue: QueueLine?
    
    init(partyOnStatus: PartyStatus?, fullness: Fullness?, musicType: Music?, genderRatio: GenderRatio?, coverCharge: CoverCharge?, queue: QueueLine?) {
        
        self.partyOnStatus = partyOnStatus
        self.fullness = fullness
        self.musicType = musicType
        self.genderRatio = genderRatio
        self.coverCharge = coverCharge
        self.queue = queue
        
        super.init(postOwner: User.currentUser()!, createdDate: Date())
        
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        partyOnStatus <- (map["is_going"], Report.partyStatusTransform())
        fullness <- map["bar_filling"]
        musicType <- map["music_type"]
        genderRatio <- map["gender_relation"]
        coverCharge <- map["charge"]
        queue <- map["queue"]
    }
    
    static func partyStatusTransform() -> TransformOf<PartyStatus, Bool> {
        return TransformOf(fromJSON: { (bool: Bool?) -> PartyStatus? in
            guard let b = bool else { return nil }
            
            return PartyStatus(bool: b)
            }, toJSON: { (status :PartyStatus?) -> Bool? in
                guard let b = status else { return nil }
                
                return b == .yes
        })
    }
    
}

extension Report : CustomStringConvertible {
    
    fileprivate func stringValue(_ opts: [CustomStringConvertible?]) -> String {
        var str = ""
        
        for optional in opts {
            if let o = optional {
                str.append(o.description)
            }
        }
        
        return str
    }
    
    var description : String {
        let array: [CustomStringConvertible?] = [partyOnStatus, fullness, musicType, genderRatio, coverCharge, queue]
        return stringValue(array)
    }
    
}

protocol IconProvider {
    func iconName() -> String
}

enum PartyStatus : Int, CustomStringConvertible, IconProvider {
    
    case yes = 1
    case no
    
    init(bool: Bool) {
        self = bool ? .yes : .no
    }
    
    var description: String {
        switch self {
        case .yes:
            return "Party is on!"
        case .no:
            return "No"
        }
    }
    
    func iconName() -> String {
        return "recommends"
    }
    
}

enum Fullness : Int, CustomStringConvertible, IconProvider {
    case empty = 1
    case low
    case crowded
    case packed
    
    var description: String {
        switch self {
        case .empty:
            return "Empty"
        case .low:
            return "Slow"
        case .crowded:
            return "Crowded"
        case .packed:
            return "Packed"
        }
    }
    
    func iconName() -> String {
        return "fullness"
    }
    
}

enum Music : Int, CustomStringConvertible, IconProvider {
    
    case noMusic = 1
    case dj_EDM_House
    case dj_disco
    case dj_hip
    case pop
    case liveBand
    case karaoke
    case other
    
    var description: String {
        switch self {
        case .noMusic:
            return "None"
        case .dj_EDM_House:
            return "DJ-EDM/House"
        case .dj_disco:
            return "DJ-disco"
        case .dj_hip:
            return "DJ-hip hop"
        case .pop:
            return "DJ-top 40"
        case .liveBand:
            return "Live Band"
        case .karaoke:
            return "Karaoke"
        case .other:
            return "Other"
        }
    }
    
    func iconName() -> String {
        return "music"
    }
    
}

enum GenderRatio : Int, CustomStringConvertible, IconProvider {
    case mostlyGuys = 1
    case moreGuys
    case balanced
    case moreLadies
    case mostlyLadies
    
    var description: String {
        switch self {
        case .mostlyGuys:
            return "Mostly Guys"
        case .moreGuys:
            return "More Guys"
        case .balanced:
            return "Balanced"
        case .moreLadies:
            return "More Ladies"
        case .mostlyLadies:
            return "Mostly Ladies"
        }
    }
    
    func iconName() -> String {
        return "gender"
    }
    
}

enum CoverCharge : Int, CustomStringConvertible, IconProvider  {
    case free = 1
    case small
    case moderete
    case big
    
    var description: String {
        switch self {
        case .free:
            return "Free"
        case .small:
            return "1-5$"
        case .moderete:
            return "10$"
        case .big:
            return "Over 10$"
        }
    }
    
    func iconName() -> String {
        return "cover_chardge"
    }
    
}

enum QueueLine : Int, CustomStringConvertible, IconProvider  {
    case noQueue
    case short
    case long
    case enormous
    
    var description: String {
        switch self {
        case .noQueue:
            return "No line"
        case .short:
            return "Less than 10 people"
        case .long:
            return "Long"
        case .enormous:
            return "Extra long"
        }
    }
    
    func iconName() -> String {
        return "queue"
    }
    
}
