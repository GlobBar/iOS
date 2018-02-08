//
//  InstagramLoginViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/12/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

enum InstagramError : Error {
    case userCanceled
    case failedToLoadScreen
}

typealias AccessTokenCallback = (_ token: String?,_ error: InstagramError? ) -> Void


class InstagramLoginViewController: UIViewController, UIWebViewDelegate {
    
    private let webView = UIWebView()
    private let callback: AccessTokenCallback
    private weak var presenter: UIViewController?
    
    init(presenter: UIViewController, callback: @escaping AccessTokenCallback) {
        self.callback = callback
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentLogin() {
        self.presenter!.present(UINavigationController(rootViewController: self),
                                animated: true,
                                completion: nil)
    }
    
    func stopLoading() {
        webView.stopLoading()
    }
    
    override func loadView() {
        super.loadView()
        
        let webView = self.webView
        webView.frame = self.view.frame
        webView.scrollView.bounces = false;
        webView.contentMode = UIViewContentMode.scaleAspectFit;
        webView.delegate = self;
        
        self.view.addSubview(webView)
        
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InstagramLoginViewController.cancel))
        
    }
    
    private var configuration : [String: String] {
        get {
            let configPath = Bundle.main.path(forResource: "InstagramKit", ofType: "plist")!
            return NSDictionary(contentsOfFile: configPath) as! [String : String]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HTTPCookieStorage.shared.cookies!
            .filter { ($0.properties![HTTPCookiePropertyKey.domain] as! String) == "www.instagram.com" }
            .forEach{ HTTPCookieStorage.shared.deleteCookie($0) }
        
        
        let baseURL = configuration["InstagramKitAuthorizationUrl"]!
        let appClientID = configuration["InstagramKitAppClientId"]!
        let appRedirectURI = configuration["InstagramKitAppRedirectURL"]!
        
        let urlString = baseURL + "?client_id=" + appClientID + "&redirect_uri=" + appRedirectURI + "&response_type=token&scope=" + "basic"
        
        let url = URL(string: urlString)!
        let request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10.0)
        
        webView.loadRequest(request)
    }
    
    @objc func cancel() {
        self.presenter!.dismiss(animated: true, completion: nil)
        
        self.callback(nil, .userCanceled)
        
    }
    
    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        let redirectURI = configuration["InstagramKitAppRedirectURL"]!
        
        let URLString = request.url!.absoluteString
        if URLString.hasPrefix(redirectURI) {
            let delimiter = "access_token="
            let components = URLString.components(separatedBy: delimiter)
            if components.count > 1 {
                let accessToken = components.last!
                
                self.presenter!.dismiss(animated: true, completion: nil)
                
                self.callback(accessToken, nil)
                
            }
            return false;
        }
        return true;
        
    }
    
    func webView(_ webView: UIWebView,
                 didFailLoadWithError error: Error) {
        
        guard (error as NSError).code != 102 else { ///Frame load interrupted
            return
        }
        
        self.presenter!.dismiss(animated: true, completion: nil)
        
        self.callback(nil, .failedToLoadScreen)
        
    }
    
}
