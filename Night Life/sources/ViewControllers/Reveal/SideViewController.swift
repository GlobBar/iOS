//
//  SideViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController
import RxSwift

import AHKActionSheet

class SideViewController : UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.borderWidth = 1
            avatarImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectCityButton: UIButton!
    @IBOutlet weak var gradientOverlay: UIView! {
        didSet {
            
            let layer = UIConfiguration.naviagtionBarGradientLayer(forSize: CGSize(width: 1000, height: gradientOverlay.frame.size.height))
            
            gradientOverlay.layer.addSublayer(layer)
            
            gradientLayer = layer
        }
    }
    fileprivate var gradientLayer : CALayer?
    
    @IBOutlet weak var unreadMessagesLabel: UILabel!
    @IBOutlet weak var facebookInvitationSpinner: UIActivityIndicatorView!
    @IBOutlet weak var followersRequestCountLabel: UILabel!
    
    let viewModel = SideViewModel()
    let invitationViewModel = InvitationViewModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let observableUser = User.currentUser()?.observableEntity()?.asDriver() else {
            assert (false, "Logic error. Side View controller is instantiated before logged in User exists")
            return
        }
        
        observableUser.map { $0.username }
            .drive(nameLabel.rx.text)
            .disposed(by: bag)
        
        observableUser.map { $0.pictureURL! }
            .flatMap { ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(avatarImageView.rx.image)
            .disposed(by: bag)
        
        viewModel.cities.asDriver()
            .map{ $0.count > 0 }
            .drive(selectCityButton.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel.currentCityName
            .drive(onNext:{ [unowned self] cityName in
                self.selectCityButton.setTitle(cityName, for: .normal)
                
            })
            .disposed(by: bag)
        
        let messageCountDriver = MessagesContext.messages
            .asObservable()
            .flatMapLatest { messages -> Observable<Int> in
                Observable.combineLatest(
                    messages.flatMap { ///filtering out messages that are not in storage
                        $0.observableEntity()?.asObservable() /// getting observable message from storage
                    }) { actualMessages in ///mapping true messages to unread counter
                
                        let a = actualMessages.filter { !$0.isRead }.count
                        return a
                    }
                    .startWith(0)
            }
        
        
        messageCountDriver
            .map { String($0) }
            .bind(to: unreadMessagesLabel.rx.text)
            .disposed(by: bag)
        
        messageCountDriver
            .map { $0 == 0 }
            .bind(to: unreadMessagesLabel.rx.isHidden)
            .disposed(by: bag)
        
        ///follower requests count
        
        viewModel.followersRequestCount
            .drive(followersRequestCountLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.followersRequestCountHidden
            .drive(followersRequestCountLabel.rx.isHidden)
            .disposed(by: bag)
        
        ///////
        ///facebook invitation view model
        ///////
//        tableView.rx.itemSelected.filter { $0.row == 6 }
//            .subscribe(onNext: { [weak r = MainRouter.sharedInstance.rootViewController, unowned self] _ in
//                self.invitationViewModel.inviteOn(r!)
//            }
//            )
//.disposed(by: bag)
        
//        invitationViewModel.activityDriver
//            .drive(facebookInvitationSpinner.rxex_animating)
//            )
//.disposed(by: bag)
        
        invitationViewModel.message.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(onNext: { [unowned self] message in
                self.showInfoMessage(withTitle: "Message", message)
            })
            .disposed(by: bag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ///SWRevealViewController force adjusts contentInset if UIViewController's view is UIScrollView subclass (which is the case for this class)
        ///We require total control over TableViewLayout so we are canceling SWRevealViewController's rules
        //self.tableView.contentInset = UIEdgeInsetsZero
        
        viewModel.refeshFollowersCount()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
        
        //unreadMessagesLabel.layer.cornerRadius = unreadMessagesLabel.frame.size.height / 2
        self.tableView.contentInset = UIEdgeInsets.zero
    }
    
    @IBAction func selectCityTapped(_ sender: AnyObject) {
        
        let actionSheet = AHKActionSheet(title: "Select city")
        
        actionSheet?.blurTintColor = UIColor(white: 0, alpha: 0.75)
        actionSheet?.blurRadius = 8.0;
        actionSheet?.buttonHeight = 50.0;
        actionSheet?.cancelButtonHeight = 50.0;
        actionSheet?.animationDuration = 0.5;
        actionSheet?.cancelButtonShadowColor = UIColor(white: 0, alpha: 0.1)
        actionSheet?.separatorColor = UIColor(white: 1, alpha: 0.3)
        actionSheet?.selectedBackgroundColor = UIColor(white: 0, alpha: 0.5)
        actionSheet?.buttonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
            NSAttributedStringKey.foregroundColor : UIColor.white ]
        actionSheet?.disabledButtonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
            NSAttributedStringKey.foregroundColor : UIColor.gray ]
        actionSheet?.destructiveButtonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
            NSAttributedStringKey.foregroundColor : UIColor.red ]
        actionSheet?.cancelButtonTextAttributes = [ NSAttributedStringKey.font : UIConfiguration.appFontOfSize(17),
            NSAttributedStringKey.foregroundColor : UIColor.white ]
        
        for city in viewModel.cities.value {
            
            actionSheet?.addButton(withTitle: city.name, image: nil, type: .default) { _ in
                self.viewModel.selectedCity(city)
            }
            
        }
        
        actionSheet?.show();
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "following segue":
            let controller = (segue.destination as! UINavigationController).viewControllers.first! as! UserListViewController
            
            controller.viewModel = UsersListViewModel(mode: .following, handler: controller)
            
        case "followers segue":
            let controller = (segue.destination as! UINavigationController).viewControllers.first! as! UserListViewController
            
            controller.viewModel = UsersListViewModel(mode: .follower, handler: controller)
        
        case "current user profile":
            let controller = (segue.destination as! UINavigationController).viewControllers.first! as! UserProfileViewController
            
            controller.viewModel = UserProfileViewModel(userDescriptor: User.currentUser()!, handler: controller)
            
        case "privacy policy":
            
            let controller = (segue.destination as! UINavigationController).viewControllers.first! as! TermsAndConditionsController
            
            controller.titleString = "Privacy policy"
            controller.link = AppConfiguration.privacyPolicyLink
            
        case "terms conditions":
            
            let controller = (segue.destination as! UINavigationController).viewControllers.first! as! TermsAndConditionsController
            
            controller.titleString = "Terms & Conditions"
            controller.link = AppConfiguration.termsAndConditionsLink
            
        default: break

            
        }
    }
 
}
