//
//  AppDelegate.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics

import Alamofire
import RxSwift

import AlamofireNetworkActivityLogger
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    ///FIXME: Profile application for memmory leaks
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Crashlytics.self])
        SwiftyStoreKit.completeTransactions(completion: { _ in })
        
        
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        
        UIConfiguration.setUp()
        
        MainRouter.sharedInstance.initialRoutForWindow(window)
        
        ///should be called after initial rout is established.
        ///application might have been launched from notification
        NotificationManager.setup(launchOptions)
        
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    ///notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.handleDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NotificationManager.handleLocalNotification(notification)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(application.applicationState)
        
        NotificationManager.handleRemoteNotification(userInfo, applicationState: application.applicationState)
    }
    
    //applicatio
}

