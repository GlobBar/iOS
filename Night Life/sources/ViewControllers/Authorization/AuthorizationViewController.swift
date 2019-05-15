//
//  AuthorizationViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/5/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift

import ObjectMapper

import Alamofire

class AuthorizationViewController :  UIViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    fileprivate let indicator = ViewIndicator()
    
    //--------
    //viewModel section
    
    fileprivate let loggedInUser : Variable<User?> = Variable(nil)
    
    
    fileprivate let signupViewModel = SignUpViewModel()
    fileprivate let signinViewModel = SignInViewModel()
    
    //------
    
    override func loadView() {
        super.loadView()
        
        facebookButton.addLinearGradient(fromHexColor: 0x465fa9, toHexColor: 0x384b91)
        facebookButton.titleLabel?.font = UIConfiguration.appFontOfSize(14)
        
        instagramButton.addLinearGradient(fromHexColor: 0xff8b00, toHexColor: 0xff6e00)
        instagramButton.titleLabel?.font = UIConfiguration.appFontOfSize(14)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var bounds = facebookButton.layer.bounds
        facebookButton.layer.sublayers?.forEach { $0.frame = bounds }
        
        bounds = instagramButton.layer.bounds
        instagramButton.layer.sublayers?.forEach { $0.frame = bounds }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.asDriver().drive(spinner.rxex_animating)
            .disposed(by: disposeBag)
        
        let fb = facebookButton.rx.tap.map{ FacebookAuthenticator() as ExternalAuthenticator }
        let insta = instagramButton.rx.tap.map{ InstagramAuthenticator() as ExternalAuthenticator }
        
        let externalLoginObservable =
            Observable.of(fb,insta)
                .merge()
                .flatMapLatest { [unowned self] (auth: ExternalAuthenticator) in
                    return auth
                        .authenticateUser(onController: self)
                        .trackView(viewIndicator: self.indicator)
                }
                .map { data -> AccessTokenRouter? in
                    let a : AccessTokenRouter? = AccessTokenRouter.externalLogin(authData: data)
                    return a
                }
                .catchErrorJustReturn(nil)
                .filter { $0 != nil }.map { $0! }
                .flatMapLatest { [unowned self] in
                    AuthorizationManager.loginUserWithRouter($0)
                        .trackView(viewIndicator: self.indicator)
                }
                .filter { $0 != nil }.map { $0! }
                .map { _ in 1 }
        
        let signUpSignal = signupViewModel.userLoggedInSignal
            .asObservable()
            .filter { $0 != nil }.map { $0! }
        
        let signInSignal = signinViewModel.userLoggedInSignal
            .asObservable()
            .filter { $0 != nil }.map { $0! }
        
        
        ///phase 3
        ///populating current user with data
        Observable.of(externalLoginObservable, signUpSignal, signInSignal)
            .merge()
            .flatMapLatest { [unowned self] _ in
                AuthorizationManager.currentUserDetails()
                    .trackView(viewIndicator: self.indicator)
                    .silentCatch(handler: self)
            }
            .map { User.loginWithData($0 as AnyObject) }
            .bind(to: loggedInUser)
            
.disposed(by: disposeBag)
        
        
        loggedInUser.asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribe(onNext: { [unowned router = MainRouter.sharedInstance] _ in
                let _ = try? NotificationManager.saveDeviceToken()
                router.mainAppScreenRout(true)
            }
            )
.disposed(by: self.disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signup segue" {
            
            let controller = segue.destination as! SignupViewController
            controller.viewModel = signupViewModel
            
        }
        else if segue.identifier == "login segue" {
            
            let controller = segue.destination as! SignInViewController
            controller.viewModel = signinViewModel
            
        }
    }
    
}
