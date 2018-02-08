//
//  ClubCalloutViewController.swift
//  GlobBar
//
//  Created by Vlad Soroka on 2/20/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import UIKit

class ClubCalloutViewController: UIViewController {
    
    var viewModel: ClubCalloutViewModel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.title.asDriver()
            .drive(titleLabel.rx.text)
            .disposed(by: rx_disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed feed" {
            
            let c = segue.destination as! FeedCollectionViewController
            c.viewModel = viewModel.feedViewModel
            
        }
    }
    
    @IBAction func viewTap(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        
        viewModel.selectTapped()
    }
}
