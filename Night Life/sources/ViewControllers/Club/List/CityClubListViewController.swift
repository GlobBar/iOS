//
//  MainClubListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import AHKActionSheet

class CityClubListViewController: UIViewController {
    
    let viewModel = CityClubListViewModel()
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.title
            .drive(onNext: { [unowned self] title in
                self.title = title
            }
            )
.disposed(by: bag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "club list embedded" {
            
            let controller = segue.destination as! ClubsListViewController
            controller.viewModel = viewModel.clubsViewModel
            
        }
    }
    
    @IBAction func mapTapped(_ sender: Any) {
        revealViewController().rearViewController
            .performSegue(withIdentifier: "to map", sender: nil)
    }
}
