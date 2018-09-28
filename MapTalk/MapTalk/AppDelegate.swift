//
//  AppDelegate.swift
//  MapTalk
//
//  Created by Frank on 2018/9/19.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // swiftlint:disable force_cast
    static let shared = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:enable force_cast
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKSettings.setAppID("242593443093281")
        
        //let userDefault = UserDefaults.standard
        //let userFBToken = userDefault.string(forKey: "userFbTokenFile")
        
        //print("給我userToken\(userFBToken)")
        
//        if userFBToken != nil {
//            switchHomePage()
//        } else {
//            switchLogin()
//        }
       
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyDUQVZIOfdopcNAHEgv0mJY3VlEYtAaLOc")
        
        // OLD GMSPlacesClient.provideAPIKey("AIzaSyDDFveJ8LPRLCJKfmQqU-rBlbY7MPXYoUw")
        
        //鍵盤第三方
        IQKeyboardManager.shared.enable = true
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        
        //switch page
        if UserDefaults.standard.value(forKey: FirebaseType.uuid.rawValue) != nil {
            
            switchToMainStoryBoard()
            
        } else {
            switchToLoginStoryBoard()
            
        }

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let result = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return result
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let result = FBSDKApplicationDelegate.sharedInstance().application(
            application, open: url, sourceApplication: sourceApplication,
            annotation: annotation)
        return result
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func switchToLoginStoryBoard() {
        
        guard Thread.current.isMainThread else {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.switchToLoginStoryBoard()
            }
            
            return
        }
        
        window?.rootViewController = UIStoryboard.loginStoryboard().instantiateInitialViewController()
    }
    
    func switchToMainStoryBoard() {
        
        guard Thread.current.isMainThread else {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.switchToMainStoryBoard()
            }
            
            return
        }
        
        window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
        
    }
    
}
