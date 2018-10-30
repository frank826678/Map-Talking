//
//  Chat.swift
//  MapTalk
//
//  Created by Frank on 2018/10/30.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation

struct NewMessageCodable: Codable {
    
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
