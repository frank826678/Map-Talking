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
    
    // swiftlint:disable identifier_name
    case map
    // swiftlint:enable identifier_name
    
    case profile
    
    case chat
    
    func controller() -> UIViewController {
        
        switch self {
            
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
            
        }
    }
    
    func image() -> UIImage {
        
        switch self {
            
             case .chat: return #imageLiteral(resourceName: "speech_buble")
            
             case .map: return #imageLiteral(resourceName: "map_marker")
            
             case .profile: return #imageLiteral(resourceName: "user_male")
            
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
        case .chat: return #imageLiteral(resourceName: "speech_buble").withRenderingMode(.alwaysTemplate)

        case .map: return #imageLiteral(resourceName: "map_marker").withRenderingMode(.alwaysTemplate)

        case .profile: return #imageLiteral(resourceName: "user_male").withRenderingMode(.alwaysTemplate)
        }
    }
}

class TabBarViewController: RAMAnimatedTabBarController {
    
    @IBOutlet weak var frankTabBar: UITabBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTab()
    }
    
    private func setupTab() {
        
        var controllers: [UIViewController] = []
        
        let tabs: [Tab] = [.chat, .map, .profile]
        
        // swiftlint:disable identifier_name
        for tab in tabs {
            // swiftlint:enable identifier_name
            let controller = tab.controller()
            
            let item = RAMAnimatedTabBarItem(title: nil, image: tab.image(), selectedImage: tab.selectedImage())
            
            item.badgeValue = "3"
            
            let animation = RAMBounceAnimation()
            
            animation.iconSelectedColor = #colorLiteral(red: 0.1019607843, green: 0.4509803922, blue: 0.9098039216, alpha: 1)
            item.animation = animation
            
            item.imageInsets = UIEdgeInsets(
                
                top: 20, //8 or 6
                left: 0,
                bottom: -8, //-6
                right: 0
            
            )
            //調整照片的 icon 在 tabbar 的高度
            item.yOffSet = -4
            
            controller.tabBarItem = item
                    
            controllers.append(controller)
        }

        setViewControllers(controllers, animated: false)
    }
    
}
