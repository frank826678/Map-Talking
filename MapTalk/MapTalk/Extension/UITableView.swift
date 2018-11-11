//
//  UITableView.swift
//  MapTalk
//
//  Created by Frank on 2018/11/11.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

extension UITableView {
    
    func registerTableViewCell(identifiers: [String]) {
        
        let identifiersArray = identifiers
        
        for identifier in identifiersArray {
            
            let nibCell = UINib(nibName: identifier, bundle: nil)
            self.register(nibCell, forCellReuseIdentifier: identifier)
            
        }
    }
}
