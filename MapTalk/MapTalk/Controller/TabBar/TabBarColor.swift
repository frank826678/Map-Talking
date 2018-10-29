//
//  TabBarColor.swift
//  MapTalk
//
//  Created by Frank on 2018/9/25.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

extension UITabBar {
    
    func setup(width: CGFloat, height: CGFloat) {
        
        let layerGradient = CAGradientLayer()
        
        //layerGradient.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        layerGradient.colors = [
            UIColor(red: 70/255.0, green: 95/255.0, blue: 222/255.0, alpha: 0.9).cgColor,
            UIColor(red: 235/255.0, green: 121/255.0, blue: 243/255.0, alpha: 0.9).cgColor
        ]

        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        self.layer.addSublayer(layerGradient)
    }
}
