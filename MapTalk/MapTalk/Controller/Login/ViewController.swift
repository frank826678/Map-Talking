//
//  ViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/19.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class EntryViewController: UIViewController {
    
    @IBOutlet weak var logingButtonShape: UIButton!
    
    private let manager = FacebookManager()
    
//    @IBAction func loginButtonAction(_ sender: UIButton) {
//
//        bindFB()
//
//    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        changeStyle()
    
    }
    
    @IBAction func loginFacebook(_ sender: UIButton) {
        
        manager.facebookLogin(
            fromController: self,
            success: { [weak self] token in
                
                //self?.signupUser(token: token)
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                
                Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in
                    if error == nil {
                        print("登入成功 Success")
                        print(Auth.auth().currentUser?.displayName)
                        print(Auth.auth().currentUser?.email)
                        print(Auth.auth().currentUser?.photoURL)
                        
                        
                    } else {
                        print(error)
                    }
                })
                
            },
            failure: { _ in
                // TODO
        }
        )
        
        /*
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(
            withReadPermissions: ["public_profile", "email"],
            from: self,
            handler: { result, error in
                
                if let error = error {
                    self.loginErrorAlert(errorMessage: error.localizedDescription)
                    return
                }
                
                guard let result = result else {
                    self.loginErrorAlert(errorMessage: nil)
                    return
                }
                
                guard result.isCancelled == false else {
                    return
                }
                
                if result.token.declinedPermissions.contains("email") {
                    let errorMessage = "Please allow your email permission to sign up the Voyage account."
                    self.loginErrorAlert(errorMessage: errorMessage)
                    return
                }
                
                guard let tokenString = result.token.tokenString else {
                    self.loginErrorAlert(errorMessage: nil)
                    return
                }
                
                print(tokenString)
                
                //self.createVoyageAccount(token: tokenString)
        })
        
        */
    }
    
    
    func loginErrorAlert(errorMessage: String?) {
        
        let alert = UIAlertController(title: "Login Failed", message: errorMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeStyle() {
        
        //美化字體
        logingButtonShape.layer.cornerRadius = 25
//        entryContent.layer.shadowOffset = CGSize(width: 0, height: 2)
//        entryContent.layer.shadowOpacity = 1
//        entryContent.layer.shadowRadius = 5
        
    }
    
}
