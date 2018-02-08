//
//  ClubCalloutViewModel.swift
//  GlobBar
//
//  Created by Vlad Soroka on 2/20/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import ObjectMapper

extension ClubCalloutViewModel {
    
    var title: Driver<String> {
        return club.asDriver().notNil()
            .map { $0.name }
    }
    
    var selectedClub: Observable<Club> {
        return selectedClubVar.asObservable()
            .notNil()
    }
    
    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 17)
    }
    
    func preferredHeightFor(width: CGFloat) -> CGFloat {
        
        var totalHeight: CGFloat = 0
        
        totalHeight += 16 ///top margin
        
        var textHeight = titleFont
            .sizeOfString(string: club.value!.name, constrainedToWidth: Double(width)).height
        if textHeight < 20 {
            textHeight = 20
        }
        totalHeight += textHeight ///message height
        totalHeight += 15 ///name to feed space
        
        totalHeight += width / 3 ///space for 3 feed items
        
        totalHeight += 8 ///bottom margin
        
        return totalHeight
        
    }
}

struct ClubCalloutViewModel {
    
    let feedViewModel: FeedViewModel = FeedViewModel()
    
    init() {
        
        club.asObservable().notNil()
            .map { DataProvider(club: $0) }
            .bind(to: feedViewModel.dataProvider)
                .disposed(by: bag)
        
        
    }
    
    fileprivate let bag = DisposeBag()
    fileprivate let club = Variable<Club?>(nil)
    fileprivate let selectedClubVar = Variable<Club?>(nil)
}

extension ClubCalloutViewModel {
    
    func switchClub(_ club: Club) {
        self.club.value = club
    }
    
    func selectTapped() {
        selectedClubVar.value = self.club.value
    }
    
}

extension ClubCalloutViewModel {
    
    struct DataProvider: FeedDataProvider {
        
        let club: Club

        func loadBatch(_ batch: Batch) -> Observable<[FeedDataItem]> {
            
            if batch.offset > 0 {
                return Observable.just([])
            }
            
            let rout = FeedDisplayableRouter.feedOfClub(club: club,
                                                        filter: .today,
                                                        batch: Batch(offset: 0, limit: 3) )
            
            return Alamofire.request(rout)
                .rx_Response(Response<CityReportsMapping>.self)
                .map { response -> [FeedDataItem] in
                    
                    ///FIXME: parsing response into seperate entities must be encapsulated
                    guard let clubsJSON = response.reports else {
                        return []
                    }

                    let users = Mapper<User>().mapArray(JSONArray: clubsJSON.map ({ $0["owner"] as! [String : AnyObject] }))
                    
                    users.forEach { user in
                        ///FIXME: get away from heruistic on merging entities
                        if user != User.currentUser() {
                            user.saveEntity()
                        }
                    }
                    
                    return clubsJSON.map { FeedDataItem(feedItemJSON: $0)! }
            }
            
            
            
        }
    }

}
