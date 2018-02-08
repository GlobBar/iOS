//
//  InMemmoryStore.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/6/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

protocol Storable {
    
    var identifier: Int { get }

    static var storage: [Int : Variable<Self>] { get set }
    
    //static func entity(descriptor: Self) -> Self?
    static func entityByIdentifier(_ identifier: Int) -> Self?
    static func observableEntityByIdentifier(_ identifier: Int) -> Variable<Self>?
    static func allEntities() -> [Variable<Self>]
    
    func observableEntity() -> Variable<Self>?
    func saveEntity()
    func removeFromStorage()
    
}

extension Storable {
    
    static func entityByIdentifier(_ identifier: Int) -> Self? {
        return self.storage[identifier]?.value
    }
    
    static func observableEntityByIdentifier(_ identifier: Int) -> Variable<Self>? {
        return self.storage[identifier]
    }
    
    static func allEntities() -> [Variable<Self>] {
        return Array(self.storage.values)
    }
    
    func observableEntity() -> Variable<Self>? {
        return Self.storage[identifier]
    }
    
    func saveEntity() {
        if let existingEntity = observableEntity() {
            existingEntity.value = self
        }
        else {
            let variable = Variable(self)
            Self.storage[identifier] = variable
        }
    }
    
    func removeFromStorage() {
        Self.storage.removeValue(forKey: identifier)
    }
    
}

extension User {
    static var storage: [Int : Variable<User>] = [ : ]
}

extension Club {
    static var storage: [Int : Variable<Club>] = [ : ]
}

extension Message {
    static var storage: [Int : Variable<Message>] = [ : ]
}

extension MediaItem {
    static var storage: [Int : Variable<MediaItem>] = [ : ]
}
