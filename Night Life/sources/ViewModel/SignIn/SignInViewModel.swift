//
//  SignInViewModel.swift
//  GlobBar
//
//  Created by admin on 16.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

import Alamofire
import ObjectMapper

class SignInViewModel {
    
    fileprivate let bag = DisposeBag()
    let indicator = ViewIndicator()
    
    let userLoggedInSignal: Variable<Int?> = Variable(nil)
    
    let errorMessage: Variable<String?> = Variable(nil)
    
    let backSignal: Variable<Int?> = Variable(nil)
    
    func signInAction(_ email: String, password: String) {
        
        let rout = AccessTokenRouter.logIn(email: email, password: password)
        
        AuthorizationManager.loginUserWithRouter(rout)
            .trackView(viewIndicator: self.indicator)
            .catchError{ [unowned self] (er: Error) -> Observable<String?> in
                
                if let e = er as? AuthorizationError {
                    switch e {
                    case .customError(let description):
                        self.errorMessage.value = description ?? "Unknown error occured. Try again later"
                        
                    }
                }
                else {
                    self.errorMessage.value = "Unknown error occured. Try again later"
                }
                
                return Observable.just(nil)
            }
            .filter { $0 != nil }.map { $0! }
            .map{ [unowned self] _ in
                
                self.backSignal.value = 1;
                
                return 1
            }
            .bind(to: userLoggedInSignal)
.disposed(by: bag)
        
    }
}
