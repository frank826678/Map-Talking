//
//  UIView.swift
//  MapTalk
//
//  Created by Frank on 2018/10/2.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

extension UIImage {
    static func setIconTemplate(iconName: String) -> UIImage {
        
        guard let image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate) else { return UIImage() }

        return image
    }
}
