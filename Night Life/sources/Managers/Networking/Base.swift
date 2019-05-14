//
//  Base.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/16/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Alamofire
import RxSwift

struct GatewayConfiguration {

//#if DEBUG
//    
//    static let hostName = "http://127.0.0.1:8000"
//    
//    static let clientId = "67zg2qByvIfygCVA3QzDEg43iu2c8ZliHEmj9b75"
//    static let clientSecret = "PeM2lYqNNEslKm3sKuRJda2AArZIry3YPlDX7By3YM7Co1QSS4FXeziVzvaBiTWcorj0auRANoYwD7gmEb54CZguzjH4IVxLTZ3d9wlppPMkW5kmNrap5DY5ZLaTCcod"
    
//#elseif ADHOC
//    static let hostName = "http://test.globbar.partyzhere.com"
//    
//    static let clientId = "9FOssUJCOxk9VxBMtlftVsOcPyitNbFaTpX4dJEb"
//    static let clientSecret = "mrWAhEt1WQU2HObbIrQkuLrtfKV4J3cAMYnKzXr25Fwwu1qfXwiZOcGEexAyoUBqacAuE94fN7BXKrtrIbDdIOnScaRHTKrMDnUHPKXf88IGkv4Wbh7unXM0jAHpTDX7"
    
//#else
    
    static let hostName = "http://107.170.102.38:9000"
    
    static let clientId = "LZBcV40CXsWKedPwUEfYae81TIMKGZcPEzLUmfc4"
    static let clientSecret = "EqE4JoEnRBiO4Yslze9vrElueXvGURa9XqONMeObb2lh1COxgCWC5Q4X5J92ZyXHIFCgQJbzq3yWOVMCRrLj9nb6OJlS6eePyVsPW8ZaQTnBZ2BaEL7rGSyI1iMjxEJN"
    
//#endif

}

protocol AuthorizedRouter : URLRequestConvertible {
    
    func authorizedRequest(_ method: Alamofire.HTTPMethod,
                           path: String,
                           encoding: ParameterEncoding,
                           body: Parameters,
                           headers: HTTPHeaders?) -> URLRequest
    
    func unauthorizedRequest(_ method: Alamofire.HTTPMethod,
                             path: String,
                             encoding: ParameterEncoding,
                             body: Parameters,
                             headers: HTTPHeaders?) -> URLRequest
    
}

extension AuthorizedRouter {
    
    func authorizedRequest(_ method: Alamofire.HTTPMethod,
                           path: String,
                           encoding: ParameterEncoding = URLEncoding.default,
                           body: Parameters = [:],
                           headers: HTTPHeaders? = nil) -> URLRequest{
        
        var request = self.unauthorizedRequest(method,
                                               path: path,
                                               encoding: encoding,
                                               body: body,
                                               headers: headers)
        
        guard let token = AccessToken.token else {
            fatalError("Can't make authorized request without stored token")
        }
        
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func unauthorizedRequest(_ method: Alamofire.HTTPMethod,
                             path: String,
                             encoding: ParameterEncoding = URLEncoding.default,
                             body: Parameters = [:],
                             headers: HTTPHeaders? = nil) -> URLRequest {
    
            let URL = NSURL(string: GatewayConfiguration.hostName)!
            var request = URLRequest(url: URL.appendingPathComponent(path)!)
            request.httpMethod = method.rawValue
            
            if let h = headers {
                for (key, value) in h {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            do {
                return try encoding.encode(request, with: body)
            }
            catch (let error) {
                fatalError("Error encoding request \(request), details - \(error)")
            }
            
    }
    
}
