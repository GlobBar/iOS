//
//  CheckinViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/23/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class CheckinViewController : UIViewController {
    
    var viewModel : CheckinViewModel!
    
    fileprivate let bag = DisposeBag()
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var checkinsCountLabel: UILabel!
    @IBOutlet weak var checkinQuestionLabel: UILabel!
    @IBOutlet weak var checkinQuestionCheckmark: UIImageView!
    
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var clubAdressLabel: UILabel!
    @IBOutlet weak var dancingClubLabel: UILabel!
    @IBOutlet weak var todayCheckinLabel: UILabel!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    
    @IBOutlet weak var lastCheckedInUsersView: CircularIconsGroupView!
    
    @IBOutlet weak var chekinAffirmativeButton: UIButton!
    @IBOutlet weak var checkinNegativeButton: UIButton!
    
    @IBOutlet weak var createReportButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var recordVideoButton: UIButton!
    
    @IBOutlet weak var broadcastLocationButton: CheckButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()

        configureUI()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { assert(false) /*view model must be initialized before using view controller*/  }
        
        ///hidden vs. shown action buttons
        
        let hideObservable = viewModel.checkinControlsShown.asObservable()
        let showObservable = hideObservable.map { !$0 }
        
        showObservable
            .bind(to: chekinAffirmativeButton.rx.isHidden)
.disposed(by: bag)
        
        showObservable
            .bind(to: broadcastLocationButton.rx.isHidden)
.disposed(by: bag)
        
        hideObservable
            .bind(to: createReportButton.rx.isHidden)
.disposed(by: bag)
        
        hideObservable
            .bind(to: takePhotoButton.rx.isHidden)
.disposed(by: bag)
        
        hideObservable
            .bind(to: recordVideoButton.rx.isHidden)
.disposed(by: bag)
        
        hideObservable
            .filter { !$0 }
            .subscribe(onNext:{ [unowned self] _ in
                self.checkinQuestionLabel.text = "YOU'VE CHEKED IN HERE!"
                self.checkinQuestionLabel.font = UIFont(name: "Raleway-Medium", size: 15)
                self.checkinQuestionLabel.textColor = UIColor(fromHex: 0xf07800)
            }
            )
.disposed(by: bag)
        
        hideObservable
            .bind(to: checkinQuestionCheckmark.rx.isHidden)
.disposed(by: bag)
        
        ///loading spinner
        
        viewModel.loadingIndicator.asDriver()
            .drive(loadingSpinner.rxex_animating)
.disposed(by: bag)
        
        guard let observableClub = viewModel.club.observableEntity() else {
            fatalError("Can't present Checkin screen without stored club with id \(viewModel.club.id)")
        }
        
        ///cover photo
        observableClub.asDriver()
            .map{ $0.coverPhotoURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(coverPhotoImageView.rx.image)
.disposed(by: bag)
        
        ///logo
        observableClub.asDriver()
            .map{ $0.logoImageURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(logoImageView.rx.image)
.disposed(by: bag)
        
        ///name
        observableClub.asDriver()
            .map{ $0.name }
            .drive(clubNameLabel.rx.text)
.disposed(by: bag)
        
        ///addres
        observableClub.asDriver()
            .map{ $0.adress }
            .drive(clubAdressLabel.rx.text)
.disposed(by: bag)

        ///checkin count
        observableClub.asDriver()
            .map{ String($0.checkinsCount) }
            .drive(checkinsCountLabel.rx.text)
.disposed(by: bag)
        
        ///likes count
        observableClub.asDriver()
            .map{ String($0.likesCount) }
            .drive(likesCountLabel.rx.text)
.disposed(by: bag)
        
        ///last checked in users
        
        observableClub.asDriver()
            .asObservable()
            .flatMap { club in
                Observable.combineLatest(
                    club.lastCheckedInUsers /// all lastCheckedInUsers
                        .flatMap { ///filtering out users taht are not in storage
                            $0.observableEntity()?.asObservable() /// getting observable user from storage
                    })
                        { actualUsers in ///mapping true users to their picture URLs
                        actualUsers.map { $0.pictureURL! }
                    }
            }
            .subscribe(onNext: { [weak v = self.lastCheckedInUsersView] icons in
                v?.addIconURLs(icons)
            }
            )
.disposed(by: bag)
        
        ///error presenting
        viewModel.errorMessage.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(onNext: { [unowned self] message in
                self.showInfoMessage(withTitle: "Error", message)
            }
            )
.disposed(by: bag)
    }
    
    @IBAction func yes(_ sender: AnyObject) {
        viewModel.userChekedIn(!broadcastLocationButton.isSelected)
    }

    @IBAction func takePhoto(_ sender: AnyObject) {
        viewModel.addPhotoClicked()
    }
    
    @IBAction func createReport(_ sender: AnyObject) {
        viewModel.addReportClicked()
    }
    
    @IBAction func noClicked(_ sender: AnyObject) {
        viewModel.noClicked()
    }
}

