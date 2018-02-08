//
//  GradientLayer.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(fromHex:Int) {
        self.init(red:(fromHex >> 16) & 0xff, green:(fromHex >> 8) & 0xff, blue:fromHex & 0xff)
    }
}

extension UIView {
    
    func addLinearGradient(fromHexColor from: Int, toHexColor: Int) {
        
        let from = UIColor(fromHex: from)
        let toColor = UIColor(fromHex: toHexColor)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.layer.bounds;
        
        gradientLayer.colors = [from.cgColor, toColor.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        gradientLayer.cornerRadius = self.layer.cornerRadius;
        self.layer.addSublayer(gradientLayer)
        
    }
    
}

@IBDesignable class TIFAttributedLabel: UILabel {
    
    @IBInspectable var fontSize: CGFloat = 40.0
    
    @IBInspectable var fontFamily: String = "Raleway-Regular"
    
    override func awakeFromNib() {
        let attrString = NSMutableAttributedString(attributedString: self.attributedText!)
        attrString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: self.fontFamily, size: self.fontSize)!, range: NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}
