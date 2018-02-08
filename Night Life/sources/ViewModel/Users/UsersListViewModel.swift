//
//  UsersListViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa

import Alamofire

import ObjectMapper

enum UserListMode {
    case following
    case follower
}

typealias RelationActionMetadata = (user: User, type: RelationType, isCreate: Bool)

class UsersListViewModel {
    
    let displayData: Driver<[UserSection]>
    
    fileprivate let usersViewModels: Variable<[UserViewModel]> = Variable([])
    
    fileprivate let bag = DisposeBag()
    
    let searchBarObservable: Variable<Observable<String>?> = Variable(nil)
    
    let selectedUser: Variable<UserViewModel?> = Variable(nil)
    let shouldDisplaySearchBar: Bool
    let message: Variable<String?> = Variable(nil)
    let title: Variable<String?> = Variable(nil)
    
    fileprivate weak var handler: UIViewController?
    
    init(mode: UserListMode, handler: UIViewController) {
        
        self.handler = handler
        
        shouldDisplaySearchBar = mode == .following
        
        displayData = usersViewModels.asDriver()
            .map { items in
                
                return [ UserSection(items: items ) ]
            }
        
        ///observing actions of UserViewModels
        let userActionsObservable =
        displayData.map{ $0.first?.items }
            .filter { $0 != nil }.map { $0! } ///get currently displayed non-nil UserViewModels
            .map{ $0.map( { $0.performedAction.asObservable() } ) } ///map them to their performedAction Variables
            .asObservable()
            .flatMapLatest { Observable.from($0).merge() } ///Merge Variables into one sequence and observe only most recent batch
            .catchError{ [unowned self] (er) -> Observable<UserViewModelAction?> in
                
                self.message.value = "Error performing request. Details: \(er)"
                
                return Observable.just(nil)
            }
            .filter { $0 != nil }.map { $0! } ///ignore empty performed actions
        
        userActionsObservable
            .subscribe(onNext: { [unowned self] item in
            
                var metadata: RelationActionMetadata? = nil
                var newActions : [UserViewModelActionType]? = nil
                
                switch item.type {
                case .sendFollowRequest:
                    metadata = (item.user, RelationType.request, true)
                    
                case .declineFollowRequest:
                    metadata = (item.user, RelationType.request, false)
                    
                    
                case .acceptFollowRequest:
                    metadata = (item.user, RelationType.following, true)
                    newActions = [UserViewModelActionType.block]
                    
                case .unsubscribe:
                    metadata = (item.user, RelationType.following, false)
                    
                case .block:
                    metadata = (item.user, RelationType.follower, false)
                    
                    
                }
                
                self.performActionRequest(metadata!, newActions: newActions)

            }
            )
.disposed(by: bag)
        
        
        
        switch mode {
        case .follower:
            Observable.combineLatest(followRequestsObservable(), followersObservable()) { $0 + $1 }
                .bind(to: usersViewModels)
                .disposed(by: bag)
            
            title.value = "My Followers"
            
            
        case .following:
            followingModeListObservable()
                .bind(to: usersViewModels)
                .disposed(by: bag)
            
            title.value = "I'm Following"
            
        }
        
    }
    
    func userViewModelSelected(_ selectedViewModel: UserViewModel) {
        selectedUser.value = selectedViewModel
    }
    
}

extension UsersListViewModel {
    
    fileprivate func followRequestsObservable() -> Observable<[UserViewModel]> {
        return self.performUserListRequest(RelationRouter.followRequests).map {
            $0.map { UserViewModel(user: $0,
                actions: [
                    UserViewModelActionType.declineFollowRequest,
                    UserViewModelActionType.acceptFollowRequest]) }
        }
    }
    
    fileprivate func followersObservable() -> Observable<[UserViewModel]> {
        return self.performUserListRequest(RelationRouter.followers).map {
            $0.map { UserViewModel(user: $0, actions: [UserViewModelActionType.block]) }
        }
    }
    
    fileprivate func followingObservable() -> Observable<[UserViewModel]> {
        return self.performUserListRequest(RelationRouter.following).map {
                $0.map { UserViewModel(user: $0, actions: [UserViewModelActionType.unsubscribe]) }
            }
            .share()
    }
    
    fileprivate func performUserListRequest(_ router: AuthorizedRouter) -> Observable<[User]> {
        return Alamofire.request(router)
            .rx_ArrayResponse(User.self)
            .map { users in
                
                users.filter{ $0.observableEntity() == nil }
                    .forEach{ $0.saveEntity() }
                
                return users
        }
    }
}

extension UsersListViewModel {
    
    fileprivate func performActionRequest(_ metadata: RelationActionMetadata, newActions: [UserViewModelActionType]?) {
        
        var items = self.usersViewModels.value
        
        guard let index = items.index( where: { $0.user == metadata.user } ) else {
            fatalError("Logic error. Passed user does not correspond to any user that is currently displayed")
        }
        
        let router = RelationRouter.postRelation(user: metadata.user, type: metadata.type, createAction: metadata.isCreate)
        
        Alamofire.request(router)
            .rx_Response(EmptyResponse.self)
            .map { _ -> String in
                
                if let actions = newActions {
                    
                    let viewModel = items[index]
                    let newViewModel = UserViewModel(user: viewModel.user, actions: actions)
                    items[index] = newViewModel
                    self.usersViewModels.value = items
                    
                }
                else {
                    items.remove(at: index)
                    self.usersViewModels.value = items
                }
                
                return "Request has been sent"
            }
            .catchError { Observable.just("Error performing request. Details: \($0)") }
            .bind(to: message)
            
.disposed(by: bag)
    }

}

extension UsersListViewModel {
    
    fileprivate func followingModeListObservable() -> Observable<[UserViewModel]> {
        
        return searchBarObservable.asObservable()
            .filter { $0 != nil }.map { $0! } ///waiting until query emitter is set up
            .switchLatest()
            .catchErrorJustReturn("")
//            .filter{ query in ///ignoring queries with less than 2 symbols
//                let length = query.lengthOfBytes(using: .utf8)
//                return length > 2 || length == 0
//            }
            .throttle(0.3, scheduler: MainScheduler.instance) ///taking care of fast typers
            .flatMapLatest { [unowned self] query -> Observable<[UserViewModel]> in  /// executing backend query
                guard query.lengthOfBytes(using: .utf8) > 0 else {
                    ///followers list
                    return self.followingObservable()
                }
                
                return self.performUserListRequest(UserRouter.list(filterQuery: query)).map {
                    $0.map { UserViewModel(user: $0, actions: [UserViewModelActionType.sendFollowRequest]) }
                }
            }
        
    }
    
}
