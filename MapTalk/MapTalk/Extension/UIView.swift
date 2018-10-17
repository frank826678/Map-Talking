//
//  UIView.swift
//  MapTalk
//
//  Created by Frank on 2018/10/10.
//  Copyright © 2018 Frank. All rights reserved.
//

//import Foundation

import UIKit

extension UIView {
    
    func cornerSetup(
        cornerRadius: CGFloat,
        borderWidth: CGFloat = 0,
        borderColor: CGColor? = nil,
        maskToBounds: Bool = true) {
        
        self.layer.masksToBounds = maskToBounds
        self.layer.cornerRadius = cornerRadius
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
    }
    
    //常用的參數可以給預設值 想要有自己的就輸入值
    func shadowSetup(
        cgSize: CGSize = CGSize(width: 1, height: 1),
        shadowRadius: CGFloat = 4,
        shadowOpacity: Float = 0.2
        ) {
        
        self.layer.shadowOffset = cgSize
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = shadowOpacity
        
    }
    
    //邊框切虛線用
    func addDashdeBorderLayer(color: UIColor, lineWidth width: CGFloat) {
        
        let shapeLayer = CAShapeLayer()
        let size = self.frame.size
        
        let shapeRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        
        shapeLayer.lineDashPattern = [20, 10]
        let path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0)
        shapeLayer.path = path.cgPath
        self.layer.addSublayer(shapeLayer)
        
    }
    
}

//extension CALayer {
//    func addShadow() {
//        self.shadowOffset = .zero
//        self.shadowOpacity = 0.2
//        self.shadowRadius = 10
//        self.shadowColor = UIColor.black.cgColor
//        self.masksToBounds = false
//        if cornerRadius != 0 {
//            addShadowWithRoundedCorners()
//        }
//    }
//    func roundCorners(radius: CGFloat) {
//        self.cornerRadius = radius
//        if shadowOpacity != 0 {
//            addShadowWithRoundedCorners()
//        }
//    }
//    
//    private func addShadowWithRoundedCorners() {
//        if let contents = self.contents {
//            masksToBounds = false
//            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
//                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
//            self.contents = nil
//            if let sublayer = sublayers?.first,
//                sublayer.name == Constants.contentLayerName {
//                
//                sublayer.removeFromSuperlayer()
//            }
//            let contentLayer = CALayer()
//            contentLayer.name = Constants.contentLayerName
//            contentLayer.contents = contents
//            contentLayer.frame = bounds
//            contentLayer.cornerRadius = cornerRadius
//            contentLayer.masksToBounds = true
//            insertSublayer(contentLayer, at: 0)
//        }
//    }
//
//}
