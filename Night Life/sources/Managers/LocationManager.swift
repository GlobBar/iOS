//
//  LocationManager.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa
import RxCoreLocation

class LocationManager {
    
    static var instance = LocationManager()
    
    fileprivate let manager = CLLocationManager()
    fileprivate let warningView = Bundle.main.loadNibNamed("GeoWarning", owner: nil, options: [:])!.first! as! UIView
    
    fileprivate let lastRecordedLocationVar = Variable<CLLocation?>(nil)
    
    lazy var lastRecordedLocationObservable: Observable<CLLocation> = {
        
        self.startMonitoring()
        
        let trueLocation = self.manager.rx.didUpdateLocations
            .map { $0.locations }
            .filter { $0.count > 0 }
            .map { $0.last! }
        
        let fakeLocation = self.fakeLocation.asObservable()

        return Observable.combineLatest(trueLocation, fakeLocation) { trueLoc, fakeLoc in
            return fakeLoc ?? trueLoc
        }
        .share(replay: 1)
        .do(onNext: { [unowned self] l in
            self.lastRecordedLocationVar.value = l
        })
        
    }()

    var lastRecordedLocation: CLLocation? {
        return lastRecordedLocationVar.value
    }
    
    var fakeLocation: Variable<CLLocation?> = Variable(nil)
    
    fileprivate func startMonitoring() {
        
        let _ =
        manager.rx.didChangeAuthorization
            .subscribe(onNext:{ [unowned self] x in
                
                let m = x.manager
                let e = x.status
                
                switch (e) {
                    
                case .denied:
                    self.presentRestrictionView()
                    
                case .notDetermined: fallthrough    ///here we should present introduction on why we need his location
                case .authorizedAlways: fallthrough
                case .authorizedWhenInUse: fallthrough
                case .restricted: fallthrough
                default:
                    ///hide warning window if any present
                    self.hideView()
                    m.startUpdatingLocation()
                    
                    self.setupRegionHandling()
                    self.startRegionMonitoring()
                    
                }

            })
        
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = kCLDistanceFilterNone
    }
    
    func endMonitoring() {
        for r in manager.monitoredRegions {
            manager.stopMonitoring(for: r)
        }
    }
    
    fileprivate func presentRestrictionView() {
        
        let window = UIApplication.shared.windows.first!
        
        
        let view = warningView
        view.frame = window.bounds

        window.addSubview(warningView)
        
    }
    
    fileprivate func hideView() {
        warningView.removeFromSuperview()
    }
}

extension LocationManager {
    
    fileprivate static let lastBaseLocationKey = "com.nightlife.lastBaseLocationKey.v2"
    
    fileprivate var lastBaseLocation: CLLocation? {
        get {
            guard let dict = UserDefaults.standard.object(forKey: LocationManager.lastBaseLocationKey) as? [String : CLLocationDegrees] else {
                return nil
            }
            
            return CLLocation(latitude: dict["lat"]!, longitude: dict["long"]!)
        }
        set {
            
            if let location = newValue {
            
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                let value = ["lat":lat,"long":lon]
                
                UserDefaults.standard.set(value, forKey: LocationManager.lastBaseLocationKey)
                
            }
            else {
                UserDefaults.standard.setNilValueForKey(LocationManager.lastBaseLocationKey)
            }
            
            
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate var lastNotificationDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "com.erminesoft.lastNotificationDate") as? Date
        }
        set {
            
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: "com.erminesoft.lastNotificationDate")
                
            }
            else {
                UserDefaults.standard.set(nil, forKey: "com.erminesoft.lastNotificationDate")
            }
            
            
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate func startRegionMonitoring() {
        
        
        let _ =
        lastRecordedLocationObservable
            .filter { [unowned self] newLocation in
                guard let l = self.lastBaseLocation else { return true }
                
                return l.distance(from: newLocation) > AppConfiguration.recalculateRegionsRadius
            }
            .flatMapLatest { [unowned self] newBaseLocation -> Observable<[Club]> in
                self.lastBaseLocation = newBaseLocation
                
                return ClubsManager
                    .clubListFromRouter(ClubListRouter.nearest(location: newBaseLocation))
                    .map{ clubs in
                        clubs.filter { $0.location.distance(from: newBaseLocation) < AppConfiguration.recalculateRegionsRadius }
                    }
            }
            
            .subscribe(onNext: { [unowned m = self.manager] clubs in
                for region in m.monitoredRegions {
                    m.stopMonitoring(for: region)
                }
                
                for club in clubs {
                    m.startMonitoring(for: CLCircularRegion(center: club.location.coordinate,
                                                            radius: AppConfiguration.invitationToClubRadius,
                                                            identifier: "\(club.id)"))
                }
            })
        
    }
    
    fileprivate func setupRegionHandling () {
        
        let _ =
        manager.rx.didReceiveRegion
            .filter { $0.state == .enter }
            .map { $0.region }
            .filter { [unowned self] region in
                
                guard let lastDate = self.lastNotificationDate else {
                    return true
                }
                
                return lastDate.timeIntervalSinceNow * -1 > 3600 * 12 //true //
                
            }
            .filter{ _ -> Bool in
                
                ///receive notifications only from 9 pm to 3 am
                
                let hour = NSCalendar.current.component(Calendar.Component.hour, from: Date())
                
                return hour > 20 || hour < 3 //true //
            }
            .flatMapFirst { region -> Observable<Club> in
                ClubsManager.clubForId(Int(region.identifier)!)
            }
            .subscribe(onNext: { [unowned self] club in
                
                ///last notification triggered wins
                if let notifications = UIApplication.shared.scheduledLocalNotifications {
                    
                    notifications.filter { ($0.userInfo?["clubId"] as? Int) != nil }
                        .forEach { UIApplication.shared.cancelLocalNotification($0) }
                    
                }
                
                let notificationDate = Date(timeIntervalSinceNow: AppConfiguration.clubInviteDelayTime)
                self.lastNotificationDate = notificationDate
                
                let notificatio = UILocalNotification()
                notificatio.alertBody = "You are near \(club.name). Check in and submit a report!"
                notificatio.userInfo = ["clubId" : club.id,
                                        "lat" : club.location.coordinate.latitude,
                                        "long" : club.location.coordinate.longitude]
                
                notificatio.fireDate = notificationDate
                UIApplication.shared.scheduleLocalNotification(notificatio)
        })
        
        let _ =
        manager.rx.didReceiveRegion
            .filter { $0.state == .enter }
            .map { $0.region }
            .subscribe(onNext: { (region) in
            
                guard let notifications = UIApplication.shared.scheduledLocalNotifications else { return }
                guard let regionsClub = Int(region.identifier) else { return }
                
                let maybeNotification =
                notifications.filter({ (notification) -> Bool in
                    
                    guard let clubId = notification.userInfo?["clubId"] as? Int else { return false }
                    
                    return clubId == regionsClub
                }).first
                
                guard let n = maybeNotification else { return }
                self.lastNotificationDate = nil
                
                UIApplication.shared.cancelLocalNotification(n)
            
        })
        
    }
}
