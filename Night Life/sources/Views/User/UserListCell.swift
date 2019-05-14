//
//  UserListCell.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/22/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserListCell : UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var firstButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var secondButtonActivityIndicator: UIActivityIndicatorView!
    
    let bag = DisposeBag()
    
    fileprivate var viewModel: UserViewModel? = nil
    func setViewModel(_ viewModel: UserViewModel) {
        self.viewModel = viewModel
        
        if let firstAction = viewModel.actions.first {
            
            firstLabel.text = firstAction.description().0
            firstButton.setImage(UIImage(named: firstAction.description().1), for: UIControlState())
            
        }
        
        if viewModel.actions.indices.contains(1) {
            let secondAction = viewModel.actions[1]
            
            secondLabel.text = secondAction.description().0
            secondButton.setImage(UIImage(named: secondAction.description().1), for: UIControlState())
         
            secondLabel.isHidden = false
            secondButton.isHidden = false
        }
        else {
            secondButton.isHidden = true
            secondLabel.isHidden = true
        }
        
        nameLabel.text = viewModel.user.username
        ImageRetreiver.imageForURLWithoutProgress(viewModel.user.pictureURL!)
            .drive(avatarImageView.rx.image)
.disposed(by: bag)
        
        if viewModel.actions.contains(.acceptFollowRequest) {
            self.backgroundColor = UIColor(white: 1, alpha: 0.18)
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
    }
    
    @IBAction func firstButtonTapped(_ sender: AnyObject) {
        
        firstButton.isHidden = true
        firstLabel.isHidden = true
        firstButtonActivityIndicator.isHidden = false
        
        viewModel?.actionPerformedAtIndex(0)
    }
    
    @IBAction func secondButtonTapped(_ sender: AnyObject) {
        secondButton.isHidden = true
        secondLabel.isHidden = true
        secondButtonActivityIndicator.isHidden = false
        
        viewModel?.actionPerformedAtIndex(1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.backgroundColor = UIColor.clear
    }
    
}
