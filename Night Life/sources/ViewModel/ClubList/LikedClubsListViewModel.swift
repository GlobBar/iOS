//
//  LikedClubsListViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

class LikedClubsListViewModel {
    
    let clubsViewModel = ClubListViewModel()
    
    init() {
        
        self.clubsViewModel.clubsRouter.value = .liked
        
    }
    
}
    