extension CheckinViewController {
    
    func configureUI() {
        
        checkmarkImageView.layer.borderWidth = 1
        checkmarkImageView.layer.borderColor = UIColor.white.cgColor
        checkmarkImageView.layer.cornerRadius = checkmarkImageView.frame.size.height / 2

        ///bottom buttons
        let font = UIConfiguration.appFontOfSize(16)
        let bigFont = UIConfiguration.appFontOfSize(21)
        let color = UIColor.white
        
        ///YES
        chekinAffirmativeButton.setTitleColor(color, for: UIControlState())
        chekinAffirmativeButton.titleLabel?.font = bigFont
        chekinAffirmativeButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), at: 0)
        chekinAffirmativeButton.setTitle("YES", for: UIControlState())
        
        ///CREATE REPORT
        createReportButton.setTitleColor(color, for: UIControlState())
        createReportButton.titleLabel?.font = font
        createReportButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), at: 0)
        createReportButton.setTitle("CREATE REPORT", for: UIControlState())

        ///NO
        checkinNegativeButton.setTitleColor(color, for: UIControlState())
        checkinNegativeButton.titleLabel?.font = bigFont
        checkinNegativeButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0x898989), to: UIColor(fromHex: 0x585756)), at: 0)
        checkinNegativeButton.setTitle("NO", for: UIControlState())

        ///add photo
        takePhotoButton.setTitleColor(color, for: UIControlState())
        takePhotoButton.titleLabel?.font = font
        takePhotoButton.layer.insertSublayer(UIConfiguration.gradientLayer(UIColor(fromHex: 0xff9200), to: UIColor(fromHex: 0xff6700)), at: 0)
        takePhotoButton.setTitle("ADD PHOTO", for: UIControlState())
        
        ///checkin question
        checkinQuestionLabel.text = "CHECK IN?"
        checkinQuestionLabel.font = UIConfiguration.appSecondaryFontOfSize(21)
        
        ///club attributes
        clubNameLabel.font = UIConfiguration.appSecondaryFontOfSize(23)
        clubAdressLabel.font = UIConfiguration.appFontOfSize(10)
        dancingClubLabel.font = UIConfiguration.appSecondaryFontOfSize(15)
        todayCheckinLabel.font = UIConfiguration.appSecondaryFontOfSize(14)
        
        ///checkin checkmark color
        checkinQuestionCheckmark.image? = (checkinQuestionCheckmark.image?.withRenderingMode(.alwaysTemplate))!
        checkinQuestionCheckmark.tintColor = UIColor(fromHex: 0xf07800)
    }
    
    override func viewDidLayoutSubviews() {
        let buttonsForResize = [checkinNegativeButton, chekinAffirmativeButton, takePhotoButton, createReportButton]
        
        buttonsForResize.forEach{ view in
            view?.layer.sublayers?.forEach { $0.frame = (view?.bounds)! }
        }
        
        logoImageView.layer.cornerRadius = logoImageView.frame.size.height / 2
    }
    
}
