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
            
        case .map: return #imageLiteral(resourceName: "map")
            
        case .profile: return #imageLiteral(resourceName: "tab_profile_normal")
            
        case .chat: return #imageLiteral(resourceName: "tab_chat_normal")
            
        //case .arView: return #imageLiteral(resourceName: "arTab")
            
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
//        case .article: return #imageLiteral(resourceName: "tab_main_normal").withRenderingMode(.alwaysTemplate)
//
        case .map: return #imageLiteral(resourceName: "map").withRenderingMode(.alwaysTemplate)

        case .profile: return #imageLiteral(resourceName: "tab_profile_normal").withRenderingMode(.alwaysTemplate)
            
        case .chat: return #imageLiteral(resourceName: "tab_chat_normal").withRenderingMode(.alwaysTemplate)
            
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
        
        //let tabs: [Tab] = [.article, .discover, .arView,  .chat, .profile]
        
        let tabs: [Tab] = [.map,  .chat, .profile]
        
        // swiftlint:disable identifier_name
        for tab in tabs {
        // swiftlint:enable identifier_name
            let controller = tab.controller()
            
            let item = RAMAnimatedTabBarItem(title: nil, image: tab.image(), selectedImage: tab.selectedImage())
            
            //item.badgeValue = "5"
            item.badgeValue = "3"
            
            let animation = RAMBounceAnimation()
            animation.iconSelectedColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            item.animation = animation
            
            item.imageInsets = UIEdgeInsets(
                top: 8,
                left: 0,
                bottom: -6,
                right: 0
            )
            
            controller.tabBarItem = item
            controllers.append(controller)
            
        }
        
        setViewControllers(controllers, animated: false)
    }
    
}
