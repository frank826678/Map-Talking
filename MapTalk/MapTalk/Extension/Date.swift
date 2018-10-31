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
        
        //dateFormatter.dateFormat = "EEE, d MMM yyyy"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: date)
    }
    
    static func formatMessageTime(time: Int) -> String {
        
        let seconds = time / 1000
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd hh:mm a"
        
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: timestampDate)
    }

}
