//
//  FeedCollectionViewController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

protocol FeedHeaderDataSource : class {
    
    var headerHeight: CGFloat { get }
    
    func populateHeaderView(_ view: UICollectionReusableView)
}

class FeedCollectionViewController : UICollectionViewController {
    
    var viewModel : FeedViewModel!
    weak var headerDataSource: FeedHeaderDataSource?
    
    fileprivate lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, FeedDataItem>>(configureCell: { (_, cv, ip, item) in
        
        switch item {
        case .mediaType(let mediaContext):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "media cell", for: ip) as! ReviewMediaCollectionCell
            
            cell.setMedia(mediaContext)
            
            return cell
            
        case .reportType(let report):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "report cell", for: ip) as! ReviewReportCollectionCell
            
            cell.setReport(report)
            
            return cell
        }
        
    }, configureSupplementaryView: { [unowned self] (_, cv, kind, ip) in
        let a = cv.dequeueReusableSupplementaryView(ofKind: kind,
                                                    withReuseIdentifier: "feed header", for: ip)
        self.headerDataSource?.populateHeaderView(a)
        return a
    })
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (viewModel == nil) { fatalError("viewModel must be initialized prior to using FeedCollectionViewController") }
        
        viewModel.wireframe.asDriver()
            .filter { $0 != nil }.map { $0! }
            .drive(onNext: { [unowned self] tuple in
                self.performSegue(withIdentifier: tuple.0, sender: nil)
             })
            .disposed(by: disposeBag)

        
        setUpFeed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let flowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = collectionView!.frame.size.width / 3 - 1
        
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 2
        
        flowLayout.headerReferenceSize = CGSize(width: collectionView!.frame.size.width,
                                                height: headerDataSource?.headerHeight ?? 0)
        
    }
    
    fileprivate func setUpFeed() {
        
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
        
        ///pagination trigger
        viewModel.pageTrigger.value = collectionView!
            .rx.contentOffset
            .map{ [weak c = self.collectionView] offset -> (CGFloat, UICollectionView?) in
                return (offset.y, c)
            }
            .flatMapLatest { args -> Observable<Void> in
                
                guard let collectionView = args.1 else { return Observable.empty() }
                
                let offset = args.0
                let shouldTriger = offset + collectionView.frame.size.height + 70 > collectionView.collectionViewLayout.collectionViewContentSize.height
                return shouldTriger ? Observable.just( () ) : Observable.empty()
        }
        
        ///data binding to collection view
        //let data: Observable<[FeedSection]> =
        viewModel.displayDataDriver
            .map { items -> [AnimatableSectionModel<String, FeedDataItem>] in
                return [AnimatableSectionModel(model: "", items: items)]
            }
            .drive(collectionView!.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        ///collection view event reacting
        collectionView!.rx.modelSelected(FeedDataItem.self)
            .asDriver()
            .drive(onNext: { [unowned self] in
                
                switch $0 {
                    
                case .mediaType(let media):
                    self.viewModel.presentMediaDetails(media)
                    
                case .reportType(let report):
                    self.viewModel.presentReportDetails(report)
                }
                
            })
            .disposed(by: disposeBag)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show report details"
        {
            
            let controller = segue.destination as! ReportDetailsViewController
            controller.viewModel = self.viewModel.wireframe.value!.1 as! ReportDetailsViewModel
            
        }
        else if segue.identifier == "show media details"
        {
            
            let controller = segue.destination as! MediaDetailsViewController
            controller.viewModel = self.viewModel.wireframe.value!.1 as! MediaDetailsViewModel
            
        }
    }
    
}

struct FeedSection : AnimatableSectionModelType  {
    
    typealias Item = FeedDataItem
    typealias Identity = String
    
    var items: [Item] {
        return feedItems
    }
    
    var identity : String {
        return ""
    }
    
    init(original: FeedSection, items: [Item]) {
        self = original
        self.feedItems = items
    }
    
    var feedItems: [FeedDataItem]
    
    init(items: [FeedDataItem]) {
        self.feedItems = items
    }
    
}
