//
//  Date+Extension.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/17.
//

import Foundation

/// 日期扩展
extension Date {
    
    /// 日期转字符串
    /// - parameter date: 日期
    /// - parameter dateFormat: 格式字符串
    static func toString(date: Date = Date(), dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let timeZone = NSTimeZone(abbreviation: "EST")! as TimeZone
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: date)
    }
    
    /// 字符串转日期
    /// - parameter dateString: 日期字符串
    /// - parameter dateFormat: 格式字符串
    static func toDate(dateString: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let timeZone = NSTimeZone(abbreviation: "EST")! as TimeZone
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        
        return formatter.date(from: dateString)!
    }
    
    /// 判断两个日期是否是同一天
    /// - parameter dateA: 日期一
    /// - parameter dateB: 日期二
    static func isInSameDay(_ dateA: Date, _ dateB: Date) -> Bool {
        let calendar = NSCalendar.current
        let comA = calendar.dateComponents([.year, .month, .day], from: dateA)
        let comB = calendar.dateComponents([.year, .month, .day], from: dateB)
        return comA.year == comB.year && comA.month == comB.month && comA.day == comB.day
    }
    
    //MARK: - 时间标识
    static func timeid() -> Double {
        return NSDate().timeIntervalSince1970*1000
    }
}
