//
//  ClubTableCell.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/26/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import Alamofire


class ClubTableCell : UITableViewCell {
    
    @IBOutlet weak var travelButton: UIButton!
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var adresLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var checkinCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel! {
        didSet {
            distanceLabel.layer.borderWidth  = 1
            distanceLabel.layer.borderColor = UIColor.white.cgColor
            distanceLabel.layer.cornerRadius = 3
        }
    }
    
    @IBOutlet weak var lastCheckinUsersView: CircularIconsGroupView!
    
    @IBOutlet weak var gradientContainer: GradientView!
    
    fileprivate var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        lastCheckinUsersView.addIconURLs([])
    }
    
    func setClub(_ club: Club) {
        
        guard let clubVariable = club.observableEntity() else {
            print("Can't set club info. No club stored for id \(club.identifier)")
            return
        }
        
        let clubDriver = clubVariable.asDriver()
        
        clubDriver.map { $0.name }
            .drive(clubNameLabel.rx.text)
            
.disposed(by: disposeBag)
        
        clubDriver.map { $0.adress }
            .drive(adresLabel.rx.text)
            
.disposed(by: disposeBag)
        
        ImageRetreiver.imageForURLWithoutProgress(clubVariable.value.coverPhotoURL)
            .drive(coverPhotoImageView.rx.image)
            
.disposed(by: disposeBag)

        clubDriver
            .asObservable()
            .flatMap { club in
                Observable.combineLatest(
                    club.lastCheckedInUsers /// all lastCheckedInUsers
                    .flatMap { ///filtering out users taht are not in storage
                        $0.observableEntity()?.asObservable() /// getting observable user from storage
                }) { actualUsers in ///mapping true users to their picture URLs
                        actualUsers.map { $0.pictureURL! }
                }
            }
            .subscribe(onNext: { [unowned self] icons in
                self.lastCheckinUsersView.addIconURLs(icons)
            })
.disposed(by: disposeBag)
        
        clubDriver
            .map{ String($0.checkinsCount) }
            .drive( checkinCountLabel.rx.text )
            
.disposed(by: disposeBag)
        
        clubDriver
            .map{ String($0.likesCount) }
            .drive( likeCountLabel.rx.text )
            
.disposed(by: disposeBag)
        
        clubDriver
            .map{ $0.isLikedByCurrentUser ? "like_on" : "like_off" }
            .distinctUntilChanged()
            .map{ name -> UIImage in UIImage(named: name)! }
            .drive(onNext: { [unowned self] (image: UIImage) in
                
                let crossFade = CABasicAnimation(keyPath: "contents")
                crossFade.duration = 0.2
                crossFade.fromValue = self.likeButton.imageView?.image?.cgImage
                crossFade.toValue = image.cgImage
                crossFade.isRemovedOnCompletion = false
                crossFade.fillMode = kCAFillModeForwards;
                self.likeButton?.imageView?.layer.add(crossFade, forKey:"animateContents")
                
                //Make sure to add Image normally after so when the animation
                //is done it is set to the new Image
                self.likeButton.setImage(image, for: .normal)
                
            }
            )
.disposed(by: disposeBag)

        likeButton.rx.tap
            .throttle(0.1, scheduler: MainScheduler.instance)
            .flatMapLatest{ _ -> Observable<Void> in
                let clubValue = clubVariable.value
                
                let rout = clubValue.isLikedByCurrentUser ?
                PlacesRouter.unLike(club: clubValue) :
                PlacesRouter.like(club: clubValue)
                
                return Alamofire.request(rout)
                    .rx_Response(EmptyResponse.self)
                
            }
            .subscribe(onNext: { _ in
                
                    var clubValue = clubVariable.value
                    clubValue.switchLikeStatus()
                    clubValue.saveEntity()
                    
                }, onError: { e in
                    print("Error switching like status")
                })
            
.disposed(by: disposeBag)
        
        ///fake location
        LocationManager.instance.fakeLocation.asDriver()
            .drive(onNext: { [unowned self] maybeLocation in
                guard let location = maybeLocation,
                    location.coordinate.longitude == clubVariable.value.location.coordinate.longitude
                    else {
                        
                        self.travelButton.isEnabled = true
                        self.travelButton.setTitle("Travel to this this club", for: .normal)
                        
                        return
                }
                self.travelButton.isEnabled = false
                self.travelButton.setTitle("You're in nearby this club", for: .normal)
                
            }
        )
.disposed(by: disposeBag)
        
        travelButton.rx.tap.subscribe(onNext:{ _ in
            LocationManager.instance.fakeLocation.value = clubVariable.value.location
        }
        )
.disposed(by: disposeBag)
        
#if ADHOC || DEBUG
        travelButton.isHidden = false
#else
        travelButton.isHidden = true
#endif
        
        ///location label
        Observable.combineLatest(clubDriver.asObservable(),
                                 LocationManager.instance
                                    .lastRecordedLocationObservable.take(1)) { club, location in
                                        location.distance(from: club.location).metersToMiles
            }
            .map { String(format: "%.2f miles", $0) }
            .bind(to: distanceLabel.rx.text)
            
.disposed(by: disposeBag)
    }
    
}
