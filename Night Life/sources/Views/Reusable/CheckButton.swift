//
//  CheckView.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/5/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

class CheckButton : UIButton {
    
    fileprivate var titleEdgeInset : UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    override var intrinsicContentSize : CGSize {
        var s = super.intrinsicContentSize
        s.width += titleEdgeInset.left
        return s
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setImage(UIImage(named: "Off"), for: UIControlState())
        self.setImage(UIImage(named: "On"), for: .selected)
        
        self.addTarget(self, action: #selector(getter: UIDynamicBehavior.action), for: .touchUpInside)
        
        self.titleEdgeInsets = titleEdgeInset
    }
    
    func action() {
        
        self.isSelected = !self.isSelected
        
    }
    
}
