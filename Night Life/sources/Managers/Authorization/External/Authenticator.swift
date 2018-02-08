//
//  Authenticator.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/12/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

struct RemoteAuthData {
    let token: String
    let backendIdentifier: String
    
}

///Authenticate users within third party services. For example Facebook/Instaram 
///@param AuthData - specific data that identifies the user. For example - accessToken.
protocol ExternalAuthenticator {
    
    func authenticateUser(onController controller: UIViewController?) -> Observable<RemoteAuthData>
    
}