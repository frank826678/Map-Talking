//
//  UIStoryboard.swift
//  MapTalk
//
//  Created by Frank on 2018/9/20.
//  Copyright © 2018 Frank. All rights reserved.
//

//import Foundation
import UIKit

extension UIStoryboard {
    
//    static func articleStoryboard() -> UIStoryboard {
//
//        return UIStoryboard(name: "Article", bundle: nil)
//    }
    
    static func loginStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    static func mapStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Map", bundle: nil)
    }
    
    static func mainStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static func profileStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    
    static func chatStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Message", bundle: nil)
    }
    
//    static func arStoryboard() -> UIStoryboard {
//        return UIStoryboard(name: "Ar", bundle: nil)
//    }
    
}
