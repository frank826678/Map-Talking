//
//  TabBarViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/25.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

import RAMAnimatedTabBarController

private enum Tab {
    
    //case article
    // swiftlint:disable identifier_name
    case map
    // swiftlint:enable identifier_name
    
    case profile
    
    case chat
    
    //case arView
    
    func controller() -> UIViewController {
        
        switch self {
            
            //        case .article:
            //
            //            return UIStoryboard
            //                .articleStoryboard()
            //                .instantiateInitialViewController()!
        //
        case .map:
            
            return UIStoryboard
                .mapStoryboard()
                .instantiateInitialViewController()!
            
        case .profile:
            
            return UIStoryboard
                .profileStoryboard()
                .instantiateInitialViewController()!
            
        case .chat:
            return UIStoryboard
                .chatStoryboard()
                .instantiateInitialViewController()!
            
            //        case .arView:
            //            return UIStoryboard
            //                .arStoryboard()
            //                .instantiateInitialViewController()!
            
        }
    }
    
    func image() -> UIImage {
        
        switch self {
            
            //case .article: return #imageLiteral(resourceName: "tab_main_normal")
            
        case .chat: return #imageLiteral(resourceName: "icons8-speech-bubble-30")

        case .map: return #imageLiteral(resourceName: "icons8-asia-30")

        case .profile: return #imageLiteral(resourceName: "icons8-user-30")
            
        
            
            //case .arView: return #imageLiteral(resourceName: "arTab")
            
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
            //        case .article: return #imageLiteral(resourceName: "tab_main_normal").withRenderingMode(.alwaysTemplate)
        //
            
        case .chat: return #imageLiteral(resourceName: "icons8-speech-bubble-30").withRenderingMode(.alwaysTemplate)

        case .map: return #imageLiteral(resourceName: "icons8-asia-30").withRenderingMode(.alwaysTemplate)

        case .profile: return #imageLiteral(resourceName: "icons8-user-30").withRenderingMode(.alwaysTemplate)
            
            // case .arView: return #imageLiteral(resourceName: "arTab").withRenderingMode(.alwaysTemplate)
        }
    }
}

class TabBarViewController: RAMAnimatedTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTab()
    }
    
    private func setupTab() {
        
        //tabBar.tintColor = VoyageColor.tabBarTintColor.color()
                var controllers: [UIViewController] = []
        
        //修改 tab bar 高度，沒作用
        var tabFrame: CGRect = self.tabBar.frame
        tabFrame.size.height = 80
        tabFrame.origin.y = self.view.frame.size.height - 80
        self.tabBar.frame = tabFrame
        
        
        //let layerGradient = CAGradientLayer()
        
        
        //let tabs: [Tab] = [.article, .discover, .arView,  .chat, .profile]
        
        let tabs: [Tab] = [.chat, .map, .profile]
        
        // swiftlint:disable identifier_name
        for tab in tabs {
            // swiftlint:enable identifier_name
            let controller = tab.controller()
            
            let item = RAMAnimatedTabBarItem(title: nil, image: tab.image(), selectedImage: tab.selectedImage())
            
            //item.badgeValue = "5"
            item.badgeValue = "3"
            
            let animation = RAMBounceAnimation()
            //animation.iconSelectedColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            animation.iconSelectedColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            item.animation = animation
            
            item.imageInsets = UIEdgeInsets(
                
                top: -20, //8 or 6
                left: 0,
                bottom: 0, //-6
                right: 0
            
            )
            
            controller.tabBarItem = item
            
//            controller.tabBarItem.imageInsets = UIEdgeInsets(
//                top: 100, //8 or 6
//                left: 0,
//                bottom: 10, //-6
//                right: 0
//            )
            
            controllers.append(controller)
            
        }
        
//        layerGradient.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
//        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
//        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
//        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        //self.tabBar.layer.addSublayer(layerGradient)
        
        self.tabBar.setup(width: self.view.bounds.width, height: self.view.bounds.height)
        

        setViewControllers(controllers, animated: false)
    }
    
}
