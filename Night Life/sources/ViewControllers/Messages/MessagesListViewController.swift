//
//  MessagesListViewController.swift
//  Night Life
//
//  Created by admin on 07.04.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import AHKActionSheet
import SWRevealViewController
import Alamofire
import ObjectMapper

import RxDataSources

class MessagesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let viewModel = MessageListViewModel()

    fileprivate let dataSource = RxTableViewSectionedAnimatedDataSource<MessageSection>(configureCell: { (_, tv, ip, item) in
        
        let cell = tv.dequeueReusableCell(withIdentifier: "message cell", for: ip) as! MessageTableCell
        cell.setMessage(item)
        return cell
    })
    
    fileprivate let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.canEditRowAtIndexPath = { _,_  in true }
        
        tableView.rx.itemDeleted
            .subscribe(onNext:{[unowned self] value in
            self.viewModel.deleteMessage(value.row)
        }
        )
        .disposed(by: bag)
        
        viewModel.detailMessageViewModel.asDriver()
            .filter { $0 != nil }
            .drive(onNext: {[unowned self] _ in
                self.performSegue(withIdentifier: "MessageDetailsScreen", sender: nil)
            }
        )
.   disposed(by: bag)
        
        tableView.rx.itemSelected
            .subscribe(onNext:{ [unowned self] (ip: IndexPath) in
              self.viewModel.selectedMessage(atIndexPath: ip as NSIndexPath)
        }
        )
.disposed(by: bag)
        
        viewModel.displayData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessageDetailsScreen" {
            let controller = segue.destination as! MessageViewController
            
            controller.viewModel = viewModel.detailMessageViewModel.value
        }
    }
}

struct MessageSection : AnimatableSectionModelType  {
    
    typealias Item = Message
    typealias Identity = String
    
    var items: [Item] {
        return messageItems
    }
    
    var identity : String {
        return ""
    }
    
    init(original: MessageSection, items: [Item]) {
        self = original
        self.messageItems = items
    }
    
    var messageItems: [Message]
    
    init(items: [Message]) {
        self.messageItems = items
    }
    
}
