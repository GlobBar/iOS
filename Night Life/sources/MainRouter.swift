//
//  RootViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/5/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController
import CoreLocation

/**
 *  Responsible for routing between Main Application controller and Authorization controller
*/

class MainRouter: NSObject {
    
    static var sharedInstance = MainRouter()
    
    fileprivate weak var window: UIWindow?
     var rootViewController: UINavigationController {
        get {
            return window?.rootViewController as! UINavigationController
        }
    }
    
    fileprivate var authorizationController: AuthorizationViewController {
        get {
            return mainStoryboard.instantiateViewController(withIdentifier: "AuthorizationController") as! AuthorizationViewController
        }
    }
    
    fileprivate lazy var mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    fileprivate lazy var topControllerStoryboard = UIStoryboard(name: "ClubList", bundle: nil)
    fileprivate lazy var clubFeedStoryboard = UIStoryboard(name: "ClubFeed", bundle: nil)
    
    func initialRoutForWindow(_ window: UIWindow?) {
        self.window = window
        window?.makeKeyAndVisible()
        
        rootViewController.isNavigationBarHidden = true
        
        if let _ = AccessToken.token {
            mainAppScreenRout(false)
        }
        else {
            authorizationRout()
        }
    }
   
    func mainAppScreenRout(_ animated: Bool = false) {
        
        //TODO: work on transition animation
        let revealController = self.mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        revealController.delegate = self
        
        let sideViewController = self.mainStoryboard.instantiateViewController(withIdentifier: "side view controller")
        revealController.setRear(sideViewController, animated: false)
        
        let topViewController = self.topControllerStoryboard.instantiateInitialViewController()!
        revealController.setFront(topViewController, animated: false)
        
        self.rootViewController.setViewControllers([revealController], animated: animated)
    }
    
    func authorizationRout(_ animated: Bool = false) {
        
        let controller = mainStoryboard.instantiateViewController(withIdentifier: "AuthorizationController")
        rootViewController.setViewControllers([controller], animated: animated)
        
    }
}

extension MainRouter { ///Notification Routes
    
    func routForNotification(_ notification: NightlifeNotificationType, verificationMessage: String?) {
        
        guard let _ = AccessToken.token else {
            print("WARNING: Will do nothing with notification rout, since there're no logged in user")
            return
        }
        
        var routClosure: ( ()->() )? = nil
        
        switch notification{
            
        case .newRequests:
            routClosure = { self.newRequestsNotificationRout() }
            
        case .venueIsHot(let clubId):
            routClosure = { self.venueIsHotNotificationRout(clubId) }
            
        case .nearClub(let clubId, let location):
            routClosure = { self.closeToVenueNotificationRout(clubId, venueLocation: location) }
            
        case .newCheckin: fallthrough
        case .venueNews: break;
            
        }
        
        if let message = verificationMessage { /// we need do present popup with message prior to rout
            
            guard let rout = routClosure else { ///if there're no routs, just fire popup and forget
                revealViewController().showInfoMessage(withTitle: "", message, "Got it")
                return
            }
            
            ///asking question on whether we need to perform rout
            revealViewController().showSimpleQuestionMessage(withTitle: "", message, { 
                rout()
            })
        }
        else {
            
            ///performin rout if any
            routClosure?()
            
        }
        
    }
    
    fileprivate func revealViewController() -> SWRevealViewController {
        
        guard let revealController = rootViewController.viewControllers.first as? SWRevealViewController else {
            fatalError("Please update logic for updated controllers hierarchy")
        }
        
        return revealController
    }
    
    fileprivate func newRequestsNotificationRout() {
        
        self.revealViewController().rearViewController.performSegue(withIdentifier: "followers segue", sender: nil)
        
    }
 
    fileprivate func closeToVenueNotificationRout(_ clubId: Int, venueLocation: CLLocation) {
        
        guard let navigationController = revealViewController().frontViewController as? UINavigationController,
              let feedController = clubFeedStoryboard.instantiateInitialViewController() as? ClubFeedViewController else {
            fatalError("Cannot present 'close to venue' root without navigation controller")
        }
        
        let _ =
        LocationManager.instance.lastRecordedLocationObservable
            .take(1)
            .subscribe(onNext: { location in
                let viewModel = ClubFeedViewModel(club: Club(id: clubId),
                    startFromCheckin: location.distance(from: venueLocation) < AppConfiguration.acceptableClubRadius)
                
                feedController.viewModel = viewModel
                
                navigationController.setViewControllers([feedController], animated: false)
            })
        
    }
    
    fileprivate func venueIsHotNotificationRout(_ clubId: Int) {
        
        guard let navigationController = revealViewController().frontViewController as? UINavigationController,
            let feedController = clubFeedStoryboard.instantiateInitialViewController() as? ClubFeedViewController else {
                fatalError("Cannot present 'venue is hot' root without navigation controller")
        }
        
        let viewModel = ClubFeedViewModel( club: Club(id: clubId) )
        feedController.viewModel = viewModel
        
        navigationController.setViewControllers([feedController], animated: false)
        
    }
}

extension MainRouter: SWRevealViewControllerDelegate {

    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {

        let _ = revealController.panGestureRecognizer()
        
        if let controller = revealController.frontViewController as? UINavigationController,
           let topController = controller.childViewControllers.last {
            
            topController.view.isUserInteractionEnabled = position != FrontViewPosition.right
        }
    }
}

