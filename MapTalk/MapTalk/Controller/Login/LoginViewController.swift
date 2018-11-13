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
    
    var refference: DatabaseReference!
    var userPhotoComplement: ((_ data: URL) -> Void)?
    
    let fbUserDefault: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refference = Database.database().reference()
        
        changeStyle()
        
        setupLayerGradient(width: fullScreenSize.width, height: fullScreenSize.height)
        
    }
    
    @IBAction func loginFacebook(_ sender: UIButton) {
        
        manager.facebookLogIn(
            fromController: self,
            success: { [weak self] token in
                
                self?.signInFirebase(token: token)
                
                print("登入成功 Success")
                
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
    
    func changeStyle() {
        
        logingButtonShape.layer.cornerRadius = 25
        
        anonymousLoginButtonShape.layer.cornerRadius = 25
        
        loginIcon.layer.cornerRadius = 90
        
    }
    
    func setupLayerGradient(width: CGFloat, height: CGFloat) {
        
        let layerGradient = CAGradientLayer()
        
        layerGradient.colors = [
            UIColor(red: 188/255.0, green: 229/255.0, blue: 255/255.0, alpha: 1).cgColor,
            UIColor(red: 219/255.0, green: 234/255.0, blue: 255/255.0, alpha: 1).cgColor
        ]
        
        layerGradient.startPoint = CGPoint(x: 0.5, y: 0)
        layerGradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        layerGradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        self.backgroundView.layer.addSublayer(layerGradient)
        
    }
    
    //20181018準備新增按鈕
    @IBAction func anonymousLogin(_ sender: UIButton) {
        
        let keychain = Keychain(service: "com.frank.MapTalk")
        keychain["anonymous"] = "anonymous"
        
        AppDelegate.shared.switchToMainStoryBoard()
        
    }
    
}
