//
//  UICollectionView+NextPageTrigger.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/2/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RxSwift

typealias CollectionTuple = (collectionView: UICollectionView,
    cell: UICollectionViewCell, indexPath: NSIndexPath)

extension UICollectionView {
    
    func rxex_cellDisplayed () -> Observable<CollectionTuple> {
        
        let selector = #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))
        
        return self.rx.delegate.methodInvoked(selector)
            .flatMap { (args: [Any]) -> Observable<CollectionTuple> in
                let c = args[0] as! UICollectionView
                let v = args[1] as! UICollectionViewCell
                let i = args[2] as! NSIndexPath
                
                let element = (c,v,i)
                
                return Observable.just( element )
        }
        
    }
}
