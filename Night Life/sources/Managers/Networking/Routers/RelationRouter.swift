//
//  RelationRouter.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import Alamofire

enum RelationType : String {
    case request = "request"
    case following = "following"
    case follower = "follower"
}

enum RelationRouter : AuthorizedRouter {
    
    case postRelation(user: User, type: RelationType, createAction: Bool)
    
    case followRequests
    case followers
    case following
    
    case requestCount
}

extension RelationRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self{
        case .postRelation(let user, let type, let createAction):
            
            return self.authorizedRequest(.post,
                path: "relation/",
                encoding: URLEncoding.default,
                body: [
                    "friend_pk" : user.id,
                    "relation_type" : type.rawValue,
                    "is_create" : createAction ? "true" : "false"
                ])
            
        case .followRequests:
            
            return self.authorizedRequest(.get,
                                          path: "requests/",
                                          encoding: URLEncoding.default,
                                          body: [:])
        case .followers:
            
            return self.authorizedRequest(.get,
                                          path: "followers/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .following:
            
            return self.authorizedRequest(.get,
                                          path: "followings/",
                                          encoding: URLEncoding.default,
                                          body: [:])
         
        case .requestCount:
            
            return self.authorizedRequest(.get,
                                          path: "requests/count/")
            
        }
    }
}
