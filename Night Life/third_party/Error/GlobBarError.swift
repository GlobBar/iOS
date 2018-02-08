//
//  CampfiireError.swift
//  Campfiire
//
//  Created by Vlad Soroka on 10/16/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import Foundation
import Alamofire

public enum GlobBarError: Error {
    
    case userCanceled
    
    case businessError(code: Int, serverMessage: String)
    
    case generic(description: String)
    case unknown
    
    public func shouldPresentError() -> Bool {
        switch self {
        case .userCanceled: return false
        default: return true
        }
    }
    
}

extension GlobBarError : CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            
        case .userCanceled: return ""
        case .unknown: return "We're sorry. Unknown error occured"
        case .generic(let descr): return descr
     
        case .businessError(let code, let serverMessage):
            
            if let m = GlobBarErrorStatusCode(rawValue: code)?.description {
                return m
            }
            
            return "Server generated error: " + serverMessage
            //return "We're sorry. Unknown error occured"
            
        }
    }
    
}
