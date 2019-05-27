//
//  ReviewsListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/18/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

import AHKActionSheet

class ClubFeedViewController : UIViewController {
    
    let disposeBag = DisposeBag()
    
    var viewModel : ClubFeedViewModel!
    
    fileprivate weak var checkInController : CheckinViewController? = nil
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    @IBOutlet weak var clubLogoImageView: UIImageView!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var adresLabel: UILabel!
    @IBOutlet weak var lastCheckinsView: CircularIconsGroupView!
    
    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var recomendationLabel: UILabel!
    
    @IBOutlet weak var filtersSegmentedControl: UISegmentedControl! {
        didSet {
            filtersSegmentedControl.selectedSegmentIndex = 2
        }
    }
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var addReportBtn: UIButton!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var addVideoBtn: UIButton!
    
    @IBOutlet weak var dancerClubButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (viewModel == nil) { fatalError("ViewModel must be instantiated prior to using ClubFeedViewController") }
        
        //setting up UI
        self.title = "Reviews"
        
        filtersSegmentedControl.setTitleTextAttributes([
                NSAttributedStringKey.font : UIConfiguration.appFontOfSize(10)
            ], for: UIControlState())
        
         
        
        ////binding
        
        addReportBtn.rx.tap.asObservable()
            .subscribe(onNext:
            { [unowned self] _ in
                self.viewModel.addReport()
            }
            )
.disposed(by: disposeBag)
        
        addPhotoBtn.rx.tap.asObservable()
            .subscribe(onNext:
            { [unowned self] _ in
                self.viewModel.addMedia(.photo)
            }
            )
.disposed(by: disposeBag)

        addVideoBtn.rx.tap.asObservable()
            .subscribe(onNext:
            { [unowned self] _ in
                self.viewModel.addMedia(.video)
            }
            )
.disposed(by: disposeBag)
        
        
        viewModel.infoMessage.asDriver()
            .filter{ $0 != nil }
            .map{ $0! }
            .drive(onNext: { [unowned self] message in
                self.showInfoMessage(withTitle: message.title, message.message)
            }
            )
.disposed(by: disposeBag)

        self.filtersSegmentedControl.setTitle("Last \(Date().dayOfWeekText)'s Feed", forSegmentAt: 1)
        
        guard let clubDriver = viewModel.club.observableEntity()?.asDriver() else {
            fatalError("Can't present ClubFeed screen without stored club with id \(viewModel.club.id)")
        }
        
        clubDriver
            .map{ $0.name }
            .drive(clubNameLabel.rx.text)
            
.disposed(by: disposeBag)
        
        clubDriver
            .map{ $0.adress }
            .drive(adresLabel.rx.text)
            
.disposed(by: disposeBag)
        
