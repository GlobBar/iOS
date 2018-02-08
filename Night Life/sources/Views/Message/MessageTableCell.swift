//
//  MessageTableCell.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import Alamofire


import DateTools

class MessageTableCell : UITableViewCell {
    
    @IBOutlet weak var unreadOverlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    fileprivate var disposeBag = DisposeBag()
    
    func setMessage(_ message: Message) {
       
        guard let messageObservable = message.observableEntity()?.asObservable() else {
            fatalError("Can't populate cell without message observable")
        }
        
        messageObservable.map { $0.title }
            .bind(to: titleLabel.rx.text)
            
.disposed(by: disposeBag)
        
        messageObservable.map { $0.body }
            .bind(to: bodyLabel.rx.text)
            
.disposed(by: disposeBag)
        
        messageObservable.map { ($0.created as NSDate?)?.timeAgoSinceNow() ?? "" }
            .bind(to: createdLabel.rx.text)
            
.disposed(by: disposeBag)
        
        messageObservable.map { $0.isRead }
            .bind(to: unreadOverlayView.rx.isHidden)
            
.disposed(by: disposeBag)
        
    }
    
}

