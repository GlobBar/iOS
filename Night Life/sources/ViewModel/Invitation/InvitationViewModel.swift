//
//  InvitationViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import Alamofire


enum InvitationError : Error {
    
    //case NoFacebookToken
    case noPublishPermissions
    
}

class InvitationViewModel {
    
    fileprivate let activityIndicator = ViewIndicator()
    var activityDriver: Driver<Bool> {
        return activityIndicator.asDriver()
    }
    let message: Variable<String?> = Variable(nil)
    
    fileprivate let bag = DisposeBag()
    
    func inviteOn(_ controller: UIViewController) {
        
        invitationObservable(controller)
            .map { a in let b: String? = a; return b! }
            .bind(to: message)
            
.disposed(by: bag)
        
    }
    
    fileprivate func invitationObservable(_ controller: UIViewController) -> Observable<String> {
        
        return Alamofire.request(FacebookInvitationRouter.sendInvitation)
            .rx_Response(Response<FacebookInvitationMapping>.self)
            .trackView(viewIndicator: activityIndicator)
            .flatMap { response -> Observable<String> in
                guard let data = response.data else {
                    return Observable.just("Error recognizing response. Please try again later")
                } 
                
                if data == "invalid token" {
                    return Observable.error(InvitationError.noPublishPermissions)
                }
                
                return Observable.just("Invitation was succesfully posted")
            }
            .catchError { [unowned self] er -> Observable<String> in
                guard let invitationError = er as? InvitationError else { return Observable.just("\(er)") }
                
                switch invitationError {
                    
                case .noPublishPermissions:
                    return FacebookAuthenticator
                        .reauthentiacteForPublishObservable(onController: controller)
                        .trackView(viewIndicator: self.activityIndicator)
                        .flatMap { data -> Observable<Void> in
                            
                            return Alamofire.request(FacebookInvitationRouter.updateToken(token: data.token))
                                .rx_Response(EmptyResponse.self)
                            
                        }
                        .flatMap { [unowned self] in
                            ///FIXME: check for retin count for controller var
                            self.invitationObservable(controller)
                        }
                    
                }
            }
        
    }
    
}
