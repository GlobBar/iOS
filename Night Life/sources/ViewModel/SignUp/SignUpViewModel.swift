//
//  SignUpViewModel.swift
//  GlobBar
//
//  Created by admin on 16.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

import Alamofire


class SignUpViewModel {
    
    fileprivate let bag = DisposeBag()
    let indicator = ViewIndicator()
    
    let userTypeSelected: Variable<User.ProfileType> = Variable(.fan)
    
    let userLoggedInSignal: Variable<Int?> = Variable(nil)
    
    let errorMessage: Variable<String?> = Variable(nil)
    
    let backSignal: Variable<Int?> = Variable(nil)
    
    func signUpAction(_ email: String, username: String, password: String) {
        
        let profileType = userTypeSelected.value
        let rout = AccessTokenRouter.signUp(username: username, password: password, email: email)
        
        AuthorizationManager.loginUserWithRouter(rout)
            .flatMap { x -> Observable<String?> in
                
                guard case .dancer = profileType else {
                    return .just(x)
                }
                
                return Alamofire.request(AccessTokenRouter.setDancerProfileType)
                    .rx_Response(EmptyResponse.self)
                    .map { _ in x }
            }
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
