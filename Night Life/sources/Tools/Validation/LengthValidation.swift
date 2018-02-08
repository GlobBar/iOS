//
//  LengthValidation.swift
//  Campfiire
//
//  Created by Vlad Soroka on 2/19/17.
//  Copyright © 2017 campfiire. All rights reserved.
//

import Foundation

struct LengthValidator: Validator {
    
    let min: Int
    let max: Int
    var explanation: String
    
    init(min: Int,
        max: Int,
        entityName: String) {
    
        self.min = min
        self.max = max
        
        self.explanation = "\(entityName.capitalized) should be at least \(min) and not longer than \(max) characters"
        
    }
    
    func validate(value: String) -> ValidationResult {
        let c = value.lengthOfBytes(using: .utf8)
        guard c >= min && c <= max else { return .invalid(reason: explanation) }
        
        return .valid
    }
    
}
