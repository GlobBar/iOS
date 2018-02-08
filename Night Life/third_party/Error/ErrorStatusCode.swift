//
//  ErrorStatusCodes.swift
//  Campfiire
//
//  Created by Andrew Seregin on 10/31/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import Foundation

enum GlobBarErrorStatusCode: Int {
    
    case objectWithIdNotFound = 400 /// when requesting resource with not existing id
    
}

extension GlobBarErrorStatusCode {
    
    public var description: String? {
        switch self {
            
            default: return nil
            
        }
    }
    
}
