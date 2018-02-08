//
//  MainClubListViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa

import Alamofire
import ObjectMapper

class CityClubListViewModel {
    
    var title : Driver<String> {
        return CityContext.selectedCity.asDriver()
            .map{ $0?.name ?? "List of Places" }
    }
    
    let clubsViewModel = ClubListViewModel()
    let bag = DisposeBag()
    
    init() {
        
        Observable.combineLatest(CityContext.selectedCity.asObservable(),
                                 NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive)
                                    .map { _ in true }
                                    .startWith(true)
        ) {
                        (city, _) -> City? in return city
            }
            .notNil()
            .map { .inCityNew(city: $0, location: LocationManager.instance.lastRecordedLocation) }
            .bind(to: clubsViewModel.clubsRouter)
            .disposed(by: bag)
        
    }
}
    
