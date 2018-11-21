//
//  CALayer.swift
//  MapTalk
//
//  Created by Frank on 2018/10/17.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
// swiftlint:disable identifier_name

extension CALayer {
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0,
        corner: CGFloat = 60
        ) {
        cornerRadius = corner
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            
            let center = CGPoint(x: (frame.width) / 2.0, y: (frame.height) / 2.0)
            
            shadowPath = UIBezierPath(
                arcCenter: center,
                radius: corner,
                startAngle: CGFloat(0),
                endAngle: CGFloat.pi * 2.0,
                clockwise: true
                ).cgPath
        }
    }
    
    func applySketchRectShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
}

// swiftlint:enable identifier_name
