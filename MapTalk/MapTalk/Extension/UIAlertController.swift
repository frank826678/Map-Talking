//
//  UIAlertController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/21.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func alertMessage(
        title: String? = "錯誤",
        message: String
        ) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "確定", style: .default, handler: nil)
        
        alert.addAction(action)
        
        return alert
    }
    
    static func errorMessage(errorType: ErrorComment) -> UIAlertController {
        
        return alertMessage(message: errorType.errorMessage())
        
    }
    
    static func showAlert(
        title: String?,
        message: String?,
        defaultOption: [String],
        defalutCompletion: @escaping (UIAlertAction) -> Void
        ) -> UIAlertController {
        
        let alerController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil
        )
        
        alerController.addAction(action)
        
        for item in defaultOption {
            
            let action = UIAlertAction(
                title: item,
                style: .default) { (action) in
                    
                    defalutCompletion(action)
                    
            }
            
            alerController.addAction(action)
            
        }
        
        return alerController
    }
    static func showActionSheet(
        defaultOption: [String],
        defalutCompletion: @escaping (UIAlertAction) -> Void
        ) -> UIAlertController {
        
        let alerController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let action = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil
        )
        
        alerController.addAction(action)
        
        for item in defaultOption {
            
            let action = UIAlertAction(
                title: item,
                style: .default) { (action) in
                    
                    defalutCompletion(action)
                    
            }
            
            alerController.addAction(action)
            
        }
        
        return alerController
    }
    
}
