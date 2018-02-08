//
//  ViewController+ErrorMessage.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/26/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit

typealias MessageCallback = () -> Void

extension UIViewController {
    
    func showInfoMessage(withTitle title:String,_ text: String,_ buttonText: String = "Ok" , _ callback: MessageCallback? = nil) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: buttonText, style: .default) { _ in
            if let callback = callback {
                callback()
            }
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSimpleQuestionMessage(withTitle title:String, _ question: String, _ positiveCallback: MessageCallback? = nil, _ negativeCallback: MessageCallback? = nil)
    {
        let alertController = UIAlertController(title: title, message: question, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel) { _ in
            if let callback = negativeCallback {
                callback()
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            if let callback = positiveCallback {
                callback()
            }
        })
        
        self.present(alertController, animated: true, completion: nil)

    }
    
}
