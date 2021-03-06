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
