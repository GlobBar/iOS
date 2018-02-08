//
//  SideViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import Alamofire

import RxCocoa

import CoreLocation
import ObjectMapper

extension SideViewModel {
    
    var followersRequestCountHidden: Driver<Bool> {
        return followersRequestCountVar.asDriver()
            .map { $0 == 0 }
    }
    
    var followersRequestCount: Driver<String> {
        return followersRequestCountVar.asDriver()
            .map { "\($0)" }
    }
    
}

class SideViewModel {
    
    fileprivate(set) var cities : Variable<[City]> = Variable([])
    fileprivate let bag = DisposeBag()
    
    fileprivate let followersRequestCountVar = Variable(0)
    
    var currentCityName : Driver<String> {
        return CityContext.selectedCity.asDriver()
            .filter{ $0 != nil }
            .map{ $0!.name }
    }
    
    init() {
        
        ///every time app is opened
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIApplicationDidBecomeActive)
            .map { _ in true }
            .startWith(true)
            ///take one recorded location
            .flatMapLatest { _ in
                LocationManager.instance
                    .lastRecordedLocationObservable
                    .take(1)
            }
            ///filter it out if it's less than 10 km away
            .distinctUntilChanged { $0.distance(from: $1) < 10000 }
            ///select closest city
            .flatMap { location in
                Alamofire
                    .request(PlacesRouter.cities(baseLocation: location))
                    .rx_Response(Response<CitiesMapping>.self)
                    .map { response -> (Int, [City]) in
                        
                        guard let cities = response.cities,
                            cities.count > 0 else {
                                ///this should never happen in app lifecycle
                                fatalError("error recognizing server response structure")
                        }
                        
                        return (cities.first!.id, cities)
                }
            }
            .subscribe(onNext: { [unowned self] tuple in
                
                let currentCityId = tuple.0
                self.cities.value = tuple.1
                
                ///here goes super cool logic provided by backend
                ///every place JSON contains id of club it belong to
                ///so we have to manually select current city
                CityContext.selectedCity.value = tuple.1.filter({ $0.id == currentCityId }).first
                
            })
            .disposed(by: bag)

        ////messages
        MessagesContext.refreshMessages()
            .disposed(by: bag)
        
        ////initial followers request
        refeshFollowersCount()

    }
    
    func selectedCity(_ city: City) {
        
        CityContext.selectedCity.value = city
        
    }
 
}

extension SideViewModel {
    
    func refeshFollowersCount() {
        RelationshipManager.followersRequestCount()
            .bind(to: followersRequestCountVar)
            .disposed(by: bag)
    }
    
}
