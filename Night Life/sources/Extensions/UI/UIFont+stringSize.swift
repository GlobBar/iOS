//
//  UIFont+stringSize.swift
//  GlobBar
//
//  Created by Vlad Soroka on 2/20/17.
//  Copyright © 2017 com.NightLife. All rights reserved.
//

import UIKit

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                 options: .usesLineFragmentOrigin,
                                                 attributes: [NSAttributedStringKey.font: self],
                                                 context: nil).size
    }
}
