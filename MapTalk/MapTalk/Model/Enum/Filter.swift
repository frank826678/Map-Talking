//
//  Filter.swift
//  MapTalk
//
//  Created by Frank on 2018/10/6.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation

struct Filter {
    
    let gender: Int
    
    // swiftlint:disable identifier_name
    let age: Int
    // swiftlint:enable identifier_name
    
    let location: Int
    
    let dating: Int
    
    let time: Int
    
}

struct FilterData {
    
    let gender: Int
    
    let myselfGender: Int
    
    // swiftlint:disable identifier_name
    let age: Int
    // swiftlint:enable identifier_name
    
    let location: Location //待修
    
    let dating: Int
    
    let datingTime: Int
    
    let time: Int
    
    let senderId: String
    
    let senderName: String
    
    let senderPhotoURL: String
    
}

struct Location {

    let latitude: Double
    
    let longitude: Double
    
}
