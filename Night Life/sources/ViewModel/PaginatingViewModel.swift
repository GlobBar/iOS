//
//  PaginatingViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

struct Batch {
    let offset:Int
    let limit:Int
}

protocol DataProvider {
    
    associatedtype DataType
    
    func loadBatch(_ batch: Batch) -> Observable<[DataType]>
}

class PaginatingViewModel<S: DataProvider> {
    
    fileprivate let dataProvider: S
    init(dataProvider: S) {
        self.dataProvider = dataProvider
    }
    
    func load
        (_ nextPageTrigger: Observable<Void>)
        -> Observable<[S.DataType]> {
        return recursivelyLoad(  [],
                    dataProvider: dataProvider,
                 nextPageTrigger: nextPageTrigger)
                .startWith([])
    }
    
}

extension PaginatingViewModel {
    
    fileprivate func recursivelyLoad
        (_ loadedSoFar: [S.DataType],
        dataProvider: S,
        nextPageTrigger: Observable<Void>) -> Observable<[S.DataType]> {
        
        return Observable.just(0)
            .subscribeOn(OperationQueueScheduler(operationQueue: OperationQueue()))
            .flatMap { _ in
                dataProvider.loadBatch(Batch(offset: loadedSoFar.count, limit: 10))
            }
            .flatMap { loadedNew -> Observable<[S.DataType]> in
                
                guard loadedNew.count > 0 else {
                    ///loaded everything we could
                    return Observable.empty()
                }
                
                var totalResults = loadedSoFar
                totalResults.append(contentsOf: loadedNew)
                
                return Observable
                    .concat([
                        // return loaded immediately
                        Observable.just(totalResults),
                        // wait until next page can be loaded
                        Observable.never().takeUntil(nextPageTrigger),
                        // load next page
                        self.recursivelyLoad(totalResults, dataProvider: dataProvider, nextPageTrigger: nextPageTrigger)
                        ])
                
        }
    }

}
