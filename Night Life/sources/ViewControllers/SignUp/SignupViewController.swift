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
import AHKActionSheet

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileTypeTextField: UITextField!
    
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
        
        viewModel.userTypeSelected.asDriver()
            .map { $0 == .fan ? "Fan" : "Dancer" }
            .drive(profileTypeTextField.rx.text)
            .disposed(by: bag)
        
    }
    
    @IBAction func accountTypeTap(_ sender: Any) {
        let actionSheet = AHKActionSheet(title: "Select profile type")
        
        actionSheet?.blurTintColor = UIColor(white: 0, alpha: 0.75)
        actionSheet?.blurRadius = 8.0;
        actionSheet?.buttonHeight = 50.0;
        actionSheet?.cancelButtonHeight = 50.0;
        actionSheet?.animationDuration = 0.5;
        actionSheet?.cancelButtonShadowColor = UIColor(white: 0, alpha: 0.1)
        actionSheet?.separatorColor = UIColor(white: 1, alpha: 0.3)
        actionSheet?.selectedBackgroundColor = UIColor(white: 0, alpha: 0.5)
        actionSheet?.buttonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
                                              NSAttributedStringKey.foregroundColor : UIColor.white ]
        actionSheet?.disabledButtonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
                                                      NSAttributedStringKey.foregroundColor : UIColor.gray ]
        actionSheet?.destructiveButtonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
                                                         NSAttributedStringKey.foregroundColor : UIColor.red ]
        actionSheet?.cancelButtonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
                                                    NSAttributedStringKey.foregroundColor : UIColor.white ]
        
        actionSheet?.addButton(withTitle: "I'm a Fan", image: nil, type: .default) { _ in
            self.viewModel.userTypeSelected.value = .fan
        }
        
        actionSheet?.addButton(withTitle: "I'm a dancer", image: nil, type: .default) { _ in
            self.viewModel.userTypeSelected.value = .dancer
        }
        
        actionSheet?.show();
    }
    
}

extension String {
    
    func isValidEmail() -> Bool {
        
        let emailRegex = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
        
    }
    
}
