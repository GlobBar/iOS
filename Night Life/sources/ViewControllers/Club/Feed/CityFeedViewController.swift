//
//  CityFeedViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

import RxSwift
import RxCocoa
//import TodayDayManager

class CityFeedViewController : UIViewController {
    
    var viewModel = CityFeedViewModel()
    
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl! {
        didSet {
            filterSegmentedControl.selectedSegmentIndex = 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterSegmentedControl.rx.value
            .subscribe(onNext:{ [unowned self] value in
                self.viewModel.filterAtIndexSelected(value)
            }
            )
.disposed(by: disposeBag)
        
        filterSegmentedControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIConfiguration.appFontOfSize(10)
            ], for: UIControlState())
        
        viewModel.titleObservable
            .subscribe(onNext:{ [weak self] title in
            self?.title = title
        }
        )
.disposed(by: disposeBag)
       
        self.filterSegmentedControl.setTitle("Last \(Date().dayOfWeekText)'s Feed", forSegmentAt: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feed embedded" {
            
            let controller = segue.destination as! FeedCollectionViewController
            controller.viewModel = viewModel.feedViewModel
            controller.headerDataSource = self
            
        }
    }
    
    @IBAction func mapTapped(_ sender: Any) {
        revealViewController().rearViewController
            .performSegue(withIdentifier: "to map", sender: nil)
    }
    
}

extension CityFeedViewController : FeedHeaderDataSource {
    
    var headerHeight: CGFloat { return 44 }
    
    func populateHeaderView(_ view: UICollectionReusableView) {
        view.embbedViewAsContainer(headerView)
    }
}
