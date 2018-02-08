//
//  RegexValidator.swift
//  Campfiire
//
//  Created by Vlad Soroka on 2/19/17.
//  Copyright © 2017 campfiire. All rights reserved.
//

import Foundation

struct RegexValidator: Validator {
    
    let regEx: String
    let explanation: String
    
    func validate(value: String) -> ValidationResult {
        
        guard NSPredicate(format:"SELF MATCHES %@", regEx).evaluate(with: value) else {
            
            return .invalid(reason: explanation)
        }
        
        return .valid
    }
    
}
