//
//  ThumbnailGenerator.swift
//  Night Life
//
//  Created by Vlad Soroka on 4/8/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import AVFoundation

enum ThumbnailGenerator {}

extension ThumbnailGenerator {
    
    static func thumbnailObservable(_ assetURL: NSURL) -> Observable<UIImage> {
        return Observable.create { observer in
            
            let asset = AVAsset(url: assetURL as URL)
            let generator = AVAssetImageGenerator(asset: asset)
            
            generator.appliesPreferredTrackTransform = true
            generator.apertureMode = AVAssetImageGeneratorApertureMode.encodedPixels
            
            let time = CMTimeMake(0, 60)
            
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]){ (requestTime, imageRef:CGImage?, actualTime, result, error) in
                if let ref = imageRef {
                    observer.onNext(UIImage(cgImage: ref))
                }
                else {
                    observer.onError(error!)
                }
            }
            
            
            return Disposables.create {
                generator.cancelAllCGImageGeneration()
            }
            
        }
    }

    
}
