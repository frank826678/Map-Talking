//
//  Date.swift
//  MapTalk
//
//  Created by Frank on 2018/10/31.
//  Copyright © 2018 Frank. All rights reserved.
//

import Foundation

extension Date {
    
    static func formatDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date)
    }
    
    static func formatMessageTime(time: Int) -> String {
        
        let seconds = time / 1000
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd hh:mm a"
        
        return dateFormatter.string(from: timestampDate)
    }
    
    var millisecondsSince1970: Int {
        
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
}
