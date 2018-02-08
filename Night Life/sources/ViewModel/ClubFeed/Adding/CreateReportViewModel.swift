//
//  CreateReportViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

import Alamofire


import ObjectMapper

class CreateReportViewModel {
    
    let composedReport = Variable<Report?>(nil)
    let questionStatusNumber = Variable<Int>(3)
    let errorMessage = Variable<String?>(nil)
    
    var clubName : String { return club.name }
    var clubAdress : String { return club.adress }
    var clubLogoImageURL : String { return club.logoImageURL }
    
    fileprivate let club : Club
    
    init(club :Club) {
        self.club = club
        
    }
    
    let disposeBag = DisposeBag()
    
    func submitReport(_ report: Report) {

        
        Alamofire.request(FeedDisplayableRouter.createReportForClub(report: report, club: club))
            .rx_Response(Response<Report>.self)
            .subscribe(onNext: { parsedReport in
                
                parsedReport.postOwnerId = User.currentUser()!.id
                
                self.composedReport.value = parsedReport
                
                }, onError: { (e) -> Void in
                    
                    ///TODO: Hadle error
                    assert(false, "unhadled error on report")
                    
            })
            
.disposed(by: disposeBag)
        
    }
    
    func moveToNextQuestionPage() {
        
        questionStatusNumber.value+=3
        
    }
    
}
