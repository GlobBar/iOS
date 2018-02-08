//
//  MyPointsViewController.swift
//  Night Life
//
//  Created by admin on 02.03.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SWRevealViewController
import QuartzCore

class MyPointsViewController: UIViewController, UITextFieldDelegate {
    
  fileprivate let kScrollUP:Int = 170
    
  @IBOutlet weak var scrollView: UIScrollView!
    
  @IBOutlet weak var pointsTopLbl: UILabel!
  @IBOutlet weak var pointsBottomLbl: UILabel!
  
  @IBOutlet weak var pointsMinusBtn: UIButton!
  @IBOutlet weak var pointsPlusBtn: UIButton!
  @IBOutlet weak var submitBtn: UIButton!
    
  @IBAction func minusBtnClick(_ sender: AnyObject) {
        
      self.viewModel.decreaseAmountOfPointsToSubstract()
  }
    
  @IBAction func plusBtnClick(_ sender: AnyObject) {
        
      self.viewModel.increaseAmountOfPointsToSubstract()
  }
  @IBAction func submitBtnClick(_ sender: AnyObject) {
  
    self.viewModel.removePoints()
  }
  

  fileprivate let viewModel = MyPointsViewModel()
  
  fileprivate let bag = DisposeBag()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.showInfoMessage(withTitle: "alert", "PLEASE REDEEM THE POINTS AT A PARTNER VENUE") {
        
        
    }
    
    viewModel.amountOfPointsToSubstract.asObservable()
        .map{ "\($0)" }
        .bind(to: pointsBottomLbl.rx.text)
        
.disposed(by: bag)
    
    viewModel.enableMinusButtonObservable
        .bind(to: pointsMinusBtn.rx.isEnabled)
        
.disposed(by: bag)
    
    viewModel.enableSubmitButtonObservable
        .bind(to: submitBtn.rx.isEnabled)
        
.disposed(by: bag)
    
    viewModel.generalAmountOfPoints.asObservable()
      .filter{ $0 != nil }
      .map{"\($0!.points)"}
      .bind(to: pointsTopLbl.rx.text)
      
.disposed(by: bag)
    
    ///error presenting
    viewModel.errorMessage.asDriver()
        .filter { $0 != nil }.map { $0! }
        .drive(onNext: { [unowned self] message in
            self.showInfoMessage(withTitle: "Error", message)
        }
        )
.disposed(by: bag)
  }
}
