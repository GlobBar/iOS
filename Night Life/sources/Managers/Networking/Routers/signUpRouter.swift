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

enum SignUpRouter: AuthorizedRouter {

    
    
    case signUpWithEmail(email: String, username: String, password: String, clientId: String)
}

extension SignUpRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self{

        case .signUpWithEmail(let email, let username, let password, let clientId):

            return self.unauthorizedRequest(.post,
                                          path: "users/eml_register/",
                                          encoding: URLEncoding.default,
                                          body: ["email" : email, "username" : username, "password" : password, "client_id": clientId])
            
        }
    }
}
