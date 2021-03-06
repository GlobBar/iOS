//
//  UserProfileViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Alamofire
import SwiftyStoreKit

import RxSwift
import RxCocoa

import ObjectMapper

import FDTake
import FBSDKLoginKit

enum UserProfileEditingState {
    case noEditing
    case showEditing
    case showConfirmation
}

enum UserProfileEditingError : Error {
    
    case nameDuplication
    
}

class UserProfileViewModel {
    
    fileprivate var userVariable: Variable<User>
    
    var userDriver: Driver<User> {
        return userVariable.asDriver()
    }
    
    var ownProfile: Bool {
        return userVariable.value == User.currentUser()!
    }
    
    let errorMessage: Variable<String?> = Variable(nil)
    
    var editingState: Variable<UserProfileEditingState> = Variable(.noEditing)
    
    
    var usernameTextBoxViewModel =
        TextBoxViewModel(displayText: "")
    
    
    fileprivate var fdTakeController: FDTakeController = {
        let d = FDTakeController()
        d.allowsVideo = false
        return d
    }()
    
    let uploadProgress = Variable<Float?>(nil)
    
    fileprivate let bag = DisposeBag()
    
    let feedViewModel = FeedViewModel()
    let followingViewModel: UserProfileFollowingViewModel
    
    fileprivate weak var handler: UIViewController?
    
    fileprivate let indicator: ViewIndicator = ViewIndicator()
    
    init(userDescriptor: User, handler: UIViewController) {
        
        self.handler = handler
        
        ///initial state
        userVariable = Variable(userDescriptor)
        let isCurrentUser = userDescriptor.id == User.currentUser()!.id
        editingState = Variable( isCurrentUser ? .showEditing : .noEditing )
        
        followingViewModel = UserProfileFollowingViewModel(user: userDescriptor, handler: handler)
        
        ///username editing
        let v = LengthValidator(min: 3, max: 20,
                                entityName: "Username")
        usernameTextBoxViewModel = TextBoxViewModel(displayText: userDescriptor.username,
                                                    validator: v)
        
        usernameTextBoxViewModel.text.asObservable()
            .filter { $0 != nil }.map { $0! }
            .map { [unowned self] username in
                var user = self.userVariable.value
                user.username = username
                return user
            }
            .bind(to: userVariable)
.disposed(by: bag)
        
        ///image editing
        fdTakeController.rxex_photo()
            .map { [unowned self] image in
                let tempURL = "com.nightlife.temporayAvatar"
                ImageRetreiver.registerImage(image, forKey: tempURL)
                
                var user = self.userVariable.value
                user.pictureURL = tempURL
                return user
            }
            .bind(to: userVariable)
.disposed(by: bag)
        
        ////refreshing user info
        Alamofire.request(UserRouter.info(userId: userDescriptor.id))
            .rx_Response(Response<UserMapping>.self)
            .map { response -> User in
                
                guard let user = response.user else {
                    fatalError("Error parsing user from server respnse")
                }
                
                /// .Info router provides the most full and recent data about user
                /// So we will force update local storage here
                user.saveEntity()
                
                return user
            }
            .bind(to: userVariable)
.disposed(by: bag)
        
        ///changes inside app on user should be reflected here as well
        if let x = userDescriptor.observableEntity() {
            x.asObservable()
                .bind(to: userVariable)
                .disposed(by: bag)
        }
        
        feedViewModel.dataProvider.value = UserProfileDataProvider(user: userDescriptor)
        
        indicator.asDriver()
            .drive(onNext: { [weak h = handler] (loading) in
                h?.changedAnimationStatusTo(status: loading)
            })
            .disposed(by: bag)
    }
    
    func editPhoto() {
        fdTakeController.present()
    }
    
