//
//  FacebookInvitationRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import Alamofire

enum FacebookInvitationRouter : AuthorizedRouter {
    
    case sendInvitation
    case updateToken(token: String)
    
}

extension FacebookInvitationRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self {
        case .sendInvitation:
            return self.authorizedRequest(.post,
                                          path: "/fb/post/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .updateToken(let token):
            return self.authorizedRequest(.put,
                                          path: "/fb/post/",
                                          encoding: URLEncoding.default,
                                          body: ["fb_token" : token])
        
        }
        
        
    }
    
}
