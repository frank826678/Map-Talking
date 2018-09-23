//
//  LoginViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/19.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LdddoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    private let manager = FacebookManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoginButton()
    }
    
    private func setupLoginButton() {
        
        loginButton.layer.cornerRadius = 25.0
        
        loginButton.setTitleColor(UIColor.gray, for: .highlighted)
    }
    
    @IBAction func loginFacebook() {
        
        manager.facebookLogin(
            fromController: self,
            success: { [weak self] token in
                
                //self?.signupUser(token: token)
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in
                    if error == nil {
                        print("Success")
                    } else {
                        print(error)
                    }
                })
                
            },
            failure: { _ in
                // TODO
        }
        )
    }
    
//    private func signupUser(token: String) {
//
//        UserManager.shared.loginUser(
//            facebookToken: token,
//            success: { _ in
//
//                DispatchQueue.main.async {
//
//                    AppDelegate.shared.window?.rootViewController
//                        = UIStoryboard
//                            .mainStoryboard()
//                            .instantiateInitialViewController()
//                }
//        },
//            failure: { _ in
//                // TODO
//        }
//        )
//    }
    
}
