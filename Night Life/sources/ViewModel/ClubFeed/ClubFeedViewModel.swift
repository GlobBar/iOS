//
//  ClubFeedViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/25/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire

import ObjectMapper

typealias MessageTuple = (title: String, message: String)
typealias SimpleAction = () -> Void

struct ClubFeedViewModel {
    
    var dancerClubTitle: Driver<String> {
        let c = club
        return User.currentUser()!.observableEntity()!.asDriver()
            .map { $0.dancerClub == c ? "My club" : "Choose club" }
            
    }
    
    let infoMessage: Variable<MessageTuple?> = Variable(nil)
    let addPhotoAction: Variable<(MessageTuple, yesHandler: SimpleAction, noHandler: SimpleAction)?> = Variable(nil)
    let activeViewModel: Variable<Any?> = Variable(nil)
    
    let disposeBag = DisposeBag()
    
    let club: Club

    let feedViewModel: FeedViewModel = FeedViewModel()
    
    init(club: Club, startFromCheckin: Bool = false) {
        
        self.club = club
        
        if club.observableEntity() == nil {
            
            ///we're gonna refreh club soon
            club.saveEntity()
        }
        
        ///we don't have enough info to fully present club description yet
        if Club.entityByIdentifier(club.id)?.clubDescriptors.ageGroup == nil {
            ClubsManager.clubForId(club.id, forceRefresh: true)
                .subscribe(onNext: {_ in })
                .disposed(by: disposeBag)
        }
        
        if startFromCheckin {
            presentCheckinScreen(nil)
        }
    }
    
    func filterAtIndexSelected(_ index: Int) {
        
        let dp = ClubFeedDataProvider(club: club,
                                    filter: FeedFilter(rawValue: index)!)
        
        feedViewModel.dataProvider.value = dp
        
    }
    
}

extension ClubFeedViewModel {
    
    func addMedia(_ type: MediaItemType) {
        
        if canAddCheckinDependentModel(type == .photo ? .addPhoto : .addVideo) {
            let addMediaViewModel = AddMediaViewModel(club: club, type: type)
            
            addMediaViewModel.postAction.asObservable()
                .filter { $0 != nil }
                .map { $0! }
                .subscribe(onNext: { action in
                    switch action {
                        
                    case .noAction:
                        self.activeViewModel.value = nil
                        
                    case .mediaAdded(let media):
                        self.activeViewModel.value = nil
                        
                        ///adding created report to feed
                        self.feedViewModel.insertFeedItemAtBegining(.mediaType(media: media))
                        
                        ///showing success message 
                        self.infoMessage.value = ("Success", "Media is uploaded!")
                        
                    }
                    
                }
                )
.disposed(by: disposeBag)
            
            activeViewModel.value = addMediaViewModel
        }
        
    }
    
    func addReport() {
        
        if canAddCheckinDependentModel(PostCheckinAction.addReport) {
            let reportViewModel = CreateReportViewModel(club: club)
            
            reportViewModel.composedReport.asObservable()
                .filter{ $0 != nil }
                .map { $0! }
                .subscribe(onNext: { composedReport in
                    self.activeViewModel.value = nil
                    
                    ///adding created report to feed
                    self.feedViewModel.insertFeedItemAtBegining(.reportType(report: composedReport))
                    
                    ///presenting success message
                    let message : MessageTuple = ("Success", "Report created and submitted, Good job! Would you like to create a photo?")
                    self.addPhotoAction.value = (message, {
                        self.addMedia(.photo)
                    },
                    {
                        self.feedViewModel.presentReportDetails(composedReport)
                    })
                }
                )
.disposed(by: disposeBag)
            
            activeViewModel.value = reportViewModel
        }
        
    }
    
    fileprivate func canAddCheckinDependentModel(_ predefinedAction: PostCheckinAction?) -> Bool {

        guard let userLocation = LocationManager.instance.lastRecordedLocation else {
            assert(false, "We expect currentLocation to be available")
            return false
        }
        
        guard let clubValue = Club.entityByIdentifier(club.id) else {
            return false
        }
        
        guard userLocation.distance(from: clubValue.location) < AppConfiguration.acceptableClubRadius else {
            
            var str = ""
            if let a = predefinedAction {
                switch a {
                case .addPhoto: str = "photos"
                case .addReport: str = "a review"
                case .addVideo: str = "videos"
                case .noAction: str = "these"
                }
            }
            
            infoMessage.value = ("Error" ,"To add \(str) you need to be in the \(clubValue.name)!")
            return false
        }
        
        let userCheckedIn = CheckinContext.isUserChekedInClub(clubValue)
        
        if !userCheckedIn {
            presentCheckinScreen(predefinedAction)
        }
        
        return userCheckedIn
    }
    
    fileprivate func presentCheckinScreen(_ predefinedAction: PostCheckinAction?) {
        let viewModel = CheckinViewModel(club: club, predefinedPostAction: predefinedAction)
        
        viewModel.postCheckinAction
            .asDriver()
            .filter{ $0 != nil }.map { $0! }
            .drive(onNext: { action in
                
                switch action
                {
                case .noAction:
                    self.activeViewModel.value = nil
                    
                case .addPhoto:
                    self.addMedia(.photo)
                    
                case .addReport:
                    self.addReport()
                    
                case .addVideo:
                    self.addMedia(.video)
                    
                }
                
            }
            )
.disposed(by: disposeBag)
        
        activeViewModel.value = viewModel
    }
    
    func dancerTap() {
        
        let c = club
        guard club != User.currentUser()?.dancerClub else {
            return
        }
        
        Alamofire.request(AccessTokenRouter.setDancerClub(club: club))
            .rx_Response(EmptyResponse.self)
            .silentCatch()
            .subscribe(onNext: { _ in
                var u = User.currentUser()!
                u.dancerClub = c
                u.saveLocally()
            })
            .disposed(by: disposeBag)
        
    }
    
}
