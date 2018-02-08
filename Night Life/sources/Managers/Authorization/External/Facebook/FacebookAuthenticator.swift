//
//  FacebookAuthenticator.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/12/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import FBSDKLoginKit

enum FacebookError : Error {
    case userCanceled
    case internalError(error: NSError)
}

class FacebookAuthenticator : ExternalAuthenticator {

    static fileprivate let backendIdentifier = "facebook"
    
    func authenticateUser(onController maybeController: UIViewController?) -> Observable<RemoteAuthData> {
        
        guard let controller = maybeController else {
            return Observable.just( RemoteAuthData(token: "", backendIdentifier: FacebookAuthenticator.backendIdentifier) )
        }
        
        return Observable.create { observer in
            
            let manager = FBSDKLoginManager()
            
            manager.loginBehavior = .browser
            
            manager.logIn(withReadPermissions: ["public_profile", "email"], from: controller)  { (result, error) in
                
                if let e = error {
                    observer.onError(FacebookError.internalError(error: e as NSError))
                    return
                }
                
                guard let r = result, r.isCancelled == false else {
                    observer.onError(FacebookError.userCanceled)
                    return
                }
                
                observer.onNext(
                    RemoteAuthData(token: r.token.tokenString,
                    backendIdentifier: FacebookAuthenticator.backendIdentifier))
                observer.onCompleted()
                
            }
            
            return Disposables.create()
        }
    }
    
    static func reauthentiacteForPublishObservable(onController controller:UIViewController) -> Observable<RemoteAuthData> {
        
        return Observable.create { observer in
            
            let manager = FBSDKLoginManager()
            
            manager.loginBehavior = .browser
            
            manager.logIn(withPublishPermissions: ["publish_actions"], from: controller) {
                (result, error) in
                
                if let e = error {
                    observer.onError(FacebookError.internalError(error: e as NSError))
                    return
                }
                
                guard let r = result, r.isCancelled == false else {
                    observer.onError(FacebookError.userCanceled)
                    return
                }
                
                observer.onNext(
                    RemoteAuthData(token: r.token.tokenString,
                       backendIdentifier: FacebookAuthenticator.backendIdentifier))
                observer.onCompleted()
                
            }
            
            return Disposables.create()
        }

        
    }
    
}
