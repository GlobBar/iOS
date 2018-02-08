//
//  PresentMessage.swift
//  Campfiire
//
//  Created by Vlad Soroka on 10/15/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

struct DisplayMessage {
    let title: String
    let description: String
}

protocol CanPresentMessage {
    
    func presentError(error: Error)
    func presentErrorMessage(error: String)
    func presentMessage(message: DisplayMessage)
    
}

protocol CanPresentQuestions {
    
    func presentConfirmQuestion(question: DisplayMessage) -> Observable<Bool>
    func presentSaveAndExitQuestion(question: DisplayMessage) -> Observable<(save : Bool, exit : Bool)>
    func presentTextQuestion(question: DisplayMessage, buttonSuccessName : String) -> Observable<String>
    
}

extension CanPresentMessage {
    
    func presentErrorMessage(error: String) {
        presentMessage(message: DisplayMessage(title: "Error", description: error))
    }
    
    func presentError(error: Error) {
        
        if let campfiireError = error as? GlobBarError {
            
            guard campfiireError.shouldPresentError() else { return }
//            if case .unauthorised = campfiireError {
//                MainViewModel.shared.logout()
//            }
            
            presentErrorMessage(error: campfiireError.description)
            
        }
        else if let afError = error as? AFError,

            case .responseValidationFailed(let reason) = afError,
            case .unacceptableStatusCode(let code) = reason {
            
            presentErrorMessage(error: "Sorry, seems like server returned unacceptable status code \(code)")
            
        }
        else if (error as NSError).domain == NSURLErrorDomain {
            let er = error as NSError
            
            guard er.code != NSURLErrorNotConnectedToInternet else {
                return presentErrorMessage(error: "Please check the Internet connection")
            }
            
            presentErrorMessage(error: er.localizedDescription)
        }
        else {
            presentErrorMessage(error: (error as CustomStringConvertible).description)
            
        }
    
    }
}


extension UIViewController : CanPresentMessage {
    
    func presentMessage(message: DisplayMessage) {
        
        if self.isViewLoaded {
            self.showInfoMessage(withTitle: message.title, message.description)
        }
        else {
            let _ =
            rx.sentMessage(#selector(UIViewController.viewDidLoad))
                .subscribe( onNext: { [unowned self] _ in
                    self.showInfoMessage(withTitle: message.title,
                                         message.description)
                })
        }
        
        
    }
    
}

extension UIViewController : CanPresentQuestions {
    
    func presentTextQuestion(question: DisplayMessage, buttonSuccessName : String = "Save") -> Observable<String> {
        
        return Observable.create({ [unowned self] (subscriber) -> Disposable in
            
            let alertController = UIAlertController(title: question.title,
                                                    message: question.description,
                                                    preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: buttonSuccessName, style: .default, handler: {
                alert -> Void in
                
                let firstTextField = alertController.textFields![0] as UITextField
                
                subscriber.onNext(firstTextField.text ?? "")
                subscriber.onCompleted()
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "New value"
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { [unowned self] _ in
                subscriber.onError(GlobBarError.userCanceled)
                self.dismiss(animated: true, completion: nil)
            })
            
            self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create()
        })
        
        
    }
    
    func presentcChangePasvordForm(question : DisplayMessage) -> Observable<(String, String, String)> {
        
        return Observable.create({ [unowned self] (subscriber) -> Disposable in
            
            let alertController = UIAlertController(title: question.title,
                                                    message: question.description,
                                                    preferredStyle: .alert)
            
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                alert -> Void in
                
                let first = alertController.textFields![0].text ?? ""
                let second = alertController.textFields![1].text ?? ""
                let third = alertController.textFields![2].text ?? ""
                
                subscriber.onNext( (first, second, third) )
                subscriber.onCompleted()
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                
                textField.placeholder = "Old password"
                textField.textAlignment = .center
                
            }
            alertController.addTextField { (textField: UITextField!) -> Void in
                textField.placeholder = "New password"
                textField.textAlignment = .center
            }
            
            alertController.addTextField { (textField: UITextField!) -> Void in
                textField.placeholder = "Confirm new password"
                textField.textAlignment = .center
            }
            
            
            alertController.addAction(saveAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { [unowned self] _ in
                subscriber.onError(GlobBarError.userCanceled)
                self.dismiss(animated: true, completion: nil)
            })
            
            self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create()
        })
        
        
    }
    
    
    func presentConfirmQuestion(question: DisplayMessage) -> Observable<Bool> {
        
        return Observable.create({ [unowned self] (subscriber) -> Disposable in
            
            self.showSimpleQuestionMessage(withTitle: question.title,
                                           question.description, {
                                            subscriber.onNext(true)
                                            subscriber.onCompleted()
                                            
            },
                                           {
                                            subscriber.onNext(false)
                                            subscriber.onCompleted()
                                            
            })
            
            return Disposables.create()
        })
        
    }
    
    func presentSaveAndExitQuestion(question: DisplayMessage) -> Observable<(save : Bool, exit : Bool)>
    {
        return Observable.create({ [unowned self] (subscriber) -> Disposable in
            
            let alertController = UIAlertController(title: question.title,
                                                    message: question.description,
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Exit", style: .default) { _ in
                subscriber.onNext((save: false, exit: true))
                subscriber.onCompleted()
            })
            
            alertController.addAction(UIAlertAction(title: "Don't Exit", style: .default) { _ in
                subscriber.onNext((save: false, exit: false))
                subscriber.onCompleted()
            })
            
            alertController.addAction(UIAlertAction(title: "Save and Exit", style: .default) { _ in
                subscriber.onNext((save: true, exit: true))
                subscriber.onCompleted()
            })
            
            self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create()

        })
    }
    
}
