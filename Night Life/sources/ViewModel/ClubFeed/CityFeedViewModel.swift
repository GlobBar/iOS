//
//  CityFeedViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CityFeedViewModel {
    
    let feedViewModel: FeedViewModel = FeedViewModel()
    
    let disposeBag = DisposeBag()
    
    let titleObservable : Observable<String>
    
    init() {
        
        let cityObservable = CityContext.selectedCity.asObservable()
            .filter { $0 != nil }.map { $0! }
        
        let filterObservaable = filterIndex.asObservable()
            .filter { $0 != nil }.map { $0! }
            .map { FeedFilter(rawValue: $0)! }
        
        Observable.combineLatest(cityObservable, filterObservaable) { CityFeedDataProvider(city: $0, filter: $1) }
            .bind(to: feedViewModel.dataProvider)
            
.disposed(by: disposeBag)
        
        titleObservable = cityObservable.map { $0.name }

    }
    
    fileprivate let filterIndex: Variable<Int?> = Variable(nil)
    func filterAtIndexSelected(_ index: Int) {
        filterIndex.value = index
    }
    
}
