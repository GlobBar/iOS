//
//  LiveMapViewModel.swift
//  Campfiire
//
//  Created by Vlad Soroka on 10/25/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import Foundation
import RxSwift
import MapKit
import RxCocoa

extension LiveMapViewModel {
    
    var annotations: Driver<[AnnotationWrapper]> {
        return clubs.asDriver()
            .map { $0.map { AnnotationWrapper(type: $0) } }
    }
    
    var presentVenue: Observable<ClubFeedViewModel> {
        return calloutViewModel.selectedClub
            .map { ClubFeedViewModel(club: $0) }
    }
    
}

struct LiveMapViewModel {
    
    weak var handler: UIViewController?
    init(handler: UIViewController) {
        
        self.handler = handler
        
        CityContext.selectedCity.asObservable()
            .notNil()
            .flatMapLatest { ClubsManager.clubListFromRouter( .inCity(city: $0,
                                                                      location: nil) ) }
            .bind(to: clubs)
            .disposed(by: bag)
        
        clubs.asObservable()
            .filter { $0.count > 0 }
            .map { $0.map({ $0.location.coordinate }).coordinateRegion() }
            .bind(to: visibleRegion)
            .disposed(by: bag)
        
    }
    
    fileprivate let clubs: Variable<[Club]> = Variable([])
    let visibleRegion = Variable<MKCoordinateRegion?>(nil) /// used for changing map visible region
    
    let calloutViewModel = ClubCalloutViewModel()
    
    fileprivate let bag = DisposeBag()
    
}

extension LiveMapViewModel {
    
    func annotationClicked(annotation: AnnotationWrapper) {
        
        let club = annotation.state as! Club
        
        calloutViewModel.switchClub(club)
    }

    func pinColorFor(annotation: AnnotationWrapper) -> UIColor {
        
        //let club = annotation.state as! Club
        
        //TODO: implement partner logic
//        let vowel: [Character] = ["t", "b"]
//        
//        let char: Character = club.name.lowercased()[club.name.startIndex]
        
        //return vowel.contains(char) ? UIColor.red : UIColor.blue
        return UIColor.blue
    }
    
}

extension Sequence where Iterator.Element == CLLocationCoordinate2D {
    
    func coordinateRegion() -> MKCoordinateRegion {
        
        let minLat = self.map { $0.latitude }.min()!
        let maxLat = self.map { $0.latitude }.max()!
        
        let minLon = self.map { $0.longitude }.min()!
        let maxLon = self.map { $0.longitude }.max()!
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2,
                                                                 longitude: (maxLon + minLon) / 2),
                                  span: MKCoordinateSpan(latitudeDelta: maxLat - minLat,
                                                         longitudeDelta: maxLon - minLon))
    }
    
}
