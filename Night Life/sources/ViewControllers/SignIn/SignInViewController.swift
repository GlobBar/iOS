//
//  LoginViewController.swift
//  GlobBar
//
//  Created by admin on 12.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SignInViewController: UIViewController {

    var viewModel: SignInViewModel!
    
    fileprivate let bag = DisposeBag()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func back(_ sender: AnyObject) {
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (viewModel == nil) { fatalError("ViewModel must be instantiated prior to using SignupViewController") }
        
        viewModel.indicator.asDriver()
            .drive(spinner.rxex_animating)
            .disposed(by: bag)
        
        viewModel.errorMessage.asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribe(onNext: { [unowned self] message in
                self.showInfoMessage(withTitle: "Error", message)
            }
            )
.disposed(by: bag)
        
        let emailValidation = emailTextField.rx.text.map { $0!.isValidEmail() }
        let passwordValidation = passwordTextField.rx.text.map { $0!.lengthOfBytes(using: String.Encoding.utf8) > 0 }
        
        Observable.combineLatest(emailValidation, passwordValidation)
        { $0 && $1}
            .bind(to: loginButton.rx.isEnabled)
.disposed(by: bag)
        
        loginButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.viewModel.signInAction(self.emailTextField.text!,
                password: self.passwordTextField.text!)
            
            }
            )
.disposed(by: bag)
        
        viewModel.backSignal.asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribe(onNext: { [unowned self] _ in
                self.back(self)
            }
            )
.disposed(by: bag)
        

    }
    
}
