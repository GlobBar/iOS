//
//  MessageListViewModel.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import RxSwift
import RxCocoa

import Alamofire

import ObjectMapper


enum MessageListError : Error {

    case malformedServerResponse
}

class MessageListViewModel {
    
    let displayData: Driver<[MessageSection]>
    let detailMessageViewModel: Variable<MessageViewModel?> = Variable(nil)
    
    fileprivate let bag = DisposeBag()
    
    init() {
        
        displayData = MessagesContext.messages.asDriver()
            .map { [ MessageSection(items: $0 ) ] }
        
        MessagesContext.refreshMessages()
            .disposed(by: bag)

    }
}

extension MessageListViewModel {
    
    func selectedMessage(atIndexPath ip: NSIndexPath) {
        let message = MessagesContext.messages.value[ip.row]
        
        detailMessageViewModel.value = MessageViewModel(message: message)
    }
    
    func deleteMessage(_ row: Int) {
        
        let message = MessagesContext.messages.value[row]
        
        message.removeFromStorage()
        MessagesContext.messages.value.remove(at: row)
        
        Alamofire.request(MessagesRouter.delete(message: message))
            .rx_Response(EmptyResponse.self)
            .subscribe(onError: { error in
                print("delete message from server error: \(error)")
            }
            )
.disposed(by: bag)
    }
    
}
