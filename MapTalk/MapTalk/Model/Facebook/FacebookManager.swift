//
//  FacebookManager.swift
//  MapTalk
//
//  Created by Frank on 2018/9/19.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation
import FBSDKLoginKit

enum PermissionKey: String {
    
    case email
    case publicProfile = "public_profile"
    
}

struct FacebookManager {
    
    let facebookManager = FBSDKLoginManager()
    
    func facebookLogIn(
        fromController: UIViewController? = nil,
        success: @escaping (String) -> Void,
        failure: @escaping (ErrorComment) -> Void
        ) {
        
        facebookManager.logIn(
            withReadPermissions: [
                PermissionKey.email.rawValue,
                PermissionKey.publicProfile.rawValue
            ],
            from: fromController) { (result, error) in
                
                guard error == nil else {
                    
                    failure(FBError.system(error!.localizedDescription))
                    return
                    
                }
                
                guard let fbResult = result else {
                    
                    failure(FBError.unrecognized("no such facebook data"))
                    
                    return
                }
                
                guard fbResult.isCancelled == false else {
                    
                    failure(FBError.cancelled)
                    
                    return
                }
                
                guard fbResult.declinedPermissions.count == 0 else {
                    
                    failure(FBError.permissionDeclined)
                    
                    return
                    
                }
                
                success(fbResult.token.tokenString)
                
        }
        
    }
    
}

/*
import Foundation
import FBSDKLoginKit

private enum PermissionKey: String {
    
    case email
    
    case publicProfile = "public_profile"
}

private enum FBErrorMessage: String {
    
    case fbLoseData = "Facebook data lose !"
}

enum FBError: Error {
    
    case system(String)
    
    case unrecognized(String)
    
    case cancelled
    
    case permissionDeclined
}

struct FacebookManager {
    
    let manager = FBSDKLoginManager()
    
    func facebookLogin(
        fromController controller: UIViewController? = nil,
        success: @escaping (String) -> Void,
        failure: @escaping (Error) -> Void) {
        
        manager.logIn(
            withReadPermissions: [
                PermissionKey.email.rawValue,
                PermissionKey.publicProfile.rawValue
            ],
            from: controller,
            handler: { (result, error) in
                
                guard error == nil else {
                    
                    return failure(
                        FBError.system(
                            error!.localizedDescription
                        )
                    )
                }
                
                guard let fbResult = result else {
                    
                    return failure(
                        FBError.unrecognized(
                            FBErrorMessage.fbLoseData.rawValue
                        )
                    )
                }
                
                guard fbResult.isCancelled == false else {
                    
                    return failure(
                        FBError.cancelled
                    )
                }
                
                guard fbResult.declinedPermissions.count == 0 else {
                    
                    return failure(FBError.permissionDeclined)
                }
                
                success(fbResult.token.tokenString)
        }
        )
    }
    
}

 */
