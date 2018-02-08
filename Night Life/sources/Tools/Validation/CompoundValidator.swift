//
//  CompoundValidator.swift
//  Campfiire
//
//  Created by Vlad Soroka on 2/19/17.
//  Copyright © 2017 campfiire. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == ValidationResult {
    
    func validate() -> ValidationResult {
        
        let result = self.reduce("") { (reasons, v) in
            switch v {
            case .valid: return reasons
            case .invalid(let reason): return reasons + "\n" + reason
            }
        }
        
        guard result.lengthOfBytes(using: .utf8) == 0 else {
            return .invalid(reason: result)
        }
        
        return .valid
    }
    
}
