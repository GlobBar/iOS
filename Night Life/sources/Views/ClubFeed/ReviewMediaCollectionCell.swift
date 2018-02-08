//
//  ReviewPhotoCollectionViewCell.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import MBCircularProgressBar

class ReviewMediaCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var hotImageView: UIImageView!
    
    @IBOutlet weak var playIcon: UIImageView!
    
    fileprivate var disposeBag = DisposeBag()
    
    func setMedia( _ media: MediaItem ) {
        
        playIcon.isHidden = media.type != .video
        
        media.observableEntity()?.asDriver()
            .map { !$0.isHot }
            .drive(hotImageView.rx.isHidden)
            
.disposed(by: disposeBag)
        
        Driver.just("")
            .throttle(0.3)///throttle image loading for quick scrolling case
            .flatMap { _ in
                
                return ImageRetreiver.imageForURL(media.thumbnailURL)
                    .asDriver(onErrorJustReturn: (nil, 1, false))
                
            }
            .drive(onNext: { [unowned self] (maybeImage, progress, _) in
                
                guard let image = maybeImage else {
                    
                    self.progressBar.isHidden = false
                    self.progressBar.value = CGFloat(progress) * CGFloat(100)
                    
                    return
                }
                
                self.progressBar.isHidden = true
                UIView.transition(with: self.imageView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    self.imageView.image = image
                    }, completion: nil)
                
                
            }
            )
.disposed(by: disposeBag)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        // because life cicle of every cell ends on prepare for reuse
        disposeBag = DisposeBag()
    }
    
}
