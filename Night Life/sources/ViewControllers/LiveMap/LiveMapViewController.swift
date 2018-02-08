//
//  LiveMapViewController.swift
//  Campfiire
//
//  Created by Vlad Soroka on 10/25/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import Foundation
import MapKit
import RxCocoa

class LiveMapViewController : UIViewController {
    
    lazy var viewModel: LiveMapViewModel! = {
        
//        var initialRegion = self.mapView.region
//
//        if let l = LocationManager.instance.lastRecordedLocation {
//            initialRegion = MKCoordinateRegionMakeWithDistance(l.coordinate, 5000, 5000)
//        }

        return LiveMapViewModel(handler: self)
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        c.viewModel = viewModel.calloutViewModel.feedViewModel
        
        viewModel.visibleRegion.asDriver()
            .notNil()
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] region in
                
                self.mapView.setRegion(region, animated: true)
                
            })
            .disposed(by: rx_disposeBag)
    
        viewModel.annotations
            .drive(onNext: { [unowned self] (annotations) in
                
                ///TODO: not remove annotattions that are the same.
                ///Do sets intersection and remove only extra annotations
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                self.mapView.addAnnotations(annotations)
                
            })
            .disposed(by: rx_disposeBag)
    
        viewModel.presentVenue
            .subscribe(onNext: { [unowned self] (clubViewModel) in
                let controller = UIStoryboard(name: "ClubFeed", bundle: nil).instantiateViewController(withIdentifier: "ClubFeedViewController") as! ClubFeedViewController
                
                controller.viewModel = clubViewModel
                
                self.navigationController?.pushViewController(controller, animated: true)
                
            })
            .disposed(by: rx_disposeBag)
        
        
//        viewModel.presentHotspotTrigger.asDriver()
//            .notNil()
//            .drive(onNext: { [unowned self] (hp) in
//                
//                let controller = R.storyboard.hotSpots.hotspotDetailViewController()!
//                
//                controller.viewModel = HotspotDetailsViewModel(handler: controller, hotSpot: hp)
//                
//                self.navigationController?.pushViewController(controller,
//                                                              animated: true)
//                
//            })
//            .disposed(by: rx_disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let s = HotSpot.fakeEntity()
//        s.saveEntity()
//        
//        viewModel.annotationClicked(annotation: HotspotAnnotationWrapper(type: .hotspot(hotspot: s)))
        
        //// TODO: |Any| move to Reloadable protocol and reload map only on demand 
//        viewModel.refreshMap()
        
    }
    
}

extension LiveMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        
        //viewModel.reportRegionChange(region: mapView.region)
    }
    
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let pinId = "com.campfiire.pin"
        
        let v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
        
        v.pinTintColor = viewModel.pinColorFor(annotation: annotation as! AnnotationWrapper)
        v.canShowCallout = false
        
        return v
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let wrapper = view.annotation as! AnnotationWrapper
        viewModel.annotationClicked(annotation: wrapper)
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        performSegue(withIdentifier: "present callout", sender: view)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed live feed" {
            
            let c = segue.destination as! FeedCollectionViewController
            c.viewModel = viewModel.calloutViewModel.feedViewModel
            
        }
        else if segue.identifier == "present callout" {
            
            let details = segue.destination as! ClubCalloutViewController
            details.viewModel = viewModel.calloutViewModel
            
            let preferredWidth: CGFloat = 320
            let preferredHeight = details.viewModel.preferredHeightFor(width: preferredWidth)
            details.preferredContentSize = CGSize(width: preferredWidth,
                                                  height: preferredHeight)
            
            let popOverController = details.popoverPresentationController!
            popOverController.delegate = self
            
            let pin = sender as! UIView
            
            popOverController.sourceView = mapView
            var f = pin.frame
            f.origin.x -= 8
            f.origin.y -= 3
            popOverController.sourceRect = f
            popOverController.backgroundColor = UIColor.black// details.view.backgroundColor;
            
        }
    }
    
}

extension LiveMapViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

//extension LiveMapViewController : AnnotationCalloutDelegate {
//    
//    func calloutViewTapped(for annotation: AnnotationWrapper) {
//        viewModel.annotationClicked(annotation: annotation)
//    }
//    
//}
