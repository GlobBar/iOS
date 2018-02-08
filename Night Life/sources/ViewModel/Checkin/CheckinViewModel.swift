//
//  CheckinViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/23/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift

import Alamofire


enum PostCheckinAction {
    
    case noAction
    
    case addPhoto
    case addReport
    case addVideo
    
}

struct CheckinViewModel {
    
    let club : Club
    let predefinedPostAction: PostCheckinAction?
    init(club: Club, predefinedPostAction: PostCheckinAction? = nil) {
        self.club = club
        self.predefinedPostAction = predefinedPostAction
    }
    
    let errorMessage: Variable<String?> = Variable(nil)
    
    let checkinControlsShown = Variable(true)
    let loadingIndicator = ViewIndicator()
    let disposeBag = DisposeBag()
    
    let postCheckinAction: Variable<PostCheckinAction?> = Variable(nil)
    
    func userChekedIn (_ broadcastLocation: Bool) {
        
        let rout = PlacesRouter.chekin(club: club, broadcast: broadcastLocation)
        
        Alamofire.request(rout)
            .rx_Response(Response<CheckingMapping>.self)
            .trackView(viewIndicator: loadingIndicator)
            .subscribe(onNext: { response in
                
                guard var club = Club.entityByIdentifier(self.club.id) else {
                    fatalError("Can't update checkin status because no club with id \(self.club.id) was stored")
                }
                
                ////updating current club's context
                club.checkInUser()
                club.saveEntity()
                
                ///registering within checkin context
                guard let dueDateString = response.expired,
                    let dueDate = AppConfiguration.dateFormatter().date(from: dueDateString) else {
                    
                    self.errorMessage.value = "Error parsing server response, on checkin"
                    return
                }
                CheckinContext.registerCheckinInClub(club, dueDate: dueDate)
                
                if let action = self.predefinedPostAction {
                    self.postCheckinAction.value = action
                }
                else {
                    ///updating UI for non checkin controlls
                    self.checkinControlsShown.value = false
                }
                
                }, onError: { (e) -> Void in
                    
                    self.errorMessage.value = ("Connection was lost. Please try again")
                    
                })
        
.disposed(by: disposeBag)
        
    }
    
    func noClicked () {
        postCheckinAction.value = PostCheckinAction.noAction
    }
    
    func addPhotoClicked () {
        postCheckinAction.value = PostCheckinAction.addPhoto
    }
    
    func addReportClicked () {
        postCheckinAction.value = PostCheckinAction.addReport
    }
    
}
