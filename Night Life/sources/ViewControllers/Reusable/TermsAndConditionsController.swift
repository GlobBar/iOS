//
//  TermsAndConditionsController.swift
//  GlobBar
//
//  Created by Vlad Soroka on 4/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

class TermsAndConditionsController : UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var titleString: String!
    var link: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = titleString
         
        if let url = URL(string: link) {
            webView.loadRequest(URLRequest(url: url))
        }
        
    }
    
}
