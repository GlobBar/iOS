//
//  ValidatorProtocol.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/30/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import Foundation

enum ValidationResult {
    case valid
    case invalid( reason: String )
    
    var isValid: Bool {
        switch self {
        case .valid: return true
        default: return false
        }
    }
}

protocol Validator {
    associatedtype T
    
    func validate(value: T) -> ValidationResult
}
