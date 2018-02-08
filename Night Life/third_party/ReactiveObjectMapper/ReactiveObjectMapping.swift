//
//  ReactiveObjectMapping.swift
//  Campfiire
//
//  Created by Vlad Soroka on 10/11/16.
//  Copyright © 2016 campfiire. All rights reserved.
//

import Alamofire
import ObjectMapper
import RxSwift

enum MappingError: Error {
    case generic
}

extension Alamofire.DataRequest {
    
    func rx_Response<T: ResponeProtocol>(_ unused: T.Type) -> Observable<T.DataType> {
        
        return Observable.create { [weak self] (subscriber) -> Disposable in
            
            let request =
                self?.validate(statusCode: 200...299)
                    .responseObject { [weak self] (response: DataResponse< T >) in
                
                do {
                    guard let s = self else {
                        
                        ///happens when Observer get's disposed, but request.cancel() does not interrupt network request and still invokes completition handler
                        
                        subscriber.onCompleted()
                        return;
                    }
                    
                    let data = try s.processResponse(response: response)
                    
                    subscriber.onNext( data )
                    subscriber.onCompleted()
                }
                catch (let er) {
                    
                    subscriber.onError(er)
                    
                }
            }
            
            return Disposables.create { request?.cancel() }
        }
    }
    
    func rx_ArrayResponse<T: Mappable>(_ unused: T.Type) -> Observable<[T]> {
        
        return Observable.create { [weak self] (subscriber) -> Disposable in
            
            let request =
                self?.validate(statusCode: 200...299)
                    .responseArray { [weak self] (response: DataResponse< [T] >) in
                        
                        do {
                            guard let s = self else {
                                
                                ///happens when Observer get's disposed, but request.cancel() does not interrupt network request and still invokes completition handler
                                
                                subscriber.onCompleted()
                                return;
                            }
                            
                            let data = try s.processArrayResponse(response: response)
                            
                            subscriber.onNext( data )
                            subscriber.onCompleted()
                        }
                        catch (let er) {
                            
                            subscriber.onError(er)
                            
                        }
            }
            
            return Disposables.create { request?.cancel() }
        }
    }
    
}

extension Alamofire.DataRequest {
    
    fileprivate func processResponse<S: ResponeProtocol>
        (response : DataResponse<S>) throws -> S.DataType {
        
        if let er = response.result.error {
            throw er
        }
        
        guard let mappedResponse = response.result.value else {
            fatalError("Result is not success and not error")
        }
        
        guard let data = mappedResponse.data else {
            throw MappingError.generic
        }
        
        return data
    }
    
    fileprivate func processArrayResponse<S: Mappable>
        (response : DataResponse<[S]>) throws -> [S] {
        
        if let er = response.result.error {
            throw er
        }
        
        guard let mappedResponse = response.result.value else {
            fatalError("Result is not success and not error")
        }
        
        return mappedResponse
    }
    
}

///TODO: Verify, that images are not exreamly heavy, probably squeeze them

///currently works only for images
func rx_upload<T: AuthorizedRouter>
              ( rout: T, data: [String : Data]) -> Observable<Alamofire.DataRequest> {

    return Observable.create { (observer) -> Disposable in
     
        Alamofire
            .upload(multipartFormData: { (formData) in
            
            for (key, value) in data {
                formData.append(value, withName: key, fileName: "image.jpg", mimeType: "image/jpeg")
            }
            
        }, with: rout,
           encodingCompletion: { (res: SessionManager.MultipartFormDataEncodingResult) in
            
            switch res {
            case .failure(let er):
                observer.onError(er)
                
            case .success(let request, _, _):
                
                observer.onNext( request )
                observer.onCompleted()
                
            }
            
        })
        
        return Disposables.create {  }
        
    }
    

    
}
