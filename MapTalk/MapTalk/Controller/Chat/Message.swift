//
//  Message.swift
//  MapTalk
//
//  Created by Frank on 2018/9/27.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation

struct Message: Codable {
    
    let content: String?
    
    let senderId: String
    
    let senderName: String
    
    let senderPhoto: String?
    
    let time: Int
    
    let imageUrl: String?

}

struct FriendInfo {
    
    var friendName: String
    
    var friendImageUrl: String?

}

struct FreindData {
    
    let info: FriendInfo
    let message: Message
    
}

struct NewMessage: Codable {
    
    var content: String?
    
    let senderId: String
    
    let senderName: String
    
    let senderPhoto: String?
    
    var time: Int
    
    let imageUrl: String?
    
    let friendName: String?
    
    let friendImageUrl: String?
    
    let friendUID: String
    
}

struct FriendNewInfo {
    
    let friendName: String
    
    let friendImageUrl: String
    
    let friendUID: String
    
    let friendChannel: String

}
