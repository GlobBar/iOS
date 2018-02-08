//
//  CatchError.swift
//  Campfiire
//
//  Created by Vlad Soroka on 10/15/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import RxSwift

enum Result<T> {
    case value(val: T)
    case error(er: Error)
}

extension ObservableConvertibleType {

    private var identifier : String { return "com.campfiire.rx.extensions.erroridentifier" }
    
    func silentCatch<T: CanPresentMessage>
        (handler: T?) -> Observable<E> where T: AnyObject {
        
        return self.asObservable()
            .map { Result.value(val: $0) }
            .catchError { [weak h = handler] (error) -> Observable<Result<E>> in
                
                h?.presentError(error: error)
                
                return Observable.just(Result.error(er: error))
            }
            .filter {
                switch $0 {
                case .value(_): return true
                case .error: return false
                }
                
            }
            .map {
                switch $0 {
                case .value(let val): return val
                case .error: fatalError("Shouldn't have recovered from filter")
                }
        }
    }

    func silentCatch() -> Observable<E> {
        return self.silentCatch(handler: nil as MockCanPresentMessage?)
    }
    
}

private class MockCanPresentMessage : NSObject, CanPresentMessage {
    func presentMessage(message: DisplayMessage) {}
}


