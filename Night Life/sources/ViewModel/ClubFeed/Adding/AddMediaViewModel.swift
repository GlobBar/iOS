//
//  AddMediaViewModel.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

import ObjectMapper

import AVFoundation

enum PostAddMediaActions {
    
    case noAction
    case mediaAdded(media: MediaItem)
    
}

struct AddMediaViewModel {

    let postAction = Variable<PostAddMediaActions?>(nil)
    let uploadProgress = Variable<Float?>(nil)
    
    let selectedImage: Variable<UIImage?> = Variable(nil)
    let selectedVideoURL: Variable<(NSURL, UIImage)?> = Variable(nil)
    
    let bag = DisposeBag()
    
    fileprivate let club: Club
    let mediaType: MediaItemType
    
    
    init(club: Club, type: MediaItemType) {
        self.club = club
        self.mediaType = type
    }
    
    func uploadSelectedMedia(_ description: String) {
        
        if let image = selectedImage.value {
            uploadPhoto(image, description: description)
        }
        else if let videoTuple = selectedVideoURL.value {
            uploadVideo(videoTuple.0 as URL, thumbnail: videoTuple.1, description: description)
        }
        
    }
    
    
    func addedPhoto(_ image: UIImage) {
        selectedImage.value = image
    }
    
    func addedVideo(_ url: URL) {
        
        ///probably fire spinner while we prepare thumbnail
        ThumbnailGenerator.thumbnailObservable(url as NSURL)
            .subscribe(onNext: { image in
                self.selectedVideoURL.value = (url as NSURL, image)
        }
        )
.disposed(by: bag)
        
    }
    
    func cancelMediaAdding() {
        
        postAction.value = .noAction
        
    }
    
}

extension AddMediaViewModel {
    
    fileprivate func uploadPhoto(_ image: UIImage, description: String) {
        
        let fixedImage = image.fixOrientation()
        
        mediaUpload(.uploadPhoto, formSerializer: { formData in
            
            formData.append(UIImageJPEGRepresentation(fixedImage, 0.6)!,
                withName: "file",
                fileName: "image.jpg",
                mimeType: "image/jpg")
            
            formData.append("\(self.club.id)".data(using: .utf8)!,
                            withName: "place_pk")
            formData.append(description.data(using: .utf8)!,
                            withName: "description")
            
        }) { mediaItem in
            
            ImageRetreiver.registerImage(fixedImage, forKey: mediaItem.mediaURL)
            ImageRetreiver.registerImage(fixedImage, forKey: mediaItem.thumbnailURL)
            
            self.postAction.value = .mediaAdded(media: mediaItem)
        }
        
    }
    
    fileprivate func uploadVideo(_ fileURL: URL, thumbnail: UIImage, description: String) {
        
        let fixedThumbnail = thumbnail.fixOrientation()
        
        mediaUpload(.uploadVideo, formSerializer: { (formData: MultipartFormData) in
            
            formData.append(fileURL,
                            withName: "file",
                            fileName: "video.mov",
                            mimeType: "video/quicktime")
            
            formData.append(UIImageJPEGRepresentation(fixedThumbnail, 0.6)!,
                            withName: "thumbnail",
                            fileName: "video_thumbnail.jpg",
                            mimeType: "image/jpg")
            
            formData.append("\(self.club.id)".data(using: .utf8)!,
                            withName: "place_pk")
            formData.append(description.data(using: .utf8)!,
                            withName: "description")
            
        }) { mediaItem in
            
            //ImageRetreiver.registerImage(image, forKey: mediaItem.mediaURL)
            
            self.postAction.value = .mediaAdded(media: mediaItem)
        }
        
    }
    
    fileprivate func mediaUpload( _ rout: FeedDisplayableRouter,
                              formSerializer: @escaping (MultipartFormData) -> Void,
                              completitionHandler: @escaping (MediaItem) -> () ) {
        
        
        Alamofire.upload(multipartFormData: formSerializer,
                         with: rout,
                         encodingCompletion: { (res: SessionManager.MultipartFormDataEncodingResult) in
                            
                            switch res {
                            case .success(let upload, _, _):
                                
                                upload.uploadProgress(closure: { (pr) in
                                
                                    self.uploadProgress.value = Float(pr.fractionCompleted)
                                    
                                })
                                
                                upload
                                    .rx_Response(Response<MediaItem>.self)
                                    .subscribe(onNext: { parsedMedia in
                                        
                                        parsedMedia.postOwnerId = User.currentUser()!.id
                                        
                                        parsedMedia.saveEntity()
                                        completitionHandler(parsedMedia)
                                        
                                    }, onError: { (e) -> Void in
                                        
                                        ///TODO: Hadle error
                                        assert(false, "unhadled error on add photo")
                                        
                                    })
                                    
                                    .disposed(by: self.bag)
                                
                            case .failure(let encodingError):
                                
                                assert(false, "\(encodingError)")
                                
                            }

        })
        
        
    }
    
}
