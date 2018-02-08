//
//  UserProfileFollowingViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire


enum FollowingState {
    case nothing
    case requested
    case following
}

class UserProfileFollowingViewModel {
    
    fileprivate let user: Variable<User>
    fileprivate let bag: DisposeBag = DisposeBag()
    
    var followButtonText: Driver<String> {
        return user.asDriver().map { user in
            guard let type = user.relationType else {
                return "follow"
            }
            
            switch type {
            case .request:
                return "follow"
                
            case .following: fallthrough
            case .follower:
                return "unfollow"
            }
        }
    }
    
    var followButtonEnabled: Driver<Bool> {
        return user.asDriver().map { user in
            if let type = user.relationType,
               type == .request {
                return false
            }
            
            return true
        }
    }
    
    var followButtonHidden: Driver<Bool> {
        
        return user.asDriver().map { $0 == User.currentUser() }
        
    }
    
    fileprivate weak var handler: UIViewController?
    
    init(user: User, handler: UIViewController) {
        guard let u = user.observableEntity() else {
            fatalError("Can't perform following actions on user that is not saved to InMemmoryStorage")
        }
        
        self.user = u
    }
    
    func performAction() {
        
        if user.value.relationType == nil {
            performFollowRequest()
            
            handler?.presentMessage(message: DisplayMessage(title: "Success",
                                                            description: "Request has been sent"))
            
        }
        else if let type = user.value.relationType, type == .following {
            performUnFollowAction()
        }
    }
}

extension UserProfileFollowingViewModel {
    
    fileprivate func performFollowRequest() {
        let router = RelationRouter.postRelation(user: user.value, type: .request, createAction: true)
        
        Alamofire.request(router)
            .rx_Response(EmptyResponse.self)
            .subscribe(onNext: { [unowned self] response in
                
                var user = self.user.value
                user.relationType = .request
                user.saveEntity()
                
            }
            )
.disposed(by: bag)
    }
    
    fileprivate func performUnFollowAction() {
        let router = RelationRouter.postRelation(user: user.value, type: .following, createAction: false)
        
        Alamofire.request(router)
            .rx_Response(EmptyResponse.self)
            .subscribe(onNext: { [unowned self] response in
                
                var user = self.user.value
                user.relationType = nil
                user.followingCount? -= 1
                user.saveEntity()
                
            }
            )
.disposed(by: bag)
    }
   
}
