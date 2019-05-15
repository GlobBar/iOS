//
//  ProgressView.swift
//     
//
//  Created by Vlad Soroka on 10/11/16.
//  Copyright © 2016    All rights reserved.
//

import UIKit
import QuartzCore

class SpinnerView : UIImageView {
    
    convenience init() {
        
        self.init(image: UIImage(named: "loader")!)
        
        let animationDuration: CFTimeInterval = 0.8;
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0;
        animation.toValue = Double.pi * 2
        animation.duration = animationDuration;
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float.greatestFiniteMagnitude;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = false;
        self.layer.add(animation, forKey:"rotate")
        
        self.backgroundColor = UIColor.clear
        
    }
    
}
