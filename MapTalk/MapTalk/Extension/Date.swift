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
    
    static func daysBetweenDates(startDate: Date) -> String {
        
        let nowDay = Date()
        //let birthday: Date = ...
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.day], from: startDate, to: nowDay)
        guard let ageFromBirth = ageComponents.day else {
            return
            "用戶沒有設定生日"
        }
        print("來到地球的日子\(ageFromBirth)")
        return String(ageFromBirth)
        
        //        //從第一天到現在的日子
        //        let calendar = NSCalendar.current
        //        let date = Date()
        //        let formatter = DateFormatter()
        //        // Replace the hour (time) of both dates with 00:00
        //        let date1 = calendar.startOfDay(for: startDate)
        //        let date2 = calendar.startOfDay(for: date)
        //
        //        let components = calendar.dateComponents([.day], from: date1, to: date2)
        //
        //        print(components)
        //        let result = formatter.string(from: components)
        //
        //        return result
        
        //        let calendar = NSCalendar.current
        //
        //    let comd = calendar.component(calendar, from: <#T##Date#>)
        ////        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        //
        //        return components.day
    }
    
    var millisecondsSince1970: Int {
        
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
}

//extension Date {
//
//}