        clubDriver
            .map{ $0.logoImageURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(clubLogoImageView.rx.image)
            
.disposed(by: disposeBag)
        
        clubDriver
            .map{ $0.coverPhotoURL }
            .distinctUntilChanged()
            .flatMap{ ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(coverPhotoImageView.rx.image)
            
.disposed(by: disposeBag)

        clubDriver.asObservable()
            .flatMap { club in
                Observable
                    .combineLatest(club.lastCheckedInUsers /// all lastCheckedInUsers
                        .flatMap { ///filtering out users taht are not in storage
                            $0.observableEntity()?.asObservable() /// getting observable user from storage
                    })  { actualUsers in ///mapping true users to their picture URLs
                        
                        actualUsers.map { $0.pictureURL! }
                }
            }
            .subscribe(onNext:{ [unowned self] icons in
                self.lastCheckinsView.addIconURLs(icons)
            }
            )
.disposed(by: disposeBag)
        
        clubDriver
            .map{ $0.clubDescriptors.ageGroup ?? "" }
            .drive(recomendationLabel.rx.text)
            
.disposed(by: disposeBag)
        
        clubDriver
            .map{ $0.clubDescriptors.musicType ?? "" }
            .drive(musicLabel.rx.text)
            
.disposed(by: disposeBag)
        
        clubDriver
            .map{ $0.clubDescriptors.openingHours ?? "" }
            .drive(scheduleLabel.rx.text)
            
.disposed(by: disposeBag)
        
        viewModel.addPhotoAction.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(onNext: { [unowned self] message in
                
                self.showSimpleQuestionMessage(withTitle: message.0.title, message.0.message, message.yesHandler, message.noHandler)
                
            }
            )
.disposed(by: disposeBag)
        
        filtersSegmentedControl.rx.value
            .subscribe(onNext:{ [unowned self] value in
                self.viewModel.filterAtIndexSelected(value)
            }
            )
.disposed(by: disposeBag)
        
        viewModel.activeViewModel.asDriver()
            .drive(onNext: { [unowned self] maybeViewModel in
                
                guard let viewModel = maybeViewModel else {
                    self.switchActiveViewControllerTo(nil)
                    return
                }
                
                var viewControllerToPresent: UIViewController? = nil
                if viewModel is CheckinViewModel {
                    
                    let checkinController = self.storyboard!
                        .instantiateViewController(withIdentifier: "CheckinViewController") as! CheckinViewController
                    checkinController.viewModel = (viewModel as! CheckinViewModel)
                    
                    viewControllerToPresent = checkinController
                    
                }
                else if viewModel is CreateReportViewModel {
                    
                    let checkinController = self.storyboard!
                        .instantiateViewController(withIdentifier: "CreateReportViewController") as! CreateReportViewController
                    checkinController.viewModel = (viewModel as! CreateReportViewModel)
                    
                    viewControllerToPresent = checkinController
                    
                }
                else if viewModel is AddMediaViewModel {
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddMediaViewController") as!
                        AddMediaViewController
                    
                    controller.viewModel = viewModel as! AddMediaViewModel
                    
                    viewControllerToPresent = controller
                }
                else {
                    fatalError("Logic error. Passed active viewController was not properly recognized")
                }
                
                self.switchActiveViewControllerTo(viewControllerToPresent)
                
            }
            )
.disposed(by: disposeBag)
        
        viewModel.dancerClubTitle
            .drive(dancerClubButton.rx.title(for: .normal) )
            .disposed(by: disposeBag)
        
        let isFan = User.currentUser()?.type == .fan
        
        dancerClubButton.isHidden = isFan
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        clubLogoImageView.layer.cornerRadius = clubLogoImageView.frame.size.width / 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feed embedded" {
            
            let controller = segue.destination as! FeedCollectionViewController
            controller.viewModel = viewModel.feedViewModel
            controller.headerDataSource = self
            
        }
    }
    
    @IBAction func dancerTap(_ sender: Any) {
        viewModel.dancerTap()
    }
}

extension ClubFeedViewController {
    
    /**
     * @discussion This method incapsulated context switching rules
     */
    fileprivate func isActiveViewControllerPresented() -> Bool {
        
        guard let navController = self.navigationController,
              let index = navController.viewControllers.index(of: self) else {
            fatalError("ClubFeedViewController is able to manage navigation only inside UINavigationController")
        }
        
        return index + 1 < navController.viewControllers.count
    }
    
    fileprivate func switchActiveViewControllerTo(_ viewController: UIViewController?) {
        
        guard let controllerToPresent = viewController else {
            if self.isActiveViewControllerPresented() {
                self.navigationController!.popViewController(animated: true)
            }
            
            return
        }
        
        ///in case we have viewController to present
        
        if (!self.isActiveViewControllerPresented())
        {
            self.navigationController!.pushViewController(controllerToPresent, animated: true)
        }
        else
        {
            var controllers = self.navigationController!.viewControllers
            controllers[controllers.count - 1] = controllerToPresent
            
            self.navigationController!.setViewControllers(controllers, animated: true)
        }

        
    }
    
}

extension ClubFeedViewController : FeedHeaderDataSource {
    
    var headerHeight: CGFloat { return 279 }
    
    func populateHeaderView(_ view: UICollectionReusableView) {
        view.embbedViewAsContainer(headerView)
    }
    
}
