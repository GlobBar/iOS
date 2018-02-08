//
//  FeedFilter.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

enum FeedFilter: Int {
    
    case today = 0
    case lastWeek
    case lastMonth
    
    func serverString() -> String {
        switch self {
        case .today:
            return "today"
        case .lastWeek:
            return "week"
        case .lastMonth:
            return "month"
        }
    }
    
}
