//
//  MessageListRouter.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import Alamofire

enum MessagesRouter : AuthorizedRouter {
    
    case list
    case messageDetails(id: Int)
    case delete(message: Message)
    case markRead(message: Message)
    
}

extension MessagesRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        switch self {
            
        case .list:
            
            return self.authorizedRequest(.get,
                                          path: "messages/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
            
        case .messageDetails(let pk):
            
            return self.authorizedRequest(.get,
                                          path: "messages/\(pk)/",
                                          encoding: URLEncoding.default,
                                          body: [:])
            
        case .delete(let message):
            
            return self.authorizedRequest(.delete,
                                          path: "messages/",
                                          encoding: JSONEncoding.default,
                                          body: ["message_pk" : message.id])
            
        case .markRead(let message):
            
            return self.authorizedRequest(.post,
                                          path: "messages/is_readed/",
                                          encoding: URLEncoding.default,
                                          body: [
                                            "message_pk" : message.id
                                                ])
            
        }
    }
    
}
