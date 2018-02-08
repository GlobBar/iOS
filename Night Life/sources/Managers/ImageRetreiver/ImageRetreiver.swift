//
//  ImageRetreiver.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/1/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import Alamofire
import Kingfisher

typealias ImageRetreiveResult = (image: UIImage?, progress: Double, finished: Bool)

enum ImageRetreiverError: Error {
    
    case CorruptedDataDownloaded
    
}

/**
 *  @discussion - Utility for retreiving image by given URL in Rx-way
 *  downloaded image is cached and used on next calls to save up on Internet traffic
 */
extension ImageRetreiver {
    
    static func imageForURLWithoutProgress(_ url: String) -> Driver<UIImage?> {
        
        return self.imageForURL(url)
            .filter { $0.finished }
            .map { $0.image }
        
    }
    
}


struct ImageRetreiver {
    
    private static var imageCache: ImageCache {
        let cache = KingfisherManager.shared.cache
        
        cache.maxDiskCacheSize = UInt(50 * 1024 * 1024)
        
        return cache
    }
    
    static func imageForURL<T: URLConvertible> (_ url: T) -> Driver<ImageRetreiveResult> {
        
        var unwrappedURL: URL!
        do {
            unwrappedURL = try url.asURL()
        }
        catch {
            return Driver.just( (nil, 0, true) )
        }
        
        let request = URLRequest(url: unwrappedURL)
        return imageForURLReques(request: request)
        
    }
    
    static func imageForURLReques<T: URLRequestConvertible>(request: T) -> Driver<ImageRetreiveResult> {
        
        guard let unwrappedRequest = try? request.asURLRequest(),
            let key = unwrappedRequest.url?.absoluteString else {
                return Driver.just( (nil, 0, true) )
        }
        
        return imageCache
            .rxex_retreiveImage(forKey: key)
            .flatMap{ maybeImage -> Observable<ImageRetreiveResult> in
                
                if let image = maybeImage {
                    return Observable.just((image, 1, true))
                }
                
                return Observable.create { observer in
                    
                    let imageLoadRequest = Alamofire.request(request)
                        .downloadProgress{ progress in
                            
                            observer.onNext((nil, progress.fractionCompleted, false))
                        }
                        .responseData{ result in
                            if let error = result.result.error {
                                observer.onError(error)
                                return
                            }
                            
                            guard let imageData = result.result.value,
                                let image = UIImage(data: imageData) else {
                                    
                                    observer.onNext((nil, 0, true))
                                    return
                            }
                            
                            imageCache.store(image,
                                             forKey: key,
                                             toDisk: true,
                                             completionHandler: nil)
                            
                            observer.onNext((image, 1, true))
                    }
                    
                    return Disposables.create {
                        imageLoadRequest.cancel()
                    }
                    }
                    .retry(3)
                
            }
            .asDriver(onErrorJustReturn: (nil, 0, true))
        
    }
    
    static func registerImage(_ image: UIImage, forKey key: String) {
        
        imageCache.store(image, forKey: key, toDisk: true, completionHandler: nil)
        
    }
    
    static func cachedImageForKey(key: String) -> UIImage? {
        
        return imageCache.retrieveImageInDiskCache(forKey: key)
        
    }
    
    static func flushImageForKey(key: String) {
        
        imageCache.removeImage(forKey: key)
        
    }
    
    static func flushCache() {
        imageCache.clearMemoryCache()
    }
}

extension ImageCache {
    
    func rxex_retreiveImage(forKey key: String) -> Observable<UIImage?> {
        
        return Observable.create { [unowned self] observer in
            
            self.retrieveImage(forKey: key, options: nil) { (maybeImage: Image?, _) in
                
                if let image = maybeImage {
                    observer.onNext(image)
                }
                else {
                    observer.onNext(nil)
                }
                
                observer.onCompleted()
                
            }
            
            return Disposables.create()
        }
        
        
    }
    
}
