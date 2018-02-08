//
//  AppNavigationController.swift
//  Night Life
//
//  Created by Vlad Soroka on 3/29/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import SWRevealViewController

class AppNavigationController : UINavigationController, UINavigationControllerDelegate {
    
    override func loadView() {
        super.loadView()
        
        let barSize = CGSize(width: UIApplication.shared.windows.first!.frame.size.width, height: 64);
        
        let gradientLayer = UIConfiguration.naviagtionBarGradientLayer(forSize: barSize)
        
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        
        self.navigationBar.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), for: .default)
        
        UIGraphicsEndImageContext();
        
        self.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font : UIConfiguration.appSecondaryFontOfSize(19),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        self.navigationBar.tintColor = UIColor.white
        
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let first = navigationController.viewControllers.first,
              let revealController = self.revealViewController()
        else { return }
        
        if viewController === first {
            
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu"),
                                                style: .plain,
                                                target: revealController,
                                                action: #selector(SWRevealViewController.revealToggle(_:)))
            viewController.navigationItem.leftBarButtonItem = barButtonItem
            
        }
    }
    
}

