//
//  UserStorage.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/10/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper

struct e_storage_state {
    
    static let e_storage_key = "com.ermineAuthentication.User"
    static var e_cur_user_id : Int? = nil
    
}

extension UserProtocol {
    
    func saveLocally() -> Void {
        
        let data = Mapper().toJSONString(self)
        
        ///updating base identifier value
        e_storage_state.e_cur_user_id = self.identifier
        
        ///updating User storage value to notify parties about changes
        self.saveEntity()
        
        UserDefaults.standard.set(data, forKey: e_storage_state.e_storage_key)
        UserDefaults.standard.synchronize()
    }

    
    static func loginWithData(_ data: AnyObject) -> Self {
        
        let mapper : Mapper<Self> = Mapper()
        
        guard let user = mapper.map(JSON: data as! [String : Any])
            else {
                assert(false, "Couldn't map json to User. Please check mapping between JSON and User");
                return self.currentUser()!
        }
        user.saveLocally()
        
        return user
        
    }
    
    static func currentUser() -> Self? {
        
        if let currentUserId = e_storage_state.e_cur_user_id,
           let user = User.entityByIdentifier(currentUserId) {
            return user as? Self
        }
        
        guard let storedValue = UserDefaults.standard.object(forKey: e_storage_state.e_storage_key) as? String else {
            return nil
        }
        
        let mapper : Mapper<Self> = Mapper()
        guard let cachedUser = mapper.map(JSONString: storedValue) else {
            fatalError("Disk user entry is incompatible with Mappable model")
        }
        e_storage_state.e_cur_user_id = cachedUser.identifier
        cachedUser.saveEntity()
        
        return cachedUser
    }
    
    func logout() {
        User.currentUser()?.removeFromStorage()
        
        e_storage_state.e_cur_user_id = nil
        
        UserDefaults.standard.removeObject(forKey: e_storage_state.e_storage_key)
        UserDefaults.standard.synchronize()
    }
    
}
