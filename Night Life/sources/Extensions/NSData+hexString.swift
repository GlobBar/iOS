//
//  NSData+hexString.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/31/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

extension Data {
    
    public var hexadecimalString: NSString {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        
        return NSString(string: hexString)
    }
    
}
