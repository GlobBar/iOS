//
//  TodayDayManager.swift
//  GlobBar
//
//  Created by admin on 22.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

//class TodayDayManager: NSObject {
//
//}

extension Date {
    
    /**
     * Day of the week as string
     */
    var dayOfWeekText: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        let sevenHours: TimeInterval = 60 * 60 * 7 * -1 ///seven hours ago
        
        return dateFormatter.string(from: self.addingTimeInterval(sevenHours) )
    }
}
