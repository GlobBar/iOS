//
//  CustomValidator.swift
//  Campfiire
//
//  Created by Vlad Soroka on 2/19/17.
//  Copyright © 2017 campfiire. All rights reserved.
//

import Foundation

struct CustomValidator<T>: Validator {
    
    let explanation: String
    let condition: (T) -> Bool
    
    func validate(value: T) -> ValidationResult {
        
        if condition(value) {
            return .valid
        }
        
        return .invalid(reason: explanation)
    }
}
