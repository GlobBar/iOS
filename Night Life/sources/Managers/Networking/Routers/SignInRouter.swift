//
//  SignUpRouter.swift
//  GlobBar
//
//  Created by admin on 16.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import Alamofire


import ObjectMapper

enum SignInRouter: AuthorizedRouter {
    
    case signInWithEmail(email: String, password: String, clientId: String)
}

extension SignInRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self{
            
        case .signInWithEmail(let email, let password, let clientId):
            
            return self.unauthorizedRequest(.post,
                                            path: "users/eml_login/",
                                            encoding: URLEncoding.default,
                                            body: ["email" : email, "password" : password, "client_id": clientId])
        }
    }
}
