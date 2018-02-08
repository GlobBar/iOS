//
//  UserRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/16/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

enum UserRouter : AuthorizedRouter {
    
    /**
     *  Retreives information about user with given Id
     *  if no id passed - retreives information about currently logged in user
     *  authorized user is required
     */
    case info(userId :Int?)

    /**
     *  Retreives list of users which names satisfy given query
     */
    case list(filterQuery: String?)
    
    /**
     * Associate device token with currently logged in user
     */
    case linkDeviceToken(deviceToken: Data)

    /**
     * Unlink device token from currently logged in user
     */
    case unLinkDeviceToken
    
    /**
     * Endpoint for updating user's username and optionaly avatar using form data upload 
     */
    case update
    
    /**
     *  - Deletes profile
     */
    case deleteProfile
    
    
    case sendTestPush
}

extension UserRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self{
            
        case .info(let userId):
            
            var idComponent: String? = nil
            if let id = userId {
                idComponent = "\(id)"
            } else { idComponent = "me" }
            
            return self.authorizedRequest(.get,
                path: "users/\(idComponent!)/",
                encoding: URLEncoding.default,
                body: [:])
            
        case .list(let query):
            
            var body: [String: AnyObject] = [:]
            if let q = query {
                body["search"] = q as AnyObject?
            }
            
            return self.authorizedRequest(.get,
                path: "users/",
                encoding: URLEncoding.default,
                body: body)
            
        case .linkDeviceToken(let deviceToken):
            
            return self.authorizedRequest(.post,
                                          path: "dev_token/",
                                          encoding: URLEncoding.default,
                                          body: ["dev_token" : deviceToken.hexadecimalString])
            
        case .unLinkDeviceToken:
            
            return self.authorizedRequest(.delete,
                                          path: "dev_token/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .sendTestPush:
            
            return self.authorizedRequest(.put,
                                          path: "dev_token/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .update:
            
            return self.authorizedRequest(.post,
                                          path: "files/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .deleteProfile:
            
            guard let user = User.currentUser() else { fatalError("Can't delete User profile without logged in user") }
            
            return self.authorizedRequest(.delete,
                                          path: "users/\(user.id)",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        }
    }
    
}
