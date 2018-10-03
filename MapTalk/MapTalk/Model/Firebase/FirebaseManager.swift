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
//import UIKit
import FBSDKLoginKit
//import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

var refference: DatabaseReference!


struct UserInfo {
    
    var userName: String
    var userPicUrl: URL
    
}

enum FirebaseType: String {
    
    case uuid
    
}

struct FirebaseManager {
    
    func logInFirebase(
        token: String,
        sucess: @escaping (UserInfo) -> Void,
        faliure: @escaping (Error) -> Void
        ) {
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        Auth.auth().signInAndRetrieveData(
        with: credential) { (authResult, error) in
            
            guard error == nil else {
                
                faliure(FirebaseError.system(error!.localizedDescription))
                
                return
                
            }
            
            guard let firebaseResult = authResult else {
                
                faliure(FirebaseError.unrecognized("No Firebase Data"))
                
                return
                
            }
            
            //20181003
            //getUserInfo(token: token)
            
            let user = firebaseResult.user
            let userInfo = UserInfo(userName: user.displayName!, userPicUrl: user.photoURL!)
            
            UserDefaults.standard.set(user.uid, forKey: FirebaseType.uuid.rawValue)
            
            sucess(userInfo)
            
        }
    }
    
}

func getUserInfo(token: String) {
    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (connection, result, error) in
        
        if error == nil {
            if let info = result as? [String: Any] {
                print("info: \(info)")
                guard let fbID = info["id"] as? String else { return }
                guard let fbName = info["name"] as? String else { return }
                guard let fbEmail = info["email"] as? String else { return }
                guard let fbPhoto = info["picture"] as? [String: Any] else { return }
                guard let photoData = fbPhoto["data"] as? [String: Any] else { return }
                guard let photoURL = photoData["url"] as? String else { return }
                guard let userId = Auth.auth().currentUser?.uid else { return }
                guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }
                
                //self.uploadImagePic(url: URL(string: photoURL)!)
                
                //self.fbUserDefault.set(token, forKey: "token")
                
                //                    self.refference.child("UserData").child(userId).setValue([
                //                        "FBID": fbID,
                //                        "FBName": fbName,
                //                        "FBEmail": fbEmail,
                //                        "FBPhotoURL": photoURL,
                //                        "FBPhotoSmallURL": photoSmallURL])
                
                refference.child("UserData").child("userId").setValue([
                    "FBID": "fbID",
                    "FBName": "fbName",
                    "FBEmail": "fbEmail",
                    "FBPhotoURL": "photoURL",
                    "FBPhotoSmallURL": "photoSmallURL"])
                
                print("----存到 firebase 成功")
            }
        }
    })
}


//import Foundation
//import FirebaseCore
//import FirebaseAuth
//
//struct UserInfo {
//
//    var userName: String
//    var userPicUrl: URL
//
//}
//
//enum FirebaseError: Error {
//
//    case system(String)
//    case unrecognized(String)
//
//}
//
//enum FirebaseType: String {
//
//    case uuid
//
//}
//
//struct FirebaseManager {
//
//    func logInFirebase(
//        token: String,
//        sucess: @escaping (UserInfo) -> Void,
//        faliure: @escaping (Error) -> Void
//        ) {
//
//        let credential = FacebookAuthProvider.credential(withAccessToken: token)
//
//        Auth.auth().signInAndRetrieveData(
//        with: credential) { (authResult, error) in
//
//            guard error == nil else {
//
//                faliure(FirebaseError.system(error!.localizedDescription))
//
//                return
//
//            }
//
//            guard let firebaseResult = authResult else {
//
//                faliure(FirebaseError.unrecognized("No Firebase Data"))
//
//                return
//
//            }
//
//            let user = firebaseResult.user
//            let userInfo = UserInfo(userName: user.displayName!, userPicUrl: user.photoURL!)
//
//            UserDefaults.standard.set(user.uid, forKey: FirebaseType.uuid.rawValue)
//
//            sucess(userInfo)
//
//        }
//    }
//
//}
