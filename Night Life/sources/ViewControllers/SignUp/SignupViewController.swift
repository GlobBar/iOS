//
//  SignupViewController.swift
//  GlobBar
//
//  Created by admin on 12.05.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SWRevealViewController
import QuartzCore

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var viewModel: SignUpViewModel!
    
    fileprivate let bag = DisposeBag()
    
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
        
        let emailValidation = emailField.rx.text.map { $0?.isValidEmail() }.notNil()
        let usernameValidation = usernameField.rx.text.map { ($0?.lengthOfBytes(using: String.Encoding.utf8))! > 0 }
        let passwordValidation = passwordField.rx.text.map { ($0?.lengthOfBytes(using: String.Encoding.utf8))! > 0 }
        
        
        Observable.combineLatest(emailValidation, usernameValidation, passwordValidation)
            { e, u, p -> Bool in
             return e && u && p
            }
            .bind(to: signUpButton.rx.isEnabled)
.disposed(by: bag)
        
        signUpButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.viewModel.signUpAction(self.emailField.text!,
                username: self.usernameField.text!,
                password: self.passwordField.text!)
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

extension String {
    
    func isValidEmail() -> Bool {
        
        let emailRegex = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
        
    }
    
}
