//
//  LikedClubsListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

class LikedClubsListViewController : UIViewController {
    
    let viewModel = LikedClubsListViewModel()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "club list embedded" {
            
            let controller = segue.destination as! ClubsListViewController
            controller.viewModel = viewModel.clubsViewModel
            
        }
    }
}
