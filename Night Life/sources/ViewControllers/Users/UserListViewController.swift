//
//  UserListViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/21/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

import RxSwift
import RxCocoa
import RxDataSources

class UserListViewController : UIViewController {
    
    var viewModel : UsersListViewModel!
    
    fileprivate let dataSource = RxTableViewSectionedAnimatedDataSource<UserSection>(configureCell: { (_, tv, ip, item) in
        
        let cell = tv.dequeueReusableCell(withIdentifier: "UserListCell", for: ip) as! UserListCell
        
        cell.setViewModel(item)
        
        return cell
    })
    
    fileprivate let bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 70
        }
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil { fatalError("Can't use class without initialized view model") }
        
        if !viewModel.shouldDisplaySearchBar {
            tableView.tableHeaderView = nil
        }
        
        tableView.rx.modelSelected(UserViewModel.self)
            .asDriver()
            .drive(onNext: { [unowned self] m in
                self.viewModel.userViewModelSelected(m)
            }
            )
.disposed(by: bag)
        
        viewModel.displayData
            .drive(tableView.rx.items(dataSource: dataSource))
.disposed(by: bag)
        
        let a = !viewModel.shouldDisplaySearchBar
        viewModel.displayData
            .map{ sections in
                guard let section = sections.first else { return true }
                
                return section.items.count > 0 || a
            }
            .skip(1)///initial empty dataset
            .startWith(true)
            .drive(noResultsView.rx.isHidden)
.disposed(by: bag)

        viewModel.searchBarObservable.value = searchBar.rx.text.asObservable().notNil()
        viewModel.title.asObservable()
            .subscribe(onNext: { [unowned self] title in
                self.title = title
            }
            )
.disposed(by: bag)
        
        viewModel.selectedUser.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(onNext: { [unowned self] _ in
                self.performSegue(withIdentifier: "show profile segue", sender: nil)
            }
            )
.disposed(by: bag)
        
        viewModel.message.asDriver()
            .filter { $0 != nil }.map { $0! }
            .filter { $0.lengthOfBytes(using: String.Encoding.utf8) > 0 }
            .drive(onNext: { [unowned self] message in
                self.showInfoMessage(withTitle: "Success", message)
            }
            )
.disposed(by: bag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show profile segue" {
            
            let controller = segue.destination as! UserProfileViewController
            controller.viewModel = UserProfileViewModel( userDescriptor: viewModel.selectedUser.value!.user, handler: controller )
            
        }
    }
}

struct UserSection : AnimatableSectionModelType  {
    
    typealias Item = UserViewModel
    typealias Identity = String
    
    var items: [Item] {
        return userItems
    }
    
    var identity : String {
        return ""
    }
    
    init(original: UserSection, items: [Item]) {
        self = original
        self.userItems = items
    }
    
    
    var userItems: [UserViewModel]
    
    init(items: [UserViewModel]) {
        self.userItems = items
    }
    
}
