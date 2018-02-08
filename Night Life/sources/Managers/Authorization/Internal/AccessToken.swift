//
//  AccessToken.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/6/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

enum AccessToken {}
extension AccessToken {
    
    private static let accountName = "http://nightlifedev.gotests.com.v2"
    
    private static var tokenString: String? = nil
    
    static var token : String? {
        get {
            
            guard tokenString == nil else { return tokenString }
            
            guard let base64String = UserDefaults.standard.object(forKey: accountName) as? String,
                let decryptedData = Data(base64Encoded: base64String),
                let token = String(data: decryptedData, encoding: .utf8) else {
                    
                    return nil
                    
            }
            
            tokenString = token
            
            return tokenString
        }
        set {
            tokenString = newValue
            
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: accountName)
            }
            else {
                
                guard let data = newValue?.data(using: String.Encoding.utf8) else {
                    
                    return
                }
                
                let encryptedToken = data.base64EncodedString()
                
                UserDefaults.standard.setValue(encryptedToken, forKey: accountName)
            }
            
            UserDefaults.standard.synchronize()
        }
    }
    
}
