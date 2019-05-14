//
//  MyProfile.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/15/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController
import MBCircularProgressBar

import RxSwift
import RxCocoa

import Alamofire

class UserProfileViewController : UIViewController {
    
    var viewModel: UserProfileViewModel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var pointsCountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var editUsernameButton: UIButton!
    
    @IBOutlet var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var updateProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var followActionsButton: UIButton!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var topUpButton: UIButton!
    
    @IBOutlet weak var donate1Button: UIButton!
    @IBOutlet weak var donate3Button: UIButton!
    @IBOutlet weak var donate5Button: UIButton!
    
    @IBOutlet weak var cashOutButton: UIButton!
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { fatalError("ViewModel must be initialised prior to using ViewController") }
        
        if self.navigationController?.viewControllers.index(of: self)! != 0 {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        let editingModeDriver = viewModel.editingState.asDriver()
        
        editingModeDriver.drive(onNext: { [unowned self] state in
            var barButtonItem: UIBarButtonItem? = nil
            switch state {
            case .showConfirmation:
                barButtonItem = self.saveBarButtonItem
            case .showEditing:
                barButtonItem = self.editBarButtonItem
                
            case .noEditing: break;
            }
            
            self.navigationItem .setRightBarButton(barButtonItem, animated: true)
        })
        .disposed(by: bag)
        
        let showConfirmationDriver = editingModeDriver.map { $0 != UserProfileEditingState.showConfirmation }
        let showEditingDriver = editingModeDriver.map { $0 != UserProfileEditingState.showEditing }
        
        showConfirmationDriver.drive( editPhotoButton.rx.isHidden )
.disposed(by: bag)
        
        showConfirmationDriver.drive( editUsernameButton.rx.isHidden )
.disposed(by: bag)
        
        showEditingDriver.drive(onNext: { [unowned self] val in
                self.logoutButton.isHidden = val
                self.logoutButton.isUserInteractionEnabled = !self.logoutButton.isHidden
            }
            )
.disposed(by: bag)
        
        viewModel.usernameTextBoxViewModel.text
            .asObservable()
            .notNil()
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true, completion:nil)
            })
            .disposed(by: bag)
        
        viewModel.uploadProgress.asDriver()
            .map { value in
                guard let v = value else { return true }
            
                return !(v > 0 && v < 1)
            }
            .drive(updateProgressBar.rx.isHidden)
.disposed(by: bag)
        
        viewModel.uploadProgress.asDriver()
            .drive(onNext: { [unowned self] value in
                guard let percent = value else {
                    return
                }
                
                self.updateProgressBar.value = CGFloat(percent * 100.0)
            }
            )
.disposed(by: bag)
        
        viewModel.userDriver
            .map{ $0.username }
            .drive(nameLabel.rx.text)
.disposed(by: bag)
        
        viewModel.userDriver
            .map{ $0.pictureURL }
            .filter { $0 != nil }.map { $0! }
            .flatMap { ImageRetreiver.imageForURLWithoutProgress($0) }
            .drive(avatarImageView.rx.image)
.disposed(by: bag)

        viewModel.userDriver
            .map { "\($0.followersCount ?? 0)" }
            .drive( followersCountLabel.rx.text )
.disposed(by: bag)
        
        viewModel.userDriver
            .map { "\($0.followingCount ?? 0)" }
            .drive( followingCountLabel.rx.text )
.disposed(by: bag)
        
        viewModel.userDriver
            .map { "\($0.points ?? 0)" }
            .drive( pointsCountLabel.rx.text )
.disposed(by: bag)

        viewModel.errorMessage.asObservable()
            .filter { $0 != nil }.map { $0! }
            .subscribe(onNext: { [unowned self] text in
                self.showInfoMessage(withTitle: "Error", text)
            }
            )
.disposed(by: bag)
        
        viewModel.userDriver
            .map { $0.dollars }
            .drive( balanceLabel.rx.text )
            .disposed(by: bag)
        
        ///following viewModel
        viewModel.followingViewModel
            .followButtonEnabled
            .drive(followActionsButton.rx.isEnabled)
.disposed(by: bag)
        
        viewModel.followingViewModel
            .followButtonHidden
            .drive(followActionsButton.rx.isHidden)
.disposed(by: bag)
        
        viewModel.followingViewModel
            .followButtonText
            .drive(onNext: { [unowned self] text in
                let attributedText = NSAttributedString(string: text,
                    attributes: [
                        NSAttributedStringKey.foregroundColor : UIColor(fromHex: 0xF37C00),
                        NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)
                    ])
                
                self.followActionsButton.setAttributedTitle(attributedText, for: .normal)
            }
            )
.disposed(by: bag)
        
        topUpButton.isHidden = !viewModel.ownProfile
        donate1Button.isHidden = viewModel.ownProfile
        donate3Button.isHidden = viewModel.ownProfile
        donate5Button.isHidden = viewModel.ownProfile
        cashOutButton.isHidden = !viewModel.ownProfile
        balanceLabel.isHidden = !viewModel.ownProfile
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
    }
    
    @IBAction func logoutAction(_ sender: AnyObject) {
        viewModel.logoutAction()
    }
    
    @IBAction func editPhotoAction(_ sender: AnyObject) {
       viewModel.editPhoto()
    }
    
    @IBAction func editProfileAction(_ sender: AnyObject) {
        viewModel.editingState.value = .showConfirmation
    }
    
    @IBAction func saveProfileAction(_ sender: AnyObject) {
        viewModel.uploadEdits()
    }
    
    @IBAction func followActionTapped(_ sender: AnyObject) {
        viewModel.followingViewModel.performAction()
    }
    
    @IBAction func cashOut(_ sender: Any) {
        
        let _ =
        presentTextQuestion(question: DisplayMessage(title: "Enter amount",
                                                     description: "How much do you want to cash out?"))
            .flatMapLatest { [unowned self] (amountString) in
                return self.presentTextQuestion(question: DisplayMessage(title: "Where to?",
                                                                         description: "Enter your paypal account email"))
                    .map { (amountString, $0) }
            }
            .take(1)
            .subscribe(onNext: { [unowned self] (amountString, email) in
                self.viewModel.cashout(amount: (Int(amountString) ?? 0) * 100, email: email)
            })
        
        
    }
    
    @IBAction func deleteprofileAction(_ sender: AnyObject) {
        self.showSimpleQuestionMessage(withTitle: "Delete profile", "Your profile, feed posts, reports and other information will be deleted. Are you sure?", {
                self.viewModel.deleteProfile()
            })
    }
    
    @IBAction func topUp(_ sender: Any) {
        viewModel.topUp()
    }
    
    @IBAction func donate1(_ sender: Any) {
        viewModel.donate(amount: 100)
    }
    
    @IBAction func donate3(_ sender: Any) {
        viewModel.donate(amount: 300)
    }
    
    @IBAction func donate5(_ sender: Any) {
        viewModel.donate(amount: 500)
    }
    
}

extension UserProfileViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed feed" {
            
            let controller = segue.destination as! FeedCollectionViewController
            controller.viewModel = viewModel.feedViewModel
        }
        else if segue.identifier == "present username textbox" {
            
            let controller = segue.destination as! TextBoxController
            controller.viewModel = viewModel.usernameTextBoxViewModel
        }
        
    }
    
}
