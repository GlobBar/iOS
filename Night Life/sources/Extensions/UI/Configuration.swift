//
//  Configuration.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import CoreLocation

struct UIConfiguration {
    
    static func setUp() {
        ///setup any appearence proxies if neccesary
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
                NSAttributedStringKey.font : UIConfiguration.appSecondaryFontOfSize(16),
                NSAttributedStringKey.foregroundColor : UIColor.white
            ],
            for: UIControlState())
        
    }

    static func stringFromDate(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mma ccc c LLL y"
        
        return dateFormatter.string(from: date)
        
//        //  to lowercase PM/AM part of string
//        let startIndex = string.characters.index(string.startIndex, offsetBy: 5)
//        let endIndex = string.range(of: "M")?.upperBound
//     
//        let partPM_AMRange = Range<String.Index>(startIndex...endIndex!)
//        
//        let partPM_AM = string.substringWithRange(partPM_AMRange).lowercased()
//        
//        //  to upercase PM/AM part of string
//        let startIndex2 = <#T##String.CharacterView corresponding to your index##String.CharacterView#>.index(endIndex!, offsetBy: 1)
//        let endIndex2 = <#T##String.CharacterView corresponding to `startIndex2`##String.CharacterView#>.index(startIndex2, offsetBy: 3)
//        
//        let partDayOfWeekRange = Range<String.Index>(startIndex2...endIndex2)
//        
//        let partDayOfWeek = string.substringWithRange(partDayOfWeekRange).uppercased()
//        
//        // Replace parts in original string
//        string.replaceSubrange(partPM_AMRange, with: partPM_AM)
//        string.replaceSubrange(partDayOfWeekRange, with: partDayOfWeek)
//        
//        return string
    }
    
    
    /**
     * Roboto-regular
     */
    static func appFontOfSize(_ size: CGFloat) -> UIFont {
        
        return UIFont(name: "Roboto-Regular", size: size)!
        
    }
    
    /**
     * Raleway-regular
     */
    static func appSecondaryFontOfSize(_ size: CGFloat) -> UIFont {
        
        return UIFont(name: "Raleway-Regular", size: size)!
        
    }
    
    /**
     * Raleway-light
     */
    static func appSecondaryLightFontOfSize(_ size: CGFloat) -> UIFont {
        
        return UIFont(name: "Raleway-Light", size: size)!
        
    }
    
    static func naviagtionBarGradientLayer(forSize size: CGSize) -> CALayer {

        let to = UIColor(fromHex: 0xc53e03);
        let from = UIColor(fromHex: 0xf39200);
        
        let layer = CAGradientLayer()
            
        layer.colors = [from.cgColor, to.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.frame = CGRect(origin: CGPoint.zero, size: size)
        layer.opacity = 0.38
        
        let bottomLayer = CALayer()
        
        bottomLayer.backgroundColor = UIColor(fromHex: 0xf37000).cgColor
        bottomLayer.frame = layer.frame
        bottomLayer.addSublayer(layer)
        
        return bottomLayer;
    }
    
    static func gradientLayer(_ from: UIColor, to: UIColor) -> CALayer {
        let layer = CAGradientLayer()
        
        layer.colors = [from.cgColor, to.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.cornerRadius = 4
        
        return layer
    }
    
}

struct AppConfiguration {
    
    /**
     *  If user is within this distance from club it is assumed that user is inside the club
     */
    static let acceptableClubRadius: CLLocationDistance = 80
    
    /**
     *  If user is within this distance from club it is assumed that user is inside the club
     */
    static let invitationToClubRadius: CLLocationDistance = 50
    
    /**
     *  App is monitoring nearby clubs for user. If user moved within this value from location where monitoring was set up,
     *  app will recalculate it's monitored regions
     */
    static let recalculateRegionsRadius: CLLocationDistance = 12000
    
    static let maximumRecordedVideoDuration: TimeInterval = 10
    
    static let termsAndConditionsLink: String = GatewayConfiguration.hostName + "/terms_and_conditions/"
    static let privacyPolicyLink: String = GatewayConfiguration.hostName + "/privacy_policy/"
    
    static let clubInviteDelayTime: TimeInterval = 60 * 5
    
    /**
     * This date formatter matches format of dat that is passed from nightlife servers
     */
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return formatter
    }
    
}

extension CLLocationDistance {
    
    var metersToMiles: Double {
        return self / 1609.344
    }
    
}
