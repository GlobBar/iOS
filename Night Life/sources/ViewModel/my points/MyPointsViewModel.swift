//
//  MyPointsViewModel.swift
//  Night Life
//
//  Created by admin on 03.03.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

import Alamofire
import ObjectMapper

class MyPointsViewModel {
    
    fileprivate let bag = DisposeBag()
    
    let errorMessage = Variable<String?>(nil)
    let amountOfPointsToSubstract = Variable<Int>(100)
    var generalAmountOfPoints = Variable<Points?>(nil)
  
    let enableMinusButtonObservable: Observable<Bool>
    let enablePlusButtonObservable: Observable<Bool>
    
    let enableSubmitButtonObservable: Observable<Bool>
    
    init() {
        
        let minAmountToRedeem = 100
        
        enableMinusButtonObservable = amountOfPointsToSubstract.asObservable().map { $0 > minAmountToRedeem }
        
        enablePlusButtonObservable = Observable
            .combineLatest( amountOfPointsToSubstract.asObservable(),
                            generalAmountOfPoints.asObservable().notNil().map { $0.points } )
            { (first:Int, last: Int) -> Bool in
                return first <= last
        }
        
        
        enableSubmitButtonObservable = amountOfPointsToSubstract.asObservable().map{ $0 >= minAmountToRedeem }
        
        self.refreshPoints()
    }
    
    func removePoints () {
        
        if generalAmountOfPoints.value != nil {
        
            if amountOfPointsToSubstract.value <= (generalAmountOfPoints.value?.points)! {
                
                //Alamofire.request(PointsRouter.removePoints(points: amountOfPointsToSubstract.value))
                
                generalAmountOfPoints.value!.points -= amountOfPointsToSubstract.value
                amountOfPointsToSubstract.value = 100
            }
            else
            {
                self.errorMessage.value = "Amount of points to redeem can't exceed total amount of points"
            }
        }
    }
    
    func refreshPoints() {

        Alamofire.request(PointsRouter.getPoints)
            .rx_Response(Response<Points>.self)
            .bind(to: generalAmountOfPoints)
            .disposed(by: bag)
    }
    
    func increaseAmountOfPointsToSubstract() {
        
            amountOfPointsToSubstract.value += 100
    }
    
    func decreaseAmountOfPointsToSubstract() {
        
        if (amountOfPointsToSubstract.value > 1) {
        
            amountOfPointsToSubstract.value -= 100
        }
    }
}

extension MyPointsViewModel {
  
}
