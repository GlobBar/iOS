//
//  ViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift;

class ViewController: UITableViewController {

    let loadingViewModel: PaginatingViewModel<String> = PaginatingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let trigge = Observable<Int>.interval(0.8, scheduler: MainScheduler.instance).flatMap { _ in Observable.just() }
//        
//        loadingViewModel.load(SimpleProvider(),
//            nextPageTrigger: trigge)
//            .subscribeNext{ print ($0) }
//                
        // Do any additional setup after loading the view, typically from a nib.
        LocationManager.startMonitoring()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    
    
}

class SimpleProvider : DataProvider {
    
    typealias DataType = String
    
    func loadBatch(batch: Batch) -> Observable<[String]> {
        return Observable.just(["Yo"])
    }
    
}