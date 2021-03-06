//
//  BaseNotificationBanner.swift
//  MapTalk
//
//  Created by Frank on 2018/10/16.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation
import NotificationBannerSwift

extension BaseNotificationBanner {
    
    static func warningBanner(
        title: String = "警告",
        subtitle: String,
        style: BannerStyle = .warning
        ) {
        
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
        
        banner.duration = 1.2
        banner.show()
        banner.remove()
    }
    
    static func successBanner(
        title: String = "成功",
        subtitle: String,
        style: BannerStyle = .success
        ) {
        
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
        
        banner.duration = 2
        
        banner.show()
        banner.remove()
        
    }
}
