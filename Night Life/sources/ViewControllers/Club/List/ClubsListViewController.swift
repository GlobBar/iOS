//
//  ViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/4/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift
import SWRevealViewController

import Alamofire
import ObjectMapper

class ClubsListViewController: UITableViewController {

    var viewModel: ClubListViewModel!
    
    fileprivate let bag = DisposeBag()
  
    override func loadView() {
        super.loadView()
        
        if viewModel == nil { assert(false, "view model must be initialized before using view controller")  }
        
        self.tableView.rowHeight = 170
        self.tableView.estimatedRowHeight = 170
        
        viewModel.clubs.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel.wireframe.asObservable()
            .filter{ $0 != nil }
            .map { $0! }
            .subscribe(onNext: { [unowned self] wireframe in
                self.performSegue(withIdentifier: wireframe.segueIdentifier, sender: nil)
            }
            )
            .disposed(by: bag)
        
        viewModel.errorMessage.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(onNext: { [unowned self] message in
                self.showInfoMessage(withTitle: "Error", message)
            }
            )
            .disposed(by: bag)
        
        viewModel.clubs.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.tableView.reloadSections([0], animationStyle: .automatic)
                self.tableView.scrollRectToVisible(CGRect(x: 0,y: 0,width: 1,height: 1), animated: true)
            }
            )
            .disposed(by: bag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show club feed"
        {
            guard let vm = viewModel.wireframe.value?.viewModel else {
                assert(false, "Can't go to checkin screen without selected club")
                return
            }
            
            let controller = segue.destination as! ClubFeedViewController
            controller.viewModel = vm
        }
    }
}

extension ClubsListViewController /*TableViewDataSource, delegate*/ {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.clubs.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "club cell", for: indexPath) as! ClubTableCell
        
        let club = viewModel.clubs.value[indexPath.row]
        cell.setClub(club)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.clubSelected(atIndexPath: indexPath as NSIndexPath)
    }
    
}
