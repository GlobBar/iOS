//
//  TextBoxController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/31/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextBoxController : UIViewController {
    
    fileprivate static let transitionAnimator = CommentsTransitionAnimator()
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.font = UIConfiguration.appSecondaryFontOfSize(14)
            textView.textColor = UIColor.black
        }
    }
    
    
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var negativeButton: UIButton! {
        didSet {
            negativeButton.setTitleColor(UIColor(fromHex: 0x7D7C7B), for: UIControlState())
        }
    }
    
    var viewModel: TextBoxViewModel!
    
    fileprivate let bag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = TextBoxController.transitionAnimator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { fatalError("Can't use TextBoxController without viewModel") }
        
        positiveButton.rx.tap
        .map { [unowned self] _ in
            return self.textView.text
        }
        .notNil()
        .filter{ [unowned self] (input) -> Bool in
            
            let res = self.viewModel.isValid(input: input)
            
            if case .invalid(let reason) = res {
                self.presentErrorMessage(error: reason)
            }
            
            return res.isValid
        }
        .bind(to: viewModel.text)
        
.disposed(by: bag)
        
        textView.text = viewModel.displayText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
        textView.select(self)
        textView.selectedRange = NSRange(location: 0, length: textView.text.lengthOfBytes(using: String.Encoding.utf8))
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

class TextBoxViewModel {
    
    let text: Variable<String?> = Variable(nil)
    let displayText: String
    let validator: LengthValidator?
    init(displayText: String, validator: LengthValidator? = nil) {
        self.displayText = displayText
        self.validator = validator
    }
    
    func isValid(input: String) -> ValidationResult {
        
        guard let v = validator else { return .valid }
        
        return v.validate(value: input)
    }
}


class CommentsTransitionAnimator : NSObject, UIViewControllerTransitioningDelegate {

    @objc func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CommentsEnteringAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CommentsLeavingAnimator()
    }
    
    
    class CommentsEnteringAnimator : NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.5
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            
            let containerView = transitionContext.containerView
            
            let containerBounds = containerView.bounds
            
            toViewController.view.frame = containerBounds;
            
            let overlay = UIView(frame: containerBounds)
            overlay.backgroundColor = UIColor.black
            overlay.alpha = 0
            
            containerView.addSubview(overlay)
            containerView.addSubview(toViewController.view)
            
            toViewController.view.alpha = 0.0
            toViewController.view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            
            let duration = self.transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration / 2.0, animations: {
                toViewController.view.alpha = 1.0;
                overlay.alpha = 0.5;
            }) 
            
            let damping: CGFloat = 0.55
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 1 / damping, options: [], animations: {
                toViewController.view.transform = CGAffineTransform.identity;
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
            
        }
        
    }
    
    class CommentsLeavingAnimator : NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.3
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            
            let containerView = transitionContext.containerView
            
            guard let overlay = containerView.subviews.first,
                  let textBoxView = containerView.subviews.last, overlay.alpha == 0.5 else {
                    
                    assert(false, "View hierarchy changed, cant perform smooth transition")
                    return
            }
            
            let duration = self.transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, animations: {
                overlay.alpha = 0.0;
                
                textBoxView.alpha = 0.0
                textBoxView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            }) 
            
        }
        
    }
    
}
