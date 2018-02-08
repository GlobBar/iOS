//
//  MapAnnotationSwift.swift
//  GlobBar
//
//  Created by Vlad Soroka on 10/26/16.
//  Copyright © 2016 GlobBar. All rights reserved.
//

import Foundation
import MapKit

protocol GlobBarMapAnnotation {
    
    var coordinate: CLLocationCoordinate2D { get }
    
    var annotationTitle: String? { get }
    var annotationSubtitle: String? { get }
}


class AnnotationWrapper : NSObject, MKAnnotation {
    
    let state: GlobBarMapAnnotation
    init(type: GlobBarMapAnnotation) {
        
        state = type
        
        super.init()
    }
 
    var coordinate: CLLocationCoordinate2D { return state.coordinate }
    var title: String? { return state.annotationTitle }
    var subtitle: String? { return state.annotationSubtitle }

}

extension MKCoordinateRegion : Equatable {
    
    static var worldRegion: MKCoordinateRegion {
        return     MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0,
                                                                     longitude: 0),
                                      span: MKCoordinateSpan(latitudeDelta: 90,
                                                             longitudeDelta: 180))
    }
    
    
    
}

public func ==(lhs: MKCoordinateRegion,
               rhs: MKCoordinateRegion) -> Bool {
    
    let epsilon = 0.000001
    
    ///we'll use Taxicab metrics
    
    let dlat = abs(lhs.center.latitude - rhs.center.latitude)
    let dlon = abs(lhs.center.longitude - rhs.center.longitude)
    let dlatD = abs(lhs.span.latitudeDelta - rhs.span.latitudeDelta)
    let dlonD = abs(lhs.span.longitudeDelta - rhs.span.longitudeDelta)
    
    let closeEnough = (dlat + dlon + dlatD + dlonD) < epsilon
    
    return closeEnough
}
