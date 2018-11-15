//
//  FirebaseManager.swift
//  MapTalk
//
//  Created by Frank on 2018/9/21.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FBSDKLoginKit
import FirebaseStorage
import FirebaseDatabase
import KeychainAccess

struct UserInfo {
    
    var userName: String
    var userPicUrl: String
    
}

enum FirebaseType: String {
    
    case uuid
    
}

struct FirebaseManager {
    
    let refference = Database.database().reference()
    
    func logInFirebase(
        token: String,
        sucess: @escaping (UserInfo) -> Void,
        faliure: @escaping (Error) -> Void
        ) {
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        Auth.auth().signInAndRetrieveData(
        with: credential) { (authResult, error) in
            
            guard error == nil else {
                
                print("***登入錯誤！！！***")
                faliure(FirebaseError.system(error!.localizedDescription))
                
                return
                
            }
            
            guard let firebaseResult = authResult else {
                
                faliure(FirebaseError.unrecognized("No Firebase Data"))
                
                return
                
            }
            
            self.getUserInfo(token: token)
            
            let user = firebaseResult.user
            let userInfo = UserInfo(userName: user.displayName!, userPicUrl: user.photoURL!.absoluteString)
            
            let keychain = Keychain(service: "com.frank.MapTalk")
            keychain[FirebaseType.uuid.rawValue] = user.uid

            sucess(userInfo)
            
        }
    }
    
    func getUserInfo(token: String) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (_, result, error) in
                        
            if error == nil {
                if let info = result as? [String: Any] {
                    
                    print("info: \(info)")
                    
                    let fbID = info["id"] as? String
                    let fbName = info["name"] as? String
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }
                    
                    self.refference.child("UserData").child(userId).updateChildValues([
                        "FBID": fbID,
                        "FBName": fbName,
                        "FBPhotoSmallURL": photoSmallURL,
                        "UID": userId
                        ])
                    
                    print("----存到 firebase 成功 -----")
                }
            }
        })
    }
}
