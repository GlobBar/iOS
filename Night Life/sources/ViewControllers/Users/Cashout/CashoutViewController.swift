//
//  CashoutViewController.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/15/19.
//Copyright © 2019 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class CashoutViewController: UIViewController {
    
    var viewModel: CashoutViewModel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cashoutButton: UIButton!
    /**
     *  Connect any IBOutlets here
     *  @IBOutlet weak var label: UILabel!
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x = amountTextField.rx.text.notNil().map { !$0.isEmpty }
        let y = emailTextField.rx.text.map { $0?.isValidEmail() }.notNil()
        
        Observable.combineLatest(x, y) { $0 && $1 }
            .bind(to: cashoutButton.rx.isEnabled)
            .disposed(by: bag)
        
        /**
         *  Set up any bindings here
         *  viewModel.labelText
         *     .drive(label.rx.text)
         *     .addDisposableTo(rx_disposeBag)
         */
        
        viewModel.ballance
            .drive(amountLabel.rx.text)
            .disposed(by: bag)
        
        
    }
    
    let bag = DisposeBag()
    
}

extension CashoutViewController {
    
    @IBAction func cashoutAction(_ sender: Any) {
        viewModel.cashout(amount: Int(amountTextField.text ?? "0")!,
                          email: emailTextField.text ?? "")
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     *  Describe any IBActions here
     *
     
     @IBAction func performAction(_ sender: Any) {
     
     }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
 
    */
    
}
