//
//  AuthorizationManager.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire


enum AuthorizationError : Error {
    
    case customError(description: String?)
    
}

enum AuthorizationManager { }
extension AuthorizationManager {
    
    static func loginUserWithRouter(_ router: AccessTokenRouter) -> Observable<String?> {
        
        return Alamofire
            .request(router)
            .rx_Response(Response<AccessTokenMapping>.self)
            .flatMap { resp -> Observable<String?> in
                
                guard let nightLifeAcessToken = resp.token else {
                    
                    let reason = resp.errorString
                    return Observable.error(AuthorizationError.customError(description: reason))
                    
                }
                
                AccessToken.token = nightLifeAcessToken
                return Observable.just(nightLifeAcessToken)
            }
        
    }
 
    static func currentUserDetails() -> Observable<[String : AnyObject]> {
        
        return Alamofire
            .request(UserRouter.info(userId: nil))
            .rx_Response(Response<CurrentUserMapping>.self)
            .map { $0.user }
            
    }
    
}
