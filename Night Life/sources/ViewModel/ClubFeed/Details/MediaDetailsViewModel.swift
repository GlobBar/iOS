//
//  PhotoDetailsViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import Alamofire

import ObjectMapper

import MobileCoreServices

enum PostMediaDetailsAction {
    
    case deletedMedia(media: MediaItem)
    
}

extension MediaDetailsViewModel {
    
    var lockedSatus: Driver<Bool> {
        return mediaDriver.map { $0.isLocked }
    }
    
}

struct MediaDetailsViewModel {
    
    let club: Club
    let media: MediaItem
    let message: Variable<String?> = Variable(nil)
    let bag = DisposeBag()
    let likeProgressIndicator = ViewIndicator()
    
    let editPhotoViewModel: Variable<TextBoxViewModel?> = Variable(nil)
    
    let shareController: Variable<UIDocumentInteractionController?> = Variable(nil)
    let shareButtonEnabled: Variable<Bool> = Variable(false)
    
    let postAction = Variable<PostMediaDetailsAction?>(nil)
    
    var mediaDriver: Driver<MediaItem> {
        guard let m = media.observableEntity() else {
            fatalError("Can't present details of media that has not been stored in memmory storage")
        }
        
        return m.asDriver()
    }
    
    ///FIXME: reimplement to MediaPlayer ViewModel. Observe data on it's viewModel and get rid of ViewController reference here
    weak var mediaPlayer: MediaPlayerViewController? {
        didSet {
            guard let m = mediaPlayer else { return }
            
            Observable.of(
            m.image.asObservable().map ({ $0 != nil }),
            m.playableContentURL.asObservable().map ({ $0 != nil }))
            .merge()
            .bind(to: shareButtonEnabled)
.disposed(by: bag)
        }
    }
    
    var canAlterMedia: Bool {
        get {
            return media.postOwnerId == User.currentUser()!.id
        }
    }
    
    init(club: Club, media: MediaItem) {
        self.club = club
        self.media = media
        
        let a =
        editPhotoViewModel.asObservable()
            .filter { $0 != nil }.map { $0! }
            .flatMapLatest { viewModel -> Observable<String?> in
                return viewModel.text.asObservable()
            }
            .filter { $0 != nil }.map { $0! }
        
        let media = media
        Observable.combineLatest(a, Observable.just(media).take(1)) { ($0, $1) }
            .subscribe(onNext: { [unowned message = self.message] args in
                Alamofire.upload(
                    multipartFormData: { formData in
                        
                        formData.append("\(args.1.id)".data(using: .utf8)!,
                                        withName: "report_pk")
                        formData.append(args.0.data(using: .utf8)!,
                                        withName: "description")
                        
                    },
                    with: FeedDisplayableRouter.updateMediaDescription,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            
                            let _ =
                            upload
                                .rx_Response(EmptyResponse.self)
                                .map { _ in
                                    
                                    let copy = media
                                    
                                    copy.mediaDescription = args.0
                                    copy.saveEntity()
                                    
                                    return "Description updated"
                                }
                                .bind(to: message)
                            
                        case .failure(let encodingError):
                            
                            assert(false, "\(encodingError)")
                            
                        }
                })
                
            }
            )
.disposed(by: bag)
        
    }
    
    var mediaURL : String {
        return media.mediaURL
    }
    
    var dateDescription: String {
        return UIConfiguration.stringFromDate(media.createdDate!)
    }
    
    var user: String {
        return UIConfiguration.stringFromDate(media.createdDate!)
    }
    
    func unlock() {
        
        var x = media
        x.isLocked = false
        x.saveEntity()
        
    }
    
    func performLikeAction() {
        
        Alamofire.request(FeedDisplayableRouter.likeMedia(media: media))
            .rx_Response(EmptyResponse.self)
            .trackView(viewIndicator: likeProgressIndicator)
            .map { _ -> String in
                
                self.media.setLikeStatusOn()
                self.media.saveEntity()
                
                return "Succesfully Liked photo"
            }
            .catchError{ (er: Error) -> Observable<String?> in
                
                return Observable.just("Internal server error. Give this info to the devs it might be helpful: " + (er as NSError).description)
            }
            .bind(to: message)
.disposed(by: bag)
        
    }
    
    func performEditAction() {
        editPhotoViewModel.value = TextBoxViewModel(displayText: media.mediaDescription)
    }
    
    func performDeleteAction() {
        
        Alamofire.request(FeedDisplayableRouter.deleteMedia(media: media))
            .rx_Response(EmptyResponse.self)
            .map { _ -> PostMediaDetailsAction in
                
                ImageRetreiver.flushImageForKey(key: self.media.thumbnailURL)
                ImageRetreiver.flushImageForKey(key: self.media.mediaURL)
                self.media.removeFromStorage()
                
                return .deletedMedia(media: self.media)
            }
            .bind(to: postAction)
.disposed(by: bag)
        
    }
    
    func shareAction() {
        
        guard let type = media.type, type == .photo || type == .video,
              let player = mediaPlayer else {
            fatalError("Can't share media other than Photo or Video")
        }

        let exportPath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: [.userDomainMask]).first!.appendingPathComponent("temp")
        
        var uti: String? = type == .photo ? kUTTypeImage as String : kUTTypeQuickTimeMovie as String
        
        if type == .photo {
            
            guard let image = player.image.value else {
                fatalError("Can't share without image loaded on mediaPlayer")
            }
            
            ///writing to public folder
            try! UIImageJPEGRepresentation(image, 1)!.write(to: exportPath,
                                                       options: [.atomic])
            
            uti = kUTTypeJPEG as String
        }
        else if type == .video {
            guard let videoURL = player.playableContentURL.value else {
                fatalError("Can't share without video stored on disk")
            }
            
            NSData(contentsOf: videoURL as URL)!.write(to: exportPath,
                                                       atomically: true)
            
            uti = kUTTypeMPEG4 as String
        }
        
        let controller = UIDocumentInteractionController(url: exportPath)
        controller.uti = uti
        
        shareController.value = controller
    }
    
}
