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
import FirebaseStorage
import FirebaseDatabase


class LoginViewController: UIViewController {
    
    @IBOutlet weak var logingButtonShape: UIButton!
    
    private let manager = FacebookManager()
    private let firebaseManager = FirebaseManager()
    
    //20181003
    //var dataRef: DatabaseReference!
    var refference: DatabaseReference!
    var userPhotoComplement: ((_ data: URL) -> Void)?
    

    
    let fbUserDefault: UserDefaults = UserDefaults.standard

    
//    @IBAction func loginButtonAction(_ sender: UIButton) {
//
//        bindFB()
//
//    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        changeStyle()
        
         refference = Database.database().reference()
    
    }
    
    @IBAction func loginFacebook(_ sender: UIButton) {
        
        manager.facebookLogIn(
            fromController: self,
            success: { [weak self] token in
                
                //self?.signupUser(token: token)
                
                // 有 weak self 所以 當沒人 keep 住他時，因為 ARC 0，消失後會 nil。
                
                self?.signInFirebase(token: token)
                self?.getUserInfo(token: token)

                //這裡有 signInFirebase 下面 firebase login 可以刪掉
                
            //    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                
              //  Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in
                        print("登入成功 Success")
//                        print(Auth.auth().currentUser?.displayName)
//                        print(Auth.auth().currentUser?.email)
//                        print(Auth.auth().currentUser?.photoURL)
//
                
//                        AppDelegate.shared.window?.rootViewController
//                                                = UIStoryboard
//                                                    .mainStoryboard()
//                                                    .instantiateInitialViewController()
//
            },
            failure: { [weak self ] (error) in
                
                guard let error = error as? FBError else {
                    
                    return
                    
                }
                
                self?.present(
                    UIAlertController.errorMessage(errorType: error),
                    animated: true,
                    completion: nil
                )
                
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
    
    
    private func signInFirebase(token: String) {
        
        firebaseManager.logInFirebase(
            token: token,
            sucess: { (userInfo) in
                
                DispatchQueue.main.async {
                   AppDelegate.shared.switchToMainStoryBoard()
                }
                
        },
            faliure: { [weak self ] (error) in
                
                guard let error = error as? FBError else {
                    
                    return
                    
                }
                
                self?.present(
                    UIAlertController.errorMessage(errorType: error),
                    animated: true,
                    completion: nil
                )
                
        })
        
    }
    
    func getUserInfo(token: String) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
            
            if error == nil {
                if let info = result as? [String: Any] {
                    print("info: \(info)")
                    guard let fbID = info["id"] as? String else { return }
                    guard let fbName = info["name"] as? String else { return }
                    //guard let fbEmail = info["email"] as? String else { return }
//                  guard let fbPhoto = info["picture"] as? [String: Any] else { return }
//                    guard let photoData = fbPhoto["data"] as? [String: Any] else { return }
//                    guard let photoURL = photoData["url"] as? String else { return }
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }

                    //self.uploadImagePic(url: URL(string: photoURL)!)
                    
                    //self.fbUserDefault.set(token, forKey: "token")
                    
                    self.refference.child("UserData").child(userId).setValue([
                        "FBID": fbID,
                        "FBName": fbName,
                        "FBPhotoSmallURL": photoSmallURL,
                        "UID": userId
                        ])
                    
//                    self.refference.child("UserData").child(userId).setValue([
//                        "FBID": fbID,
//                        "FBName": fbName,
//                        "FBEmail": fbEmail,
//                        "FBPhotoURL": photoURL,
//                        "FBPhotoSmallURL": photoSmallURL,
//                        "UID": userId
//                        ])

                    
                    print("----存到 firebase 成功")
                }
            }
        })
    }
    
    func uploadImagePic(
        url: URL
        ) {
        
        let storageRef = Storage.storage().reference()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let data = try? Data(contentsOf: url) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.child("UserPhoto").child(userId).putData(data, metadata: metaData) { (_, error) in
            if let error = error {
                return
            } else {
                print("Storage Success")
            }
        }
    }
    
    // old
//    private func signInFirebase(token: String) {
//
//        firebaseManager.logInFirebase(token: token, sucess: { (userInfo) in
//
//            DispatchQueue.main.async {
//                AppDelegate.shared.switchToMainStoryBoard()
//            }
//
//        }) { (error) in
//
//            // TODO:
//
//        }
//
//    }
    
    
//    func loginErrorAlert(errorMessage: String?) {
//        
//        let alert = UIAlertController(title: "Login Failed", message: errorMessage, preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        
//        self.present(alert, animated: true, completion: nil)
//    }
    
    func changeStyle() {
        
        //美化字體
        logingButtonShape.layer.cornerRadius = 25
//        entryContent.layer.shadowOffset = CGSize(width: 0, height: 2)
//        entryContent.layer.shadowOpacity = 1
//        entryContent.layer.shadowRadius = 5
        
//        facebookLoginBot.layer.cornerRadius = 10
//        facebookLoginBot.layer.borderWidth = 1
//        facebookLoginBot.layer.borderColor = UIColor.lightGray.cgColor
        
        
    }
    
}
