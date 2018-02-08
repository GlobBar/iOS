//
//  CheckinContext.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/14/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

class CheckinContext {
    
    typealias Checkin = (clubId: Int, dueDate: Date)
    
    fileprivate static var checkins : [Checkin] = []
    
    class func drainAllCheckins() {
        checkins.removeAll()
    }
    
    class func registerCheckinInClub(_ club: Club, dueDate date:Date) {
        
        if let index = checkins.index(where: { $0.clubId == club.id }) {
            checkins.remove(at: index)
        }
        
        checkins.append((club.id, date))
    }

    class func isUserChekedInClub(_ club: Club) -> Bool {
        
        return checkins.index(where: {
                $0.clubId == club.id &&
                $0.dueDate.compare(Date()) == .orderedDescending
        }) != nil
        
    }
    
}
