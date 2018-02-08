//
//  NotificationManager.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

enum NotificationError : Error {
    case noAuthorizedUser
    case noTokenStored
}

class NotificationManager {

    fileprivate static let deviceTokenKey = "com.nighlife.deviceTokenKey"
    
    static func setup(_ launchOptions: [AnyHashable: Any]?) {
        
        let notificationSettings = UIUserNotificationSettings( types: [.alert, .sound], categories: nil )
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        if UserDefaults.standard.object(forKey: deviceTokenKey) == nil {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        
        if let localNotification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification
        {
            self.handleLocalNotification(localNotification)
        }
        
        //let fakePayload = ["data": ["type" : 5, "club_id" : 4] ]
        
        if let remoteNotificationPayload = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        {
            self.handleRemoteNotification(remoteNotificationPayload, applicationState: .inactive)
        }
        
    }
    
    static func handleDeviceToken(_ tokenData: Data) {
        
        UserDefaults.standard.set(tokenData, forKey: deviceTokenKey)
        UserDefaults.standard.synchronize()
        
        do { try saveDeviceToken() }
        catch { print("Can't save token now. Will try later") }
        
    }
    
    static func saveDeviceToken() throws {
        
        guard let _ = AccessToken.token else {
            throw NotificationError.noAuthorizedUser
        }
        
        guard let token = UserDefaults.standard.object(forKey: deviceTokenKey) as? Data else {
            throw NotificationError.noTokenStored
        }
        
        Alamofire.request(UserRouter.linkDeviceToken(deviceToken: token))
            .responseJSON { response in
                
                //print(response.result.value)
            }
        
    }
    
    static func flushDeviceToken() {
        
          Alamofire.request(UserRouter.unLinkDeviceToken)
            .responseJSON { response in
                //print(response.result.value)
        }
        
    }
    
}

enum NightlifeNotificationType {
    
    case newRequests
    case newCheckin
    case venueIsHot(clubId: Int)
    case venueNews
    
    case nearClub(clubId: Int, location: CLLocation)
    
    init?(type: Int, clubId: Int? = nil, location: CLLocation? = nil) {
        
        guard 1...5 ~= type else { return nil }
        
        switch type {
            
        case 1:
            self = .newRequests
            
        case 2:
            self = .newCheckin
            
        case 3:
            guard let id = clubId else { return nil }
            self = .venueIsHot(clubId: id)
            
        case 4:
            self = .venueNews
            
        case 5:
            guard let id = clubId, let l = location else { return nil }
            self = .nearClub(clubId: id, location: l)
            
        default:
            return nil
            
        }
        
    }
    
}

extension NotificationManager {
    
    static func handleLocalNotification(_ localNotification: UILocalNotification) {
        if let clubId           = localNotification.userInfo?["clubId"] as? Int,
           let latitude         = localNotification.userInfo?["lat"] as? CLLocationDegrees,
           let longitude        = localNotification.userInfo?["long"] as? CLLocationDegrees,
           let notificationType = NightlifeNotificationType(type: 5,
                                                            clubId: clubId,
                                                            location: CLLocation(latitude: latitude, longitude: longitude)) {
        
            MainRouter.sharedInstance.routForNotification(notificationType, verificationMessage: localNotification.alertBody)
            
        }
    }
    
    static func handleRemoteNotification(_ notificationPayload: [AnyHashable: Any], applicationState: UIApplicationState) {
        
        guard let data = notificationPayload["data"] as? [AnyHashable: Any],
              let payload = notificationPayload["aps"] as? [AnyHashable: Any],
              let typeNumber = data["type"] as? Int,
              let alertString = payload["alert"] as? String,
              let notification = NightlifeNotificationType(type: typeNumber, clubId: data["club_id"] as? Int) else {
                assert(false, "Error retreiving notification type from \(notificationPayload)")
                return
        }
        
        ///if app was active when notification arrived we'll present popup with alert string
        let verificationMessage: String? = applicationState == .active ? alertString : nil
        
        MainRouter.sharedInstance.routForNotification(notification, verificationMessage: verificationMessage)
        
    }
    
}
