//
//  CashoutRouter.swift
//  GlobBar
//
//  Created by Vlad Soroka on 5/15/19.
//Copyright © 2019 com.NightLife. All rights reserved.
//

import UIKit

struct CashoutRouter {
    
    var owner: UIViewController {
        return _owner!
    }
    
    weak private var _owner: UIViewController?
    init(owner: UIViewController) {
        self._owner = owner
    }
    
    /**
     
     func showNextModule(with data: String) {
     
        let nextViewController = owner.storyboard.instantiate()
        let nextRouter = NextRouter(owner: nextViewController)
        let nextViewModel = NextViewModel(router: nextRuter, data: data)
        
        nextViewController.viewModel = nextViewModel
        owner.present(nextViewController)
     }
     
     */
    
}
