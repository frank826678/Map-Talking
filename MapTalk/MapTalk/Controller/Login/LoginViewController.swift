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
import KeychainAccess

class LoginViewController: UIViewController {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var loginIcon: UIImageView!
    @IBOutlet weak var logingButtonShape: UIButton!
    let fullScreenSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var anonymousLoginButtonShape: UIButton!
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
        
        refference = Database.database().reference()
        
        changeStyle()
           //邊緣都會跑掉 why?
//        setupLayerGradient(width: backgroundView.frame.width, height: backgroundView.frame.height)
        
        setupLayerGradient(width: fullScreenSize.width, height: fullScreenSize.height)

    }
    
    @IBAction func loginFacebook(_ sender: UIButton) {
        
        manager.facebookLogIn(
            fromController: self,
            success: { [weak self] token in
                
                //self?.signupUser(token: token)
                
                // 有 weak self 所以 當沒人 keep 住他時，因為 ARC 0，消失後會 nil。
                
                self?.signInFirebase(token: token)
                
                //20181019
                //self?.getUserInfo(token: token)

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
            sucess: { (_) in
                
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
    
    //20181019
    /*
    func getUserInfo(token: String) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) in
            
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
            //guard let 改成 let
            
            if error == nil {
                if let info = result as? [String: Any] {
                    print("info: \(info)")
                    //old
                    
//                    guard let fbID = info["id"] as? String else { return }
//                    guard let fbName = info["name"] as? String else { return }
//                    guard let userId = Auth.auth().currentUser?.uid else { return }
//                    guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }

                    //OLD END
                    //guard let fbEmail = info["email"] as? String else { return }
//                  guard let fbPhoto = info["picture"] as? [String: Any] else { return }
//                    guard let photoData = fbPhoto["data"] as? [String: Any] else { return }
//                    guard let photoURL = photoData["url"] as? String else { return }

                    //self.uploadImagePic(url: URL(string: photoURL)!)
                    
                    //self.fbUserDefault.set(token, forKey: "token")
                    
                     let fbID = info["id"] as? String
                     let fbName = info["name"] as? String
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }

                    
                    //20181018 改成 updatevalue setValue
                    self.refference.child("UserData").child(userId).updateChildValues([
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

                    
                    print("----存到 firebase 成功 -----")
                }
            }
        })
    }
       */
      //20181019END
 
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
                print(" ***存照片成功 Storage Success *** ")
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
        anonymousLoginButtonShape.layer.cornerRadius = 25
        
        loginIcon.layer.cornerRadius = 90
        
        //let layerGradient = CAGradientLayer()
        
//        entryContent.layer.shadowOffset = CGSize(width: 0, height: 2)
//        entryContent.layer.shadowOpacity = 1
//        entryContent.layer.shadowRadius = 5
        
//        facebookLoginBot.layer.cornerRadius = 10
//        facebookLoginBot.layer.borderWidth = 1
//        facebookLoginBot.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    func setupLayerGradient(width: CGFloat, height: CGFloat) {
        
        let layerGradient = CAGradientLayer()
        
        //layerGradient.colors = [#colorLiteral(red: 0.1764705882, green: 0.7647058824, blue: 0.9960784314, alpha: 1) , #colorLiteral(red: 0.07058823529, green: 0.4431372549, blue: 1, alpha: 1) ]
        
//        layerGradient.colors = [
//            UIColor(red: 70/255.0, green: 95/255.0, blue: 222/255.0, alpha: 0.9).cgColor,
//            UIColor(red: 235/255.0, green: 121/255.0, blue: 243/255.0, alpha: 0.9).cgColor
//        ]
        
        //OK 重藍到清藍 alpha 1 - 0.5
//        layerGradient.colors = [
//            UIColor(red:0.07, green:0.44, blue:1.00, alpha:0.6).cgColor,
//            UIColor(red:0.18, green:0.76, blue:1.00, alpha:0.8).cgColor
//        ]

        layerGradient.colors = [
            UIColor(red: 188/255.0, green: 229/255.0, blue: 255/255.0, alpha: 1).cgColor,
            UIColor(red: 219/255.0, green: 234/255.0, blue: 255/255.0, alpha: 1).cgColor
        ]
        
//        layerGradient.colors = [UIColor(hex: 0x1271ff).CGColor,UIColor(hex: 0x2dc3fe).CGColor]
        //#2dc3fe 淡藍
        //#1271ff 重藍 UIColor(red:0.07, green:0.44, blue:1.00, alpha:1.0)
        
        //layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        //layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.startPoint = CGPoint(x: 0.5, y: 0)
        layerGradient.endPoint = CGPoint(x: 0.5, y: 1)

        layerGradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        self.backgroundView.layer.addSublayer(layerGradient)
    
        //self.layer.addSublayer(layerGradient)
    }
    
    //20181018準備新增按鈕
    @IBAction func anonymousLogin(_ sender: UIButton) {
        
        let keychain = Keychain(service: "com.frank.MapTalk")
        keychain["anonymous"] = "anonymous"
        
        //AppDelegate.shared.switchMainPage()
        AppDelegate.shared.switchToMainStoryBoard()

    }
    
}
