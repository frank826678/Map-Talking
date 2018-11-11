//
//  UITableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/11/11.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static func createCell<T: UITableViewCell>(tableView: UITableView, indexPath: IndexPath) -> T {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            
            fatalError("遺失 \(String(describing: T.self)) 註冊檔") //fatalError不关心调用者需要返回什么，因为到了fatalError以后，直接就终止了。
        }
        
        return cell
        
    }
    
}
