//
//  ClubListViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/23/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

import Alamofire
import ObjectMapper

typealias SelectedClubRout = (segueIdentifier: String, viewModel: ClubFeedViewModel)

enum ClubListError : Error {
    
    case malformedServerResponse
    
}

class ClubListViewModel {
    
    let clubs : Variable<[Club]> = Variable([])
    let clubsRouter: Variable<ClubListRouter?> = Variable(nil)
    
    let errorMessage: Variable<String?> = Variable(nil)
    
    fileprivate let bag = DisposeBag()

    init() {
        
        clubsRouter.asObservable()
            .filter { $0 != nil }.map { $0! }
            .flatMapLatest { ClubsManager.clubListFromRouter($0) }
            .bind(to: clubs)
            .disposed(by: bag)
        
    }
    
    var wireframe : Variable<SelectedClubRout?> = Variable(nil)
    func clubSelected(atIndexPath indexPath: NSIndexPath) {
        
        let club = clubs.value[indexPath.row]
        
        self.wireframe.value = ("show club feed", ClubFeedViewModel(club: club) )
        
    }
    
}