    func uploadEdits() {
        
        Alamofire.upload(multipartFormData: { formData in
            
            if let avatar = ImageRetreiver.cachedImageForKey(key: "com.nightlife.temporayAvatar") {
                formData.append(UIImageJPEGRepresentation(avatar, 0.6)!,
                                withName: "file",
                                fileName: "image.jpg",
                                mimeType: "image/jpg")
            }
            
            formData.append("\(self.userVariable.value.id)".data(using: .utf8)!,
                            withName: "user_pk")
            
            formData.append("\(self.userVariable.value.username)".data(using: .utf8)!,
                            withName: "user_name")
            
        },
                         with: UserRouter.update,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                
                                upload.uploadProgress(closure: { (pr) in
                                    self.uploadProgress.value = Float(pr.fractionCompleted)
                                })
                                
                                upload
                                    .rx_Response(Response<EditUserMapping>.self)
                                    .flatMap { userEdit -> Observable<User> in
                                        
                                        if let duplication = userEdit.errorReason,
                                            duplication == "Name duplication" {
                                            return Observable.error(UserProfileEditingError.nameDuplication)
                                        }
                                        
                                        guard let username = userEdit.username,
                                            let pictureURL = userEdit.profileImage else {
                                                fatalError("Error recognizing server sturcture");
                                        }
                                        
                                        if let newAvatar = ImageRetreiver.cachedImageForKey(key: "com.nightlife.temporayAvatar") {
                                            ImageRetreiver.registerImage(newAvatar, forKey: pictureURL)
                                            ImageRetreiver.flushImageForKey(key: "com.nightlife.temporayAvatar")
                                        }
                                        
                                        var newCurrentUser = User.currentUser()!
                                        newCurrentUser.username = username
                                        newCurrentUser.pictureURL = pictureURL
                                        
                                        newCurrentUser.saveLocally()
                                        
                                        self.editingState.value = .showEditing
                                        
                                        return Observable.just(newCurrentUser)
                                    }
                                    .catchError({ (er) -> Observable<User> in
                                        
                                        if (er as? UserProfileEditingError) == UserProfileEditingError.nameDuplication {
                                            self.errorMessage.value = "This username is alreday taken, please choose another one"
                                        }
                                        else {
                                            print(er)
                                        }
                                        
                                        return Observable.just(self.userVariable.value)
                                    })
                                    .bind(to: self.userVariable)
                                    
                                    .disposed(by: self.bag)
                                
                            case .failure(let encodingError):
                                
                                assert(false, "\(encodingError)")
                                
                            }
        })

    }
    
    func tip() {
        
        let amount = 100
        let u = userVariable.value
        
        SwiftyStoreKit.purchaseProduct(PriceTiers.one.rawValue) { (res) in
            
            switch res {
                
            case .error(let error):
                print(error)
                //self.router.owner.presentError(error)
                
            case .success(let purchase):
                
                Alamofire.request( UserRouter.topUp(amount: amount) )
                    .rx_Response(EmptyResponse.self)
                    .flatMapLatest {
                        Alamofire.request( UserRouter.donate(user: u, amount: amount) )
                            .rx_Response(EmptyResponse.self)
                    }
                    .trackView(viewIndicator: self.indicator)
                    .silentCatch(handler: self.handler)
                    .subscribe(onNext: { [weak h = self.handler] (_) in
                        
                        h?.presentMessage(message: DisplayMessage(title: "Success", description: "You've tipped \(u.username) $\(Double(amount) / 100)"))
                        
                    })
                    .disposed(by: self.bag)
                
            }
            
        }
        
        
        
    }
    
    func logoutAction() {
        NotificationManager.flushDeviceToken()
        LocationManager.instance.endMonitoring()
        
        ImageRetreiver.flushCache()
        
        AccessToken.token = nil
        User.currentUser()?.logout()
        FBSDKLoginManager().logOut()
        CheckinContext.drainAllCheckins()
        
        User.storage = [:]
        Club.storage = [:]
        Message.storage = [:]
        MediaItem.storage = [:]
        
        MainRouter.sharedInstance.authorizationRout(true)
    }
    
    func deleteProfile() {
        Alamofire.request(UserRouter.deleteProfile)
            .responseJSON { _ in
                self.logoutAction()
            }
    }
    
    func topUp() {
        
        ////refreshing user info
        Alamofire.request(UserRouter.topUp(amount: 300))
            .rx_Response(EmptyResponse.self)
            .silentCatch(handler: handler)
            .map { [unowned self] response -> User in
                
                var user = self.userVariable.value
                user.balance += 300
                return user
                
            }
            .bind(to: userVariable)
            .disposed(by: bag)
        
    }
    
    func donate(amount: Int) {
        
        guard User.currentUser()!.balance >= amount else {
            handler?.presentErrorMessage(error: "Sorry, you only have \(User.currentUser()!.balance) left on your account")
            return
        }
        
        Alamofire.request(UserRouter.donate(user: userVariable.value,
                                            amount: amount))
            .rx_Response(EmptyResponse.self)
            .silentCatch(handler: handler)
            .map { [unowned self] response -> User in
                
                var cu = User.currentUser()!
                cu.balance -= amount
                cu.saveLocally()
                
                var user = self.userVariable.value
                user.balance += Int( 0.95 * Double(amount) )
                return user
                
            }
            .bind(to: userVariable)
            .disposed(by: bag)
        
    }
    
}

class UserProfileDataProvider: FeedDataProvider {
    
    fileprivate let user: User
    init(user: User) {
        self.user = user
        
    }
    
    fileprivate var loadOnceFlag = true
    func loadBatch(_ batch: Batch) -> Observable<[FeedDataItem]> {

        if loadOnceFlag {
            loadOnceFlag = false
            return Alamofire.request(UserRouter.info(userId: user.id))
                .rx_Response(Response<LastReportsMapping>.self)
                .map { response -> [FeedDataItem] in
                    
                    guard let lastReportsJSON = response.reports else {
                        fatalError("Error recognising server respnse")
                    }
                    
                    return lastReportsJSON.map { FeedDataItem(feedItemJSON: $0, postOwner: self.user)! }
            }
        }
        else {
            return Observable.just([])
        }
    }
}

extension FDTakeController {
    
    func rxex_photo() -> Observable<UIImage> {
        
        return Observable.create{ observer in
        
            self.didGetPhoto = { image, info in
                observer.onNext(image)
                //observer.onCompleted()
            }
            
            return Disposables.create()
        }
        
    }
    
}
