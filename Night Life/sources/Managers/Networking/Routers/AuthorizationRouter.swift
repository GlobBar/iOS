//
//  AuthorizationRouter.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import Alamofire

enum AccessTokenRouter : AuthorizedRouter {
    
    /**
     *  Exchanges facebook/instagram token for NightLifeToken
     */
    case externalLogin(authData : RemoteAuthData)

    case signUp(username: String, password: String, email: String)
    
    case logIn(email: String, password: String)
}

extension AccessTokenRouter {
    
    func asURLRequest() throws -> URLRequest {
    
        switch self {
            
        case .externalLogin(let authData):
            
            return self.unauthorizedRequest(.post,
                                            path: "auth/convert-token/",
                                            encoding: URLEncoding.default,
                                            body: [
                                                "grant_type" : "convert_token",
                                                "client_id" : GatewayConfiguration.clientId,
                                                "client_secret" : GatewayConfiguration.clientSecret,
                                                "backend" : authData.backendIdentifier,
                                                "token" : authData.token
                ])
         
        case .logIn(let email, let password):
            
            return self.unauthorizedRequest(.post,
                                            path: "users/eml_login/",
                                            encoding: URLEncoding.default,
                                            body: ["email" : email,
                                                "password" : password,
                                                "client_id": GatewayConfiguration.clientId])
            
        case .signUp(let username, let password, let email):
            
            return self.unauthorizedRequest(.post,
                                            path: "users/eml_register/",
                                            encoding: URLEncoding.httpBody,
                                            body: ["email" : email,
                                                "username" : username,
                                                "password" : password,
                                                "client_id": GatewayConfiguration.clientId],
                                            headers: ["content-type": "application/x-www-form-urlencoded"])
            
        }
        
    }
    
}
