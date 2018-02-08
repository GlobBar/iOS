//
//  MainAppController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

class MainAppController : SWRevealViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.rearViewRevealWidth = self.view.frame.size.width - 64
        
    }

    
}
