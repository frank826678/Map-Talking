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
            
             case .chat: return #imageLiteral(resourceName: "speech_buble")
            
             case .map: return #imageLiteral(resourceName: "map_marker")
            
             case .profile: return #imageLiteral(resourceName: "user_male")

            
            //1 speech_buble
            //2 map_marker
            //3 user_male
            
            //case .article: return #imageLiteral(resourceName: "tab_main_normal")
        // OLD OK
       // case .chat: return #imageLiteral(resourceName: "new2-chat-bubble-30")

       // case .map: return #imageLiteral(resourceName: "new2-europe-30")

       // case .profile: return #imageLiteral(resourceName: "new2-male-user-30")
       // OLD END
            //case .arView: return #imageLiteral(resourceName: "arTab")
            
        }
    }
    
    func selectedImage() -> UIImage {
        
        switch self {
            
            //        case .article: return #imageLiteral(resourceName: "tab_main_normal").withRenderingMode(.alwaysTemplate)
        //
        // case .arView: return #imageLiteral(resourceName: "arTab").withRenderingMode(.alwaysTemplate)
            
            //OLD OK
//        case .chat: return #imageLiteral(resourceName: "new2-chat-bubble-30").withRenderingMode(.alwaysTemplate)
//
//        case .map: return #imageLiteral(resourceName: "new2-europe-30").withRenderingMode(.alwaysTemplate)
//
//        case .profile: return #imageLiteral(resourceName: "new2-male-user-30").withRenderingMode(.alwaysTemplate)
            //OLD END
            
        case .chat: return #imageLiteral(resourceName: "speech_buble").withRenderingMode(.alwaysTemplate)

        case .map: return #imageLiteral(resourceName: "map_marker").withRenderingMode(.alwaysTemplate)

        case .profile: return #imageLiteral(resourceName: "user_male").withRenderingMode(.alwaysTemplate)
            
            
        }
    }
}

class TabBarViewController: RAMAnimatedTabBarController {
    
    @IBOutlet weak var frankTabBar: UITabBar!
    
   // let tabs: [Tab] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTab()
        
        //20181022
       // self.tabBarController?.tabBar.isTranslucent = false
//        // swiftlint:disable force_cast
//        let ramTBC = self.window!.rootViewController as! TabBarViewController
//        
//        // swiftlint:enable force_cast
//        
//        
//        ramTBC.selectedIndex = 1
//        
//        ramTBC.setSelectIndex(from: 0, to: 1)
        
        //20181016
        //change tabbar page 有作用 但是顏色沒變過去
        //寫在這沒用 寫去 chatVC 的 viewDidLoad()
        //tabBarController?.selectedIndex = 2
        
        
        //frankTabBar.selectedItem = 1
        //RAMAnimatedTabBarItem.selectedState(1)
       
        //let controller = tab.controller()
        
        
        
        //RAMAnimatedTabBarItem.selectedState(1)
        //20181005
        
//        let controller = tab.controller()
//
//        let item = RAMAnimatedTabBarItem(title: nil, image: tab.image(), selectedImage: ta)

        // self.selectedViewController = tabs
//        UIImage *anImage = [UIImage imageNamed:@"foo"];
//        self.tabBarItem.image = anImage;
    }
    
    private func setupTab() {
        
        //tabBar.tintColor = VoyageColor.tabBarTintColor.color()
                var controllers: [UIViewController] = []
        
        //修改 tab bar 高度，沒作用
       
//        var tabFrame: CGRect = self.frankTabBar.frame
//        tabFrame.size.height = 80
//        tabFrame.origin.y = self.view.frame.size.height - 80
//        self.frankTabBar.frame = tabFrame
        
//        var tabFrame: CGRect = self.tabBar.frame
//        tabFrame.size.height = 80
//        tabFrame.origin.y = self.view.frame.size.height - 80
//        self.tabBar.frame = tabFrame
        
        //let layerGradient = CAGradientLayer()
        
        //let tabs: [Tab] = [.article, .discover, .arView,  .chat, .profile]
        
        let tabs: [Tab] = [.chat, .map, .profile]
        
        // swiftlint:disable identifier_name
        for tab in tabs {
            // swiftlint:enable identifier_name
            let controller = tab.controller()
            
            let item = RAMAnimatedTabBarItem(title: nil, image: tab.image(), selectedImage: tab.selectedImage())
            
//            let itemSize = item.image?.size ?? CGSize(width: 30, height: 30)
            
            //item.selectedImage?.size.
            
//            item.t
            
            //item.badgeValue = "5"
            item.badgeValue = "3"
            
            let animation = RAMBounceAnimation()
            //animation.iconSelectedColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            
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
            
//            controller.tabBarItem.imageInsets = UIEdgeInsets(
//                top: 100, //8 or 6
//                left: 0,
//                bottom: 10, //-6
//                right: 0
//            )
            
            controllers.append(controller)
            
//            self.selectedIndex = 1
            
        }
        
//        layerGradient.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
//        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
//        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
//        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        //self.tabBar.layer.addSublayer(layerGradient)
        
        //tabbar 漸層
        
        //self.tabBar.setup(width: self.view.bounds.width, height: self.view.bounds.height)
        

        setViewControllers(controllers, animated: false)
    }
    
}
