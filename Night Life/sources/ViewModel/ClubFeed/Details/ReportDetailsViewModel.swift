//
//  ReportDetailsViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/3/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

typealias ReportData = (iconName: String, title: String, description: String)

struct ReportDetailsViewModel {
    
    let club: Club
    let report: Report
    
    let dataSource : [ReportData]
    
    init(club:Club, report: Report) {
        self.club = club
        self.report = report
        
        self.dataSource = ReportDetailsViewModel.populate([
            ("Party is On?", report.partyOnStatus),
            ("Waiting Line", report.queue),
            ("Cover Charge", report.coverCharge),
            ("Gender Ratio", report.genderRatio),
            ("Fullness", report.fullness),
            ("Music", report.musicType),
            ])
    }
    
    static fileprivate func populate(_ namedItems: [(String, (CustomStringConvertible & IconProvider)?)]) -> [ReportData] {
        
        return namedItems
            .filter { $0.1 != nil }
            .map{ ( $0.1!.iconName(), $0.0, $0.1!.description) }
        
    }
}
