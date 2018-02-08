//
//  MessagesViewModel.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift

import Alamofire


struct MessageViewModel {
    
    var message : Message
    
    fileprivate let bag = DisposeBag()
    
    init(message: Message) {
        self.message = message
        
        if !message.isRead {
            
            Alamofire.request(MessagesRouter.markRead(message: message))
                .rx_Response(EmptyResponse.self)
                .subscribe(onNext: { _ in
                    var copy = message
                    copy.isRead = true
                    copy.saveEntity()
                }
                )
                .disposed(by: bag)
        }
    }
}
