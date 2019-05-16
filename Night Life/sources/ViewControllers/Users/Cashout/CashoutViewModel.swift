//
//  CashoutViewModel.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/15/19.
//  Copyright © 2019 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire

extension CashoutViewModel {
    
    /** Reference binding drivers that are going to be used in the corresponding view
    
    var text: Driver<String> {
        return privateTextVar.asDriver().notNil()
    }
 
     */
    var ballance: Driver<String> {
        return User.currentUser()!.observableEntity()!
            .asDriver()
            .map { "$ \(Double($0.balance) / 100) available" }
    }
    
}

struct CashoutViewModel {
    
    /** Reference dependent viewModels, managers, stores, tracking variables...
     
     fileprivate let privateDependency = Dependency()
     
     fileprivate let privateTextVar = BehaviourRelay<String?>(nil)
     
     */
    
    init(router: CashoutRouter) {
        self.router = router
        
        /**
         
         Proceed with initialization here
         
         */
        
        /////progress indicator
        
        indicator.asDriver()
            .drive(onNext: { [weak h = router.owner] (loading) in
                h?.changedAnimationStatusTo(status: loading)
            })
            .disposed(by: bag)
    }
    
    let router: CashoutRouter
    
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    fileprivate let bag = DisposeBag()
    
}

extension CashoutViewModel {
    
    func cashout(amount: Int, email: String) {
        
        let cents = amount * 100
        
        guard User.currentUser()!.balance >= cents else {
            router.owner.presentErrorMessage(error: "Sorry, you only have \(User.currentUser()!.dollars) left on your account")
            return
        }
        
        Alamofire.request(UserRouter.cashout(amount: cents, email: email))
            .rx_Response(EmptyResponse.self)
            .trackView(viewIndicator: indicator)
            .silentCatch(handler: router.owner)
            .map { [weak o = router.owner] response -> User in
                
                o?.presentMessage(message: DisplayMessage(title: "Success",
                                                          description: "You will receive a transfer shortly. We will notify you as soon as payment comes out"))
                
                var cu = User.currentUser()!
                cu.balance -= cents
                cu.saveLocally()
                
                return cu
                
            }
            .subscribe()
            .disposed(by: bag)
        
    }
    
    /** Reference any actions ViewModel can handle
     ** Actions should always be void funcs
     ** any result should be reflected via corresponding drivers
     
     func buttonPressed(labelValue: String) {
     
     }
     
     */
    
}
