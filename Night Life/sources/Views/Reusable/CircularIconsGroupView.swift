//
//  CircularIconsGroup.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class CircularIconsGroupView : UIView {

    fileprivate var iconImageViews : [UIImageView] = []
    
    let bag = DisposeBag()
    
    func addIconURLs(_ iconURLs: [String]) {
        
        self.subviews.forEach { $0.removeFromSuperview() }
        
        iconImageViews =
        iconURLs.suffix(8).map { [unowned self] iconURL -> UIImageView in
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            imageView.layer.cornerRadius = imageView.frame.size.height / 2
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            ImageRetreiver.imageForURLWithoutProgress(iconURL)
                .drive(imageView.rx.image)
                
.disposed(by: self.bag)
            
            return imageView
        }
        
        iconImageViews.forEach { [unowned self] view in
                self.addSubview(view)
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard iconImageViews.count > 0 else {
            return
        }
        
        let avaliableWidth = self.bounds.size.width;
        let oneButtonWidth = self.iconImageViews.first!.bounds.size.width;
        
        var itemsInRow: Int = Int(avaliableWidth / oneButtonWidth);
        
        if itemsInRow > self.iconImageViews.count {
            itemsInRow = self.iconImageViews.count;
        }
        
        let spacing: CGFloat = 20
        
        var previousIcon : UIImageView? = nil
        
        iconImageViews.forEach { icon in
            
            if let prev = previousIcon
            {
                icon.center = CGPoint(x: prev.center.x + icon.bounds.size.width + spacing,
                    y: prev.center.y)
                
            }
            else
            {
                icon.center = CGPoint(x: spacing,
                    y: self.bounds.size.height / 2)
            }
            
            previousIcon = icon;
        }
        
    }

}
