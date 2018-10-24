//
//  Message.swift
//  MapTalk
//
//  Created by Frank on 2018/9/27.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation

struct Message {
    
    let content: String?
    
    let senderId: String
    
    let senderName: String
    
    let senderPhoto: String?
    
    let time: Int
    
    let imageUrl: String?

}

struct FriendInfo {
    
    let friendName: String
    
    let friendImageUrl: String?

}

struct FreindData {
    
    let info: FriendInfo
    let message: Message
    
}

struct NewMessage {
    
    var content: String?
    
    let senderId: String
    
    let senderName: String
    
    let senderPhoto: String?
    
    let time: Int
    
    let imageUrl: String?
    
    let friendName: String?
    
    let friendImageUrl: String?
    
    let friendUID: String
    
}

//201801014
struct FriendNewInfo {
    
    let friendName: String
    
    let friendImageUrl: String
    
    let friendUID: String
    
    let friendChannel: String

}
